#!/usr/bin/perl
#
# Sid::Entity
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

package Sid::Entity;

use strict;
use warnings;

use Moose;
use Params::Validate qw(:all);
use Data::Dump qw(dump);

has 'agent_id' => ( is => 'rw', isa => 'Str', required => 1);
has 'plugin_id' => ( is => 'rw', isa => 'Str', required => 1);
has 'type' => ( is => 'rw', isa => 'Str', required => 1);
has 'primary_id' => ( is => 'rw', isa => 'Str', required => 1);
has 'tags' => ( is => 'rw', isa => 'ArrayRef', default => sub { [] } );
has 'fields' => ( is => 'rw', isa => 'HashRef', default => sub { {} } );
has 'parent' => ( is => 'rw', isa => 'HashRef', default => sub { {} } );

with 'Sid::Role::Log4perl';

sub add_tag {
    my $self = shift;
    my %p = validate(@_, {
            tag => { type => SCALAR | ARRAYREF },
        }
    );

    my $local_tags = $self->_wrap_array($p{'tag'});
    foreach my $ltag (@{$local_tags}) {
        push(@{$self->tags}, $ltag);
    }
    return 1;
}

sub _wrap_array {
    my $self = shift;
    my $thing = shift;

    if (ref($thing) eq "ARRAY") {
        return $thing;
    } else {
        return [ $thing ];
    }
}

sub add_field {
    my $self = shift;
    my %p = validate(@_, {
            field => { type => SCALAR },
            value => { type => SCALAR },
            tags => { type => SCALAR | ARRAYREF, optional => 1, default => [] },
        }
    );

    my $tags = $self->_wrap_array($p{'tags'}); 
    my $field_value = { 
        value => $p{'value'}, 
        tags => $tags,
        search_type => $self->type,
    };
    if (exists($self->fields->{$p{'field'}})) {
        push(@{$self->fields->{$p{'field'}}}, $field_value);
    } else {
        $self->fields->{$p{'field'}} = [ $field_value ];
    }
    return 1;
}

sub add_field_from_exec {
    my $self = shift;
    my %p = validate(@_, {
            field => { type => SCALAR },
            command => { type => SCALAR },
            do_chomp => { type => SCALAR, default => 0 },
            tags => { type => SCALAR | ARRAYREF, optional => 1, default => [] },
        },
    );

    my $output;
    open(COMMAND, "-|", "$p{'command'}") or die "Can't run $p{'command'}: $!";
    while (my $line = <COMMAND>) {
        $output .= $line;
    }
    close(COMMAND);
    chomp($output) if $p{'do_chomp'};

    $self->add_field(field => $p{'field'}, tags => $p{'tags'}, value => $output);
    return 1;
}

sub find_field {
    my $self = shift;
    my %p = validate(@_, {
            field => { type => SCALAR },
            as_struct => { type => SCALAR, default => 0 },
            as_value => { type => SCALAR, default => 1 },
        }
    );

    return undef unless exists($self->fields->{$p{'field'}});
    
    my $field = $self->fields->{$p{'field'}};

    return $field if $p{'as_struct'};

    if ($p{'as_value'}) {
        my @return;
        foreach my $fe (@{$field}) {
            push(@return, $fe->{'value'});
        }
        if (wantarray) {
            return @return; 
        } elsif (defined wantarray) {
            if (scalar(@return) == 1) {
                return $return[0];
            } else {
                return "@return";
            }
        }
    }
}

sub set_parent {
    my $self = shift;
    my %p = validate(@_, {
            agent_id => { type => SCALAR, optional => 1 },
            plugin_id => { type => SCALAR, optional => 1 },
            type => { type => SCALAR, optional => 1 },
            primary_id => { type => SCALAR, optional => 1 }, 
            entity => { type => OBJECT, optional => 1 },
        },
    );
   
    my $agent_id;
    my $plugin_id;
    my $type;
    my $primary_id;
    if (exists($p{'entity'})) {
        $agent_id = $p{'entity'}->agent_id;
        $plugin_id = $p{'entity'}->plugin_id;
        $type = $p{'entity'}->type;
        $primary_id = $p{'entity'}->primary_id;
    } else {
        die "Requires agent_id argument!" unless exists $p{'agent_id'};
        die "Requires plugin_id argument!" unless exists $p{'plugin_id'};
        die "Requires type argument!" unless exists $p{'type'};
        die "Requires primary_id argument!" unless exists $p{'primary_id'};
        $agent_id = $p{'agent_id'};
        $plugin_id = $p{'plugin_id'};
        $type = $p{'type'};
        $primary_id = $p{'primary_id'};    
    }

    my $parent_data = {
        agent_id => $agent_id,
        plugin_id => $plugin_id,
        type => $type,
        primary_id => $primary_id,
    }; 
    $self->parent($parent_data);
    return 1;
}

sub prepare {
    my $self = shift;

    my $datastruct = {
        type => $self->type,
        primary_id => $self->primary_id,
        fields => $self->fields,
        tags => $self->tags,
        parent => $self->parent,
    };

    return $datastruct;
}

1;
