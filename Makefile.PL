use inc::Module::Install;

name            'Email-POP3-Markdown';
author          'Logan Bell <logan@orchardtech.com>';
version         '0.01';
license         'gpl';
perl_version    '5.008008';
all_from        'lib/Email/POP3/Markdown.pm';

requires        'Test::MockModule'          => '0.05';
requires        'Moose'                     => '1.08';
requires        'Net::POP3'                 => '2.29';
requires        'Text::Markdown'            => '1.000031';
requires        'Email::Simple'             => '2.100';

WriteAll;
