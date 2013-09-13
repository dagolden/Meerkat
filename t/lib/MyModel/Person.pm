package MyModel::Person;

use Moose 2;

with 'Meerkat::Role::Document';

has name => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has likes => (
    is      => 'ro',
    isa     => 'Num',
    default => 0,
);

has tags => (
    is      => 'ro',
    isa     => 'ArrayRef',
    default => sub { [] },
);

has parents => (
    is      => 'ro',
    isa     => 'HashRef',
    default => sub { {} },
);

has birthday => (
    is  => 'ro',
    isa => 'DateTime',
);

sub _indexes {
    return ( [ { unique => 1 }, name => 1 ], [ tags => 1, likes => 1 ], );
}

1;
