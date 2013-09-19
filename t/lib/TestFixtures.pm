use 5.008001;
use strict;
use warnings;

package TestFixtures;

use Test::Roo::Role;
use Test::Fatal;
use MooX::Types::MooseLike::Base qw/:all/;
use Meerkat;
use Data::Faker qw/Name DateTime/;

#--------------------------------------------------------------------------#
# fixtures
#--------------------------------------------------------------------------#

has faker => (
    is  => 'lazy',
    isa => InstanceOf ['Data::Faker'],
);

sub _build_faker {
    return Data::Faker->new;
}

has meerkat => (
    is  => 'lazy',
    isa => InstanceOf ['Meerkat'],
);

sub _build_meerkat {
    my ($self) = @_;
    return Meerkat->new( $self->meerkat_options );
}

has meerkat_options => (
    is  => 'lazy',
    isa => HashRef,
);

sub _build_meerkat_options {
    my ($self) = @_;
    return {
        namespace     => 'MyModel',
        database_name => 'test',
    };
}

has person => (
    is  => 'lazy',
    isa => InstanceOf ['Meerkat::Collection'],
);

sub _build_person {
    my ($self) = @_;
    return $self->meerkat->collection("Person");
}

#--------------------------------------------------------------------------#
# modifiers
#--------------------------------------------------------------------------#

before each_test => sub {
    my ($self) = @_;
    $self->meerkat->_database->drop;
};

#--------------------------------------------------------------------------#
# methods
#--------------------------------------------------------------------------#

sub create_person {
    my ( $self, @args ) = @_;
    return $self->person->create(
        name     => $self->faker->name,
        birthday => $self->faker->unixtime,
        @args
    );
}

sub fail_update {
    my ( $self, $op, $obj, $field, $value ) = @_;
    my $type = $obj->__field_type( $obj->_deep_field($field) );
    like(
        exception { $obj->$op( $field, defined($value) ? $value : () ) },
        qr/Can't use $op on $type field '$field'/,
        "$op on $type field croaks"
    );
}

sub fail_type_update {
    my ( $self, $op, $obj, $field, $value ) = @_;
    my $type        = $obj->__field_type( $obj->_deep_field($field) );
    my $target_type = $obj->__field_type($value);
    like(
        exception { $obj->$op( $field, defined($value) ? $value : () ) },
        qr/Can't use $op to change $type field '$field' to $target_type/,
        "$op on $type field that changes type croaks"
    );
}

sub pass_update {
    my ( $self, $op, $obj, $field, $value ) = @_;
    my $type = $obj->__field_type( $obj->_deep_field($field) );
    is( exception { $obj->$op( $field, defined($value) ? $value : () ) },
        undef, "$op on $type field succeeds" );
}

1;
# COPYRIGHT
# vim: ts=4 sts=4 sw=4 et:
