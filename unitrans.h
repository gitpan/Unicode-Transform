#ifndef UNITRANS_H
#define UNITRANS_H

/***************************************

All UTFs are limited in 0..10FFFF for roundtrap.

(i) on ASCII platform

    UTF-8 Bit pattern           1st Byte  2nd Byte  3rd Byte  4th Byte

                    0xxxxxxx    0xxxxxxx
           00000yyy yyxxxxxx    110yyyyy  10xxxxxx
           zzzzyyyy yyxxxxxx    1110zzzz  10yyyyyy  10xxxxxx
  000wwwzz zzzzyyyy yyxxxxxx    11110www  10zzzzzz  10yyyyyy  10xxxxxx

		      UTF-8   UTF8MOD       UTF-16    UTF-32
     0000..  007F	1	1	     2(2)      4(4)
     0080..  07FF	2	1/3(1.5)<2>  2         4
     0800..  FFFF	3	3/4	     2<1.5>    4
    10000..1FFFFF	4	4/5	     4         4<1>

  * (n) determines MaxLenFmUni (max. pre-expansion from UTF-8 to other)
  * <n> determines MaxLenToUni (max. pre-expansion from other to UTF-8)

(ii) on EBCDIC platform

    UTF-8-Mod Bit pattern       1st Byte 2nd Byte 3rd Byte 4th Byte 5th Byte
           00000000 0xxxxxxx    0xxxxxxx
           00000000 100xxxxx    100xxxxx
           000000yy yyyxxxxx    110yyyyy 101xxxxx
           00zzzzyy yyyxxxxx    1110zzzz 101yyyyy 101xxxxx
      00ww wzzzzzyy yyyxxxxx    11110www 101zzzzz 101yyyyy 101xxxxx
  00vvwwww wzzzzzyy yyyxxxxx    111110vv 101wwwww 101zzzzz 101yyyyy 101xxxxx

		  UTF-EBCDIC   UTF-8      UTF-16    UTF-32
     0000..  009F	1	1/2(2)	    2(2)      4(4)
     00A0..  03FF	2	2	    2         4
     0400..  3FFF	3	2/3<1.5>    2         4
     4000.. 3FFFF	4       3/4	   2/4<2>     4
    40000..3FFFFF	5       4/5	    4         4<1.25>

  * (n) determines MaxLenFmUni (max. pre-expansion from UTF-EBCDIC to another)
  * <n> determines MaxLenToUni (max. pre-expansion from another to UTF-EBCDIC)

 ***************************************/

/*for the conv from unicode to UTF-32, dstlen should be duplicated in XSUB */
#define MaxLenFmUni	(2)
#define MaxLenToUni	(2)

#define VALID_UTF_MAX		(0x10FFFF)
#define VALID_UTF(uv)		((uv) <= VALID_UTF_MAX)
#define INVALID_UTF(uv)		((uv) >  VALID_UTF_MAX)

#define UTF16_IS_SURROG(uv)	(0xD800 <= (uv) && (uv) <= 0xDFFF)
#define UTF16_HI_SURROG(uv)	(0xD800 <= (uv) && (uv) <= 0xDBFF)
#define UTF16_LO_SURROG(uv)	(0xDC00 <= (uv) && (uv) <= 0xDFFF)

#define UTF8A_SKIP(uv)	\
	( (uv) < 0x80           ? 1 : \
	  (uv) < 0x800          ? 2 : \
	  (uv) < 0x10000        ? 3 : \
	  (uv) < 0x200000       ? 4 : \
	  (uv) < 0x4000000      ? 5 : \
	  (uv) < 0x80000000     ? 6 : 7 )

#define UTF8A_TRAIL(c)	(((c) & 0xC0) == 0x80)

#define UTF8M_SKIP(uv)	\
	( (uv) < 0xA0           ? 1 : \
	  (uv) < 0x400          ? 2 : \
	  (uv) < 0x4000         ? 3 : \
	  (uv) < 0x40000        ? 4 : \
	  (uv) < 0x400000       ? 5 : \
	  (uv) < 0x4000000      ? 6 : 7 )

