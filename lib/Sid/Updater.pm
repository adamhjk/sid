#!/usr/bin/perl
#
# Sid::Agent
#
# $Id$
#

package Sid::Updater;

use Moose;
use Sid::Exception;
use Params::Validate qw(:all);
use Data::Dump qw(dump);
use Exception::Class::TryCatch;
use Sid::Queue;
use Search::Xapian;
use Sid::Dump::Xapian;
use YAML::Syck;

has 'queue' => ( is => 'rw', isa => 'Str', required => 1);
has 'xapian' => ( is => 'rw', isa => 'Str', required => 1);
has 'sq' => ( is => 'ro', isa => 'Obj', );
has 'xdb' => ( is => 'ro', isa => 'Obj', );
has 'sdump' => ( is => 'ro', isa => 'Obj', );

with 'Sid::Role::Log4perl';

$ENV{'XAPIAN_PREFER_FLINT'} = 1;

sub BUILD {
    my ($self, $params) = @_;

    $self->{'sq'} = Sid::Queue->new(queue => $params->{'queue'});
    $self->{'xdb'} = Search::Xapian::WritableDatabase->new( 
        $params->{'xapian'},
        Search::Xapian::DB_CREATE_OR_OPEN ) or
      Sid::Exception::Xapian->throw("can't create write-able xapian db object: $!");
   $self->{'sdump'} = Sid::Dump::Xapian->new;
}

sub process_add {
    my $self = shift;
    my %p = validate(@_,
        {
            data => { type => HASHREF },
        },
    );
    
    my ($type, $sidkey, $parent) = $self->_get_meta($p{'data'});

    # If I already have this sidkey, do a replace.  We have to do this
    # in case an agents get run more often than the updater does, and
    # potentially causes multiple add requests.
    my $enq = $self->xdb->enquire;
    $enq->set_query(Search::Xapian::Query->new("XSIDKEY" . lc($sidkey)));

    my @matches = $enq->matches(0, 1);
    if (scalar(@matches)) {
        return $self->process_replace(data => [$matches[0]->get_docid(), $p{'data'}]);
    }

    my $doc_id = $self->xdb->add_document($self->sdump->inflate_document($p{'data'}));

    $self->log->info("Added Document $doc_id, Type $type, Key $sidkey");

    $self->_update_schema_object(entity => $p{'data'});

    return $doc_id;
}

sub _update_schema_object {
    my $self = shift;
    my %p = validate(@_, 
        {
            entity => { type => HASHREF },
        },
    );

    return 1 if $p{'entity'}->{'type'} ne "entity";
    return 1 if !exists($p{'entity'}->{'data'}->{'entity'}->{'type'});

    my $schema = {};
    my $type = $p{'entity'}->{'data'}->{'entity'}->{'type'};
    my $entity = $p{'entity'};
    my @searchfields = sort(keys(%{$entity->{data}->{entity}->{fields}}));
    my @resultfields = sort(keys(%{$entity->{data}->{search}->{fields}}));

    my $enq = $self->xdb->enquire;
    $enq->set_query(Search::Xapian::Query->new("XSIDSCHEMAentity"));
    my @matches = $enq->matches(0, 1);
    my $doc_id;
    my $document;
    if (@matches) {
        $doc_id = $matches[0]->get_docid;
        $document = $matches[0]->get_document;
        $schema = Load($document->get_data);
    } else {
        $document = Search::Xapian::Document->new;
    }
    if (exists($schema->{$type})) {
        foreach my $field (@searchfields) {
            if (! exists($schema->{$type}->{search_fields}->{$field})) {
                $schema->{$type}->{search_fields}->{$field} = 1;
            }
        }
        foreach my $field (@resultfields) {
            if (! exists($schema->{$type}->{result_fields}->{$field})) {
                $schema->{$type}->{result_fields}->{$field} = 1;
            }
        }
    } else {
        my %searchmap = map { $_, 1 } @searchfields; 
        my %resultmap = map { $_, 1 } @resultfields; 
        $schema->{$type} = {
            search_fields => \%searchmap,
            result_fields => \%resultmap,
        };
    }
    $document->set_data(Dump($schema));
    if (defined($doc_id)) {
        $self->xdb->replace_document($doc_id, $document);
    } else {
        $document->add_term("XSIDSCHEMAentity");
        $self->xdb->add_document($document);
    } 
    return 1; 
}

sub process_replace {
    my $self = shift;
    my %p = validate(@_,
        {
            data => { type => ARRAYREF },
        },
    );

    my ($doc_id, $doc) = @{$p{'data'}};
    my ($type, $sidkey, $parent) = $self->_get_meta($doc);

    $self->xdb->replace_document($doc_id, $self->sdump->inflate_document($doc));
    $self->_update_schema_object(entity => $doc);
    $self->log->info("Replaced Document $doc_id, Type $type, Key $sidkey");

    return $doc_id;
}

sub process_remove {
    my $self = shift;
    my %p = validate(@_,
        {
            data => { type => SCALAR },
        },
    );

    my ($doc_id, $doc) = $self->_find_by_sidkey(sidkey => $p{'data'});
   
    if (defined($doc_id)) {
        $self->xdb->delete_document($doc_id);
        $self->log->info("Removed Document " . $p{'data'});

        # Delete any children of ours as well.
        my $enq = $self->xdb->enquire;
        $enq->set_query(Search::Xapian::Query->new("XSIDPARENT" . lc($p{'data'})));
        my @matches = $enq->matches(0, 100000);
        foreach my $match (@matches) {
            $self->process_remove(data => $match->get_value(1));
        }
    } 

    return $p{'data'};
}

sub _find_by_sidkey {
    my $self = shift;
    my %p = validate(@_,
        {
            sidkey => { type => SCALAR },
        },
    );

    my $enq = $self->xdb->enquire;
    $enq->set_query(Search::Xapian::Query->new("XSIDKEY" . lc($p{'sidkey'})));
    my @matches = $enq->matches(0, 1);
    if (scalar(@matches)) {
        return $matches[0]->get_docid, $matches[0];
    } else {
        return undef;
    }
}

sub do_job {
    my $self = shift;
    my $data = shift;

    my %tasks = (
        add => "process_add",
        remove => "process_remove",
        replace => "process_replace",
        unit_test => undef,
    );

    $data ||= $self->sq->dequeue;

    return undef unless defined $data;
   
    Sid::Exception::Updater->throw("Cannot do a job without a task!")
      unless exists($data->{'task'}); 
    Sid::Exception::Updater->throw("Cannot find a way to process this task: " . $data->{'task'}) unless exists($tasks{$data->{'task'}});

    my $sub = $tasks{$data->{'task'}}; 
    my $rv = $self->$sub(data => $data->{'data'});
    
    return $data->{'task'}, $rv;
}

sub wait_for_job {
    my $self = shift;
    my $interval = shift;

    $interval ||= 1;

    my $changes = 0;
    my $data;
    while ($data = $self->sq->wait_for_it($interval)) {
        $self->do_job($data);
        $changes = 1 unless $changes;
    }
    return $changes;
}

sub _get_meta {
    my $self = shift;
    my $doc = shift;

    return ($doc->{'type'}, $doc->{'key'});
}

sub flush {
    my $self = shift;
    $self->xdb->flush;
}

1;
