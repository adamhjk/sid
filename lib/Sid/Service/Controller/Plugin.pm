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

package Sid::Service::Controller::Plugin;

use strict;
use warnings;
use lib qw(/home/adam/src/sandbox/catalyst-svn/Catalyst-Action-REST/lib);
use base 'Catalyst::Controller::REST';
use Exception::Class::TryCatch;

=head1 NAME

Sid::Service::Controller::Plugin - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub plugin : PathPart('agent') : Chained : Args(2) : ActionClass('REST') {
}

sub plugin_GET {
    my ( $self, $c, $agent_id, $plugin_id ) = @_;

    my $plugin;
    eval {
        $plugin = $c->model('Plugin')->get(
            agent_id  => $agent_id,
            plugin_id => $plugin_id,
        );
    };
    if ( catch my $e ) {
        return $self->status_not_found( $c, message => $e->message );
    }

    $self->status_ok( $c, entity => $self->_uri_for_stuff( $c, $plugin ), );
}

sub plugin_PUT {
    my ( $self, $c, $agent_id, $plugin_id ) = @_;

    eval {
        $c->model('Plugin')->create(
            plugin => {
                plugin_id => $c->request->data->{'plugin_id'},
                agent_id  => $agent_id,
            }
        );
    };
    if ( catch my $e ) {
        return $self->status_bad_request( $c, message => $e->message );
    }
    $self->status_accepted(
        $c,
        entity   => {
            status => 'queued',
            location => $c->req->uri->as_string,
        },
    );
}

sub plugin_POST {
    my ( $self, $c, $agent_id, $plugin_id ) = @_;

    my $data = $c->req->data;
    $data->{'agent_id'} = $agent_id;
    eval { $c->model('Plugin')->update( plugin => $data ); };
    if ( catch my $e ) {
        return $self->status_bad_request( $c, message => $e->message );
    }

    $self->status_accepted( $c, entity => { status => 'queued', });
}

sub plugin_DELETE {
    my ( $self, $c, $agent_id, $plugin_id ) = @_;

    eval {
        $c->model('Plugin')->remove(
            agent_id  => $agent_id,
            plugin_id => $plugin_id,
        );
    };
    if ( catch my $e ) {
        return $self->status_not_found( $c, message => $e->message );
    }
    $self->status_accepted( $c, entity => { status => 'queued' }, );
}

sub _uri_for_stuff {
    my ( $self, $c, $plugin ) = @_;

    my $agent_id = $plugin->{'agent_id'};
    delete( $plugin->{'agent_id'} );
    $plugin->{'agent'} = $c->uri_for( $c->action, $agent_id )->as_string;
    for ( my $x = 0; $x < scalar( @{ $plugin->{'entities'} } ); $x++ ) {
        my $entity_name = $plugin->{'entities'}->[$x]->{'type'};
        my $primary_id  = $plugin->{'entities'}->[$x]->{'primary_id'};
        $plugin->{'entities'}->[$x] =
          $c->uri_for( $c->action, $agent_id, $plugin->{'plugin_id'},
            $entity_name, $primary_id )->as_string;
    }
    return $plugin;
}

=head1 AUTHOR

Adam Jacob

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
