#
# Document.pm
# Created by: Adam Jacob, Marchex, <adam@marchex.com>
#
# $Id: DB.pm,v 1.1.2.1 2006/07/07 02:23:11 adam Exp $

use strict;
use warnings;

package Sid::Service::Model::Xapian::Document;
use base qw/Sid::Service::Model::Xapian/;
use Params::Validate qw(:all);
use Sid::Exception;

sub get {
    my $self = shift;
    my %p = validate( @_, { document_id => { type => SCALAR }, } );
}

1;

