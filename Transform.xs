#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#define PkgName "Unicode::Transform"

/* Some functions are defined in this. */
#include "unitrans.h"

/* Perl 5.6.1 ? */
#ifndef uvuni_to_utf8
#define uvuni_to_utf8   uv_to_utf8
#endif /* uvuni_to_utf8 */

/* Perl 5.6.1 ? */
#ifndef utf8n_to_uvuni
#define utf8n_to_uvuni  utf8_to_uv
#endif /* utf8n_to_uvuni */

static UV (*ord_uv_in[])(U8 *, STRLEN, STRLEN *) = {
    ord_in_utf16le,
    ord_in_utf16be,
    ord_in_utf32le,
    ord_in_utf32be,
    ord_in_utf8,
    ord_in_utf8mod,
    ord_in_utfcp1047,
};

static U8* (*app_uv_in[])(U8 *, UV) = {
    app_in_utf16le,
    app_in_utf16be,
    app_in_utf32le,
    app_in_utf32be,
    app_in_utf8,
    app_in_utf8mod,
    app_in_utfcp1047,
};


static void
sv_cat_retcvref (SV *dst, SV *cv, SV *sv)
{
    dSP;
    int count;
    ENTER;
    SAVETMPS;
    PUSHMARK(SP);
    XPUSHs(sv_2mortal(sv));
    PUTBACK;
    count = call_sv(cv, G_EVAL|G_SCALAR);
    SPAGAIN;
    if (SvTRUE(ERRSV) || count != 1) {
	croak("died in XS, " PkgName "\n");
    }
    sv_catsv(dst,POPs);
    PUTBACK;
    FREETMPS;
    LEAVE;
}

MODULE = Unicode::Transform	PACKAGE = Unicode::Transform

void
utf16le_to_unicode (arg1, arg2=0)
    SV* arg1
    SV* arg2
  PROTOTYPE: $;$
  ALIAS:
    utf16be_to_unicode = 1
    utf32le_to_unicode = 2
    utf32be_to_unicode = 3
       utf8_to_unicode = 4
    utf8mod_to_unicode = 5
    utfcp1047_to_unicode = 6
  PREINIT:
    SV *src, *dst, *cvref;
    STRLEN srclen, dstlen, retlen, ulen;
    U8 *s, *e, *p, *d, ubuf[UTF8_MAXLEN + 1];
    UV uv;
    UV (*ord_uv)(U8 *, STRLEN, STRLEN *);
  PPCODE:
    cvref = NULL;
    if (items == 2)
	if (SvROK(arg1) && SvTYPE(SvRV(arg1)) == SVt_PVCV)
	    cvref = SvRV(arg1);
	else
	    croak(PkgName " 1st argument is not CODEREF");

    src = cvref ? arg2 : arg1;

    if (SvUTF8(src)) {
	src = sv_mortalcopy(src);
	sv_utf8_downgrade(src, 0);
    }

    s = (U8*)SvPV(src,srclen);
    e = s + srclen;

    dstlen = srclen * MaxLenUni + 1;

    dst = sv_2mortal(newSV(dstlen));
    (void)SvPOK_only(dst);
    SvUTF8_on(dst);

    ord_uv = ord_uv_in[ix];

    if (cvref) {
	for (p = s; p < e;) {
	    uv = ord_uv(p, e - p, &retlen);

	    if (retlen)
		p += retlen;
	    else
		uv = (UV)*p++;

	    if (retlen && !UTF16_IS_SURROG(uv) && Is_VALID_UTF(uv)) {
		ulen = uvuni_to_utf8(ubuf, uv) - ubuf;
		sv_catpvn(dst, (char*)ubuf, ulen);
	    }
	    else
		sv_cat_retcvref(dst, cvref, newSVuv(uv));
	}
    }
    else {
	d = (U8*)SvPVX(dst);

	for (p = s; p < e;) {
	    uv = ord_uv(p, e - p, &retlen);

	    if (retlen)
		p += retlen;
	    else {
		p++;
		continue;
	    }

	    if (!UTF16_IS_SURROG(uv) && Is_VALID_UTF(uv))
		d = uvuni_to_utf8(d, uv);
	}
	*d = '\0';
	SvCUR_set(dst, d - (U8*)SvPVX(dst));
    }
    XPUSHs(dst);