#define UTF8M_TRAIL(c)	(((c) & 0xE0) == 0xA0)

UV
ord_in_utf16le(U8 *s, STRLEN curlen, STRLEN *retlen)
{
    UV uv, luv;
    U8 *p = s;

    if (curlen < 2) {
	if (retlen)
	    *retlen = 0;
	return 0;
    }

    uv = (UV)((p[1] << 8) | p[0]);
    p += 2;

    if (UTF16_HI_SURROG(uv) && (4 <= curlen)) {
	luv = (UV)((p[1] << 8) | p[0]);

	if (UTF16_LO_SURROG(luv)) {
	    uv = 0x10000 + ((uv-0xD800) * 0x400) + (luv-0xDC00);
	    p += 2;
	}
    }

    if (retlen)
	*retlen = p - s;
    return uv;
}


UV
ord_in_utf16be(U8 *s, STRLEN curlen, STRLEN *retlen)
{
    UV uv, luv;
    U8 *p = s;

    if (curlen < 2) {
	if (retlen)
	    *retlen = 0;
	return 0;
    }

    uv = (UV)((p[0] << 8) | p[1]);
    p += 2;

    if (UTF16_HI_SURROG(uv) && (4 <= curlen)) {
	luv = (UV)((p[0] << 8) | p[1]);

	if (UTF16_LO_SURROG(luv)) {
	    uv = 0x10000 + ((uv-0xD800) * 0x400) + (luv-0xDC00);
	    p += 2;
	}
    }

    if (retlen)
	*retlen = p - s;
    return uv;
}


UV
ord_in_utf32le(U8 *s, STRLEN curlen, STRLEN *retlen)
{
    if (curlen < 4) {
	if (retlen)
	    *retlen = 0;
	return 0;
    }

    if (retlen)
	*retlen = 4;
    return (UV)((s[3] << 24) | (s[2] << 16) | (s[1] << 8) | s[0]);
}


UV
ord_in_utf32be(U8 *s, STRLEN curlen, STRLEN *retlen)
{
    if (curlen < 4) {
	if (retlen)
	    *retlen = 0;
	return 0;
    }

    if (retlen)
	*retlen = 4;
    return (UV)((s[0] << 24) | (s[1] << 16) | (s[2] << 8) | s[3]);
}


UV
ord_in_utf8(U8 *s, STRLEN curlen, STRLEN *retlen)
{
    UV uv = 0;
    int len, i;

    if (*s < 0x80) {
	uv = (UV)*s;
	len = 1;
    }
    else if (*s < 0xC0) {
	len = 0;
    }
    else if (*s < 0xE0) {
	uv = (UV)(((s[0] & 0x1f) << 6) | (s[1] & 0x3f));
	len = 2;
    }
    else if (*s < 0xF0) {
	uv = (UV)(((s[0] & 0x0f) << 12) |
		  ((s[1] & 0x3f) <<  6) | (s[2] & 0x3f));
	len = 3;
    }
    else if (*s < 0xF8) {
	uv = (UV)(((s[0] & 0x07) << 18) | ((s[1] & 0x3f) << 12) |
		  ((s[2] & 0x3f) <<  6) |  (s[3] & 0x3f));
	len = 4;
    }
    else
	len = 0;

    for (i = 1; i < len; i++)
	if (!UTF8A_TRAIL(s[i])) {
	    len = 0;
	    break;
	}

    if (len != UTF8A_SKIP(uv))
	len = 0;

    if (retlen)
	*retlen = (STRLEN)len;
    return uv;
}


UV
ord_in_utf8mod(U8 *s, STRLEN curlen, STRLEN *retlen)
{
    UV uv = 0;
    int len, i;

    if (*s < 0xA0) {
	uv = (UV)*s;
	len = 1;
    }
    else if (*s < 0xC0) {
	len = 0;
    }
    else if (*s < 0xE0) {
	uv = (UV)(((s[0] & 0x1f) << 5) | (s[1] & 0x1f));
	len = 2;
    }
    else if (*s < 0xF0) {
	uv = (UV)(((s[0] & 0x0f) << 10) |
		  ((s[1] & 0x1f) <<  5) | (s[2] & 0x1f));
	len = 3;
    }
    else if (*s < 0xF8) {
	uv = (UV)(((s[0] & 0x07) << 15) | ((s[1] & 0x1f) << 10) |
		  ((s[2] & 0x1f) <<  5) |  (s[3] & 0x1f));
	len = 4;
    }
    else if (*s < 0xFC) {
	uv = (UV)(((s[0] & 0x03) << 20) | ((s[1] & 0x1f) << 15) |
		  ((s[2] & 0x1f) << 10) | ((s[3] & 0x1f) <<  5) |
		   (s[4] & 0x1f));
	len = 5;
    }
    else
	len = 0;

    for (i = 1; i < len; i++)
	if (!UTF8M_TRAIL(s[i])) {
	    len = 0;
	    break;
	}

    if (len != UTF8M_SKIP(uv))
	len = 0;

    if (retlen)
	*retlen = (STRLEN)len;
    return uv;
}


STRLEN
app_in_utf16le(U8* s, UV uv)
{
    if (uv <= 0xFFFF) {
	*s++ = (U8)(uv & 0xff);
	*s++ = (U8)(uv >> 8);
	return 2;
    }
    else if (VALID_UTF(uv)) {
	int hi, lo;
	uv -= 0x10000;
	hi = (0xD800 | (uv >> 10));
	lo = (0xDC00 | (uv & 0x3FF));
	*s++ = (U8)(hi & 0xff);
	*s++ = (U8)(hi >> 8);
	*s++ = (U8)(lo & 0xff);
	*s++ = (U8)(lo >> 8);
	return 4;
    }
    else
	return 0;
}


STRLEN
app_in_utf16be(U8* s, UV uv)
{
    if (uv <= 0xFFFF) {
	*s++ = (U8)(uv >> 8);
	*s++ = (U8)(uv & 0xff);
	return 2;
    }
    else if (VALID_UTF(uv)) {
	int hi, lo;
	uv -= 0x10000;
	hi = (0xD800 | (uv >> 10));
	lo = (0xDC00 | (uv & 0x3FF));
	*s++ = (U8)(hi >> 8);
	*s++ = (U8)(hi & 0xff);
	*s++ = (U8)(lo >> 8);
	*s++ = (U8)(lo & 0xff);
	return 4;
    }
    else
	return 0;
}


STRLEN
app_in_utf32le(U8* s, UV uv)
{
    if (VALID_UTF(uv)) {
	*s++ = (U8)((uv      ) & 0xff);
	*s++ = (U8)((uv >>  8) & 0xff);
	*s++ = (U8)((uv >> 16) & 0xff);
	*s++ = (U8)((uv >> 24) & 0xff);
	return 4;
    }
    else
	return 0;
}


STRLEN
app_in_utf32be(U8* s, UV uv)
{
    if (VALID_UTF(uv)) {
	*s++ = (U8)((uv >> 24) & 0xff);
	*s++ = (U8)((uv >> 16) & 0xff);
	*s++ = (U8)((uv >>  8) & 0xff);
	*s++ = (U8)((uv      ) & 0xff);
	return 4;
    }
    else
	return 0;
}


STRLEN
app_in_utf8(U8* s, UV uv)
{
    if (uv < 0x80) {
	*s++ = (U8)(uv & 0xff);
	return 1;
    }
    if (uv < 0x800) {
	*s++ = (U8)(( uv >>  6)         | 0xc0);
	*s++ = (U8)(( uv        & 0x3f) | 0x80);
	return 2;
    }
    if (uv < 0x10000) {
	*s++ = (U8)(( uv >> 12)         | 0xe0);
	*s++ = (U8)(((uv >>  6) & 0x3f) | 0x80);
	*s++ = (U8)(( uv        & 0x3f) | 0x80);
	return 3;
    }
    if (uv < 0x200000) {
	*s++ = (U8)(( uv >> 18)         | 0xf0);
	*s++ = (U8)(((uv >> 12) & 0x3f) | 0x80);
	*s++ = (U8)(((uv >>  6) & 0x3f) | 0x80);
	*s++ = (U8)(( uv        & 0x3f) | 0x80);
	return 4;
    }
    return 0;
}


