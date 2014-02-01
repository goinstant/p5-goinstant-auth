package GoInstant::Auth;
use 5.008005;
use strict;
use warnings;

our $VERSION = "0.01";

use GoInstant::Auth::Signer;

sub Signer {
    my (undef,$key) = @_;
    return GoInstant::Auth::Signer->new({ key => $key });
}

1;
__END__

=encoding utf-8

=head1 NAME

GoInstant::Auth - GoInstant Authentication for Your Perl Application

=head1 SYNOPSIS

    use GoInstant::Auth;

    my $signer = GoInstant::Auth->Signer($key);

    my $jwt = $signer->sign({
        user_id => 'permanentid',
        display_name => 'Bob Smith',
        groups => [
            { id => 'bobgroup', display_name => "Bob's Group" }
        ]
    });

=head1 DESCRIPTION

This is an implementation of JWT tokens consistent with what's specified in the
L<GoInstant Users and Authentication Guide|https://developers.goinstant.com/v1/guides/users_and_authentication.html>.

This library is not intended as a general-use JWT library.  In fact, this
module is a thin wrapper around L<JSON::WebToken>, which should be sufficient
for more advanced use-cases.

=head1 METHODS

=head2 Signer($key)

Returns a L<GoInstant::Auth::Signer> object, which can be used to create and sign many JWTs.  Please see L<GoInstant::Auth::Signer/sign> for details.

=head1 CONTRIBUTING

This module uses the L<Minilla> CPAN module authoring tool.

=head2 Development Pre-requisites

=over 4

=item perl >= 5.8.1

=item L<Minilla> >= 0.11.0

=back

=head2 Running Tests

Simply run C<minil test>.  Tests are located in the C<t/> directory.

=head1 SEE ALSO

L<JSON::WebToken> for generic JWT operations.

=head1 LICENSE

Copyright (C) 2014 GoInstant Inc., a salesforce.com company.

Licensed under the 3-Clause BSD Licence (see LICENCE.txt).

=head1 AUTHOR

Jeremy Stashewsky E<lt>jeremy@goinstant.comE<gt> for GoInstant Inc. E<lt>support@goinstant.comE<gt>
