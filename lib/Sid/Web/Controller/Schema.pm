package Sid::Web::Controller::Schema;

use strict;
use warnings;
use base 'Catalyst::Controller::REST';

=head1 NAME

Sid::Web::Controller::Schema - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

sub single_schema : Path :Args(1) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Sid::Web::Controller::Schema in Schema.');
}


=head1 AUTHOR

Adam Jacob

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