STRLEN
app_in_utf8mod(U8* s, UV uv)
{
    if (uv < 0xa0) {
	*s++ = (U8)(uv & 0xff);
	return 1;
    }
    if (uv < 0x400) {
	*s++ = (U8)(( uv >>  5)         | 0xc0);
	*s++ = (U8)(( uv        & 0x1f) | 0xa0);
	return 2;
    }
    if (uv < 0x4000) {
	*s++ = (U8)(( uv >> 10)         | 0xe0);
	*s++ = (U8)(((uv >>  5) & 0x1f) | 0xa0);
	*s++ = (U8)(( uv        & 0x1f) | 0xa0);
	return 3;
    }
    if (uv < 0x40000) {
	*s++ = (U8)(( uv >> 15)         | 0xf0);
	*s++ = (U8)(((uv >> 10) & 0x1f) | 0xa0);
	*s++ = (U8)(((uv >>  5) & 0x1f) | 0xa0);
	*s++ = (U8)(( uv        & 0x1f) | 0xa0);
	return 4;
    }
    if (uv < 0x400000) {
	*s++ = (U8)(( uv >> 20)         | 0xf8);
	*s++ = (U8)(((uv >> 15) & 0x1f) | 0xa0);
	*s++ = (U8)(((uv >> 10) & 0x1f) | 0xa0);
	*s++ = (U8)(((uv >>  5) & 0x1f) | 0xa0);
	*s++ = (U8)(( uv        & 0x1f) | 0xa0);
	return 5;
    }
    return 0;
}


unsigned char utf_to_i8_cp1047[] = {
  0x00, 0x01, 0x02, 0x03, 0x37, 0x2D, 0x2E, 0x2F,
  0x16, 0x05, 0x15, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F,
  0x10, 0x11, 0x12, 0x13, 0x3C, 0x3D, 0x32, 0x26,
  0x18, 0x19, 0x3F, 0x27, 0x1C, 0x1D, 0x1E, 0x1F,
  0x40, 0x5A, 0x7F, 0x7B, 0x5B, 0x6C, 0x50, 0x7D,
  0x4D, 0x5D, 0x5C, 0x4E, 0x6B, 0x60, 0x4B, 0x61,
  0xF0, 0xF1, 0xF2, 0xF3, 0xF4, 0xF5, 0xF6, 0xF7,
  0xF8, 0xF9, 0x7A, 0x5E, 0x4C, 0x7E, 0x6E, 0x6F,

  0x7C, 0xC1, 0xC2, 0xC3, 0xC4, 0xC5, 0xC6, 0xC7,
  0xC8, 0xC9, 0xD1, 0xD2, 0xD3, 0xD4, 0xD5, 0xD6,
  0xD7, 0xD8, 0xD9, 0xE2, 0xE3, 0xE4, 0xE5, 0xE6,
  0xE7, 0xE8, 0xE9, 0xAD, 0xE0, 0xBD, 0x5F, 0x6D,
  0x79, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87,
  0x88, 0x89, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96,
  0x97, 0x98, 0x99, 0xA2, 0xA3, 0xA4, 0xA5, 0xA6,
  0xA7, 0xA8, 0xA9, 0xC0, 0x4F, 0xD0, 0xA1, 0x07,

  0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x06, 0x17,
  0x28, 0x29, 0x2A, 0x2B, 0x2C, 0x09, 0x0A, 0x1B,
  0x30, 0x31, 0x1A, 0x33, 0x34, 0x35, 0x36, 0x08,
  0x38, 0x39, 0x3A, 0x3B, 0x04, 0x14, 0x3E, 0xFF,
  0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48,
  0x49, 0x4A, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56,
  0x57, 0x58, 0x59, 0x62, 0x63, 0x64, 0x65, 0x66,
  0x67, 0x68, 0x69, 0x6A, 0x70, 0x71, 0x72, 0x73,

  0x74, 0x75, 0x76, 0x77, 0x78, 0x80, 0x8A, 0x8B,
  0x8C, 0x8D, 0x8E, 0x8F, 0x90, 0x9A, 0x9B, 0x9C,
  0x9D, 0x9E, 0x9F, 0xA0, 0xAA, 0xAB, 0xAC, 0xAE,
  0xAF, 0xB0, 0xB1, 0xB2, 0xB3, 0xB4, 0xB5, 0xB6,
  0xB7, 0xB8, 0xB9, 0xBA, 0xBB, 0xBC, 0xBE, 0xBF,
  0xCA, 0xCB, 0xCC, 0xCD, 0xCE, 0xCF, 0xDA, 0xDB,
  0xDC, 0xDD, 0xDE, 0xDF, 0xE1, 0xEA, 0xEB, 0xEC,
  0xED, 0xEE, 0xEF, 0xFA, 0xFB, 0xFC, 0xFD, 0xFE,
};

