use strict;
use warnings;
use Test::Roo;
use Test::FailWarnings;
use Test::Deep '!blessed';
use Test::Fatal;
use Test::Requires qw/MongoDB::MongoClient/;

my $conn = eval { MongoDB::MongoClient->new; };
plan skip_all => "No MongoDB on localhost" unless $conn;

use lib 't/lib';

with 'TestFixtures';

test 'bad sync' => sub {
    my $self = shift;
    my $obj  = $self->create_person;
    my $copy = $self->person->find_id( $obj->_id );

    # intentionally create a bad document
    $self->person->_mongo_collection->update( { _id => $obj->_id }, { name => [] } );

    like(
        exception { $obj->sync },
        qr/Could not inflate updated document/,
        "syncing a bad document threw an exception"
    );
    cmp_deeply( $obj, $copy, "object is unchanged" );
};

test 'update_set must be on scalar or undef' => sub {
    my $self = shift;
    my $obj  = $self->create_person;

    # payload starts undef
    $self->pass_update( update_set => $obj, payload => 'foo' );
    # then payload has a scalar value
    $self->pass_update( update_set => $obj, payload => 'bar' );

    $self->fail_update( update_set => $obj, tags    => 'foo' );
    $self->fail_update( update_set => $obj, parents => 'foo' );
};

test 'update_push/add must be on undef or ARRAY' => sub {
    my $self = shift;

    for my $op (qw/update_push update_add/) {
        my $obj = $self->create_person;
        # payload starts undef
        $self->pass_update( $op => $obj, payload => 'foo' );
        # then payload has a ARRAY
        $self->pass_update( $op => $obj, payload => 'bar' );

        # name is scalar
        $self->fail_update( $op => $obj, name => 'foo' );
        # parents is hash
        $self->fail_update( $op => $obj, parents => 'foo' );
    }
};

test 'update_pop/shift must be on undef or ARRAY' => sub {
    my $self = shift;

    for my $op (qw/update_pop update_shift /) {
        my $obj = $self->create_person;
        # payload starts undef
        $self->pass_update( $op => $obj, 'payload' );
        # then push on a value
        $obj->update_push( payload => 'foo' );
        # then payload has a ARRAY
        $self->pass_update( $op => $obj, 'payload' );

        # name is scalar
        $self->fail_update( $op => $obj, 'name' );
        # parents is hash
        $self->fail_update( $op => $obj, 'parents' );
    }
};

test 'update_remove must be on undef or ARRAY' => sub {
    my $self = shift;

    for my $op (qw/update_remove/) {
        my $obj = $self->create_person;
        # payload starts undef
        $self->pass_update( $op => $obj, payload => 'foo' );
        # then push on a value
        $obj->update_push( payload => 'foo' );
        # then payload has a ARRAY
        $self->pass_update( $op => $obj, payload => 'bar' );

        # name is scalar
        $self->fail_update( $op => $obj, name => 'foo' );
        # parents is hash
        $self->fail_update( $op => $obj, parents => 'foo' );
    }
};

test 'update_clear works on undef, scalar, ARRAY or HASH' => sub {
    my $self = shift;

    for my $op (qw/update_clear/) {
        my $obj = $self->create_person;
        # payload starts undef
        $self->pass_update( $op => $obj, 'payload' );
        # then set a value
        $obj->update_set( payload => 'foo' );
        # then payload has a scalar
        $self->pass_update( $op => $obj, 'payload' );
        # tags is array
        $self->pass_update( $op => $obj, 'tags' );
        # parents is hash
        $self->pass_update( $op => $obj, 'parents' );
    }
};

run_me;
done_testing;
# COPYRIGHT
# vim: ts=4 sts=4 sw=4 et:
