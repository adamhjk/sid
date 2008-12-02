#
# Output.pm
# Created by: Adam Jacob, Marchex, <adam@marchex.com>
# Created on: 10/31/2006 12:58:58 PM PST
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

package Sid::Format::Output;

use strict;
use warnings;

use Moose;
use Params::Validate qw(:all);
with 'Sid::Role::Log4perl';

has 'store_output' => ( is => 'rw', isa => 'Bool', default => 0 );
has 'saved_output' => ( is => 'rw', isa => 'Str', );
has 'search_fields' => ( is => 'rw', isa => 'ArrayRef' );
has 'search_data' => ( is => 'rw', isa => 'ArrayRef', required => 1 );

sub BUILD {
    my ($self, $params) = @_;
    if (! exists($params->{'search_fields'})) {
        my %search_fields;
        foreach my $sr (@{$params->{'search_data'}}) {
            foreach my $key (keys(%{$sr->{'fields'}})) {
                $search_fields{$key} = 1 unless exists($search_fields{$key});
            } 
        } 
        my @temp = sort(keys(%search_fields));
        $self->search_fields(\@temp);
    }
}

sub output {
    my $self = shift;
    my $outputstring = shift;

    if ($self->store_output) { 
        my $co = $self->saved_output;
        if (defined($co)) {
            $self->saved_output($co . $outputstring . "\n");
        } else {
            $self->saved_output($outputstring . "\n");
        }
    } else {  
        $self->log->info($outputstring);
    }
}

1;
