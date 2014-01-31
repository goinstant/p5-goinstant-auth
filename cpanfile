requires 'perl', '5.008001';
requires 'JSON::WebToken', '>= 0.07';
requires 'MIME::Base64';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

