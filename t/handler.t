
BEGIN { $| = 1; print "1..10\n"; }
END {print "not ok 1\n" unless $loaded;}

use Unicode::Transform;
$loaded = 1;
$IsEBCDIC = ord("A") != 0x41;
print "ok 1\n";

#####

$sub = sub { sprintf "%04X", shift };
$str = "\x{10fffd}\x{110000}A";

print 1
  && "\xff\xdb\xfd\xdf110000\x41\0"	eq unicode_to_utf16le($sub, $str)
  && "\xdb\xff\xdf\xfd110000\0\x41"	eq unicode_to_utf16be($sub, $str)
  && "\xfd\xff\x10\x00110000\x41\0\0\0"	eq unicode_to_utf32le($sub, $str)
  && "\x00\x10\xff\xfd110000\0\0\0\x41"	eq unicode_to_utf32be($sub, $str)
  && "\xf4\x8f\xbf\xbd110000\x41"	eq unicode_to_utf8($sub, $str)
  && "\xf9\xa1\xbf\xbf\xbd110000\x41"	eq unicode_to_utf8mod($sub, $str)
  ? "ok" : "not ok", " 2\n";

print 1
  && "ABcccc" eq utf16le_to_unicode(sub { chr(shift) x 4 }, "\x41\0\x42\0c")
  && "ABcccc" eq utf16be_to_unicode(sub { chr(shift) x 4 }, "\0\x41\0\x42c")
  ? "ok" : "not ok", " 3\n";

print 1
  && "Aqqrrss" eq utf32le_to_unicode(sub { chr(shift) x 2 }, "\x41\0\0\0qrs")
  && "Aqqrrss" eq utf32be_to_unicode(sub { chr(shift) x 2 }, "\0\0\0\x41qrs")
  ? "ok" : "not ok", " 4\n";

print 'A± '
  eq utf8_to_unicode(sub {""},
	"\x41\xC0\x80\xC2\xB1\xC2\x20\xff")
  ? "ok" : "not ok", " 5\n";

print 'Ac080±c2 ff'
  eq utf8_to_unicode(sub { sprintf "%02x", shift },
	"\x41\xC0\x80\xC2\xB1\xC2\x20\xff")
  ? "ok" : "not ok", " 6\n";

$c1_0 = chr($IsEBCDIC ? 32 : 128);

print 'A'. $c1_0 .' '
  eq utf8_to_unicode(sub {""},
	"\x41\xC0\x80\xC2\x80\xC2\x20\xff")
  ? "ok" : "not ok", " 7\n";

print 'Ac080' . $c1_0 . 'c2 ff'
  eq utf8_to_unicode(sub { sprintf "%02x", shift },
	"\x41\xC0\x80\xC2\x80\xC2\x20\xff")
  ? "ok" : "not ok", " 8\n";

eval { $a = utf16be_to_unicode(sub { die }, "\x30\x42") }; # even

print !$@ && $a eq "\x{3042}"
  ? "ok" : "not ok", " 9\n";

eval { $a = utf16be_to_unicode(sub { die }, "\x30\x42\x30") }; # odd

print $@
  ? "ok" : "not ok", " 10\n";

