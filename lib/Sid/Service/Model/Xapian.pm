#
# Agent.pm
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

package Sid::Service::Model::Xapian;
use base qw/Catalyst::Model/;
use Params::Validate qw(:all);
use Sid::Exception;
use Search::Xapian qw(:standard);
use Search::Xapian::WritableDatabase;
use Search::Xapian::Database;
use HOP::Lexer qw(string_lexer);
use Exception::Class::TryCatch;
use Data::Dump qw(dump);
use YAML::Syck;
use Data::Page;

__PACKAGE__->mk_accessors( "_application", "xdb_path" );

*_app = *_application;

$ENV{XAPIAN_PREFER_FLINT} = 1;

use Sid::Exception;

sub new {
    my $self = shift;
    my $app  = $_[0];
    my $new  = $self->NEXT::new(@_);
    $new->_application($app);
    return $new;
}

sub xdb_path {
    my $self = shift;
    return $self->_app->path_to('xapian-db')->stringify;
}

sub xdb_write {
    my $self = shift;
    my $path = $self->xdb_path;
    my $xdb  =
      Search::Xapian::WritableDatabase->new( $path,
        Search::Xapian::DB_CREATE_OR_OPEN )
      or
      Sid::Exception::Xapian->throw("can't create write-able db object: $!");

    return $xdb;
}

sub remove_document {
    my $self = shift;
    my %p    = validate( @_, { key => { type => SCALAR }, } );

    $self->_app->log->debug("Deleting document with sidkey $p{'key'}");

    $self->_app->model('Queue')->enqueue(
        task => 'remove',
        data => $p{'key'},
    );
    return 1;
}

sub update_or_create {
    my $self = shift;
    my %p    = validate(
        @_,
        {
            key       => { type => SCALAR },
            type      => { type => SCALAR },
            data      => { type => HASHREF },
            terms     => { type => HASHREF },
            raw_terms => { type => ARRAYREF, optional => 1, default => [] },
        },
    );

    #   my ( $doc_id, $doc ) = $self->find(
    #    key    => $p{'key'},
    #    type   => $p{'type'},
    #    as_doc => 1,
    #);
    my $doc = {
        key       => $p{'key'},
        type      => $p{'type'},
        data      => $p{'data'},
        terms     => $p{'terms'},
        raw_terms => $p{'raw_terms'},
    };

    #if ( defined($doc_id) ) {
    #    $self->_app->model('Queue')->enqueue(
    #        task => 'replace',
    #        data => [ $doc_id, $doc ],
    #    );
    #} else {
    $self->_app->model('Queue')->enqueue(
        task => 'add',
        data => $doc,
    );

    #}

    return $p{'key'}, $doc;
}

sub find_and_remove {
    my $self = shift;
    my %p    = validate(
        @_,
        {
            key  => { type => SCALAR },
            type => { type => SCALAR },
            xdb  => { type => OBJECT, optional => 1 },
        },
    );

    $self->remove_document( key => $p{'key'}, );
    return 1;
}

sub find {
    my $self = shift;
    my %p    = validate(
        @_,
        {
            key    => { type => SCALAR },
            type   => { type => SCALAR },
            as_doc => { type => SCALAR, default => 0 },
        },
    );

    my $doc_set = $self->search(
        query => 'sidkey:"'
          . $p{'key'}
          . '" AND sidtype:"'
          . $p{'type'} . '"',
        as_doc => 1,
    );
    my $doc_id;
    my $doc;
    if ( scalar( @{$doc_set} ) == 1 ) {
        $doc_id = $doc_set->[0]->[0];
        $doc    = $doc_set->[0]->[1];
    }
    if ( scalar( @{$doc_set} ) > 1 ) {
        Sid::Exception::Xapian->throw(
"Found more than one Xapian document with $p{'key'} for $p{'type'} !"
        );
    }
    if ( $p{'as_doc'} ) {
        if ( defined $doc_id && defined $doc ) {
            return $doc_id, $doc;
        } else {
            return undef, undef;
        }
    } else {
        if ( defined $doc ) {
            return Load( $doc->get_data );
        } else {
            return undef;
        }
    }
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
        $self->_app->log->debug("Adding term $result\n");
        $doc->add_term($result);
    }
    return $doc;
}

