use strict;
use warnings;
use Test::Roo;
use Test::FailWarnings;
use Test::Fatal;
use Test::Requires qw/MongoDB/;

my $conn = eval { MongoDB::MongoClient->new; };
plan skip_all => "No MongoDB on localhost"
  unless eval { $conn->get_database("admin")->run_command( [ ismaster => 1 ] ) };

use lib 't/lib';

with 'TestFixtures';

sub _build_meerkat_options {
    my ($self) = @_;
    return {
        model_namespace      => 'My::Model',
        collection_namespace => 'Bad::Collection',
        database_name        => 'test',
    };
}

test 'meerkat will propogate custom collection errors' => sub {
    my $self = shift;

    my $err = exception { $self->meerkat->collection('Doom') };
    like(
        $err,
        qr/This attribute will blow up on construction/,
        "Caught error from custom collection object"
    );

    my $coll;
    $err = exception { $coll = $self->meerkat->collection('Person') };
    ok( !$err, 'No exception when custom collection package is missing' );
    isa_ok( $coll, 'Meerkat::Collection' );
};

run_me;
done_testing;
# COPYRIGHT
# vim: ts=4 sts=4 sw=4 et:
