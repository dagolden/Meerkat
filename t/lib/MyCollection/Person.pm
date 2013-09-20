use 5.008001;
use strict;
use warnings;

package MyCollection::Person;

use Moose 2;
extends 'Meerkat::Collection';

sub find_name {
    my ( $self, $name ) = @_;
    return $self->find_one( { name => $name } );
}

1;

