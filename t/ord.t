
BEGIN { $| = 1; print "1..35\n"; }

use Unicode::Transform qw(:ord);
use strict;
use warnings;

print "ok 1\n";

#####

# returns undef if string is empty or begins at an illegal char.

print ord_utf16be("\x00\x00") == 0
   ? "ok" : "not ok", " 2\n";

print ord_utf16le("\x00\x00") == 0
   ? "ok" : "not ok", " 3\n";

print ord_utf32be("\0\0\0\0") == 0
   ? "ok" : "not ok", " 4\n";

print ord_utf32le("\0\0\0\0") == 0
   ? "ok" : "not ok", " 5\n";

print ord_utf8("\x00") == 0
   ? "ok" : "not ok", " 6\n";

print ord_utf8mod("\x00") == 0
   ? "ok" : "not ok", " 7\n";

print ord_utfcp1047("\x00") == 0
   ? "ok" : "not ok", " 8\n";

print !defined ord_utf16be("")
   ? "ok" : "not ok", " 9\n";

print !defined ord_utf16le("")
   ? "ok" : "not ok", " 10\n";

print !defined ord_utf32be("")
   ? "ok" : "not ok", " 11\n";

print !defined ord_utf32le("")
   ? "ok" : "not ok", " 12\n";

print !defined ord_utf8("")
   ? "ok" : "not ok", " 13\n";

print !defined ord_utf8mod("")
   ? "ok" : "not ok", " 14\n";

print !defined ord_utfcp1047("")
   ? "ok" : "not ok", " 15\n";

print ord_utf16be("\xFE\xFF") == 0xFEFF
   ? "ok" : "not ok", " 16\n";

print ord_utf16le("\xFF\xFE") == 0xFEFF
   ? "ok" : "not ok", " 17\n";

print ord_utf32be("\0\0\xFE\xFF") == 0xFEFF
   ? "ok" : "not ok", " 18\n";

print ord_utf32le("\xFF\xFE\0\0") == 0xFEFF
   ? "ok" : "not ok", " 19\n";

print ord_utf8("\xef\xbb\xbf") == 0xFEFF
   ? "ok" : "not ok", " 20\n";

print ord_utf8mod("\xf1\xbf\xb7\xbf") == 0xFEFF
   ? "ok" : "not ok", " 21\n";

print ord_utfcp1047("\xdd\x73\x66\x73") == 0xFEFF
   ? "ok" : "not ok", " 22\n";

print ord_utf16be("\xD8\x08\xDF\x45") == 0x12345
   ? "ok" : "not ok", " 23\n";

print ord_utf16le("\x08\xD8\x45\xDF") == 0x12345
   ? "ok" : "not ok", " 24\n";

print ord_utf32be("\x00\x01\x23\x45") == 0x12345
   ? "ok" : "not ok", " 25\n";

print ord_utf32le("\x45\x23\x01\x00") == 0x12345
   ? "ok" : "not ok", " 26\n";

print ord_utf8("\320\261") == 0x0431
   ? "ok" : "not ok", " 27\n";

print ord_utf8("\316\261") == 0x03B1
   ? "ok" : "not ok", " 28\n";

print ord_utf8("\327\221") == 0x05D1
   ? "ok" : "not ok", " 29\n";

print ord_utf8("\360\220\221\215") == 0x1044D
   ? "ok" : "not ok", " 30\n";

print ord_utfcp1047("\301") == 0x41
   ? "ok" : "not ok", " 31\n";

print ord_utfcp1047("\270\102\130") == 0x0431
   ? "ok" : "not ok", " 32\n";

print ord_utfcp1047("\264\130") == 0x03B1
   ? "ok" : "not ok", " 33\n";

print ord_utfcp1047("\270\125\130") == 0x05D1
   ? "ok" : "not ok", " 34\n";

print ord_utfcp1047("\336\102\103\124") == 0x1044D
   ? "ok" : "not ok", " 35\n";