sub parse_query {
    my $self = shift;
    my %p    = validate(
        @_,
        {
            query      => { type => SCALAR },
            default_op => { type => SCALAR, default => OP_AND },
        },
    );

    my @input_tokens = (
        [ 'PGROUP',  qr/\(\[.*?\]\)/ ],
        [ 'REGEX',   qr/[\w\-\_\\\/\.]+\=\~\/.+?\// ],
        [ 'REGEX',   qr/[\w\-\_\\\/\.]+\!\~\/.+?\// ],
        [ 'INRANGE', qr/[\w\-\_\\\/\.]+\:\[.+?\% TO .+?\%\]/ ],
        [ 'EXRANGE', qr/[\w\-\_\\\/\.]+\:\{.+?\% TO .+?\%\}/ ],
        [ 'INRANGE', qr/[\w\-\_\\\/\.]+\:\[.+? TO .+?\]/ ],
        [ 'EXRANGE', qr/[\w\-\_\\\/\.]+\:\{.+? TO .+?\}/ ],
        [ 'TERM',    qr/[\w\-\_\\\/\.]+\:".+?"/ ],
        [ 'TERM',    qr/[\w\-\_\\\/\.]+\:'.+?'/ ],
        [ 'TERM',    qr/[\w\-\_\\\/\.]+\:[\w\-\_\\\/\.]+/ ],
        [ 'TERM',    qr/[\w\-\_\\\/\.]+\:/ ],
        [ 'OP',      qr/\bAND\b/i, ],
        [ 'OP',      qr/\bOR\b/i, ],
        [ 'OP',      qr/\bNOT\b/i, ],
        [ 'SPLAT',   qr/\*/ ],
        [ 'WORD',    qr/[\w\-\_\\\/\.]+/ ],
        [ 'SPACE', qr/\s*/, sub { () } ],
        [ 'OTHER', qr/./ ],
    );

    my $lexer = string_lexer( $p{'query'}, @input_tokens );
    my @tokens;
    my $mquery = undef;
    my $last_query;
    my @qstack;
    my $inparen = 0;
  TOKE: while ( my $token = $lexer->() ) {

        #next TOKE unless (ref($token) eq "ARRAY");
        my ( $label, $value ) = @{$token};
        push @tokens, $token;

        if ( $label eq "TERM" ) {
            my ( $field, $fv ) = split( /:/, $value );
            $fv =~ s/^["']//;
            $fv =~ s/["']$//;
            my $term  = "X" . uc($field) . lc($fv);
            my $query = Search::Xapian::Query->new($term);
            my @splat = ($query);
            if ( defined( my $next = $lexer->('peek') ) ) {

                #if (ref($next) eq "ARRAY") {
                my ( $next_label, $next_value ) = @{$next};
                if ( $next_label eq 'SPLAT' ) {
                    my @extra = $self->_parse_splat( term => $term );
                    push( @splat, @extra ) if scalar(@extra);
                }

                #}
            }
            if ( scalar(@splat) > 1 ) {
                push( @qstack, \@splat );
            } else {
                push( @qstack, $query );
            }
        } elsif ( $label eq "INRANGE" ) {
            my ( $field, $from, $to ) =
              $value =~ /^([\w\-\_\\\/\.]+)\:\[(.+?) TO (.+?)\]$/;
            my $term    = "X" . uc($field);
            my $tfrom   = $term . $from;
            my $tto     = $term . $to;
            my $query   = Search::Xapian::Query->new( OP_OR, $tfrom, $tto );
            my @results = ($query);
            my @range_results =
              $self->_parse_range( term => $term, from => $from, to => $to );
            if ( scalar(@range_results) ) {
                push( @results, @range_results );
            }
            push( @qstack, \@results );
        } elsif ( $label eq "EXRANGE" ) {
            my ( $field, $from, $to ) =
              $value =~ /^([\w\-\_\\\/\.]+)\:\{(.+?) TO (.+?)\}$/;
            my $term  = "X" . uc($field);
            my $query =
              Search::Xapian::Query->new( OP_OR, $term, "never_match_me" );
            my @results = ($query);
            $self->_app->log->debug("$term $from $to");
            my @range_results =
              $self->_parse_range( term => $term, from => $from, to => $to );
            if ( scalar(@range_results) ) {
                push( @results, @range_results );
            }
            push( @qstack, \@results );
        } elsif ( $label eq "REGEX" ) {
            my $field;
            my $rx;
            my $rxtype;
            if ( $value =~ /^(.+)\=\~\/(.+)\/$/ ) {
                $field  = $1;
                $rx     = $2;
                $rxtype = "standard";
            } elsif ( $value =~ /^(.+)\!\~\/(.+)\/$/ ) {
                $field  = $1;
                $rx     = $2;
                $rxtype = "negative";
            }
            my $term          = "X" . uc($field);
            my $query         = Search::Xapian::Query->new( $term . $rx );
            my @results       = ($query);
            my @regex_results = $self->_parse_regex(
                term  => $term,
                regex => $rx,
                type  => $rxtype
            );
            if ( scalar(@regex_results) ) {
                push( @results, @regex_results );
            }
            push( @qstack, \@results );
        } elsif ( $label eq "WORD" ) {
            $value =~ s/\s//g;
            my $query = Search::Xapian::Query->new($value);
            my @splat = ($query);
            if ( defined( my $next = $lexer->('peek') ) ) {
                my ( $next_label, $next_value ) = @{$next};
                if ( $next_label eq 'SPLAT' ) {
                    my @extra = $self->_parse_splat( term => $value );
                    push( @splat, @extra ) if scalar(@extra);
                }
            }
            if ( scalar(@splat) > 1 ) {
                push( @qstack, \@splat );
            } else {
                push( @qstack, $query );
            }
        } elsif ( $label eq "OP" ) {
            my %ops = (
                AND => OP_AND,
                OR  => OP_OR,
                NOT => OP_AND_NOT,
            );
            push( @qstack, $ops{ uc($value) } );
        } elsif ( $label eq "SPLAT" ) {

            # Do old search
        } elsif ( $label eq 'PGROUP' ) {
            $value =~ s/^\(//;
            $value =~ s/\)$//;
            my $results = $self->parse_query( query => $value );
            push( @qstack, $results );
        }
    }
    return \@qstack;
}

sub _parse_range {
    my $self = shift;
    my %p    = validate(
        @_,
        {
            'term' => { type => SCALAR },
            'from' => { type => SCALAR },
            'to'   => { type => SCALAR },
        },
    );
    my @splat;
    my $term = $p{'term'};

    my $allterms = $self->xdb_read->allterms_begin;
    my $allend   = $self->xdb_read->allterms_end;
    $allterms->skip_to($term);

    $p{'from'} =~ s/\%$//;
    $p{'to'}   =~ s/\%$//;

    my $type = "string";
    if ( $p{'from'} =~ /^\d+($|[[:alpha:]]+$)/ ) {
        $type = "numeric";
        $p{'from'} =~ s/^(\d+)[[:alpha:]]+$/$1/;
        $p{'to'}   =~ s/^(\d+)[[:alpha:]]+$/$1/;
    }
    while ( $allterms != $allend && $allterms =~ /^$term/ ) {
        my $comp_term = $allterms;
        $comp_term =~ s/^$term//g;
        my $pass = 0;
        if ( $type eq "numeric" ) {
            $comp_term =~ s/^(\d+)([[:alpha:]]|\%)+$/$1/;
            if ( $p{'from'} eq '*' ) {
                $pass++;
            } elsif ( ( $comp_term <=> $p{'from'} ) == 1 ) {
                $pass++;
            }
            if ( $p{'to'} eq '*' ) {
                $pass++;
            } elsif ( ( $comp_term <=> $p{'to'} ) == -1 ) {
                $pass++;
            }
        } elsif ( $type eq "string" ) {
            if ( $p{'from'} eq '*' ) {
                $pass++;
            } elsif ( ( $comp_term cmp $p{'from'} ) == 1 ) {
                $pass++;
            }
            if ( $p{'to'} eq '*' ) {
                $pass++;
            } elsif ( ( $comp_term cmp $p{'to'} ) == -1 ) {
                $pass++;
            }
        }
        push( @splat, OP_OR, Search::Xapian::Query->new($allterms) )
          if $pass == 2;
        ++$allterms;
    }
    return @splat;
}

sub _parse_regex {
    my $self = shift;
    my %p    = validate(
        @_,
        {
            'term'  => { type => SCALAR },
            'regex' => { type => SCALAR },
            'type'  => { type => SCALAR },
        },
    );

    my @splat;
    my $term = $p{'term'};

    my $allterms = $self->xdb_read->allterms_begin;
    my $allend   = $self->xdb_read->allterms_end;
    $allterms->skip_to($term);
    while ( $allterms != $allend && $allterms =~ /^$term/ ) {
        my $comp_term = $allterms;
        $comp_term =~ s/^$term//g;
        if ( $p{'type'} eq "standard" ) {
            if ( $comp_term =~ /$p{'regex'}/ ) {
                push( @splat, OP_OR, Search::Xapian::Query->new($allterms) );
            }
        } elsif ( $p{'type'} eq "negative" ) {
            if ( $comp_term !~ /$p{'regex'}/ ) {
                push( @splat, OP_OR, Search::Xapian::Query->new($allterms) );
            }
        }
        ++$allterms;
    }
    return @splat;
}

sub _parse_splat {
    my $self = shift;
    my %p    = validate( @_, { 'term' => { type => SCALAR }, }, );

    my @splat;
    my $term = $p{'term'};

    my $allterms = $self->xdb_read->allterms_begin;
    my $allend   = $self->xdb_read->allterms_end;
    $allterms->skip_to($term);
    while ( $allterms != $allend && $allterms =~ /^$term/ ) {
        push( @splat, OP_OR, Search::Xapian::Query->new($allterms) );
        ++$allterms;
    }
    return @splat;
}

sub build_query {
    my $self = shift;
    my %p    = validate( @_, { 'qstack' => { type => ARRAYREF }, }, );

    my $q          = undef;
    my $default_op = OP_AND;
    my $op         = $default_op;
    foreach my $part ( @{ $p{'qstack'} } ) {
        if ( ref($part) eq 'Search::Xapian::Query' ) {
            if ( !defined($q) ) {
                $q = $part;
            } else {
                $op ||= $default_op;

                #die "$op $q $part";
                $q = Search::Xapian::Query->new( $op, $q, $part );
                $op = $default_op;
            }
        } elsif ( ref($part) eq 'ARRAY' ) {
            my $sq = $self->build_query( qstack => $part );
            $op ||= $default_op;
            if ( defined $q ) {
                $q = Search::Xapian::Query->new( $op, $q, $sq );
            } else {
                $q = Search::Xapian::Query->new( $op, $sq );
            }
            $op = $default_op;
        } else {
            $op = $part;
        }
    }
    return $q;
}

sub search_and_remove {
    my $self = shift;
    my %p    = validate(
        @_,
        {
            query => { type => SCALAR },
            xdb   => { type => OBJECT, optional => 1 },
        },
    );

    #$p{'xdb'} ||= $self->xdb_write;
    my $results = $self->search(
        query  => $p{'query'},
        as_doc => 1,
    );

    foreach my $docbit ( @{$results} ) {
        $self->remove_document( key => $docbit->[1]->get_value(1), );
    }
    return $results;
}

sub search {
    my $self = shift;
    my %p    = validate(
        @_,
        {
            query   => { type => SCALAR },
            as_doc  => { type => SCALAR, default => 0 },
            num_per => { type => SCALAR, optional => 1 },
            page    => { type => SCALAR, optional => 1 },
        },
    );
    my $db = $self->xdb_read;

    my $enq = $db->enquire;
    $enq->set_weighting_scheme( Search::Xapian::BoolWeight->new );
    my $qstack = $self->parse_query( query  => $p{'query'} );
    my $query  = $self->build_query( qstack => $qstack );
    $enq->set_query($query);

    $self->_app->log->debug( sprintf "Parsing query '%s'",
        $enq->get_query()->get_description() );

    my @matches = $enq->matches( 0, 10000000 );
    my $num_matches = scalar(@matches);
    $self->_app->log->debug( scalar(@matches) . " results found" );

    my @results;
    my $realset;
    my $page;
    if ( exists( $p{'num_per'} ) && exists( $p{'page'} ) ) {
        $page = Data::Page->new();
        $page->total_entries($num_matches);
        $page->entries_per_page( $p{'num_per'} );
        $page->current_page( $p{'page'} );
        my @set = $page->splice( \@matches );
        $realset = \@set;
    } else {
        $realset = \@matches;
    }
    foreach my $match ( @{$realset} ) {
        $self->_app->log->debug( sprintf "ID %d %d%%",
            $match->get_docid(), $match->get_percent() );
        my $doc = $match->get_document;
        if ( $p{'as_doc'} ) {
            push( @results, [ $match->get_docid, $doc ] );
        } else {
            push( @results, Load( $doc->get_data ) );
        }
    }
    if (wantarray) {
        return \@results, $page;
    } elsif ( defined(wantarray) ) {
        return \@results,;
    } else {
        return;
    }
}

sub xdb_read {
    my $self = shift;

    my $xdb;
    eval {
        $xdb = Search::Xapian::Database->new( $self->xdb_path )
          or die "can't create read-able db object: $!\n";
    };
    if ( catch my $e ) {
        if ( $e->message =~ "Couldn't detect type of database" ) {
            my $txdb = $self->xdb_write;
            $txdb->flush;
            $xdb = $self->xdb_read;
        } else {
            $e->rethrow;
        }
    }
    return $xdb;
}

1;

