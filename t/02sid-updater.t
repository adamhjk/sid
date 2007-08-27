use Test::More qw(no_plan);
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

# process_add - adds a new document
my $new_id = $su->process_add(
    data => &get_doc,
);
ok(defined($new_id), "Added document");

# process_replace - replace a document
my $old_id = $su->process_replace(
    data => [ $new_id, &get_doc ],
);
ok(defined($old_id), "Replaced document");

# process_remove - remove a document
my $dead_id = $su->process_remove(
    data => $new_id,
);
ok(defined($dead_id), "Removed document");

sub get_doc {
    my $doc = {
        data => {
            agent_id    => "unit_test",
            description => "Sid Agent",
          },
        key => "unit_test",
        raw_terms => [],
        terms => {
            agent_id    => "unit_test",
            description => "Sid Agent",
        },
        type => "agent",
    };

    return $doc; 
}

