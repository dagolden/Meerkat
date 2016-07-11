use strict;
use warnings;

package Bad::Collection::Doom;

use Moose 2;
extends 'Meerkat::Collection';

has bad_attribute => (
    is      => 'ro',
    default => sub {
        die "This attribute will blow up on construction";
    }
);

1;
