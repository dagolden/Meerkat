use v5.10;
use strict;
use warnings;

package Meerkat::DateTime;
# ABSTRACT: DateTime proxy for lazy inflation from an epoch value
# VERSION

use Moose 2;
use MooseX::AttributeShortcuts;
use MooseX::Storage;

use DateTime;
use namespace::autoclean;

with Storage;

=attr epoch (required)

Floating point epoch seconds

=cut

has epoch => (
    is       => 'ro',
    isa      => 'Num',
    required => 1,
);

=attr DateTime

A lazily-inflated DateTime object.  It is not serialized or stored.

=cut

has DateTime => (
    is     => 'lazy',
    isa    => 'DateTime',
    traits => ['DoNotSerialize'],
);

sub _build_DateTime {
    my ($self) = @_;
    return DateTime->from_epoch( $self->epoch );
}

__PACKAGE__->meta->make_immutable;

1;

=for Pod::Coverage method_names_here

=head1 SYNOPSIS

  use Time::HiRes;
  use Meerkat::DateTime;

  my $mkdt = Meerkat::DateTime->new( epoch = time );
  my $datetime = $mkdt->DateTime;

=head1 DESCRIPTION

This module provides a way to lazily inflate floating point
epoch seconds into a DateTime object.  It's conceptually similar
to DateTime::Tiny, but without all the year, month, day, etc. fields.

The L<Meerkat::Types> module provides Moose type support and coercions and
L<MooseX::Storage> type handling to simplify having a Meerkat::DateTime
attribute.

See the L<Merkat::Cookbook> for more on handling dates and times.

=cut

# vim: ts=4 sts=4 sw=4 et:
