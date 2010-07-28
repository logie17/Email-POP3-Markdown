use strict;
use warnings;
use Test::MockModule;

use Test::More tests => 6;                      # last test to print

BEGIN{ use_ok('Email::POP3::Markdown'); }


# Create a dummy e-mail
use Email::Simple;
my $email_obj = Email::Simple->create(
    header => [
        'From'  =>  'foo@bar.com',
        'To'    =>  'test@test.com',
        'Date'  =>  'Fri, 23 Jul 2010 02:27:15',
    ],
    body    => 'Lorem Ipsum',
);

my @email_msg = ($email_obj->as_string);

# Mock up Net::POP3
my $mock_pop3_module = Test::MockModule->new('Net::POP3');
my ($hostname, $username, $password);
$mock_pop3_module->mock('login', sub { $username = $_[1]; $password = $_[2]; 1;} );
$mock_pop3_module->mock('list', sub { { 1 => 2} } );
$mock_pop3_module->mock('get', sub { \@email_msg });
$mock_pop3_module->mock('new', sub { 
                            my $proto = shift; 
                            my $class = ref($proto) || $proto; 
                            my $self = {}; 
                            $hostname = shift;
                            bless($self, $class); 
                        } );

# Create our test subject
my $email_markdown_obj = Email::POP3::Markdown->new(username => 'foo', password => 'bar', hostname => 'baz.com');

# The tests
is $username, 'foo';
is $password, 'bar';
is $hostname, 'baz.com';

ok $email_markdown_obj->emails->[0];
is $email_markdown_obj->emails->[0]->mark_down, "<p>Lorem Ipsum</p>\n";






