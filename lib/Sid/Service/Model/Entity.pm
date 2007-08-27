#
# Agent.pm
# Created by: Adam Jacob, Marchex, <adam@marchex.com>
#
# $Id: DB.pm,v 1.1.2.1 2006/07/07 02:23:11 adam Exp $

use strict;
use warnings;

package Sid::Service::Model::Entity;
use base qw/Catalyst::Model/;
use Params::Validate qw(:all);
use Sid::Exception;
use Search::Xapian::WritableDatabase;
use Search::Xapian;
use YAML::Syck;
use Exception::Class::TryCatch;
use Digest::MD5 qw(md5_base64);
use Data::Dump qw(dump);
use DBM::Deep;

__PACKAGE__->mk_accessors("_application");

*_app = *_application;

sub new {
    my $self = shift;
    my $app  = $_[0];
    my $new  = $self->NEXT::new(@_);
    $new->_application($app);
    return $new;
}

sub create {
    my $self = shift;
    my %p    = validate(
        @_,
        {
            'agent_id'  => { type => SCALAR, },
            'plugin_id' => { type => SCALAR, },
            'entity'    => { type => HASHREF, },
            'as_doc'    => { type => SCALAR, default => 0 },
        },
    );

    # We need to have these defined...
    Sid::Exception::InvalidArgument->throw(
        'Cannot create or update new Entity. Missing type in new entity data')
      unless defined $p{'entity'}->{'type'};
    Sid::Exception::InvalidArgument->throw(
'Cannot create or update new Entity. Missing primary_id in new entity data'
      )
      unless defined $p{'entity'}->{'primary_id'};

    my $sidkey = md5_base64($p{'agent_id'} . $p{'plugin_id'} . $p{'entity'}->{'type'} . $p{'entity'}->{'primary_id'});

    # Next, we need to create this entity's field and tag list 
    Sid::Exception::Create->throw(
        "Cannot create an entity with no fields!",
    ) unless exists($p{'entity'}->{'fields'});

    my %termlist;
    my %searchfields;
    my @rawterms;

    my $type = $p{'entity'}->{'type'};

    # First, all my own fields 
    foreach my $fieldkey (keys(%{$p{'entity'}->{'fields'}})) {
        my $fvarray = $p{'entity'}->{'fields'}->{$fieldkey};
        my $do_position = (scalar @{$fvarray} == 1) ? 0 : 1;
        for (my $x = 0; $x < scalar(@{$fvarray}); $x++) {
            my $fv = $fvarray->[$x];
            my $searchfield = "$fv->{'search_type'}:$fieldkey";
            # We should always have a tag that is our field name
            push(@{$fv->{'tags'}}, $fieldkey) unless grep(/^$fieldkey$/, @{$fv->{'tags'}});
            push(@{$searchfields{$searchfield}}, $fv->{'value'});
            if ($do_position) {
                my $pos = $x + 1;
                my $tag = $fieldkey . $pos;
                push(@{$searchfields{$searchfield . $pos}}, $fv->{'value'});
                # And optionally, a positional tag
                push(@{$fv->{'tags'}}, $fieldkey . $pos) unless grep(/^$tag$/, @{$fv->{'tags'}});
            }
        } 
        my @bobo = @{$fvarray};
        $termlist{$fieldkey} = \@bobo;
        push(@rawterms, $fieldkey);
    }
    $termlist{'type'} = [ 
        { value => $p{'entity'}->{'type'}, tags => [ 'type' ], }
    ];
    $termlist{'agent'} = [
        { value => $p{'agent_id'}, tags => [ 'agent' ], },
    ];
    $termlist{'plugin'} = [
        { value => $p{'plugin_id'}, tags => [ 'plugin' ], },
    ];

    # Finally, update the entity itself
    my $entity_obj = $p{'entity'};
    my $search_obj = {
        agent_id => $p{'agent_id'},
        plugin_id => $p{'plugin_id'},
        primary_id => $p{'entity'}->{'primary_id'},
        type => $type,
        fields => \%searchfields,
    };

    my $update_obj = {
        key => $sidkey,
        type => 'entity',
        terms => \%termlist,
        data => {
            search => $search_obj,
            entity => $entity_obj,
            agent_id => $p{'agent_id'},
            plugin_id => $p{'plugin_id'},
        },
        raw_terms => \@rawterms,
    };
    my ($doc_id, $entity) = $self->_app->model('Xapian')->update_or_create(
        $update_obj,
    );
    Sid::Exception::Create->throw(
        "Cannot create this Entity.  Database Error.")
      unless defined $entity;

    return ($doc_id, $entity) if $p{'as_doc'} == 1;
    return 1 if $p{'as_doc'} == 0;
}

