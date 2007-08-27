package Sid::Service::Controller::Root;

use strict;
use warnings;
use base 'Catalyst::Controller';
use URI::Escape;

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

=head1 NAME

Sid::Controller::Root - Root Controller for Sid

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

=head2 default

=cut

sub default : Private {
    my ( $self, $c ) = @_;

    $c->response->status(404);
    $c->response->content_type('text/plain');
    $c->response->body(
"The Sid Service doesn't know what you are talking about.  But it's paying lots of attention, you see.  That's what makes it Sid!"
    );
}

sub index : Private {
    my ( $self, $c ) = @_;

    $c->response->status(200);
    $c->response->content_type('text/plain');
    $c->response->body(
        "The Sid Service. Try " . $c->uri_for('/agent')->as_string . " or " . $c->uri_for('/q')
    );
}

=head1 AUTHOR

Adam Jacob

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

