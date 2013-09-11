use strict;
use warnings;
use Test::Roo;
use Test::FailWarnings;
use Test::Fatal;
use Test::Requires qw/MongoDB::MongoClient/;

my $conn = eval { MongoDB::MongoClient->new; };
plan skip_all => "No MongoDB on localhost" unless $conn;

use lib 't/lib';

with 'TestFixtures';

test 'update_set' => sub {
    my $self = shift;
    my $obj  = $self->create_person;
    $obj->update_set( name => "Larry Wall" );
    is( $obj->name, "Larry Wall", "attribute set in object" );
    my $got = $self->person->find_id( $obj->_id );
    is( $got->name, "Larry Wall", "attribute set in DB" );
};

run_me;
done_testing;
# COPYRIGHT
# vim: ts=4 sts=4 sw=4 et:
