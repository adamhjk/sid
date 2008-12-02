#
# Sid::Exception
#
# $Id: Exception.pm,v 1.1 2006/09/24 09:25:21 adam Exp $
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

