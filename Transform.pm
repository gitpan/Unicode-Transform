package Unicode::Transform;

require 5.006;

use strict;
no warnings 'utf8';

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

require Exporter;
require DynaLoader;

$VERSION = '0.31';

@ISA = qw(Exporter DynaLoader);

our @UTF_names = qw(utf16le utf16be utf32le utf32be utf8 utf8mod utfcp1047);
our @Codenames = ("unicode", @UTF_names);

our %EXPORT_TAGS = (
    'from' => [ map('unicode_to_'.$_, @UTF_names) ],
    'to'   => [ map($_.'_to_unicode', @UTF_names) ],
    'chr'  => [ map('chr_'.$_,        @Codenames) ],
    'ord'  => [ map('ord_'.$_,        @Codenames) ],
);

for my $a (@Codenames) {
    for my $b (@Codenames) {
	push @{ $EXPORT_TAGS{'conv'} }, "${a}_to_${b}";
    }
}

@EXPORT    = (map @$_, @EXPORT_TAGS{qw(from to)});
@EXPORT_OK = (map @$_, @EXPORT_TAGS{qw(conv chr ord)});
$EXPORT_TAGS{'all'} = \ @EXPORT_OK;

bootstrap Unicode::Transform $VERSION;

1;
__END__

=head1 NAME

Unicode::Transform - conversion among Unicode Transformation Formats (UTFs)

=head1 SYNOPSIS

    use Unicode::Transform;

    $unicode_string = utf16be_to_unicode($utf16be_string);
    $utf16le_string = unicode_to_utf16le($unicode_string);
    $utf8_string    = utf32be_to_utf8   ($utf32be_string);

=head1 DESCRIPTION

This module provides some functions to convert a string
among some Unicode Transformation Formats (UTFs).

=head2 Conversion Between UTF

(Exporting: C<use Unicode::Transform qw(:conv);>)

B<Function names>

A function name consists of C<SRC_UTF_NAME>, string C<'_to_'>,
and C<DST_UTF_NAME>.

C<SRC_UTF_NAME> (UTF name which a source string is in) and
C<DST_UTF_NAME> (UTF name which a return value is in) must be
one in the list of hyphen-removed and lowercased names following:

    unicode    (for Perl's internal strings; see perlunicode)
    utf16le    (for UTF-16LE)
    utf16be    (for UTF-16BE)
    utf32le    (for UTF-32LE)
    utf32be    (for UTF-32BE)
    utf8       (for UTF-8)
    utf8mod    (for UTF-8-Mod)
    utfcp1047  (for CP-1047-oriented UTF-EBCDIC).

In all, 64 (i.e. 8 times 8) functions are available.
Available function names include C<utf16be_to_utf32le()>,
C<utf8_to_unicode()>.
C<DST_UTF_NAME> may be same as C<SRC_UTF_NAME> like C<utf8_to_utf8()>.

B<Parameters>

If the first parameter is a reference,
that is C<CALLBACK>, which is used for coping with
illegal characters and octets.
Any reference will not allowed as C<STRING>.

If C<CALLBACK> is given, C<STRING> is
the second parameter; otherwise the first.
C<STRING> is a source string.
Currently, only coderefs are allowed as C<CALLBACK>.

If C<CALLBACK> is omitted, illegal code points and partial octets
are deleted.

Illegal code points comprise
surrogate code points [C<0xD800..0xDFFF>] and
out-of-range code points [C<0x110000> and greater]).

Partial octets are octets which do not represent any code point.
They include the first octet without following octets in UTF-8 like C<"\xC2">,
the last octet in UTF-16BE,LE with odd-numbered octets.

If C<CALLBACK> is specified,
the appearance of an illegal code point or a partial octet calls
the code reference. The first parameter for C<CALLBACK>
is the unsigned integer value of its code point;
if the value is lesser than 256, that is a partial octet.

The return value from C<CALLBACK> is inserted there.

(You can call C<die> or C<croak> in C<CALLBACK>
if you want to trap an ill-formed source.)

=head2 Conversion from Code Point to String

(Exporting: C<use Unicode::Transform qw(:chr);>)

Returns the character represented by that C<CODEPOINT> as the string
in the Unicode transformation format.
C<CODEPOINT> can be in the range of C<0..0x7FFF_FFFF>.
Returns a string even if C<CODEPOINT> is
a surrogate code point [C<0xD800..0xDFFF>].

C<chr_utf16le()> and C<chr_utf16be()> returns C<undef> when C<CODEPOINT>
is out of range [i.e., when C<0x110000> and greater]).

=over 4

=item C<chr_unicode(CODEPOINT)>

=item C<chr_utf16le(CODEPOINT)>

=item C<chr_utf16be(CODEPOINT)>

=item C<chr_utf32le(CODEPOINT)>

=item C<chr_utf32be(CODEPOINT)>

=item C<chr_utf8(CODEPOINT)>

=item C<chr_utf8mod(CODEPOINT)>

=item C<chr_utfcp1047(CODEPOINT)>

=back

=head2 Numeric Value of the First Character

(Exporting: C<use Unicode::Transform qw(:ord);>)

Returns an unsigned integer value of the first character of C<STRING>.
If C<STRING> is empty or begins at a partial octet, returns C<undef>.

C<STRING> may begin at a surrogate code point [C<0xD800..0xDFFF>]
or an out-of-range code point  [C<0x110000> and greater]).

=over 4

=item C<ord_unicode(CODEPOINT)>

=item C<ord_utf16le(CODEPOINT)>

=item C<ord_utf16be(CODEPOINT)>

=item C<ord_utf32le(CODEPOINT)>

=item C<ord_utf32be(CODEPOINT)>

=item C<ord_utf8(CODEPOINT)>

=item C<ord_utf8mod(CODEPOINT)>

=item C<ord_utfcp1047(CODEPOINT)>

=back

=head1 AUTHOR

SADAHIRO Tomoyuki <SADAHIRO@cpan.org>

  http://homepage1.nifty.com/nomenclator/perl/

  Copyright(C) 2002-2003, SADAHIRO Tomoyuki. Japan. All rights reserved.

This module is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

=over 4

=item F<perlunicode>

=item UTF-EBCDIC (and UTF-8-Mod)

L<http://www.unicode.org/reports/tr16>

=back

=cut
