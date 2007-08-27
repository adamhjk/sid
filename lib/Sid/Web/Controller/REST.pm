package Sid::Web::Controller::REST;

use strict;
use warnings;

use base "Catalyst::Controller::REST";

__PACKAGE__->config->{'serialize'}->{'map'}->{'text/javascript'} = 'JSON';

=head1 NAME

Sid::Web::Controller::REST - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut
sub schema :Local :Args(1) :ActionClass('REST') { }

sub schema_GET {
    my ($self, $c, $schema) = @_;

    my $schema_type = $c->model('Sid')->get_schema_type(type => $schema);
    return $self->status_ok($c, entity => $schema_type);
}

=head1 AUTHOR

Adam Jacob

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
