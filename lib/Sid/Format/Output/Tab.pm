#
# Tab.pm
# Created by: Adam Jacob, Marchex, <adam@marchex.com>
# Created on: 10/31/2006 11:32:06 AM PST
#
# $Id: $
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

