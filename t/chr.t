
BEGIN { $| = 1; print "1..35\n"; }

use Unicode::Transform qw(:chr);
use strict;
use warnings;

print "ok 1\n";

#####

print "\x00\x00" eq chr_utf16be(0)
   ? "ok" : "not ok", " 2\n";

print "\x00\x00" eq chr_utf16le(0)
   ? "ok" : "not ok", " 3\n";

print "\0\0\0\0" eq chr_utf32be(0)
   ? "ok" : "not ok", " 4\n";

print "\0\0\0\0" eq chr_utf32le(0)
   ? "ok" : "not ok", " 5\n";

print "\x00" eq chr_utf8(0)
   ? "ok" : "not ok", " 6\n";

print "\x00" eq chr_utf8mod(0)
   ? "ok" : "not ok", " 7\n";

print "\x00" eq chr_utfcp1047(0)
   ? "ok" : "not ok", " 8\n";

print !defined chr_utf16be(0x110000)
   && !defined chr_utf16be(0xD800)
   && !defined chr_utf16be(0xDFFF)
   ? "ok" : "not ok", " 9\n";

print !defined chr_utf16le(0x110000)
   && !defined chr_utf16le(0xD800)
   && !defined chr_utf16le(0xDFFF)
   ? "ok" : "not ok", " 10\n";

print !defined chr_utf32be(0x110000)
   && !defined chr_utf32be(0xD800)
   && !defined chr_utf32be(0xDFFF)
   ? "ok" : "not ok", " 11\n";

print !defined chr_utf32le(0x110000)
   && !defined chr_utf32le(0xD800)
   && !defined chr_utf32le(0xDFFF)
   ? "ok" : "not ok", " 12\n";

print !defined chr_utf8(0x110000)
   && !defined chr_utf8(0xD800)
   && !defined chr_utf8(0xDFFF)
   ? "ok" : "not ok", " 13\n";

print !defined chr_utf8mod(0x110000)
   && !defined chr_utf8mod(0xD800)
   && !defined chr_utf8mod(0xDFFF)
   ? "ok" : "not ok", " 14\n";

print !defined chr_utfcp1047(0x110000)
   && !defined chr_utfcp1047(0xD800)
   && !defined chr_utfcp1047(0xDFFF)
   ? "ok" : "not ok", " 15\n";

print "\xFE\xFF" eq chr_utf16be(0xFEFF)
   ? "ok" : "not ok", " 16\n";

print "\xFF\xFE" eq chr_utf16le(0xFEFF)
   ? "ok" : "not ok", " 17\n";

print "\0\0\xFE\xFF" eq chr_utf32be(0xFEFF)
   ? "ok" : "not ok", " 18\n";

print "\xFF\xFE\0\0" eq chr_utf32le(0xFEFF)
   ? "ok" : "not ok", " 19\n";

print "\xef\xbb\xbf" eq chr_utf8(0xFEFF)
   ? "ok" : "not ok", " 20\n";

print "\xf1\xbf\xb7\xbf" eq chr_utf8mod(0xFEFF)
   ? "ok" : "not ok", " 21\n";

print "\xdd\x73\x66\x73" eq chr_utfcp1047(0xFEFF)
   ? "ok" : "not ok", " 22\n";

print "\xD8\x08\xDF\x45" eq chr_utf16be(0x12345)
   ? "ok" : "not ok", " 23\n";

print "\x08\xD8\x45\xDF" eq chr_utf16le(0x12345)
   ? "ok" : "not ok", " 24\n";

print "\x00\x01\x23\x45" eq chr_utf32be(0x12345)
   ? "ok" : "not ok", " 25\n";

print "\x45\x23\x01\x00" eq chr_utf32le(0x12345)
   ? "ok" : "not ok", " 26\n";

print "\320\261" eq chr_utf8(0x0431)
   ? "ok" : "not ok", " 27\n";

print "\316\261" eq chr_utf8(0x03B1)
   ? "ok" : "not ok", " 28\n";

print "\327\221" eq chr_utf8(0x05D1)
   ? "ok" : "not ok", " 29\n";

print "\360\220\221\215" eq chr_utf8(0x1044D)
   ? "ok" : "not ok", " 30\n";

print "\301" eq chr_utfcp1047(0x41)
   ? "ok" : "not ok", " 31\n";

print "\270\102\130" eq chr_utfcp1047(0x0431)
   ? "ok" : "not ok", " 32\n";

print "\264\130"  eq chr_utfcp1047(0x03B1)
   ? "ok" : "not ok", " 33\n";

print "\270\125\130" eq chr_utfcp1047(0x05D1)
   ? "ok" : "not ok", " 34\n";

print "\336\102\103\124" eq chr_utfcp1047(0x1044D)
   ? "ok" : "not ok", " 35\n";

