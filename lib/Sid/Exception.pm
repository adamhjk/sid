#
# Sid::Exception
#
# $Id: Exception.pm,v 1.1 2006/09/24 09:25:21 adam Exp $

package Sid::Exception;

use strict;
use warnings;

use Exception::Class (

    'Sid::Exception::Generic' =>
      { description => 'Had a problem doing something... random', },

    'Sid::Exception::InvalidArgument' => {
        description => 'Had a problem with my arguments',
        isa         => 'Sid::Exception::Generic',
    },
    'Sid::Exception::Create' => {
        description => 'Had a problem creating something',
        isa         => 'Sid::Exception::Generic',
    },
    'Sid::Exception::Get' => {
        description => 'Had a problem getting something',
        isa         => 'Sid::Exception::Generic',
    },
    'Sid::Exception::Update' => {
        description => 'Had a problem updating something',
        isa         => 'Sid::Exception::Generic',
    },
    'Sid::Exception::Delete' => {
        description => 'Had a problem deleting something',
        isa         => 'Sid::Exception::Generic',
    },
    'Sid::Exception::Xapian' => {
        description => 'Had a problem with Xapian',
        isa         => 'Sid::Exception::Generic',
    },
    'Sid::Exception::Client' => {
        description => 'Had a problem talking to the Server',
        isa         => 'Sid::Exception::Generic',
    },
    'Sid::Exception::Format' => {
        description => 'Had a problem formatting something!',
        isa         => 'Sid::Exception::Generic',
    },
    'Sid::Exception::File' => {
        description => 'Had a problem dealing with a file!',
        isa         => 'Sid::Exception::Generic',
    },
    'Sid::Exception::Updater' => {
        description => 'Had a problem Updating my index!',
        isa         => 'Sid::Exception::Generic',
    },

);

1;

