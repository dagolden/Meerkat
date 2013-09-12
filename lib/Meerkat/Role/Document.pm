use v5.10;
use strict;
use warnings;

package Meerkat::Role::Document;
# ABSTRACT: Enhances a Moose object with Meerkat methods and metadata
# VERSION

use Moose::Role 2;
use MooseX::AttributeShortcuts;
use MooseX::Storage;
use MooseX::Storage::Engine;

use Carp qw/croak/;
use MongoDB::OID;
use Type::Params qw/compile Invocant/;
use Types::Standard qw/slurpy :types/;

use namespace::autoclean;

with Storage;

# pass through OID's without modification as MongoDB will
# consume/provide them; pass through Meerkat::Collection
# as Meerkat will strip/add as necessary
for my $type (qw/MongoDB::OID Meerkat::Collection/) {
    MooseX::Storage::Engine->add_custom_type_handler(
        $type => (
            expand   => sub { shift },
            collapse => sub { shift },
        )
    );
}

has _collection => (
    is       => 'ro',
    isa      => 'Meerkat::Collection',
    required => 1,
);

has _id => (
    is      => 'ro',
    isa     => 'MongoDB::OID',
    default => sub { MongoDB::OID->new },
);

=method is_removed

    if ( $obj->is_removed ) { ... }

Returns a boolean value indicating whether the associated document was removed
from the database.

=cut

has _removed => (
    is      => 'rw',
    isa     => 'Bool',
    reader  => 'is_removed',
    writer  => '_set_removed',
    default => 0,
);

=method new

B<Don't call this directly!>  Create your objects through the
L<Meerkat::Collection> or your object won't be added to the database.

    $meerkat->collection("Person")->create( name => "Joe" );

=method update

    $obj->update( { '$set' => { 'name' => "Moe" } } );

Executes a MongoDB update command on the associated document and updates the
object's attributes.  You should only use MongoDB update operators to modify
the document's fields or you risk creating an invalid document that can't be
synchronized.

Returns true if synced.  If the document has been removed, the method returns
false and the object is marked as removed; subsequent C<update>, C<sync> or
C<remove> calls will do nothing and return false.

This command is intended for custom updates with unusual logic or operators.
Many typical updates can be accomplished with the C<update_*> methods described
below.

=cut

sub update {
    state $check = compile( Object, HashRef );
    my ( $self, $update ) = $check->(@_);
    return if $self->is_removed; # NOP
    return $self->_collection->update( $self, $update );
}

sub update_set {
    state $check = compile( Object, Defined, Defined );
    my ( $self, $field, $value ) = $check->(@_);
    return $self->update( { '$set' => { "$field" => $value } } );
}

sub update_inc {
    state $check = compile( Object, Defined, Defined );
    my ( $self, $field, $value ) = $check->(@_);
    return $self->update( { '$inc' => { "$field" => $value } } );
}

sub update_push {
    state $check = compile( Object, Defined, slurpy ArrayRef );
    my ( $self, $field, $list ) = $check->(@_);
    return $self->update( { '$push' => { "$field" => { '$each' => $list } } } );
}

sub update_add {
    state $check = compile( Object, Defined, slurpy ArrayRef );
    my ( $self, $field, $list ) = $check->(@_);
    return $self->update( { '$addToSet' => { "$field" => { '$each' => $list } } } );
}

sub update_pop {
    state $check = compile( Object, Defined );
    my ( $self, $field ) = $check->(@_);
    return $self->update( { '$pop' => { "$field" => 1 } } );
}

sub update_shift {
    state $check = compile( Object, Defined );
    my ( $self, $field ) = $check->(@_);
    return $self->update( { '$pop' => { "$field" => -1 } } );
}

sub update_remove {
    state $check = compile( Object, Defined, slurpy ArrayRef );
    my ( $self, $field, $list ) = $check->(@_);
    return $self->update( { '$pullAll' => { "$field" => $list } } );
}

=method update_clear

    $obj->update_clear( 'tags' );

Clears an array field, setting it back to an empty array reference.

=cut

sub update_clear {
    state $check = compile( Object, Defined );
    my ( $self, $field ) = $check->(@_);
    return $self->update( { '$set' => { "$field" => [] } } );
}

=method sync

    $obj->sync;

Updates object attributes from the database.  Returns true if synced.  If the
document has been removed, the method returns false and the object is marked as
removed; subsequent C<update>, C<sync> or C<remove> calls will do nothing and
return false.

=cut

sub sync {
    state $check = compile(Object);
    my ($self) = $check->(@_);
    return $self->_collection->sync($self);
}

=method remove

    $obj->remove;

Removes the associated document from the database.  The object is marked as
removed; subsequent C<update>, C<sync> or C<remove> calls will do nothing and
return false.

=method is_removed

    if ( $obj->is_removed ) { ... }

Predicate method for whether the object is known to be removed from the
database.

=cut

sub remove {
    state $check = compile(Object);
    my ($self) = $check->(@_);
    return 1 if $self->is_removed; # NOP
    return $self->_collection->remove($self);
}

sub reinsert {
    state $check = compile( Object, slurpy Dict [ force => Optional [Bool] ] );
    my ( $self, $options ) = $check->(@_);
    return if !$self->is_removed and !$options->{force}; # NOP
    return $self->_collection->reinsert($self);
}

1;

=for Pod::Coverage method_names_here

=head1 SYNOPSIS

    package MyModel::Person;

    use Moose 2;

    with 'Meerkat::Role::Document';

    has name => (
        is       => 'ro',
        isa      => 'Str',
        required => 1,
    );

    1;

=head1 DESCRIPTION

This module might be cool, but you'd never know it from the lack
of documentation.

=head1 USAGE

Good luck!

=head1 SEE ALSO

=for :list
* L<Meerkat>
* L<Meerkat::Tutorial>

=cut

# vim: ts=4 sts=4 sw=4 et:
