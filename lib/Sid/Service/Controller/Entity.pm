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

package Sid::Service::Controller::Entity;

use strict;
use warnings;
use lib qw(/home/adam/src/sandbox/catalyst-svn/Catalyst-Action-REST/lib);
use base 'Catalyst::Controller::REST';
use Exception::Class::TryCatch;
use URI::Escape;

=head1 NAME

Sid::Service::Controller::Entity - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub single_entity : Regex('^agent/(.+?)/(.+?)/(.+?)/(.+)$') : ActionClass('REST') {
}

sub single_entity_GET {
    my ( $self, $c ) = @_;
    my ( $agent_id, $plugin_id, $entity_name, $primary_id ) =
      $self->_uri_unescape(@{ $c->req->snippets });
    my $entity;
    eval {
        $entity = $c->model('Entity')->get(
            agent_id    => $agent_id,
            plugin_id   => $plugin_id,
            entity_type => $entity_name,
            primary_id  => $primary_id,
        );
    };
    if ( catch my $e ) {
        return $self->status_not_found( $c, message => $e->message );
    }
    $self->status_ok( $c, entity => $entity );
}

sub _uri_unescape {
    my $self = shift;
   
    my @return;
    foreach my $thing (@_) {
        $thing =~ s/XFSLHX/\//g;
        push(@return, uri_unescape($thing));
    }
    return @return;
}

#TODO: Decided if these will ever be implemented.  As it stands, with the
#broken up queue structure, they are difficult to implement well. (Since
#parent/child relationships are no longer worked out in service, but expected
#to be done by the agents)
#
sub single_entity_PUT {
    my ( $self, $c ) = @_;

    my ( $agent_id, $plugin_id, $entity_name, $primary_id ) =
      $self->_uri_unescape(@{ $c->req->snippets });

    my $ed = $c->req->data;

    return $self->status_bad_request( $c,
        message => "Entity Name in URL does not match data in request" )
      unless $ed->{'type'} eq $entity_name;
    return $self->status_bad_request( $c,
        message => "Entity Primary ID in URL does not match data in request: '" . $ed->{'primary_id'} . "' in req and '" . $primary_id . "' in url")
      unless $ed->{'primary_id'} eq $primary_id;

    my $entity;
    eval {
        $entity = $c->model('Entity')->create(
            agent_id  => $agent_id,
            plugin_id => $plugin_id,
            entity    => $ed,
        );
    };

    if ( catch my $e ) {
        return $self->status_bad_request( $c, message => $e->message );
    }
    $self->status_accepted(
        $c,
        entity   => {
            status => 'queued',
            entity => $entity,
        },
    );
}

sub single_entity_POST {
    my ( $self, $c ) = @_;
    my ( $agent_id, $plugin_id, $entity_name, $primary_id ) =
      $self->_uri_unescape(@{ $c->req->snippets });
    my $ed = $c->req->data;

    return $self->status_bad_request( $c,
        message => "Entity Name in URL does not match data in request" )
      unless $ed->{'type'} eq $entity_name;
    return $self->status_bad_request( $c,
        message => "Entity Primary ID in URL does not match data in request: '" . $ed->{'primary_id'} . "' in req and '" . $primary_id . "' in url")
      unless $ed->{'primary_id'} eq $primary_id;

    my $entity;
    eval {
        $entity = $c->model('Entity')->update(
            agent_id  => $agent_id,
            plugin_id => $plugin_id,
            entity    => $ed,
        );
    };

    if ( catch my $e ) {
        return $self->status_bad_request( $c, message => $e->message );
    }
    $self->status_accepted( $c, entity => { status => 'queued', entity => $entity, } );
}

sub single_entity_DELETE {
    my ( $self, $c ) = @_;
    my ( $agent_id, $plugin_id, $entity_name, $primary_id ) =
      $self->_uri_unescape(@{ $c->req->snippets });

    my $rc;
    eval {
        $rc = $c->model('Entity')->remove(
            agent_id    => $agent_id,
            plugin_id   => $plugin_id,
            entity_type => $entity_name,
            primary_id  => $primary_id,
        );
    };
    if ( catch my $e ) {
        return $self->status_bad_request( $c, message => $e->message );
    }
    $self->status_accepted( $c, entity => { status => 'queued', } );
}

=head1 AUTHOR

Adam Jacob

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
