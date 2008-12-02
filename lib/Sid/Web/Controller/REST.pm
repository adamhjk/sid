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