unsigned char i8_to_utf_cp1047[] = {
  0x00, 0x01, 0x02, 0x03, 0x9C, 0x09, 0x86, 0x7F,
  0x97, 0x8D, 0x8E, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F,
  0x10, 0x11, 0x12, 0x13, 0x9D, 0x0A, 0x08, 0x87,
  0x18, 0x19, 0x92, 0x8F, 0x1C, 0x1D, 0x1E, 0x1F,
  0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x17, 0x1B,
  0x88, 0x89, 0x8A, 0x8B, 0x8C, 0x05, 0x06, 0x07,
  0x90, 0x91, 0x16, 0x93, 0x94, 0x95, 0x96, 0x04,
  0x98, 0x99, 0x9A, 0x9B, 0x14, 0x15, 0x9E, 0x1A,

  0x20, 0xA0, 0xA1, 0xA2, 0xA3, 0xA4, 0xA5, 0xA6,
  0xA7, 0xA8, 0xA9, 0x2E, 0x3C, 0x28, 0x2B, 0x7C,
  0x26, 0xAA, 0xAB, 0xAC, 0xAD, 0xAE, 0xAF, 0xB0,
  0xB1, 0xB2, 0x21, 0x24, 0x2A, 0x29, 0x3B, 0x5E,
  0x2D, 0x2F, 0xB3, 0xB4, 0xB5, 0xB6, 0xB7, 0xB8,
  0xB9, 0xBA, 0xBB, 0x2C, 0x25, 0x5F, 0x3E, 0x3F,
  0xBC, 0xBD, 0xBE, 0xBF, 0xC0, 0xC1, 0xC2, 0xC3,
  0xC4, 0x60, 0x3A, 0x23, 0x40, 0x27, 0x3D, 0x22,

  0xC5, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67,
  0x68, 0x69, 0xC6, 0xC7, 0xC8, 0xC9, 0xCA, 0xCB,
  0xCC, 0x6A, 0x6B, 0x6C, 0x6D, 0x6E, 0x6F, 0x70,
  0x71, 0x72, 0xCD, 0xCE, 0xCF, 0xD0, 0xD1, 0xD2,
  0xD3, 0x7E, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78,
  0x79, 0x7A, 0xD4, 0xD5, 0xD6, 0x5B, 0xD7, 0xD8,
  0xD9, 0xDA, 0xDB, 0xDC, 0xDD, 0xDE, 0xDF, 0xE0,
  0xE1, 0xE2, 0xE3, 0xE4, 0xE5, 0x5D, 0xE6, 0xE7,

  0x7B, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47,
  0x48, 0x49, 0xE8, 0xE9, 0xEA, 0xEB, 0xEC, 0xED,
  0x7D, 0x4A, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F, 0x50,
  0x51, 0x52, 0xEE, 0xEF, 0xF0, 0xF1, 0xF2, 0xF3,
  0x5C, 0xF4, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58,
  0x59, 0x5A, 0xF5, 0xF6, 0xF7, 0xF8, 0xF9, 0xFA,
  0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37,
  0x38, 0x39, 0xFB, 0xFC, 0xFD, 0xFE, 0xFF, 0x9F,
};

#endif
