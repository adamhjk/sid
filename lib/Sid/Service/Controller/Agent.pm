package Sid::Service::Controller::Agent;

use strict;
use warnings;
use lib qw(/home/adam/src/sandbox/catalyst-svn/Catalyst-Action-REST/lib);
use base 'Catalyst::Controller::REST';
use Exception::Class::TryCatch;

=head1 NAME

Sid::Service::Controller::Agent - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub single_agent : PathPart('agent') : Chained : Args(1) : ActionClass('REST')
{
}

sub single_agent_GET {
    my ( $self, $c, $agent_id ) = @_;

    my $agent;
    eval { $agent = $c->model('Agent')->get( agent_id => $agent_id ); };
    if ( catch my $e ) {
        return $self->status_not_found( $c, message => $e->message );
    }

    $self->status_ok( $c, entity => $self->_uri_for_plugins( $c, $agent ), );
}

sub single_agent_PUT {
    my ( $self, $c, $agent ) = @_;

    my $new_agent_data = $c->request->data;

    eval {
        $c->model('Agent')->create( agent => $new_agent_data, );
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

sub single_agent_POST {
    my ( $self, $c, $agent_id ) = @_;

    eval {
        $c->model('Agent')->update( agent => $c->request->data, );
    };
    if ( catch my $e ) {
        return $self->status_not_found( $c, message => $e->message );
    }

    $self->status_accepted( $c, entity => { status => 'queued', }, );
}

sub single_agent_DELETE {
    my ( $self, $c, $agent_id ) = @_;

    eval { $c->model('Agent')->remove( agent_id => $agent_id, ); };
    if ( catch my $e ) {
        return $self->status_not_found( $c, message => $e->message );
    }

    $self->status_accepted($c, entity => { status => 'queued' }, );
}

sub agent : Path : Args(0) : ActionClass('REST') {
}

sub agent_GET {
    my ( $self, $c ) = @_;

    my $alist = $c->model('Agent')->list;
    foreach my $key ( keys( %{$alist} ) ) {
        $alist->{$key}->{'url'} = $c->uri_for( $c->action, $key )->as_string;
    }
    $self->status_ok( $c, entity => $alist, );
}

sub _uri_for_plugins {
    my ( $self, $c, $agent ) = @_;

    for ( my $x = 0; $x < scalar( @{ $agent->{'plugins'} } ); $x++ ) {
        my $pv = $agent->{'plugins'}->[$x];
        $agent->{'plugins'}->[$x] =
          $c->uri_for( $c->action, $agent->{'agent_id'}, $pv )->as_string;
    }
    return $agent;
}

=head1 AUTHOR

Adam Jacob

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
