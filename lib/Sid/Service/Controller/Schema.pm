package Sid::Service::Controller::Schema;

use strict;
use warnings;
use lib qw(/home/adam/src/sandbox/catalyst-svn/Catalyst-Action-REST/lib);
use base 'Catalyst::Controller::REST';
use Exception::Class::TryCatch;
use Data::Dump qw(dump);

=head1 NAME

Sid::Service::Controller::Schema - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub schema_list :Path : ActionClass('REST')
{
}

sub schema_list_GET {
    my ($self, $c) = @_;
    
    my $sr = $c->model('Xapian')->search(
        query => 'XSIDSCHEMAentity',
    );
    my $response = {};
    foreach my $type (sort(keys(%{$sr->[0]}))) {
        $response->{$type} = $c->uri_for('/schema/' . $type)->as_string;
    }
    $self->status_ok($c, entity => $response);
}

sub schema_entry :Chained :PathPart('schema') :Args(1) :ActionClass('REST') {}

sub schema_entry_GET {
    my ($self, $c, $type) = @_;

    my $sr = $c->model('Xapian')->search(
        query => 'XSIDSCHEMAentity',
    );
    if (!scalar(@{$sr}) || !exists($sr->[0]->{$type})) {
        return $self->status_not_found($c, message => "Cannot find schema for $type");
    }
    $self->status_ok($c, entity => $sr->[0]->{$type}); 
}

=head1 AUTHOR

Adam Jacob

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
