use v5.10;
use strict;
use warnings;

package Meerkat::Cursor;
# ABSTRACT: Wrap MongoDB::Cursor to inflate data to objects
# VERSION

# Dependencies
use Moose 2;

=attr cursor (required)

A L<MongoDB::Cursor> object

=cut

has cursor => (
    is       => 'ro',
    isa      => 'MongoDB::Cursor',
    required => 1,
    handles  => [
        qw( fields sort limit tailable skip snapshot hint ),
        qw( explain count reset has_next next info all ),
    ],
);

=attr collection (required)

A L<Meerkat::Collection> used for inflating results.

=cut

has collection => (
    is       => 'ro',
    isa      => 'Meerkat::Collection',
    required => 1,
);

around 'next' => sub {
    my $orig = shift;
    my $self = shift;

    if ( my $data = $self->$orig ) {
        return $self->collection->thaw_object($data);
    }
    else {
        return;
    }
};

1;

=for Pod::Coverage method_names_here

=head1 SYNOPSIS

  use Meerkat::Cursor;

=head1 DESCRIPTION

When a L<Meerkat::Collection> method returns a query cursor, it provides this
proxy for a L<MongoDB::Cursor>.  See documentation of that module for usage
information.

The only difference is that the C<next> method will return objects of the class
associated with the originating L<Meerkat::Collection>.

=cut

# vim: ts=4 sts=4 sw=4 et:
