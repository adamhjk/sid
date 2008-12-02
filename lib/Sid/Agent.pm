#!/usr/bin/perl
#
# Sid::Agent
#
# $Id$
#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2008 Adam Jacob
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package Sid::Agent;

use strict;
use warnings;

use Sub::Name;
use Moose;
use Sid::Exception;
use Sid::Client;
use Params::Validate qw(:all);
use YAML::Syck;
use File::Find;
use Data::UUID;
use Data::Dump qw(dump);
use IPC::Open3;
use Exception::Class::TryCatch;
use Hash::Merge qw(merge);

has 'run_dir' => ( is => 'rw', isa => 'Str',      required => 1 );
has 'tmp_dir' => ( is => 'rw', isa => 'Str',      required => 1 );
has 'plugins' => ( is => 'rw', isa => 'ArrayRef', required => 1 );
has 'plugin_objects' =>
  ( is => 'rw', isa => 'ArrayRef', default => sub { [] } );
has 'client' => ( is => 'ro', isa => 'Object' );
has 'current_data' => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub {
        {
            agent   => {},
            plugins => [],
        };
    }
);
has 'agent_id'      => ( is => 'ro', isa => 'Str' );
has 'agent_id_file' => ( is => 'ro', isa => 'Str' );
has 'description'   =>
  ( is => 'rw', isa => 'Str', default => 'Perl Sid Agent' );
has 'agent'  => ( is => 'ro', isa => 'Object' );
has 'server' => ( is => 'rw', isa => 'Str', default => 'http://sid' );

with 'Sid::Role::Log4perl';

sub BUILD {
    my ( $self, $params ) = @_;

    my $client;
    if ( exists( $params->{'server'} ) ) {
        $client = Sid::Client->new( server => $params->{'server'} );
    } else {
        $client = Sid::Client->new;
    }
    $self->{'client'} = $client;

    if ( !exists( $params->{'agent_id'} ) ) {

        # Set up the Agent ID
        my $agent_id_file = $params->{'run_dir'} . "/sid-agent.uuid";
        $self->{'agent_id_file'} = $agent_id_file;
        if ( -f $agent_id_file ) {
            $self->log->debug("Loading agent_id from $agent_id_file");
            open( AGENT, "<", $agent_id_file )
              or
              Sid::Exception::File->throw("Cannot open $agent_id_file: $!\n");
            my $agent_id = <AGENT>;
            chomp($agent_id);
            $self->log->debug("agent_id is $agent_id");
            $self->{'agent_id'} = $agent_id;
            close(AGENT);
        } else {
            my $ug = Data::UUID->new;
            $self->{'agent_id'} = lc( $ug->create_str );
            $self->log->debug(
                "Generated new agent_id " . $self->{'agent_id'} );
            open( AGENT, ">", $agent_id_file )
              or Sid::Exception::File->throw(
                "Cannot open " . $agent_id_file . " for writing: $!\n" );
            print AGENT $self->{'agent_id'};
            close(AGENT);
            $self->log->debug("Wrote agent_id to $agent_id_file");
        }
    }
}

sub register {
    my $self = shift;

    $self->log->debug( "Registering agent " . $self->agent_id );
    my $agent_data = $self->client->register_agent(
        agent_id    => $self->agent_id,
        description => $self->description,
    );
    $self->current_data->{'agent'} = $agent_data;
    return $agent_data;
}

sub remove {
    my $self = shift;

    $self->log->debug( "Removing agent " . $self->agent_id );
    my $agent_data =
      $self->client->remove_agent( agent_id => $self->agent_id, );
    unlink( $self->agent_id_file )
      or Sid::Exception::File("Could not delete $self->agent_id_file: $!");

    return $agent_data;
}

sub update_service {
    my $self = shift;
    my %p    = validate( @_, { pstruct => { type => HASHREF, }, }, );

    $self->log->debug(
        "Updating Sid Service for plugin $p{'pstruct'}->{'plugin_id'}");

    my $seenids = {};

    # First pass, catalog all our entities
    for ( my $x = 0; $x < scalar( @{ $p{'pstruct'}->{'entities'} } ); $x++ ) {
        my $entity = $p{'pstruct'}->{'entities'}->[$x];
        $seenids->{ $entity->{'type'} }->{ $entity->{'primary_id'} } = $x;
        if ( exists( $entity->{'parent'}->{'primary_id'} ) ) {
            my $parent_data = $entity->{'parent'};

            unless (
                exists(
                    $seenids->{ $parent_data->{'type'} }
                      ->{ $parent_data->{'primary_id'} }
                )
              ) {
                die "Cannot find parent entity " . dump($parent_data);
            }

            my $parent_slot =
              $seenids->{ $parent_data->{'type'} }
              ->{ $parent_data->{'primary_id'} };
            my $parent     = $p{'pstruct'}->{'entities'}->[$parent_slot];
            my $new_fields =
              merge( $entity->{'fields'}, $parent->{'fields'} );
            push(
                @{ $new_fields->{'from'} },
                {
                    search_type => $entity->{'type'},
                    tags        => [],
                    value       => $parent->{'type'}
                }
            );
            $entity->{'fields'} = $new_fields;
        }
    }
    my $plugin = $self->client->register_plugin(
        agent_id  => $self->agent_id,
        plugin_id => $p{'pstruct'}->{'plugin_id'},
        entities  => $p{'pstruct'}->{'entities'}
    );

    return 1;
}

sub run {
    my $self = shift;
    my %p    =
      validate( @_, { 'update' => { type => SCALAR, default => '1' }, } );

    my @plugins;
    foreach my $plugin_dir ( @{ $self->plugins } ) {
        $plugin_dir =~ /.+\/(.+?)$/;
        my $plugin  = $1;
        my $pstruct = {
            plugin_id => $plugin,
            entities  => [],
        };
        my @files = $self->_find_plugin_files( directory => $plugin_dir );
        $self->log->debug( "Loaded Plugin $plugin Files: " . dump(@files) );
        foreach my $file (@files) {
            $self->log->debug("Running Plugin $plugin Script $file");
            my $return_pstruct =
              $self->_execute_script( script => $file, pstruct => $pstruct );
            if ( ref($return_pstruct) eq "HASH" ) {
                $pstruct = $return_pstruct;
            } else {
                die "Plugin $plugin Script $file failed!";
            }
        }
        push( @{ $self->current_data->{'plugins'} }, $pstruct );
        $self->update_service( pstruct => $pstruct )
          if scalar( @{ $pstruct->{'entities'} } ) && $p{'update'};
    }
    return 1;
}

sub _execute_script {
    my $self = shift;
    my %p    = validate(
        @_,
        {
            script  => { type => SCALAR },
            pstruct => { type => HASHREF },
        }
    );

    # Open script with STDIN, STDOUT, STDERR attached
    my $pid;
    eval {
        $pid =
          open3( \*WRITEFH, \*READFH, \*ERRFH, $p{'script'}, $self->agent_id,
            $p{'pstruct'}->{'plugin_id'},
            $self->server, $self->tmp_dir, );
    };
    if ( catch my $e ) {
        $self->log->error(
            "Error with open3 for $p{'script'}: " . $e->message );
        return 0;
    }
    my $writefh = *WRITEFH;
    my $readfh  = *READFH;
    my $errfh   = *ERRFH;

    # Print the current entities to STDIN, read STDOUT and STDERR
    print $writefh Dump( $p{'pstruct'}->{'entities'} );
    close($writefh);
    my $output = "";
  RSTDOUT: while (1) {
        my $newdata;
        my $bytes = sysread( $readfh, $newdata, 1024 ) or last RSTDOUT;
        $output .= $newdata;
    }
    close($readfh);

    my $errout = "";
  RSTDERR: while (1) {
        my $newdata;
        my $bytes = sysread( $errfh, $newdata, 1024 ) or last RSTDERR;
        $errout .= $newdata;
    }
    close($errfh);

    $self->log->debug(
        "Finished with $p{'script'}, waiting for it's exit status.");
    waitpid( $pid, 0 );

    # Check the return code
    if ( $? == -1 ) {
        $self->log->error("Failed to execute $p{'script'}: $!\n");
        return 0;
    } elsif ( $? & 127 ) {
        my $error = sprintf "$p{'script'} died with signal %d, %s coredump\n",
          ( $? & 127 ), ( $? & 128 ) ? 'with' : 'without';
        $self->log->error($error);
        return 0;
    } elsif ( $? >> 8 ) {
        $self->log->error( sprintf "$p{'script'} exited with value %d\n",
            $? >> 8 );
        if ( defined($errout) ) {
            $self->log->error( "$p{'script'} STDERR:\n" . $errout );
        }
        return 0;
    } else {
        if ( defined($output) ) {
            $self->log->debug("$p{'script'} ran successfully!");
            $self->log->debug("$p{'script'} returned:");
            $self->log->debug($output);
        } else {
            $self->log->error(
                "$p{'script'} ran successfully, but produced no output!");
            if ( defined($errout) ) {
                $self->log->error( "$p{'script'} STDERR:\n" . $errout );
            }
            return 0;
        }
    }

    my $new_data;
    eval { $new_data = Load($output) };
    if ( catch my $e ) {
        $self->log->debug(
            "Error loading the response from $p{'script'}: " . $e->message );
    }
    $p{'pstruct'}->{'entities'} = $new_data;
    return $p{'pstruct'};
}

sub dump_data {
    my $self = shift;

    return Dump( $self->current_data );
}

sub _find_plugin_files {
    my $self = shift;
    my %p    = validate( @_, { directory => { type => SCALAR }, } );

    my @plugin_files;
    find(
        sub {
            my $filename = $_;
            if ( -f $filename && -x $filename ) {
                push( @plugin_files, $File::Find::name );
            }
        },
        $p{'directory'}
    );
    return sort(@plugin_files);
}

1;
