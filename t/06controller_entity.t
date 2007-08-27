use strict;
use warnings;
use FindBin;
use lib ( "$FindBin::Bin/../lib", "$FindBin::Bin/lib" );
use Test::More qw(no_plan);
use Test::Rest;
use Data::Dump qw(dump);

$ENV{CATALYST_HOME} = "$FindBin::Bin";

use_ok 'Catalyst::Test', 'Sid::Service';
use_ok 'Sid::Service::Controller::Agent';

my $t = Test::Rest->new( content_type => 'text/x-yaml' );

my $agent_id  = "unit_test";
my $plugin_id = "unit_test_plugin";
my $type = "unit";
my $primary_id = "test";

# GET to /agent/(agent_id)/(plugin_id)/(type)/(primary_id) 
#   returns the entity
my $eg_res = request(
    $t->get(
        url  => "/agent/$agent_id/$plugin_id/$type/$primary_id" ,
    )
);
ok($eg_res->is_success, "Got the entity that I created in the first place");

