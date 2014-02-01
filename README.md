
# NAME

GoInstant::Auth - GoInstant Authentication for Your Perl Application

# SYNOPSIS

    use GoInstant::Auth;

    my $signer = GoInstant::Auth->Signer($key);

    my $jwt = $signer->sign({
        user_id => 'permanentid',
        display_name => 'Bob Smith',
        groups => [
            { id => 'bobgroup', display_name => "Bob's Group" }
        ]
    });

# DESCRIPTION

This is an implementation of JWT tokens consistent with what's specified in the
[GoInstant Users and Authentication Guide](https://developers.goinstant.com/v1/guides/users_and_authentication.html).

This library is not intended as a general-use JWT library.  In fact, this
module is a thin wrapper around [JSON::WebToken](https://metacpan.org/pod/JSON::WebToken), which should be sufficient
for more advanced use-cases.

# METHODS

## Signer($key)

Returns a [GoInstant::Auth::Signer](https://metacpan.org/pod/GoInstant::Auth::Signer) object, which can be used to create and sign many JWTs.  Please see ["sign" in GoInstant::Auth::Signer](https://metacpan.org/pod/GoInstant::Auth::Signer#sign) for details.

# CONTRIBUTING

This module uses the [Minilla](https://metacpan.org/pod/Minilla) CPAN module authoring tool.

## Development Pre-requisites

- perl >= 5.8.1
- [Minilla](https://metacpan.org/pod/Minilla) >= 0.11.0

## Running Tests

Simply run `minil test`.  Tests are located in the `t/` directory.

# SEE ALSO

[JSON::WebToken](https://metacpan.org/pod/JSON::WebToken) for generic JWT operations.

# LICENSE

Copyright (C) 2014 GoInstant Inc., a salesforce.com company.

Licensed under the 3-Clause BSD Licence (see LICENCE.txt).

# AUTHOR

Jeremy Stashewsky <jeremy@goinstant.com> for GoInstant Inc. <support@goinstant.com>
