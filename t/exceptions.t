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

test 'array ops on non array field' => sub {
    my $self = shift;
    my $obj  = $self->create_person;

    my %got;
    $got{'push'} = exception { $obj->update_push( 'name', qw/foo bar/ ) };
    $got{'add'}    = exception { $obj->update_add( 'name', qw/foo bar/ ) };
    $got{'pop'}    = exception { $obj->update_pop('name') };
    $got{'shift'}  = exception { $obj->update_shift('name') };
    $got{'remove'} = exception { $obj->update_remove( 'name', qw/foo bar/ ) };
    $got{'clear'}  = exception { $obj->update_clear('name') };

    for my $op ( sort keys %got ) {
        like(
            $got{$op},
            qr/Can't use update_$op on non-arrayref field 'name'/,
            "update_$op on non-arrayref field exception"
        );
    }
};

test 'array ops on deep non array field' => sub {
    my $self = shift;
    my $obj  = $self->create_person;

    my $got = exception { $obj->update_push( 'parents.birth', qw/foo bar/ ) };

    like(
        $got,
        qr/Can't use update_push on non-arrayref field 'parents\.birth'/,
        "update_push on deep non-arrayref field exception"
    );
};

run_me;
done_testing;
# COPYRIGHT
# vim: ts=4 sts=4 sw=4 et:
