# COPYRIGHTuse strict;
use warnings;
use Test::Roo;
use Test::Deep '!blessed';
use Test::FailWarnings;
use Test::Fatal;
use Test::Requires qw/MongoDB::MongoClient/;

use DateTime;

my $conn = eval { MongoDB::MongoClient->new; };
plan skip_all => "No MongoDB on localhost" unless $conn;

use lib 't/lib';

with 'TestFixtures';

test 'datetime field' => sub {
    my $self = shift;
    my $obj  = $self->create_person;
    my $birthday =
      DateTime->new( year => 1973, month => 7, day => 16, time_zone => "UTC" );
    $obj->update_set( birthday => $birthday );
    is( $obj->birthday->ymd, $birthday->ymd, "attribute set" );
};

run_me;
done_testing;
# COPYRIGHT
# vim: ts=4 sts=4 sw=4 et:
# vim: ts=4 sts=4 sw=4 et:
