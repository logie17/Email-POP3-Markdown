package Email::POP3::Markdown;
{
    use Moose;
    use Net::POP3;

    #~~~ Accessors

    has 'emails' => (
        is          => 'rw',
        isa         => 'ArrayRef[Email::POP3::Markdown::Email]',
        default     => sub { [] },
    );

    has hostname => (
        is  => 'ro',
        isa => 'Str',
        required => 1,
    );

    has password => (
        is  => 'ro',
        isa => 'Str',
        required => 1,
    );

    has pop3  => (
        is      => 'ro',
        isa     => 'Net::POP3',
        builder => "_build_pop3",
    );

    has username => (
        is  => 'ro',
        isa => 'Str',
        required => 1,
    );


    #~~~ Public Methods

    sub BUILD 
    # Purpose:  Called after object inialization
    # Input:    Ref to self
    # Output:   None
    {
        my $self = shift;
        $self->_load_emails;
    }

    #~~~ Private Methods

    sub _build_pop3 
    # Purpose:  Builder method for pop3
    # Input:    Ref to self
    # Output:   Net::POP3 object
    {
        my ($self ) = @_;
        return Net::POP3->new($self->hostname);
    }

    sub _load_emails
    # Purpose:  Gathers up all e-mails
    # Input:    Ref to self
    # Output:   None
    {
        my ( $self ) = @_;

        if ( $self->pop3->login($self->username,$self->password) > 0)
        {
            my $msgnums_hr = $self->pop3->list;
            for my $msgnum(keys %{$msgnums_hr})
            {
                my $msg = $self->pop3->get($msgnum);
                my $email = Email::POP3::Markdown::Email->new(join "", @$msg);

                push @{$self->emails}, $email;

            }
        }

    }

    __PACKAGE__->meta->make_immutable;
    no Moose;
}

package Email::POP3::Markdown::Email;
{
    use Moose;

    use Text::Markdown 'markdown';
    use Email::Simple;

    use overload '""' =>\&to_string, 'fallback' => 1;

    has html => (
        is          => 'rw',
        isa         => 'Str',
        lazy_build  => 1,
    );

    has msg_body => (
        is          => 'rw',
        isa         => 'Str',
        lazy_build  => 1,
    );

    has raw_msg => (
        is          => 'rw',
        isa         => 'Str',
        required    => 1,
    );

    #~~~ Public Methods

    sub to_string 
    # Purpose:  Returns raw_msg for overload - Direct call of the object
    # Input:    Ref to self
    # Output:   Raw email
    {
        my ($self) = @_;
        $self->raw_msg;
    }

    around BUILDARGS => sub {
        my $orig = shift;
        my $class = shift;
    
        if ( @_ == 1 && ! ref $_[0] ) {
            return $class->$orig(raw_msg => $_[0]);
        }
        else {
            return $class->$orig(@_);
        }
    };

    #~~~ Private Methods

    sub _build_html {
        my $self = shift;
        return markdown($self->msg_body);
    }

    sub _build_msg_body {
        my $self = shift;
        return Email::Simple->new($self->raw_msg)->body;
    }

    
    __PACKAGE__->meta->make_immutable;
    
    no Moose;

}

1;

__END__

=head1 NAME

Email::POP3::Markdown

=head1 SYNOPSIS

my $email_mgr_obj = Email::POP3::Markdown->new(username => 'foo', password => 'bar', hostname => 'baz.com');

for my $email_obj ($email_mgr_obj->emails )
{
    print $email_obj->html;
}

=head1 DESCRIPTION

Email::POP3::Markdown is an e-mail client that reads e-mails and converts the body contents of the e-mail from markdown into html.

=head1 METHODS

=head2 emails

An accessor to get Email::POP3::Markdown::Email objects.

=head2 hostname

An accessor for the set host name.

=head2 new

Contructor method that takes the following parameters: username, password, and hostname.

=head2 password 

An accessor for the current password.

=head2 pop3

An accessor to get a Net::Pop3 object.

=head2 username

An accessor for the username.

=head2 

=head1 NAME 

Email::POP3::Markdown

=head1 DESCRIPTION

This this class manages individual e-mails and has accessors to get a basic elements of e-mails.

=head2 html

An accessor to get the HTMLized message body.

=head2 msg_body

An accessor to get the message body of an email.

=head2 raw_msg 

An accessor to get the entire e-mail message.

=head1 VERSION HISTORY

See the Changes file for detailed release notes for this version.

=head1 AUTHOR

Logan Bell
http://loganbell.org

=head1 THIS DISTRIBUTION

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.

=cut

