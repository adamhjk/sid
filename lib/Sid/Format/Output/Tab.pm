#
# Tab.pm
# Created by: Adam Jacob, Marchex, <adam@marchex.com>
# Created on: 10/31/2006 11:32:06 AM PST
#
# $Id: $

package Sid::Format::Output::Tab;

use strict;
use warnings;

use Moose;
use Params::Validate qw(:all);
use Data::Dump qw(dump);

extends 'Sid::Format::Output';

sub output_search {
    my $self = shift;
    my %p = @_;

    my $search_fields = $self->search_fields;
    my $search_data = $self->search_data;

    $self->output(join("\t", @{$search_fields})) unless exists($p{'noheader'});
    
    foreach my $sr (@{$search_data}) {
        my @outfields;
        foreach my $sf (@{$search_fields}) {
            if (exists($sr->{'fields'}->{$sf})) {
                push(@outfields, join(",", @{$sr->{'fields'}->{$sf}}));
            } else {
                if (exists($sr->{$sf})) {
                    push(@outfields, $sr->{$sf});
                } else {
                    push(@outfields, 'NA');
                }
            }
        }
        $self->output(join("\t", @outfields));
    }
}

sub output_entity {
}

1;

