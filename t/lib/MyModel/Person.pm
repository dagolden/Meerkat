package MyModel::Person;

use Moose 2;
use Meerkat::Types qw/:all/;

with 'Meerkat::Role::Document';

has name => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has birthday => (
    is       => 'ro',
    isa      => MeerkatDateTime,
    coerce   => 1,
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

sub _indexes {
    return ( [ { unique => 1 }, name => 1 ], [ tags => 1, likes => 1 ], );
}

1;
