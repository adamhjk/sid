#!/usr/bin/perl
#
# Sid::Client
#
# $Id$
#
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

package Sid::Client;

use strict;
use warnings;

use Moose;
use LWP::UserAgent;
use LWP::ConnCache;
use Sid::Exception;
use Params::Validate qw(:all);
use YAML::Syck;
use Data::Dump qw(dump);
use Digest::MD5 qw(md5_base64);
use URI::Escape qw(uri_escape);

has 'ua' => (
    is      => 'ro',
    isa     => 'Object',
    default =>
      sub { my $ua = LWP::UserAgent->new(agent => 'sid-client/0.1', timeout => 10800); },
  );

has 'content_type' => ( is => 'rw', isa => 'Str', default => 'text/x-yaml', );
has 'server' => ( is => 'rw', isa => 'Str', default => 'http://sid' );

with 'Sid::Role::Log4perl';

sub search {
    my $self = shift;
    my %p    = validate(
        @_,
        {
            query  => { type => SCALAR, default => 'type:*' },
            fields => { type => ARRAYREF, optional => 1 },
            num_per => { type => SCALAR, optional => 1 },
            page => { type => SCALAR, optional => 1 },
        },
    );

    my $params = [ s => $p{'query'} ];
    my $fields = $p{'fields'} || [];
    if (scalar(@{$fields})) {
        foreach my $field (@{$fields}) {
            push(@{$params}, f => $field);
        }
    }
    push(@{$params}, "n", $p{'num_per'}) if exists ($p{'num_per'});
    push(@{$params}, "p", $p{'page'}) if exists ($p{'page'});
    my ($response, $url) = $self->get(
        url    => "q",
        params => $params,
    );
    my $paged = shift(@{$response});
    if (wantarray) {
        return ($response, $url, $paged);
    } elsif (defined wantarray) {
        return $response;
    } else {
        return;
    }
}

sub register_agent {
    my $self = shift;
    my %p = validate(
        @_,
        {
            agent_id => { type => SCALAR },
            description => { type => SCALAR },
        },
    );

    my ($agent, $url) = $self->post(
        url => "agent/" . _uri_escape($p{'agent_id'}),
        data => {
            agent_id => $p{'agent_id'},
            description => $p{'description'},
        },
    );

    if (wantarray) {
        return $agent, $url;
    } elsif (defined wantarray) {
        return $agent;
    } else {
        return;
    }
}

sub register_plugin {
    my $self = shift;
    my %p = validate(
        @_,
        {
            agent_id => { type => SCALAR },
            plugin_id => { type => SCALAR },
            entities => { type => ARRAYREF },
        },
    );
    my $data = {
            agent_id => $p{'agent_id'},
            plugin_id => $p{'plugin_id'},
            entities => [],
    };

    if (scalar(@{$p{'entities'}})) {
        foreach my $e (@{$p{'entities'}}) {
            push(@{$data->{'entities'}}, md5_base64($p{'agent_id'} . $p{'plugin_id'} . $e->{'type'} . $e->{'primary_id'}));
        }
    }

    my ($plugin, $url) = $self->post(
        url => "agent/" . _uri_escape($p{'agent_id'}) . "/" . _uri_escape($p{'plugin_id'}),
        data => $data,
    );

    if (scalar(@{$p{'entities'}})) {
        $self->register_entity(
            agent_id => $p{'agent_id'},
            plugin_id => $p{'plugin_id'},
            entity => $_,
        ) foreach (@{$p{'entities'}});
    }
    if (wantarray) {
        return $plugin, $url;
    } elsif (defined wantarray) {
        return $plugin;
    } else {
        return;
    }
}

sub register_entity {
    my $self = shift;
    my %p = validate(
        @_,
        {
            agent_id => { type => SCALAR },
            plugin_id => { type => SCALAR },
            entity => { type => HASHREF },
        },
    );

    my ($entity, $url) = $self->post(
        url => "agent/" . _uri_escape($p{'agent_id'}) ."/" . _uri_escape($p{'plugin_id'}) . "/" . _uri_escape($p{'entity'}->{'type'}) . "/" . _uri_escape($p{'entity'}->{'primary_id'}),
        data => $p{'entity'}
    );
    if (wantarray) {
        return $entity, $url;
    } elsif (defined wantarray) {
        return $entity;
    } else {
        return;
    }
}

sub remove_agent {
    my $self = shift;
    my %p = validate(
        @_,
        {
            agent_id => { type => SCALAR },
        },
    );

    my ($agent, $url) = $self->delete(
        url => "agent/" . _uri_escape($p{'agent_id'}),
    );
    if (wantarray) {
        return $agent, $url;
    } elsif (defined wantarray) {
        return $agent;
    } else {
        return;
    }
}

sub get_entity {
    my $self = shift;
    my %p = validate(
        @_,
        {
            agent_id => { type => SCALAR },
            plugin_id => { type => SCALAR },
            type => { type => SCALAR },
            primary_id => { type => SCALAR },
        },
    );

    my ($entity, $url) = $self->get(
        url => "agent/" . _uri_escape($p{'agent_id'}) . "/" . _uri_escape($p{'plugin_id'}) . "/" . _uri_escape($p{'type'}) . "/" . _uri_escape($p{'primary_id'}),
    );

    if (wantarray) {
        return $entity, $url;
    } elsif (defined wantarray) {
        return $entity;
    } else {
        return;
    }
}

sub load {
    my $self = shift;
    my $data = shift;
    return Load($data);
}

sub _uri_escape {
    my $string = $_[0];
    # Apache 2, at least, collapses multiple //'s.  This avoids that.
    $string =~ s/\//XFSLHX/g;
    return URI::Escape::uri_escape($string);
}

sub _make_url {
    my $self = shift;
    my %p    = validate(
        @_,
        {
            url    => { type => SCALAR },
            params => { type => ARRAYREF, optional => 1 },
            server => { type => SCALAR, default => $self->server },
        }
    );

    my $url;
    if ($p{'url'} !~ /^http:\/\//) { 
        $url = URI->new( $self->server . "/" . $p{'url'} );
    } else {
        $url = URI->new( $p{'url'} );
    }
    if ( defined( $p{'params'} ) ) {
        $url->query_form( $p{'params'} );
    }
    return $url;
}

sub get_schema {
    my $self = shift;
    
    my ($entity, $url) = $self->get(
        url => "schema" 
    );

    if (wantarray) {
        return $entity, $url;
    } elsif (defined wantarray) {
        return $entity;
    } else {
        return;
    } 
}

sub get_schema_type {
    my $self = shift;
    my %p = validate(@_,
        {
            type => { type => SCALAR },
        },
    );
    my ($entity, $url) = $self->get(
        url => "schema/" . _uri_escape($p{'type'}),
    );

    if (wantarray) {
        return $entity, $url;
    } elsif (defined wantarray) {
        return $entity;
    } else {
        return;
    } 
}

# Closures rule!
{
    foreach my $sub (qw(get delete)) {
        no strict 'refs';
        *{$sub} = sub {
            my $self = shift;
            my %p    = validate(
                @_,
                {
                    url    => { type => SCALAR },
                    params => { type => ARRAYREF, optional => 1 },
                },
            );

            my $url = $self->_make_url(%p);
            $self->log->debug("Making $sub request for $url");
            my $req = HTTP::Request->new( uc($sub) => $url );
            $req->content_type( $self->{'content_type'} );
            my $res = $self->ua->request($req);
            my $response = $self->load($res->content);
            Sid::Exception::Client->throw(
                    "Cannot send $sub request to $url: "
                  . $res->code . " "
                  . $res->message . "\n" . "  "
                  . $response->{'error'} . "\n" )
              if $res->is_error;
            return $response, $url;
          }
    }
    foreach my $sub (qw(put post)) {
        no strict 'refs';
        *{$sub} = sub {
            my $self = shift;
            my %p    = validate(
                @_,
                {
                    url  => { type => SCALAR },
                    params => { type => ARRAYREF, optional => 1 },
                    data => 1,
                },
            );
            my $data = Dump( $p{'data'} );
            my $url;
            if (exists($p{'params'})) { 
                $url = $self->_make_url(url => $p{'url'}, params => $p{'params'} );
            } else {
                $url = $self->_make_url(url => $p{'url'});
            }
            my $req = HTTP::Request->new( uc($sub) => $url );
            $req->content_type( $self->content_type );
            $req->header('Content_Length' => length($data));
            $req->content($data);
            my $res = $self->ua->request($req);
            my $response = $self->load($res->content);
            Sid::Exception::Client->throw(
                    "Cannot send $sub request to $url: "
                  . $res->code . " "
                  . $res->message . "\n" . "  "
                  . $response->{'error'} . "\n" )
              if $res->is_error;
            return $response, $url;
          }
    }
}

1;
