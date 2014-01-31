package GoInstant::Auth::Signer;
use 5.008005;
use strict;
use warnings;

use MIME::Base64 qw(decode_base64);

sub _decode_key {
    my $key = shift;
    $key =~ tr{_-}{/+};
    $key .= '=' while length($key) % 4;
    return decode_base64($key);
}

sub new {
    my ($clazz, $args) = @_;
    my $self = bless {}, $clazz;

    die "A Base64 key is required"
        unless defined $args->{key} and $args->{key};

    $self->{key} = _decode_key($args->{key});

    die "Could not parse Base64 key"
        unless $self->{key};
    die "Key appears to be too short"
        if length($self->{key}) < 64;

    $self->{alg} = $args->{alg} || 'HS256';

    if ($self->{alg} ne 'HS256' &&
        $self->{alg} ne 'HS384' &&
        $self->{alg} ne 'HS512'
    ) {
        die 'Invalid signature algorithm; '.
            'GoInstant supports HS256/HS384/HS512';
    }

    return $self;
}

my %REQUIRED = (
    domain => 'iss',
    user_id => 'sub',
    display_name => 'dn',
);

my %OPTIONAL = (
    email => 'email',
    avatar_url => 'avatarUrl'
);

my %GROUP_REQUIRED = (
    id => 'id',
    display_name => 'dn',
);

sub _info_to_claims {
    my ($self, $args) = @_;
    my $k;
    my %claims = ();

    for $k (keys %REQUIRED) {
        die "$k is required" unless defined $args->{$k};
        $claims{$REQUIRED{$k}} = $args->{$k};
    }

    for $k (keys %OPTIONAL) {
        $claims{$OPTIONAL{$k}} = $args->{$k}
            if defined $args->{$k};
    }

    if ($args->{groups}) {
        $claims{g} = [];
        for my $group (@{$args->{groups}}) {
            my $g_claims = {};
            for $k (keys %GROUP_REQUIRED) {
                die "group $k is required" unless defined $group->{$k};
                $g_claims->{$GROUP_REQUIRED{$k}} = $group->{$k};
            }
            push @{$claims{g}}, $g_claims;
        }
    }

    $claims{aud} = ['goinstant.net'];
    $claims{iat} = time;

    return \%claims;
}

sub sign {
    my ($self, $args) = @_;

    my $claims = $self->_info_to_claims($args);
    return JSON::WebToken->encode($claims, $self->{key}, $self->{alg});
}

sub _decode {
    my ($self, $jwt) = @_;
    return JSON::WebToken->decode($jwt, $self->{key}, $self->{alg});
}

1;
__END__

=encoding utf-8

=head1 NAME

GoInstant::Auth::Signer

=head1 SYNOPSIS

    use GoInstant::Auth::Signer;

    my $signer = GoInstant::Auth::Signer->new({
        key => $secret_key_in_base64
    });

    my $user = {
        domain => 'example.com',
        user_id => 42,
        display_name => 'Bob Smith',
        groups => [
            { id => 'bobgroup', display_name => "Bob's Group" }
        ]
    };
    my $jwt = $signer->sign($user);
    print "jwt to pass to GoInstant is",$jwt,$/;

=head1 METHODS

=head2 new($key)

Creates a new Signer object.  C<$key> must be a string with a Base64 or
Base64url encoded key.

=head2 sign($user)

Creates a signed JWT for the supplied user.  Currently, an HMAC-SHA256
signature (the C<HS256> algorithm) is used.

=head3 User Information

The C<sign()> method must be passed a hash of user information.  The fields of
that hash are as follows:

=over 4

=item domain

The domain of this user, in which the C<user_id> is unique.

=item user_id

The permanent identifier of this user on your system, unique at least within
your C<domain>.

Database row-IDs might be a good choice, but email addresses (which can in
theory change) are not.

=item display_name

The name to display for this user.

=item groups

I<Optional> An array of groups that this user belongs to, which can be used within
GoInstant to enforce access controls.

=over 4

=item id

The permanent, unique id of this group within the above C<domain>.

=item display_name

I<Optional> The name to display for this group.

=back

=item email

I<Optional> Email address to add to the JWT.

=item avatar_url

I<Optional> URL to a small picture to display for this user.

=back

=head1 SEE ALSO

L<JSON::WebToken> for generic JWT operations.
