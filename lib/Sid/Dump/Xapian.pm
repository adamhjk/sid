#!/usr/bin/perl
#
# Sid::Dump::Xapian
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

package Sid::Dump::Xapian;
use Data::Dump qw(dump);
use Params::Validate qw(:all);
use Search::Xapian::Document;
use YAML::Syck;

sub new {
    my $self = shift;
    my $foo = {};
    bless $foo, $self;
    return $foo;
}

sub deflate_document {
    my $self = shift;
    my $doc = shift;

    return $doc;
}

sub make_term {
    my $self = shift;
    my %p    = validate(
        @_,
        {
            tag      => { type => SCALAR },
            value    => { type => SCALAR },
            document => { type => OBJECT },
        },
    );

    my $doc = $p{'document'};
    my $tag = "X" . uc( $p{'tag'} );

    my $val = $p{'value'};
    $val = lc($val);
    my $result;
    if ( $val =~ /^\p{IsUpper}/ ) {
        $result = $tag . ":$val";
    } else {
        $result = $tag . $val;
    }

    if ( bytes::length($result) > 240 ) {
        $result = bytes::substr( $result, 240 );
    } else {
        $doc->add_term($result);
    }
    return $doc;
}

sub inflate_document {
    my $self = shift;
    my $doc_ref = shift;

    my $doc = Search::Xapian::Document->new;

    $doc = $self->make_term(
        tag      => 'sidtype',
        value    => $doc_ref->{'type'},
        document => $doc,
    );
    $doc = $self->make_term(
        tag      => 'sidkey',
        value    => $doc_ref->{'key'},
        document => $doc,
    );
    my $terms = $doc_ref->{'terms'};
    foreach my $term ( keys( %{$terms} ) ) {
        if ( ref( $terms->{$term} ) eq "ARRAY" ) {
            foreach my $thash ( @{ $terms->{$term} } ) {

                if ( exists( $thash->{'tags'} ) ) {
                    foreach my $tag ( @{ $thash->{'tags'} } ) {
                        $doc = $self->make_term(
                            tag      => $tag,
                            value    => $thash->{'value'},
                            document => $doc,
                        );
                    }
                } else {
                    $doc = $self->make_term(
                        tag      => $term,
                        value    => $thash->{'value'},
                        document => $doc,
                    );
                }
            }
        } else {
            $doc = $self->make_term(
                tag      => $term,
                value    => $terms->{$term},
                document => $doc,
            );
        }
    }
    foreach my $rawterm (@{$doc_ref->{'raw_terms'}}) {
        $doc->add_term($rawterm);
    }
    $doc->set_data( Dump( $doc_ref->{'data'} ) );
    $doc->add_value( 0, $doc_ref->{'type'} );
    $doc->add_value( 1, $doc_ref->{'key'} );
    $doc->add_value( 2, $doc_ref->{'data'}->{'entity'}->{'type'} ) if exists($doc_ref->{'data'}->{'entity'}->{'type'});
    return $doc;
}


1;