# The update method is actually just the create method by another name
*update = *create;

sub get {
    my $self = shift;
    my %p    = validate(
        @_,
        {
            agent_id    => { type => SCALAR, optional => 1 },
            plugin_id   => { type => SCALAR, optional => 1 },
            entity_type => { type => SCALAR, optional => 1 },
            primary_id  => { type => SCALAR, optional => 1 },
            entity      => { type => HASHREF, optional => 1 },
        },
    );

    my $entity;
    if ( exists( $p{'entity'} ) ) {
        $entity = $p{'entity'};
    } else {
        # We need to have these defined...
        Sid::Exception::InvalidArgument->throw(
            'Cannot get Entity. Missing agent_id.')
          unless defined $p{'agent_id'};
        Sid::Exception::InvalidArgument->throw(
            'Cannot get Entity. Missing plugin_id.')
          unless defined $p{'plugin_id'};
        Sid::Exception::InvalidArgument->throw(
            'Cannot get Entity. Missing entity_type.')
          unless defined $p{'entity_type'};
        Sid::Exception::InvalidArgument->throw(
            'Cannot get Entity. Missing primary_id.')
          unless defined $p{'primary_id'};

        my $tentity = $self->_app->model('Xapian')->find(
            key => md5_base64($p{'agent_id'} . $p{'plugin_id'} . $p{'entity_type'} . $p{'primary_id'}),
            type => 'entity'
        );
        Sid::Exception::Get->throw('Could not find Entity!')
          unless defined $tentity;
        $entity = $tentity->{'entity'};
    }

    return $entity;
}

sub remove {
    my $self = shift;
    my %p    = validate(
        @_,
        {
            agent_id    => { type => SCALAR, optional => 1 },
            plugin_id   => { type => SCALAR, optional => 1 },
            entity_type => { type => SCALAR, optional => 1 },
            primary_id  => { type => SCALAR, optional => 1 },
            sidkey => { type => SCALAR, optional => 1 },
        },
    );

    my $sidkey;

    if ( defined( $p{'sidkey'} ) ) {
        $sidkey = $p{'sidkey'};
    } else {
        $sidkey = md5_base64($p{'agent_id'} . $p{'plugin_id'} . $p{'entity_type'} . $p{'primary_id'});
    }
    $self->_app->model('Xapian')->remove_document(
        key => $sidkey,
    );

    return 1;
}

sub search {
    my $self = shift;
    my %p    = validate(
        @_,
        {
            query  => { type => SCALAR, },
            fields => { type => ARRAYREF, optional => 1 },
            num_per => { type => SCALAR, optional => 1 },
            page   => { type => SCALAR, optional => 1 },
        }
    );

    my $args = {
        query => $p{'query'},
    };
    $args->{num_per} = $p{'num_per'} if exists ($p{'num_per'});
    $args->{page} = $p{'page'} if exists ($p{'page'});

    my ($search, $page) =
      $self->_app->model('Xapian')->search( $args );

    my @response;

    if ( exists( $p{'fields'} ) ) {
        my %field_test;
        foreach my $f ( @{ $p{'fields'} } ) {
            $field_test{$f} = 1;
        }
        my @todel;
        for ( my $x = 0; $x < scalar( @{$search} ); $x++ ) {

            # Unless the key we want is in the search field, delete it!
            foreach my $key ( keys( %{ $search->[$x]->{'search'}->{'fields'} } ) ) {
                unless ( exists( $field_test{$key} ) ) {
                    delete( $search->[$x]->{'search'}->{'fields'}->{$key} );
                }
            }
            push(@response, $search->[$x]->{'search'});
        }
    } else {
        foreach my $entity (@{$search}) {
            push(@response, $entity->{'search'});
        }
    }
    return \@response, $page;
}

1;

