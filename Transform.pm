package Unicode::Transform;

require 5.006;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

require Exporter;
require DynaLoader;
require AutoLoader;

@ISA = qw(Exporter DynaLoader);

our %EXPORT_TAGS = (
    'from' => [
	qw/unicode_to_utf16le	unicode_to_utf16be	unicode_to_utf32le
	   unicode_to_utf32be	unicode_to_utf8		unicode_to_utf8mod
	   unicode_to_utfcp1047
	/ ],
    'to' => [
	qw/utf16le_to_unicode	utf16be_to_unicode	utf32le_to_unicode
	   utf32be_to_unicode	utf8_to_unicode		utf8mod_to_unicode
	   utfcp1047_to_unicode
	/ ],

# not tested.
    'chr' => [
	qw/chr_utf16le	chr_utf16be	chr_utf32le	chr_utf32be
	   chr_utf8	chr_utf8mod	chr_utfcp1047
	/ ],

# not implemented.
#    'ord' => [
#	qw/ord_utf16le	ord_utf16be	ord_utf32le	ord_utf32be
#	   ord_utf8	ord_utf8mod	ord_utfcp1047
#	/ ],
);

$EXPORT_TAGS{all}  = [ map @$_, values %EXPORT_TAGS ];

@EXPORT_OK = @{ $EXPORT_TAGS{all} };
@EXPORT = (map @$_, @EXPORT_TAGS{qw(from to)});

$VERSION = '0.21';

bootstrap Unicode::Transform $VERSION;

1;
__END__

=head1 NAME

Unicode::Transform - conversion among Unicode Transformation Formats (UTFs)

=head1 SYNOPSIS

    use Unicode::Transform;

    $unicode_string = utf16be_to_unicode($utf16be_string);
    $utf16le_string = unicode_to_utf16le($unicode_string);

=head1 DESCRIPTION

This module provides some functions to convert a string
among some Unicode Transformation Formats (UTFs).

=head2 conversion from UTF to Perl internal's Unicode format

C<STRING> is the source string.

If C<CODEREF> is omitted,
any partial octets are deleted.

If C<CODEREF> is specified,
the appearance of a partial octet calls it
with an argument the value of which is an integer of its octet code point,
and the return value of that is inserted.

(You can call C<die> or C<croak> in C<CODEREF>
if you want to trap an ill-formed source.)

=over 4

=item C<utf16le_to_unicode([CODEREF,] STRING)>

Converts UTF-16LE to Unicode (Perl internal's Unicode format).

=item C<utf16be_to_unicode([CODEREF,] STRING)>

Converts UTF-16BE to Unicode.

=item C<utf32le_to_unicode([CODEREF,] STRING)>

Converts UTF-32LE to Unicode.

=item C<utf32be_to_unicode([CODEREF,] STRING)>

Converts UTF-32BE to Unicode.

=item C<utf8_to_unicode([CODEREF,] STRING)>

Converts UTF-8 to Unicode.

=item C<utf8mod_to_unicode([CODEREF,] STRING)>

Converts UTF-8-Mod to Unicode.

=item C<utfcp1047_to_unicode([CODEREF,] STRING)>

Converts UTF-EBCDIC (for CP1047) to Unicode.

=back

=head2 conversion from Perl Internal's Unicode format to UTF

C<STRING> is the source string.

If C<CODEREF> is omitted,
any UTF-illegal characters (high and low surrogate characters,
and code points over C<0x10FFFF>) are deleted.

If C<CODEREF> is specified,
the appearance of a UTF-illegal character calls it
with an argument the value of which is an integer of its Unicode code point,
and the return value of that is inserted.

=over 4

=item C<unicode_to_utf16le([CODEREF,] STRING)>

Converts UTF-16LE to Unicode.

=item C<unicode_to_utf16be([CODEREF,] STRING)>

Converts UTF-16BE to Unicode.

=item C<unicode_to_utf32le([CODEREF,] STRING)>

Converts UTF-32LE to Unicode.

=item C<unicode_to_utf32be([CODEREF,] STRING)>

Converts UTF-32BE to Unicode.

=item C<unicode_to_utf8([CODEREF,] STRING)>

Converts UTF-8 to Unicode.

=item C<unicode_to_utf8mod([CODEREF,] STRING)>

Converts UTF-8-Mod to Unicode.

=item C<unicode_to_utfcp1047([CODEREF,] STRING)>

Converts UTF-EBCDIC (for CP1047) to Unicode.

=back

=head1 AUTHOR

SADAHIRO Tomoyuki, E<lt>SADAHIRO@cpan.orgE<gt>

  http://homepage1.nifty.com/nomenclator/perl/

  Copyright(C) 2002-2003, SADAHIRO Tomoyuki. Japan. All rights reserved.

This module is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

=over 4

=item F<perlunicode>

=item L<http://www.unicode.org/reports/tr16>

UTF-EBCDIC and UTF-8-Mod

=back

=cut
