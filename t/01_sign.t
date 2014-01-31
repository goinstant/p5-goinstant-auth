use strict;
use Test::More;
use MIME::Base64 ();
use JSON::WebToken;

use_ok 'GoInstant::Auth';
use_ok 'GoInstant::Auth::Signer';

# just for testing, use a right-sized key
our $VALID_KEY = MIME::Base64::encode_base64('a' x 64);
$VALID_KEY =~ s/\s//g;

{
    eval {
        my $signer = GoInstant::Auth->Signer();
    };
    ok $@ =~ /A Base64 key is required/;
}

{
    eval {
        my $signer = GoInstant::Auth->Signer('AAAA');
    };
    ok $@ =~ /Key appears to be too short/;
}

{
    note 'simple construction';
    my $signer = GoInstant::Auth->Signer($VALID_KEY);
    isa_ok $signer, 'GoInstant::Auth::Signer';
    ok $signer->{key};
    is $signer->{alg}, 'HS256';
}

{
    note 'construction as HS512';
    my $signer = GoInstant::Auth::Signer->new({
        key => $VALID_KEY,
        alg => 'HS512',
    });
    isa_ok $signer, 'GoInstant::Auth::Signer';
    ok $signer->{key};
    is $signer->{alg}, 'HS512';
}

{
    note 'simple signing';
    my $signer = GoInstant::Auth->Signer($VALID_KEY);
    isa_ok $signer, 'GoInstant::Auth::Signer';

    my $jwt = $signer->sign({
        user_id => 1234,
        domain => 'my.example.com',
        display_name => 'Bob Smith'
    });
    ok $jwt;

    my $parsed = $signer->_decode($jwt);
    is $parsed->{sub}, 1234;
    is $parsed->{iss}, 'my.example.com';
    is $parsed->{dn}, 'Bob Smith';
    ok !$parsed->{g}, 'no groups by default';

    # automatic claims:
    ok $parsed->{iat};
    ok $parsed->{aud};
    is_deeply $parsed->{aud}, ['goinstant.net'];
}

{
    note 'signing with some groups';
    my $signer = GoInstant::Auth->Signer($VALID_KEY);
    isa_ok $signer, 'GoInstant::Auth::Signer';

    my $jwt = $signer->sign({
        user_id => 1234,
        domain => 'my.example.com',
        display_name => 'Bob Smith',
        groups => [
            { id => 'cool', display_name => 'Cool People' },
            { id => 'room42', display_name => 'Room 42' },
        ]
    });
    ok $jwt;

    my $parsed = $signer->_decode($jwt);
    is $parsed->{sub}, 1234;
    is $parsed->{iss}, 'my.example.com';
    is $parsed->{dn}, 'Bob Smith';
    ok $parsed->{g};
    is_deeply $parsed->{g}, [
        { id => 'cool', dn => 'Cool People' },
        { id => 'room42', dn => 'Room 42' },
    ];

    # automatic claims:
    ok $parsed->{iat};
    ok $parsed->{aud};
    is_deeply $parsed->{aud}, ['goinstant.net'];
}

done_testing();
