#
# Agent.pm
# Created by: Adam Jacob, Marchex, <adam@marchex.com>
#
# $Id: DB.pm,v 1.1.2.1 2006/07/07 02:23:11 adam Exp $
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

use strict;
use warnings;

package Sid::Service::Model::Agent;
use base qw/Catalyst::Model/;
use Params::Validate qw(:all);
use Sid::Exception;
use Data::Dump qw(dump);

__PACKAGE__->mk_accessors("_application");

*_app = *_application;

sub new {
    my $self = shift;
    my $app  = $_[0];
    my $new  = $self->NEXT::new(@_);
    $new->_application($app);
    return $new;
}

sub create {
    my $self = shift;
    my %p    = validate( @_, { 'agent' => { type => HASHREF, }, }, );

    Sid::Exception::InvalidArgument->throw(
        'Cannot create new Agent.  Missing agent_id.')
      unless defined $p{'agent'}->{'agent_id'};
    Sid::Exception::InvalidArgument->throw(
        'Cannot create new Agent.  Missing description.')
      unless defined $p{'agent'}->{'description'};

    my ($doc_id, $doc) = $self->_app->model('Xapian')->update_or_create(
        key => $p{'agent'}->{'agent_id'},
        type => 'agent',
        data => {
            agent_id => $p{'agent'}->{'agent_id'},
            description => $p{'agent'}->{'description'},
        },
        terms => {
            agent_id => $p{'agent'}->{'agent_id'},
            description => $p{'agent'}->{'description'},
        },
    );
    return 1;
}

*update = *create;

sub list {
    my $self = shift;

    my $agents = $self->_app->model('Xapian')->search(
        query => 'sidtype:agent'
    );
    my %agentlist;
    foreach my $agent (@{$agents}) {
        $self->_app->log->debug(dump($agent));
        $agentlist{ $agent->{'agent_id'} } =
          { description => $agent->{'description'}, };
    }
    return \%agentlist;
}

sub get {
    my $self = shift;
    my %p    = validate(
        @_,
        {
            agent_id => { type => SCALAR, optional => 1 },
            agent    => { type => HASHREF, optional => 1 },
        },
    );

    Sid::Exception::InvalidArgument->throw(
        "Cannot get an agent without either an agent hashref or an agent_id")
      unless ( defined( $p{'agent_id'} ) || defined( $p{'agent'} ) );

    my $agent = $p{'agent'}
      || $self->_app->model('Xapian')->find(
         key => $p{'agent_id'},
         type => "agent",
     );
    Sid::Exception::Get->throw("Could not find the requested agent.")
      unless defined $agent;

    my $entity = {
        agent_id    => $agent->{'agent_id'},
        description => $agent->{'description'},
        plugins     => [],
    };

    my $plugins = $self->_app->model('Xapian')->search(
       query => 'sidtype:plugin agent:"' . $agent->{'agent_id'} . '"',
    );
    foreach my $plugin (@{$plugins}) {
        push( @{ $entity->{'plugins'} }, $plugin->{'plugin_id'} );
    }
    return $entity;
}

sub remove {
    my $self = shift;
    my %p    = validate( @_, { agent_id => { type => SCALAR, }, }, );

    Sid::Exception::InvalidArgument->throw(
        "Cannot delete an agent without an agent_id")
      unless defined $p{'agent_id'};

    my $return = $self->get(agent_id => $p{'agent_id'});

    my ($doc_id, $doc) = $self->_app->model('Xapian')->remove_document(
        key => $p{'agent_id'},
    );

    my $deleted = $self->_app->model('Xapian')->search_and_remove(
        query => 'agent:"' . $p{'agent_id'} . '" and (sidtype:plugin or sidtype:entity)',
    );

    return 1;
}

1;

