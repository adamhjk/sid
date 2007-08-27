#
# Queue.pm
# Created by: Adam Jacob, Marchex, <adam@marchex.com>
#
# $Id: DB.pm,v 1.1.2.1 2006/07/07 02:23:11 adam Exp $

use strict;
use warnings;

package Sid::Service::Model::Queue;
use base qw/Catalyst::Model/;
use Sid::Queue;

__PACKAGE__->mk_accessors( "_application", "dq" );

*_app = *_application;

sub new {
    my $self = shift;
    my $app  = $_[0];
    my $new  = $self->NEXT::new(@_);
    $new->_application($app);
    $new->dq(Sid::Queue->new(queue => $app->path_to('queue')->stringify));
    return $new;
}

sub AUTOLOAD {
    my $self = shift;

    (my $method) = (our $AUTOLOAD =~ /([^:]+)$/);

    if ($method eq "DESTROY") {
        return;
    }
    $self->dq->$method(@_);
}

1;

