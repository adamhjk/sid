#!/usr/bin/perl
#
# Sid::Plugin::Script
#
# $Id$
#

package Sid::Plugin::Script;

use Moose;
use Params::Validate qw(:all);
use YAML::Syck;
use Sid::Entity;
use Sid::Client;
use Data::Dump qw(dump);
use DBM::Deep;
use File::Basename;

has 'run_data'  => ( is => 'rw', default => sub { [] });
has 'run_track' => ( is => 'rw', isa => 'HashRef', default => sub { {} });
has 'agent_id'  => ( is => 'rw', isa => 'Str', );
has 'plugin_id' => ( is => 'rw', isa => 'Str', );
has 'server' => ( is => 'rw', isa => 'Str', );
has 'tmpdir' => (is => 'rw', isa => 'Str', );
has 'tmpfile' => (is => 'rw', isa => 'Str', );

sub BUILD {
    my ( $self, $params ) = @_;

    die "Call as '$0 agent_id plugin_id server'; missing arguments."
      unless $ARGV[0] && $ARGV[1] && $ARGV[2];
    
    $self->agent_id( $ARGV[0] );
    $self->plugin_id( $ARGV[1] );
    $self->server($ARGV[2]);
    if ($ARGV[3]) {
        $self->tmpdir($ARGV[3]);
    } else {
        $self->tmpdir("/tmp");
    }
    $self->tmpfile($self->tmpdir . "/sid-plugin-script-" . basename($0));
    if (-f $self->tmpfile) {
        unlink($self->tmpfile);
    }
    my $db = DBM::Deep->new(
       file => $self->tmpdir . "/sid-plugin-script-" . basename($0),
       type => DBM::Deep->TYPE_ARRAY,
       locking => 1,
    ); 
    $self->run_data($db);

    if ( exists( $params->{'fh'} ) ) {
        $self->_load_data( $params->{'fh'} );
    } else {
        select((select(STDIN), $| = 1)[0]);
        select((select(STDOUT), $| = 1)[0]);
        select((select(STDERR), $| = 1)[0]);        
        $self->_load_data(*STDIN);
    }
    return $self;
}

sub _load_data {
    my $self = shift;
    my $fh   = shift;

    my $input;
    while (<$fh>) {
        $input .= $_;
    }
    die "You must provide some YAML on STDIN!" unless defined $input;
    my $entities = Load($input);
    foreach my $entity (@{$entities}) {
        my $se = Sid::Entity->new(
            agent_id => $self->agent_id,
            plugin_id => $self->plugin_id,
            type => $entity->{'type'},
            primary_id => $entity->{'primary_id'},
            fields => $entity->{'fields'},
            parent => $entity->{'parent'},
            tags => $entity->{'tags'},
        );
        $self->add_entity(entity => $se);
    }
    return $self->run_data;
}

sub new_entity {
    my $self = shift;
    my %p    = validate(
        @_,
        {
            type       => { type => SCALAR },
            primary_id => { type => SCALAR },
        }
    );

    return Sid::Entity->new(
        agent_id => $self->agent_id,
        plugin_id => $self->plugin_id,
        type => $p{'type'},
        primary_id => $p{'primary_id'},
    );
}

sub find_entity {
    my $self = shift;
    my %p = validate(
        @_,
        {
            agent_id => { type => SCALAR, optional => 1 },
            plugin_id => { type => SCALAR, optional => 1 },
            type => { type => SCALAR },
            primary_id => { type => SCALAR },
        },
    );

    $p{'agent_id'} ||= $self->agent_id;
    $p{'plugin_id'} ||= $self->plugin_id;

    my $return_entity = undef;
    if ($p{'agent_id'} eq $self->agent_id && $p{'plugin_id'} eq $self->plugin_id) {
        foreach my $entity_yaml (@{$self->run_data}) {
            my $entity = Load($entity_yaml);
            if ($entity->type eq $p{'type'} and $entity->primary_id eq $p{'primary_id'}) {
                $return_entity = $entity;
            }
        }
    }

    return $return_entity; 
}

