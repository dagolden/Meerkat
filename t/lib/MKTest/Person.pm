use 5.008001;
use strict;
use warnings;

package MKTest::Person;
# ABSTRACT: goes here
# VERSION

use Moose 2;
use MooseX::AttributeShortcuts;
use Data::Faker qw/Name/;
use namespace::autoclean;

with 'Meerkat::Role::Document';

has name => (
    is      => 'ro',
    isa     => 'Str',
    default => sub { Data::Faker->new->name },
);

has likes => (
    is => 'ro',
    isa => 'Num',
    default => 0,
);

__PACKAGE__->meta->make_immutable;

1;

