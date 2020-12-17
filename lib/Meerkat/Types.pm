use v5.10;
use strict;
use warnings;

package Meerkat::Types;
# ABSTRACT: Moose types for Meerkat

our $VERSION = '0.017';

use MooseX::Types -declare => [qw(MeerkatDateTime)];
use MooseX::Storage::Engine;

use aliased 'Meerkat::DateTime' => 'MDT';
use DateTime;
use Types::Standard qw/:types/;

subtype MeerkatDateTime, as MDT;

coerce MeerkatDateTime, (
#<<< No perltidy
    from Num,                           via { MDT->new( epoch => $_ ) },
    from InstanceOf ['DateTime'],       via { MDT->new( epoch => $_->epoch ) },
    from InstanceOf ['DateTime::Tiny'], via { MDT->new( epoch => $_->DateTime->epoch ) },
    from InstanceOf ['BSON::Time'],     via { MDT->new( epoch => $_->epoch ) },
#>>>
);

# We "collapse" MeerkatDateTime to a DateTime object so that MongoDB will then
# translate it to the correct internal type.  On inflation, we take the epoch
# value it gives and turn that into the Meerkat::DateTime proxy

MooseX::Storage::Engine->add_custom_type_handler(
    MeerkatDateTime,
    (
        expand   => sub { MDT->new( epoch             => "$_[0]" ) },
        collapse => sub { DateTime->from_epoch( epoch => $_[0]->epoch ) },
    )
);

1;

=for Pod::Coverage method_names_here

=head1 SYNOPSIS

    use Meerkat::Types qw/:all/;

    has birthday => (
        is      => 'ro',
        isa     => MeerkatDateTime,
        coerce  => 1,
    );

=head1 DESCRIPTION

This module defines Moose types and coercions.

=head1 TYPES

=head2 MeerkatDateTime

This type is a L<Meerkat::DateTime>.  It defines coercions from C<Num> (an epoch value),
L<DateTime>, L<DateTime::Tiny>, and L<BSON::Time>.

It also sets up a L<MooseX::Storage> type handler that 'collapses' to a
DateTime object for storage by the MongoDB client, but 'expands' from an epoch
value provided by the MongoDB client back into a Meerkat::DateTime object.

=cut

# vim: ts=4 sts=4 sw=4 et:
