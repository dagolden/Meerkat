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
use Type::Params qw/compile/;
use Types::Standard qw/slurpy :types/;

use namespace::autoclean;

with Storage;

# pass through OID's without modification as MongoDB will
# consume/provide them; pass through Meerkat::Collection
# as Meerkat will strip/add as necessary
for my $type (qw/MongoDB::OID Meerkat::Collection DateTime DateTime::Tiny/) {
    MooseX::Storage::Engine->add_custom_type_handler(
        $type => (
            expand   => sub { shift },
            collapse => sub { shift },
        )
    );
}

=method new

B<Don't call this directly!>  Create objects through the
L<Meerkat::Collection> or they won't be added to the database.

    my $obj = $person->create( name => "Joe" );

=cut

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

has _removed => (
    is      => 'rw',
    isa     => 'Bool',
    reader  => 'is_removed',
    writer  => '_set_removed',
    default => 0,
);

=method update

    $obj->update( { '$set' => { 'name' => "Moe" } } );

Executes a MongoDB update command on the associated document and updates the
object's attributes.  You must only use MongoDB L<update
operators|http://docs.mongodb.org/manual/reference/operator/nav-update/> to
modify the document's fields.

Returns true if the updates are applied and synchronized.  If the document has
been removed, the method returns false and the object is marked as removed;
subsequent C<update>, C<sync> or C<remove> calls will do nothing and return
false.

This command is intended for custom updates with unusual logic or operators.
Many typical updates can be accomplished with the C<update_*> methods described
below.

For all update methods, you can use a MongoDB nested field label to modify
values deep into a data structure. For example C<parents.father> refers to
C<< $obj->parents->{father} >>.

=cut

sub update {
    state $check = compile( Object, HashRef );
    my ( $self, $update ) = $check->(@_);
    croak "The update method only accepts MongoDB update operators"
      if grep { /^[^\$]/ } keys %$update;
    return if $self->is_removed; # NOP
    return $self->_collection->update( $self, $update );
}

=method update_set

    $obj->update_set( name => "Luke Skywalker" );

Sets a field to a value.  This is the MongoDB C<$set> operator.  Returns true
if the update is applied and synchronized.  If the document has been removed,
the method returns false and the object is marked as removed.

=cut

sub update_set {
    state $check = compile( Object, Defined, Defined );
    my ( $self, $field, $value ) = $check->(@_);
    return $self->update( { '$set' => { "$field" => $value } } );
}

=method update_inc

    $obj->update_inc( likes => 1 );
    $obj->update_inc( likes => -1 );

Increments a field by a positive or negative value.  This is the MongoDB
C<$inc> operator.  Returns true if the update is applied and synchronized.  If
the document has been removed, the method returns false and the object is
marked as removed.


=cut

sub update_inc {
    state $check = compile( Object, Defined, Defined );
    my ( $self, $field, $value ) = $check->(@_);
    return $self->update( { '$inc' => { "$field" => $value } } );
}

=method update_push

    $obj->update_push( tags => qw/cool hot trendy/ );

Pushes values onto an array reference field. This is the MongoDB C<$push>
operator.  Returns true if the update is applied and synchronized.  If the
document has been removed, the method returns false and the object is marked as
removed.


=cut

sub update_push {
    state $check = compile( Object, Defined, slurpy ArrayRef );
    my ( $self, $field, $list ) = $check->(@_);
    $self->_check_arrayref( update_push => $field );
    return $self->update( { '$push' => { "$field" => { '$each' => $list } } } );
}

=method update_add

    $obj->update_add( tags => qw/cool hot trendy/ );

Pushes values onto an array reference field, but only if they do not already
exist in the array.  This is the MongoDB C<$addToSet> operator.  Returns true
if the update is applied and synchronized.  If the document has been removed,
the method returns false and the object is marked as removed.


=cut

sub update_add {
    state $check = compile( Object, Defined, slurpy ArrayRef );
    my ( $self, $field, $list ) = $check->(@_);
    $self->_check_arrayref( update_add => $field );
    return $self->update( { '$addToSet' => { "$field" => { '$each' => $list } } } );
}

=method update_pop

    $obj->update_pop( 'tags' );

Removes a value from the end of the array.  This is the MongoDB C<$pop>
operator with a direction of "1".  Returns true if the update is applied and
synchronized.  If the document has been removed, the method returns false and
the object is marked as removed.


=cut

sub update_pop {
    state $check = compile( Object, Defined );
    my ( $self, $field ) = $check->(@_);
    $self->_check_arrayref( update_pop => $field );
    return $self->update( { '$pop' => { "$field" => 1 } } );
}

=method update_shift

    $obj->update_shift( 'tags' );

Removes a value from the front of the array.  This is the MongoDB C<$pop>
operator with a direction of "-1".  Returns true if the update is applied and
synchronized.  If the document has been removed, the method returns false and
the object is marked as removed.


=cut

sub update_shift {
    state $check = compile( Object, Defined );
    my ( $self, $field ) = $check->(@_);
    $self->_check_arrayref( update_shift => $field );
    return $self->update( { '$pop' => { "$field" => -1 } } );
}

=method update_remove

    $obj->update_remove( tags => qw/cool hot/ );

Removes a list of values from the array.  This is the MongoDB C<$pullAll>
operator.  Returns true if the update is applied and synchronized.  If the
document has been removed, the method returns false and the object is marked as
removed.


=cut

sub update_remove {
    state $check = compile( Object, Defined, slurpy ArrayRef );
    my ( $self, $field, $list ) = $check->(@_);
    $self->_check_arrayref( update_remove => $field );
    return $self->update( { '$pullAll' => { "$field" => $list } } );
}

=method update_clear

    $obj->update_clear( 'tags' );

Clears an array field, setting it back to an empty array reference.  Returns
true if the update is applied and synchronized.  If the document has been
removed, the method returns false and the object is marked as removed.

=cut

sub update_clear {
    state $check = compile( Object, Defined );
    my ( $self, $field ) = $check->(@_);
    $self->_check_arrayref( update_clear => $field );
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

Returns true or false indicating whether the associated document was removed
from the database.

=cut

sub remove {
    state $check = compile(Object);
    my ($self) = $check->(@_);
    return 1 if $self->is_removed; # NOP
    return $self->_collection->remove($self);
}

=method reinsert

    $obj->reinsert;
    $obj->reinsert( force => 1 );

Reinserts a removed document.  If the C<force> option is true, then it will be
reinserted even if the document has not been removed, overwriting any existing
document in the database.  Returns false if the document is not removed (unless
the force option is true).  Returns true if the document has been reinserted.

=cut

sub reinsert {
    state $check = compile( Object, slurpy Dict [ force => Optional [Bool] ] );
    my ( $self, $options ) = $check->(@_);
    return if !$self->is_removed and !$options->{force}; # NOP
    return $self->_collection->reinsert($self);
}

=method _indexes

    $class->_indexes;

Returns an empty list.  If you want to define indexes for use with the
L<ensure_indexes|Meerkat::Collection/ensure_indexes> method of
L<Meerkat::Collection>, create your own C<_indexes> method that returns a list
of array references.  The array references can have an optional initial hash
reference of indexing options, followed by ordered key & value pairs in the
usual MongoDB way.

You must provide index fields in an array reference because Perl hashes are not
ordered and a compound index requires an order.

For example:

    sub _indexes {
        return (
            [ { unique => 1 }, name => 1 ],
            [ name => 1, zip_code => 1 ]
            [ likes => -1 ],
            [ location => '2dsphere' ],
        );
    }

See the L<Meerkat::Cookbook> for more information.

=cut

sub _indexes { return }

#--------------------------------------------------------------------------#
# private methods
#--------------------------------------------------------------------------#

sub _check_arrayref {
    my ( $self, $op, $field ) = @_;
    croak "Can't use $op on non-arrayref field '$field'"
      unless ref( $self->_deep_field($field) ) eq 'ARRAY';
}

# return whatever 'foo.bar.baz' refers to
sub _deep_field {
    my ( $self, $field ) = @_;
    my ( $head, @tail ) = split /\./, $field;
    my $target = eval { $self->$head };
    croak "Invalid attribute '$head'" if $@;
    return unless defined $target;
    while ( defined( my $p = shift @tail ) ) {
        my $ref = ref $target;
        if ( $ref eq 'ARRAY' ) {
            croak
              "Invalid subdocument '$head.$p': '$head' is an array but $p is not positive integer"
              unless $p =~ /^\d+$/;
            return if $p > $#{$target}; # doesn't exist yet
            $target = $target->[$p];
        }
        elsif ( $ref eq 'HASH' ) {
            return unless exists $target->{$p};
            $target = $target->{$p};
        }
        else {
            croak "Invalid subdocument '$head.$p': '$head' is not a reference";
        }
        $head .= ".$p";
    }
    return $target;
}

1;

=for Pod::Coverage BUILD

=head1 SYNOPSIS

Your model class:

    package MyModel::Person;

    use Moose;

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

    1;

In your code:

    use Meerkat;

    my $meerkat = Meerkat->new(
        namespace => "MyModel", database_name => "test"
    );

    my $person = $meerkat->collection("Person"); # MyModel::Person

    # create a document
    my $obj = $person->create( name => "Larry" );

    # change document in the database and update object
    $obj->update_set( name => "Moe" );
    $obj->update_inc( likes => 1 );
    $obj->update_push( tags => qw/cool hot trendy/ );

    # get any other updates from the database
    $obj->sync;

    # delete it
    $obj->remove;

=head1 DESCRIPTION

This role enhances a Moose class with attributes and methods needed to operate
in tandem with a L<Meerkat::Collection>.

The resulting object is a projection of the document state in the database.
Update methods change the state atomically in the database and synchronize the
object with the new state in the database (potentially including other changes
from other sources).

=head2 Consuming the role

When you apply this role to your Moose class, it provides and manages the
C<_id> attribute for you.  This attribute is meant to be public, but keeps
the leading underscore for consistency with L<MongoDB> classes.

The attributes you define should be read-only.  Modifying attributes directly
in the object will not be reflected in the database and will be lost the next
time you synchronize.

Objects are serialized with L<MooseX::Storage>.  Any attributes that should
not be serialized must have the C<DoNotSerialize> trait:

    has 'expensive' => (
        traits => [ 'DoNotSerialize' ],
        is     => 'lazy',
        isa    => 'HeavyObject',
    );

Attributes with embedded objects are not well supported.  See the
L<Meerkat::Cookbook> for more.

=head2 Working with objects

Create objects from an associated Meerkat::Collection, not with C<new>.

    my $obj = $person->create( %attributes );

That will construct the object, instantiate all lazy attributes (except those
marked C<DoNoSerialize>) and store the new document into the database.

Then, use the various update methods to modify state if you need to.  Use
C<sync> to refresh the object with any remote changes from the database.

=cut

# vim: ts=4 sts=4 sw=4 et:
