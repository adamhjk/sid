#!/usr/bin/perl
#
# Sid::Format
#
# $Id$
#

package Sid::Format;

use strict;
use warnings;

use Moose;
use Sid::Exception;
use Params::Validate qw(:all);
use Module::Pluggable search_path => ['Sid::Format::Output'], require => 1, sub_name => 'output_plugin';
use Module::Pluggable search_path => ['Sid::Format::Input'], require => 1, sub_name => 'input_plugin';

has 'output_filter' => ( is => 'rw', isa => 'Str', default => 'Tab', );
has 'input_filter' => ( is => 'rw', isa => 'Str', default => 'Tab', );
has 'filter_options' => ( is => 'rw', isa => 'HashRef', default => sub { {}; } );
has 'saved_output' => (is => 'rw', isa => 'Str');

with 'Sid::Role::Log4perl';

sub _full_output_filter {
    my $self = shift;
    return "Sid::Format::Output::" . $self->output_filter;
}

sub output_filter_list {
    my $self = shift;
    my @output_plugins = $self->output_plugin;
    for (my $x = 0; $x < scalar(@output_plugins); $x++) {
        $output_plugins[$x] =~ s/^Sid::Format::Output:://;
    }
    return @output_plugins;
}

sub output_search {
    my $self = shift;
    my %p = validate(@_, {
            search_fields => { type => ARRAYREF, optional => 1 },
            search_data => { type => ARRAYREF, },
        }
    );

    my $return = 1;
    my $found = 0;
    OSEARCH: foreach my $of ($self->output_plugin) {
        if ($self->_full_output_filter eq $of) {
            my $opts = $self->filter_options;
            $opts->{'search_fields'} = $p{'search_fields'} if exists $p{'search_fields'};
            $opts->{'search_data'} = $p{'search_data'};
            my $filter = $of->new($opts);
            $filter->output_search(%p);
            $self->saved_output($filter->saved_output) if $filter->saved_output;
            $found = 1;
            last OSEARCH;
        }
    }
    Sid::Exception::Format->throw("Could not find a Sid::Format::Output plugin matching " . $self->output_filter . "\n") if !$found;
    return 1;
}

sub output_entity {
}


1;