sub add_entity {
    my $self = shift;
    my %p = validate(
        @_,
        {
            entity => { type => OBJECT, },
        },
    );

    push(@{$self->run_data}, Dump($p{'entity'})); 
    my $slot = scalar(@{$self->run_data}) - 1;
    $self->run_track->{$p{'entity'}->type}->{$p{'entity'}->primary_id} = $slot;
    return scalar(@{$self->run_data}) - 1; 
}

sub add_entity_from_hash {
    my $self = shift;
    my %p = validate(
        @_,
        {
            type => { type => SCALAR, },
            entities => { type => HASHREF, },
            parent => { type => OBJECT, optional => 1 },
        },
    );

    foreach my $primary_id ( keys(%{$p{'entities'}})) {
        my $entity = $self->new_entity(
            type       => $p{'type'},
            primary_id => $primary_id,
        );
        $entity->set_parent( entity => $p{'parent'} ) if exists($p{'parent'});

        my $edata = $p{'entities'}->{$primary_id};
        foreach my $field ( keys( %{ $edata } ) ) {
            if ( ref( $edata->{$field} ) eq "ARRAY" ) {
                $entity->add_field(
                    field => $field,
                    value => $_,
                ) foreach ( @{ $edata->{$field} } );
            } else {
                $entity->add_field(
                    field => $field,
                    value => $edata->{$field},
                );
            }
        }
        $self->add_entity(entity => $entity);
    }
    return 1;
}

sub update_entity {
    my $self = shift;
    my %p = validate(
        @_,
        {
            entity => { type => OBJECT, },
        },
    );

    if (exists($self->run_track->{$p{'entity'}->type}->{$p{'entity'}->primary_id})) {
        my $slot = $self->run_track->{$p{'entity'}->type}->{$p{'entity'}->primary_id};
        $self->run_data->[$slot] = Dump($p{'entity'});
        return 1;
    } else {
        $self->add_entity(entity => $p{'entity'});
        return 1;
    }
    return 0;
}

sub cat_file {
    my $self = shift;
    my %p = validate(
        @_,
        {
            file => { type => SCALAR, },
            do_chomp => { type => SCALAR, default => 0 },
        },
    );

    return undef unless -f $p{'file'};
    my $result = "";
    open(FILE, "<", $p{'file'}) or die "Can't open $p{'file'}!";
    while (<FILE>) {
        $result .= $_;
    }
    close(FILE);
    if ($p{'do_chomp'}) {
        chomp($result);
    }
    return $result;
}

sub run_command {
    my $self = shift;
    my %p = validate(
        @_,
        {
            command => { type => SCALAR | ARRAYREF, },
        },
    );
    my $output;

    if (ref($p{'command'}) eq "ARRAY") {
        open(COMMAND, "-|", @{$p{'command'}}) or die "Can't run $p{'command'}: $!";
    } else {
        open(COMMAND, "-|", "$p{'command'}") or die "Can't run $p{'command'}: $!";
    }
    while (my $line = <COMMAND>) {
        $output .= $line;
    }
    close(COMMAND);

    return $output;
}

sub output {
    my $self = shift;
    my %p = validate(
        @_,
        {
            fh => { type => GLOBREF, optional => 1 },
        }
    );

    my $fh;
    if (exists($p{'fh'})) {
        $fh = $p{'fh'};
    } else {
        $fh = *STDOUT;
    }
    my $data = [];
    foreach my $entity_yaml (@{$self->run_data}) {
        my $entity = Load($entity_yaml);
        push(@{$data}, $entity->prepare);
    }
    print $fh Dump( $data );
    return 1;
}

sub exit_zero {
    my $self = shift;
    $self->output;
    exit 0;
}

sub DESTROY {
    my $self = shift;
    unlink($self->tmpfile) if -f $self->tmpfile;
}

1;
