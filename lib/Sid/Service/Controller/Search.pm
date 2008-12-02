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

package Sid::Service::Controller::Search;

use strict;
use warnings;
use lib qw(/home/adam/src/sandbox/catalyst-svn/Catalyst-Action-REST/lib);
use base 'Catalyst::Controller::REST';
use Exception::Class::TryCatch;

=head1 NAME

Sid::Service::Controller::Search - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub search : Path('/q') : ActionClass('REST') {

}

sub search_GET {
    my ( $self, $c ) = @_;

    my $query = $c->req->param('s');
    return $self->status_bad_request( $c,
        message => "Must specify a search query with param s!" )
      unless defined $query && $query ne "";

    my @fields = $c->req->param('f');
    my @args = ( query => $query );
    push( @args, 'fields' => [@fields] ) if scalar(@fields);
    push( @args, 'num_per' => $c->req->param('n')) if $c->req->param('n');
    push( @args, 'page' => $c->req->param('p')) if $c->req->param('p');
    my $search_result;
    my $page;
    eval { ($search_result, $page) = $c->model('Entity')->search(@args); };
    if ( catch my $e ) {
        return $self->status_not_found( $c, message => $e->message );
    }


    for ( my $x = 0; $x < scalar( @{$search_result} ); $x++ ) {
        $search_result->[$x]->{'entity'} = $c->uri_for(
            '/agent',
            $search_result->[$x]->{'agent_id'},
            $search_result->[$x]->{'plugin_id'},
            $search_result->[$x]->{'type'},
            $search_result->[$x]->{'primary_id'},
        )->as_string;
    }
    if (defined($page)) {
        unshift(@{$search_result}, 
            {
                'paged' => 'yes',
                'total' => $page->total_entries,
                'num_per' => $page->entries_per_page,
                'current_page' => $page->current_page,
                'last_page' => $page->last_page,
                'previous_page' => $page->previous_page,
                'next_page' => $page->next_page,
                'first' => $page->first,
                'last' => $page->last,
            },
        );
    } else {
        unshift(@{$search_result}, ({ paged => 'no' }));
    }
    $self->status_ok( $c, entity => $search_result );
}

=head1 AUTHOR

Adam Jacob

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
