#
# Sid::Web::Model::Sid.pm
# Created by: Adam Jacob, Marchex, <adam@marchex.com>
# Created on: 12/07/2006 12:40:51 PM PST
#
# $Id: $

package Sid::Web::Model::Sid;
use strict;
use warnings;

use base 'Catalyst::Model';
use Sid::Client;
use Catalyst::Utils;
use Data::Dump qw(dump);

sub new {
    my ($self, $c, $arguments) = @_;
    my $self = shift->NEXT::new(@_);

    $self->{'_sid-client'} = Sid::Client->new(Catalyst::Utils::merge_hashes($arguments, $self->config));

    return $self;
}

sub ACCEPT_CONTEXT {
    my ($self) = @_;
    return $self->{'_sid-client'};
}

1;

