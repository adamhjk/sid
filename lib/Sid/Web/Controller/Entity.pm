package Sid::Web::Controller::Entity;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Data::Dump qw(dump);
use Class::C3;

=head1 NAME

Sid::Web::Controller::Entity - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


sub index : Private {
    my ( $self, $c ) = @_;

    $c->stash->{'template'} = 'entity/index.tt2';
    $c->log->debug(dump($c->model('Sid')));
    my $results = $c->model('Sid')->search(
        query => 'type:* not from:*',
        fields => [ 'monkey' ],
    );
    foreach my $entity (@{$results}) {
        push(@{$c->stash->{'type'}->{$entity->{'type'}}}, $entity);
    }
    $c->log->debug(dump($c->stash));
}

=head1 AUTHOR

Adam Jacob

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