void
unicode_to_utf16le (arg1, arg2=0)
    SV* arg1
    SV* arg2
  PROTOTYPE: $;$
  ALIAS:
    unicode_to_utf16be = 1
    unicode_to_utf32le = 2
    unicode_to_utf32be = 3
    unicode_to_utf8    = 4
    unicode_to_utf8mod = 5
    unicode_to_utfcp1047 = 6
  PREINIT:
    SV *src, *dst, *cvref;
    STRLEN srclen, dstlen, retlen, ulen;
    U8 *s, *e, *p, *d, ubuf[UTF8_MAXLEN + 1];
    UV uv;
    U8* (*app_uv)(U8*, UV);
    bool touni32;
  PPCODE:
    cvref = NULL;
    if (items == 2)
	if (SvROK(arg1) && SvTYPE(SvRV(arg1)) == SVt_PVCV)
	    cvref = SvRV(arg1);
	else
	    croak(PkgName " 1st argument is not CODEREF");

    src = cvref ? arg2 : arg1;

    touni32 = ix == 2 || ix == 3;

    if (!SvUTF8(src)) {
	src = sv_mortalcopy(src);
	sv_utf8_upgrade(src);
    }

    s = (U8*)SvPV(src,srclen);
    e = s + srclen;

    dstlen = srclen * MaxLenUni + 1;
    if (touni32)
	dstlen *= 2;

    dst = sv_2mortal(newSV(dstlen));
    (void)SvPOK_only(dst);

    app_uv = app_uv_in[ix];

    if (cvref) {
	for (p = s; p < e;) {
	    uv = utf8n_to_uvuni(p, e - p, &retlen, 0);

	    if (retlen)
		p += retlen;
	    else
		uv = (UV)*p++;

	    if (retlen && !UTF16_IS_SURROG(uv) && Is_VALID_UTF(uv)) {
		ulen = app_uv(ubuf, uv) - ubuf;
		sv_catpvn(dst, (char*)ubuf, ulen);
	    }
	    else
		sv_cat_retcvref(dst, cvref, newSVuv(uv));
	}
    }
    else {
	d = (U8*)SvPVX(dst);

	for (p = s; p < e;) {
	    uv = utf8n_to_uvuni(p, e - p, &retlen, 0);

	    if (retlen)
		p += retlen;
	    else {
		p++;
		continue;
	    }

	    if (!UTF16_IS_SURROG(uv) && Is_VALID_UTF(uv))
		d = app_uv(d, uv);
	}
	*d = '\0';
	SvCUR_set(dst, d - (U8*)SvPVX(dst));
    }
    XPUSHs(dst);



SV*
chr_utf16le (uv)
    UV  uv
  PROTOTYPE: $
  ALIAS:
    chr_utf16be = 1
    chr_utf32le = 2
    chr_utf32be = 3
    chr_utf8    = 4
    chr_utf8mod = 5
    chr_utfcp1047 = 6
  PREINIT:
    SV *dst;
    U8 *u, ubuf[UTF8_MAXLEN + 1];
    U8* (*app_uv)(U8*, UV);
  CODE:
    if (UTF16_IS_SURROG(uv) || !Is_VALID_UTF(uv))
	XSRETURN_UNDEF;

    dst = newSVpvn("", 0);
    (void)SvPOK_only(dst);

    app_uv = app_uv_in[ix];
    u = app_uv(ubuf, uv);
    if (u == ubuf)
	XSRETURN_UNDEF;

    sv_catpvn(dst, (char*)ubuf, u - ubuf);
    RETVAL = dst;
  OUTPUT:
    RETVAL


SV*
ord_utf16le (src)
    SV* src
  PROTOTYPE: $
  ALIAS:
    ord_utf16be = 1
    ord_utf32le = 2
    ord_utf32be = 3
    ord_utf8    = 4
    ord_utf8mod = 5
    ord_utfcp1047 = 6
  PREINIT:
    STRLEN srclen, retlen;
    U8 *s;
    UV uv;
    UV (*ord_uv)(U8 *, STRLEN, STRLEN *);
  CODE:
    if (SvUTF8(src)) {
	src = sv_mortalcopy(src);
	sv_utf8_downgrade(src, 0);
    }

    s = (U8*)SvPV(src,srclen);
    ord_uv = ord_uv_in[ix];
    uv = ord_uv(s, srclen, &retlen);

    RETVAL = (retlen && !UTF16_IS_SURROG(uv) && Is_VALID_UTF(uv))
	? newSVuv(uv) : &PL_sv_undef;
  OUTPUT:
    RETVAL

