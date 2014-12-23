use strict;
use warnings;
use Test::Roo;
use Test::FailWarnings;
use Test::Fatal;
use Test::Requires qw/MongoDB/;

my $conn = eval { MongoDB::MongoClient->new; };
plan skip_all => "No MongoDB on localhost" unless $conn;

use lib 't/lib';

with 'TestFixtures';

sub _build_meerkat_options {
    my ($self) = @_;
    return {
        model_namespace          => 'My::Model',
        default_collection_class => 'My::DefaultCollection',
        database_name            => 'test',
    };
}

test 'default collection' => sub {
    my $self   = shift;
    my $person = $self->person;
    isa_ok( $person, "My::DefaultCollection" );
    ok( my $obj1 = $self->create_person, "created person" );
    ok( my $obj2 = $person->find_name( $obj1->name ), "searched by custom query" );
    is_deeply( $obj1, $obj2, "objects are the same" );
};

run_me;
done_testing;
# COPYRIGHT
# vim: ts=4 sts=4 sw=4 et:
