use v5.10;
use strict;
use warnings;

package Meerkat::Cursor;
# ABSTRACT: Wrap MongoDB::Cursor to inflate data to objects
# VERSION

# Dependencies
use Moose 2;

has cursor => (
    is       => 'ro',
    isa      => 'MongoDB::Cursor',
    required => 1,
    handles  => [
        qw( fields sort limit tailable skip snapshot hint ),
        qw( explain count reset has_next next info all ),
    ],
);

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

This module might be cool, but you'd never know it from the lack
of documentation.

=head1 USAGE

Good luck!

=head1 SEE ALSO

Maybe other modules do related things.

=cut

# vim: ts=4 sts=4 sw=4 et:
