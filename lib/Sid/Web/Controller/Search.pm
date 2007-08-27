package Sid::Web::Controller::Search;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Data::Dump qw(dump);

=head1 NAME

Sid::Web::Controller::Search - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub search :Path :Args(0) :Form {
    my ($self, $c) = @_;

    $c->stash->{'template'} = 'search/index.tt2';

    my @types;
    my %result_fields;
    my %seensearch;
    my @search_fields;
    foreach my $type (keys(%{$c->model('Sid')->get_schema})) {
        push(@types, $type);
        my $schema = $c->model('Sid')->get_schema_type(type => $type);
        foreach my $result (keys %{$schema->{'result_fields'}}) {
            $result_fields{$result} = 1;
        }
        foreach my $search (keys %{$schema->{'search_fields'}}) {
            if (defined($c->req->param('type')) && $c->req->param('type') ne "") {
                push(@search_fields, $search) if $c->req->param('type') eq $type;
            } else {
                push(@search_fields, $search) unless exists($seensearch{$search});
                $seensearch{$search} = 1;
            }
        }
    }
    $c->stash->{'search_fields'} = [ sort(@search_fields) ];
    $c->stash->{'result_fields'} = [ sort(keys(%result_fields)) ];
    $c->form->field(name => 'type', options => \@types);
    $c->form->field(name => 'f', options => [ sort(keys(%result_fields)) ], );

    if (defined($c->req->param('q')) || defined($c->req->param('type'))) {
        $c->forward('do_search');
    }
}

sub do_search :Private {
    my ($self, $c) = @_;

    my $query;
    if (defined($c->req->param('type')) && $c->req->param('type') ne "") {
        $query = "type:" . $c->req->param('type') . " ";
    }
    $query .= $_ foreach $c->req->param('q');
    if ($query eq "") {
        $query = "type:*";
    }
    $c->log->debug("Searching for $query");
    my $page = $c->req->param('p') || 1;
    my $num_per = $c->req->param('n') || 10;
    my %args = ( 
        query => $query,
        page => $page,
        num_per => $num_per,
    );
    my @fields = $c->req->param('f');
    $args{'fields'} = \@fields;
    my ($results, $url, $pager) = $c->model('Sid')->search( %args );
    for (my $x = 1; $x <= $pager->{'last_page'}; $x++) {
        push(@{$c->stash->{'page_list'}}, $x);
    }
    $c->stash->{'search_pager'} = $pager;
    $c->stash->{'search_results'} = $results;
    $c->stash->{'search_url'} =~ s/\&p=\d+//g;
}

=head1 AUTHOR

Adam Jacob

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
