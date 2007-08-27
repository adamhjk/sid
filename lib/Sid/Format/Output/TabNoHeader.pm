#
# Tab.pm
# Created by: Adam Jacob, Marchex, <adam@marchex.com>
# Created on: 10/31/2006 11:32:06 AM PST
#
# $Id: $

package Sid::Format::Output::TabNoHeader;

use Moose;

extends 'Sid::Format::Output::Tab';

sub output_search {
    my $self = shift;
    my %p = @_;
    $p{'noheader'} = 1;

    $self->SUPER::output_search(%p);
};

1;

