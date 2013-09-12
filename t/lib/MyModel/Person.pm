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

has slang => (
    is      => 'ro',
    isa     => 'HashRef',
    default => sub { {} },
);

1;
