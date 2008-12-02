#!/usr/bin/perl
#
# Sid::Queue
#
# $Id$
#
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

package Sid::Queue;

use Moose;
use Params::Validate qw(:all);
use IPC::DirQueue;
use YAML::Syck;
use Sid::Exception;
use Sid::Dump::Xapian;
use Data::Dump qw(dump);

has 'queue' => ( is => 'rw', isa => 'Str', required => 1);
has 'dq' => ( is => 'ro', isa => 'Obj', );
has 'sdump' => ( is => 'ro', isa => 'Obj', );

with 'Sid::Role::Log4perl';

sub BUILD {
    my ($self, $params) = @_;

    $self->{'dq'} = IPC::DirQueue->new({ dir => $params->{'queue'} });
    $self->{'sdump'} = Sid::Dump::Xapian->new;
}

sub enqueue {
    my $self = shift;
    my %p = validate(@_,
        {
            task => { type => SCALAR },
            data => 1,
        }
    );

    $self->dq->enqueue_string(Dump($p{'data'}), { task => $p{'task'} });
    return 1;
}

sub dequeue {
    my $self = shift;
    my $job = shift;

    $job ||= $self->dq->pickup_queued_job();
    return undef unless defined $job;
    my $data = LoadFile($job->get_data_path);
    $job->finish;
    my $rc = { task => $job->{'metadata'}->{'task'}, data => $data };
    return $rc;
}

sub wait_for_it {
    my $self = shift;
    my $timeout = shift;

    $timeout ||= 1;

    my $job = $self->dq->wait_for_queued_job($timeout);

    return undef unless defined $job;

    return $self->dequeue($job);
}

1;
