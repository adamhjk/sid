#
# Long.pm
# Created by: Adam Jacob, Marchex, <adam@marchex.com>
# Created on: 10/31/2006 11:32:06 AM PST
#
# $Id: $

package Sid::Format::Output::Long;

use strict;
use warnings;

use Moose;
use Params::Validate qw(:all);
use IO::Scalar;

extends 'Sid::Format::Output';

sub output_search {
    my $self = shift;

    my $search_fields = $self->search_fields;
    my $search_data = $self->search_data;

    my $outline = IO::Scalar->new;
    my @entries;
    foreach my $sr (@{$search_data}) {
        $self->output("entity: " . $sr->{'entity'});
        foreach my $field (sort(keys(%{$sr->{'fields'}}))) {
            foreach my $value (sort(@{$sr->{'fields'}->{$field}})) {
                $self->output("$field: " . $value);
            }
        }
        $self->output("\n");
    }
}

1;

