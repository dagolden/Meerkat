use strict;
use warnings;
use Test::More;
use Test::FailWarnings;
use Test::Requires qw/MongoDB::MongoClient/;

my $conn = eval { MongoDB::MongoClient->new; };
plan skip_all => "No MongoDB on localhost" unless $conn;

use Config;
use Data::Faker qw/Name/;
use Meerkat;
use Parallel::Iterator qw/iterate/;

plan skip_all => "Requires forking"
  unless $Config{d_fork};

use lib 't/lib';

my $faker = Data::Faker->new;

my $options = {
    namespace     => 'MyModel',
    database_name => 'test',
};

my $mk     = Meerkat->new($options);
my $person = $mk->collection("Person");

ok( !$mk->_has_mongo_client, "_mongo_client is lazy (not set)" );
$person->_mongo_collection->drop; # clear before testing
ok( $person->create( name => $faker->name, birthday => time ),
    "created a document" );
ok( $mk->_has_mongo_client, "_mongo_client is now set" );

my $num_forks = 3;
my $iter      = iterate(
    sub {
        my ( $id, $job ) = @_;
        $person->create( name => $faker->name, birthday => time );
        return {
            pid        => $$,
            cached_pid => $mk->_pid,
        };
    },
    [ 1 .. $num_forks ],
);

while ( my ( $index, $value ) = $iter->() ) {
    isnt( $value->{cached_pid}, $$, "child $index updated cached pid" )
      or diag explain $value;
}

is( $person->count, $num_forks + 1, "children created $num_forks objects" );

done_testing;
# COPYRIGHT
# vim: ts=4 sts=4 sw=4 et:
