# IO::Zlib.pm
#
# Copyright (c) 1998 Tom Hughes <tom@compton.demon.co.uk>.
# All rights reserved. This program is free software; you can redistribute
# it and/or modify it under the same terms as Perl itself.

package IO::Zlib;

=head1 NAME

IO::Zlib - IO:: style interface to L<Compress::Zlib>

=head1 SYNOPSIS

With any version of Perl 5 you can use the basic OO interface:

    use IO::Zlib;

    $fh = new IO::Zlib;
    if ($fh->open("file.gz", "wb")) {
        print <$fh>;
        $fh->close;
    }

    $fh = IO::Zlib->new("file.gz", "wb9");
    if (defined $fh) {
        print $fh "bar\n";
        $fh->close;
    }

    $fh = IO::Zlib->new("file.gz", "rb");
    if (defined $fh) {
        print <$fh>;
        undef $fh;       # automatically closes the file
    }

With Perl 5.004 you can also use the TIEHANDLE interface to access
compressed files just like ordinary files:

    use IO::Zlib;

    tie *FILE, 'IO::Zlib', "file.gz", "wb";
    print FILE "line 1\nline2\n";

    tie *FILE, 'IO::Zlib', "file.gz", "rb";
    while (<FILE>) { print "LINE: ", $_ };

=head1 DESCRIPTION

C<IO::Zlib> provides an IO:: style interface to L<Compress::Zlib> and
hence to gzip/zlib compressed files. It provides many of the same methods
as the L<IO::Handle> interface.

=head1 CONSTRUCTOR

=over 4

=item new ( [ARGS] )

Creates an C<IO::Zlib> object. If it receives any parameters, they are
passed to the method C<open>; if the open fails, the object is destroyed.
Otherwise, it is returned to the caller.

=back

=head1 METHODS

=over 4

=item open ( FILENAME, MODE )

C<open> takes two arguments. The first is the name of the file to open
and the second is the open mode. The mode can be anything acceptable to
L<Compress::Zlib> and by extension anything acceptable to I<zlib> (that
basically means POSIX fopen() style mode strings plus an optional number
to indicate the compression level).

=item opened

Returns true if the object currently refers to a opened file.

=item close

Close the file associated with the object and disassociate
the file from the handle.
Done automatically on destroy.

=item getc

Return the next character from the file, or undef if none remain.

=item getline

Return the next line from the file, or undef on end of string.
Can safely be called in an array context.
Currently ignores $/ ($INPUT_RECORD_SEPARATOR or $RS when L<English>
is in use) and treats lines as delimited by "\n".

=item getlines

Get all remaining lines from the file.
It will croak() if accidentally called in a scalar context.

=item print ( ARGS... )

Print ARGS to the  file.

=item read ( BUF, NBYTES, [OFFSET] )

Read some bytes from the file.
Returns the number of bytes actually read, 0 on end-of-file, undef on error.

=item eof

Returns true if the handle is currently positioned at end of file?

=item seek ( OFFSET, WHENCE )

Seek to a given position in the stream.
Not yet supported.

=item tell

Return the current position in the stream, as a numeric offset.
Not yet supported.

=item setpos ( POS )

Set the current position, using the opaque value returned by C<getpos()>.
Not yet supported.

=item getpos ( POS )

Return the current position in the string, as an opaque object.
Not yet supported.

=back

=head1 SEE ALSO

L<perlfunc>,
L<perlop/"I/O Operators">,
L<IO::Handle>,
L<Compress::Zlib>

=head1 HISTORY

Created by Tom Hughes E<lt>F<tom@compton.demon.co.uk>E<gt>.

=head1 COPYRIGHT

Copyright (c) 1998 Tom Hughes E<lt>F<tom@compton.demon.co.uk>E<gt>.
All rights reserved. This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

=cut

require 5.000;

use strict;
use vars qw($VERSION);
use Carp;
use Compress::Zlib;

$VERSION = "0.02";

sub new
{
    my($self) = bless {}, shift;

    if (@_)
    {
	$self->open(@_) or return undef;
    }

    return $self;
}

sub DESTROY
{
    my($self) = @_;

    untie $self;

    $self->close();

    return;
}

sub open
{
    my($self,$filename,$mode) = @_;

    croak "open() needs a filename" unless defined($filename);

    $self->{'file'} = gzopen($filename,$mode);
    $self->{'eof'} = 0;

    return defined($self->{'file'}) ? $self : undef;
}

sub opened
{
    my($self) = @_;

    return defined($self->{'file'});
}

sub close
{
    my($self) = @_;

    return undef unless defined($self->{'file'});

    my($status) = $self->{'file'}->gzclose();

    delete $self->{'file'};
    delete $self->{'eof'};

    return ($status == 0) ? 1 : undef;
}

sub getc
{
    my($self) = @_;
    my($character);

    my($status) = $self->{'file'}->gzread($character, 1);

    $self->{'eof'} = 1 if $status == 0;

    return ($status > 0 ) ? $character : "";
}

sub getline
{
    my($self) = @_;
    my($line);

    my($status) = $self->{'file'}->gzreadline($line);

    $self->{'eof'} = 1 if $status == 0;

    return ($status > 0) ? $line : undef;
}

sub getlines
{
    my($self) = @_;

    croak("Can't call getlines in scalar context!") unless wantarray;

    my ($line, @lines);

    push @lines, $line while (defined($line = $self->getline));

    return @lines;
}

sub print
{
    my($self) = shift;

    my($status) = $self->{'file'}->gzwrite(join('', @_));

    return ($status > 0) ? 1 : 0;
}

sub read
{
    my($self,$buf,$nbytes,$offset) = @_;

    croak "NBYTES must be specified" unless defined($nbytes);
    croak "OFFSET not yet supported" if defined($offset);

    my($status) = $self->{'file'}->gzread($_[1],$nbytes);

    $self->{'eof'} = 1 if $status >= 0 && $status < $nbytes;

    return ($status < 0) ? undef : $status;
}

sub eof
{
    my($self) = @_;

    return $self->{'eof'};
}

sub seek
{
    croak "seek not yet supported";
}

sub tell
{
    croak "tell not yet supported";
}

sub setpos
{
    croak "setpos not yet supported";
}

sub getpos
{
    croak "getpos not yet supported";
}

sub TIEHANDLE { shift->new(@_) }
sub GETC      { shift->getc(@_) }
sub PRINT     { shift->print(@_) }
sub PRINTF    { shift->print(sprintf(shift, @_)) }
sub READ      { shift->read(@_) }
sub READLINE  { wantarray ? shift->getlines(@_) : shift->getline(@_) }

1;
