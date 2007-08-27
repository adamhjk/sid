use Test::More tests => 6;
use FindBin;
use Data::Dump qw(dump);

use lib ("$FindBin::Bin/../lib");

use strict;
use warnings;

use_ok('Sid::Queue');

my $sq = Sid::Queue->new( queue => "$FindBin::Bin/queue", );
isa_ok( $sq, 'Sid::Queue' );

my $one = $sq->enqueue( task => 'unit_test', data => { 'monkey' => 'eats' } );
is( $one, 1, "Enqueued data" );

my $dtmp = {
    data => { monkey => "eats", },
    task => "unit_test",
};
my $data = $sq->dequeue;
is_deeply( $data, $dtmp, "Dequeued data" );

my $two = $sq->enqueue( task => 'unit_test', data => { 'monkey' => 'eats' } );
is( $two, 1, "Enqueued more data" );

my $odata = $sq->wait_for_it;
is_deeply( $odata, $dtmp, "Waited properly for more data" );
