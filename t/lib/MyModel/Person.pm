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

1;
