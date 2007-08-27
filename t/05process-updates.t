use Test::More tests => 3;
use FindBin;
use Data::Dump qw(dump);

use lib ("$FindBin::Bin/../lib");

use strict;
use warnings;

use_ok('Sid::Updater');

my $su = Sid::Updater->new( 
    queue => "$FindBin::Bin/queue",
    xapian => "$FindBin::Bin/xapian-db",
);
isa_ok( $su, 'Sid::Updater' );

my $x = 0;
my $changes;
LOOP: while($x != 10) {
    $changes = $su->wait_for_job(1);
    if ($changes) {
        print "Doing flush\n";
        $su->flush;
        last LOOP;
    }
    $x++;
}
ok(defined($changes), "Had changes to process");
