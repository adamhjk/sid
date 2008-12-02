#
# Queue.pm
# Created by: Adam Jacob, Marchex, <adam@marchex.com>
#
# $Id: DB.pm,v 1.1.2.1 2006/07/07 02:23:11 adam Exp $
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

use strict;
use warnings;

package Sid::Service::Model::Queue;
use base qw/Catalyst::Model/;
use Sid::Queue;

__PACKAGE__->mk_accessors( "_application", "dq" );

*_app = *_application;

sub new {
    my $self = shift;
    my $app  = $_[0];
    my $new  = $self->NEXT::new(@_);
    $new->_application($app);
    $new->dq(Sid::Queue->new(queue => $app->path_to('queue')->stringify));
    return $new;
}

sub AUTOLOAD {
    my $self = shift;

    (my $method) = (our $AUTOLOAD =~ /([^:]+)$/);

    if ($method eq "DESTROY") {
        return;
    }
    $self->dq->$method(@_);
}

1;

