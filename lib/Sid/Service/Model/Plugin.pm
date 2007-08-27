#
# Plugin.pm
# Created by: Adam Jacob, Marchex, <adam@marchex.com>
#
# $Id: DB.pm,v 1.1.2.1 2006/07/07 02:23:11 adam Exp $

use strict;
use warnings;

package Sid::Service::Model::Plugin;
use base qw/Catalyst::Model/;
use Params::Validate qw(:all);
use Sid::Exception;
use Digest::MD5 qw(md5_base64);

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
    my %p    = validate( @_, { 'plugin' => { type => HASHREF, }, }, );

    Sid::Exception::InvalidArgument->throw(
        'Cannot create new Plugin. Missing agent_id in new plugin data')
      unless defined $p{'plugin'}->{'agent_id'};
    Sid::Exception::InvalidArgument->throw(
        'Cannot create new Plugin. Missing plugin_id in new plugin data')
      unless defined $p{'plugin'}->{'plugin_id'};

     $self->_app->model('Xapian')->update_or_create(
        key => md5_base64($p{'plugin'}->{'agent_id'} . $p{'plugin'}->{'plugin_id'}),
        type => 'plugin',
        data => {
            agent_id  => $p{'plugin'}->{'agent_id'},
            plugin_id => $p{'plugin'}->{'plugin_id'},
        },
        terms => {
            agent  => $p{'plugin'}->{'agent_id'},
            plugin => $p{'plugin'}->{'plugin_id'},
        }
    );

    if ( exists( $p{'plugin'}->{'entities'} ) ) {
        # Get a list of current entities
        my $current_entities = $self->_app->model('Xapian')->search(
            query => 'sidtype:entity AND plugin:"' . $p{'plugin'}->{'plugin_id'} . '" AND agent:"' . $p{'plugin'}->{'agent_id'} . '"',
            as_doc => 1,
        );

        my %seenentity;
        # Update/create all our new entities
        ENTITY: foreach my $entity ( @{ $p{'plugin'}->{'entities'} } ) {
            $seenentity{$entity} = 1;
        }

        # Delete all the entities we did not update
        OE: foreach my $oe (@{$current_entities}) {
            my ($oe_doc_id, $oe_doc) = @{$oe};
            next OE if $seenentity{$oe_doc->get_value(1)};
            $self->_app->model('Entity')->remove(
                sidkey => $oe_doc->get_value(1),
            );
        }
    }
    return 1;
}

*update = *create;

sub get {
    my $self = shift;
    my %p    = validate(
        @_,
        {
            agent_id  => { type => SCALAR, optional => 1 },
            plugin_id => { type => SCALAR, optional => 1 },
            plugin    => { type => HASHREF, optional => 1 },
        },
    );

    my $plugin = $p{'plugin'} || $self->_app->model('Xapian')->find(
        key => md5_base64($p{'agent_id'} . $p{'plugin_id'}),
        type => 'plugin',
    );
    Sid::Exception::Get->throw(
'Cannot get Plugin. Missing agent_id and plugin_id, or did not pass a plugin'
      )
      unless defined $plugin;

    my $response = {
        agent_id  => $plugin->{'agent_id'},
        plugin_id => $plugin->{'plugin_id'},
        entities  => [],
    };
    my $entities = $self->_app->model('Xapian')->search(
        query => 'agent:"' . $plugin->{'agent_id'} . '" AND plugin:"' . $plugin->{'plugin_id'} . '" AND sidtype:entity',
    );
    foreach my $eobj (@{$entities}) {
        my $e = $eobj->{'entity'};
        push(
            @{ $response->{'entities'} },
            { type => $e->{'type'}, primary_id => $e->{'primary_id'} }
        );
    }
    return $response;
}

sub remove {
    my $self = shift;
    my %p    = validate(
        @_,
        {
            agent_id  => { type => SCALAR, optional => 1 },
            plugin_id => { type => SCALAR, optional => 1 },
            plugin    => { type => HASHREF, optional => 1 },
        },
    );

    if ( exists( $p{'plugin'} ) ) {
        $p{'agent_id'} = $p{'plugin'}->{'agent_id'};
        $p{'plugin_id'} = $p{'plugin'}->{'plugin_id'};
    } 

    Sid::Exception::Delete->throw("Cannot find Plugin to delete")
        unless exists($p{'agent_id'}) && exists($p{'plugin_id'});

    my $return = $self->get(agent_id => $p{'agent_id'}, plugin_id => $p{'plugin_id'});

    $self->_app->model('Xapian')->remove_document(
        key => md5_base64($p{'agent_id'} . $p{'plugin_id'}),
    );

    my $deleted = $self->_app->model('Xapian')->search_and_remove(
        query => 'plugin:"' . $p{'plugin_id'} . '" and sidtype:entity',
    );

    return 1; 
}

1;

