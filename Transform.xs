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
    ord_in_utf8mod, /* CP-1047 */
};

static STRLEN (*app_uv_in[])(U8 *, UV) = {
    app_in_utf16le,
    app_in_utf16be,
    app_in_utf32le,
    app_in_utf32be,
    app_in_utf8,
    app_in_utf8mod,
    app_in_utf8mod, /* CP-1047 */
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
    count = call_sv(cv, G_SCALAR);
    SPAGAIN;
    if (count != 1)
	croak("Panic in XS, " PkgName "\n");
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
    STRLEN srclen, dstlen, retlen;
    U8 *s, *e, *p, *d, uni[UTF8_MAXLEN + 1];
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
    else if (5 < ix) { /* UTF-EBCDIC */
	src = sv_mortalcopy(src);
    }

    s = (U8*)SvPV(src,srclen);
    e = s + srclen;

    if (5 < ix) {
	for (p = s; p < e; p++)
	    *p = (U8)i8_to_utf_cp1047[*p];
    }

    dstlen = srclen * MaxLenFmUni + 1;

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

	    if (retlen && !UTF16_IS_SURROG(uv) && VALID_UTF(uv)) {
		(void)uvuni_to_utf8(uni, uv);
		sv_catpvn(dst, (char*)uni, (STRLEN)UNISKIP(uv));
	    }
	    else
		sv_cat_retcvref(dst, cvref, newSVuv(uv));
	}

    } else {
	d = (U8*)SvPVX(dst);

	for (p = s; p < e;) {
	    uv = ord_uv(p, e - p, &retlen);

	    if (retlen)
		p += retlen;
	    else {
		p++;
		continue;
	    }

	    if (!UTF16_IS_SURROG(uv) && VALID_UTF(uv))
		d = uvuni_to_utf8(d, (UV)uv);
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
    STRLEN srclen, dstlen, retlen, applen;
    U8 *s, *e, *p, *d, ucs[UTF8_MAXLEN + 1];
    UV uv;
    STRLEN (*app_uv)(U8*, UV);
  PPCODE:
    cvref = NULL;
    if (items == 2)
	if (SvROK(arg1) && SvTYPE(SvRV(arg1)) == SVt_PVCV)
	    cvref = SvRV(arg1);
	else
	    croak(PkgName " 1st argument is not CODEREF");

    src = cvref ? arg2 : arg1;

    if (!SvUTF8(src)) {
	src = sv_mortalcopy(src);
	sv_utf8_upgrade(src);
    }

    s = (U8*)SvPV(src,srclen);
    e = s + srclen;

    dstlen = srclen * MaxLenFmUni + 1;

    if (ix == 2 || ix == 3) /*UTF32*/
	dstlen *= 2;

    dst = sv_2mortal(newSV(dstlen));
    (void)SvPOK_only(dst);

    app_uv = app_uv_in[ix];

    if (cvref) {
	for (p = s; p < e;) {
	    uv = utf8n_to_uvuni(p, e - p, &retlen, 0);
	    p += retlen;

	    applen = 0;
	    if (!UTF16_IS_SURROG(uv) && VALID_UTF(uv))
		applen = app_uv(ucs, uv);

	    if (0 < applen)
		sv_catpvn(dst, (char*)ucs, applen);
	    else
		sv_cat_retcvref(dst, cvref, newSVuv(uv));
	}
    }
    else {
	d = (U8*)SvPVX(dst);
	for (p = s; p < e;) {
	    uv = utf8n_to_uvuni(p, e - p, &retlen, 0);
	    p += retlen;

	    applen = 0;
	    if (!UTF16_IS_SURROG(uv) && VALID_UTF(uv))
		applen = app_uv(d, uv);

	    if (0 < applen)
		d += applen;
	}
	*d = '\0';
	SvCUR_set(dst, d - (U8*)SvPVX(dst));
    }

    if (5 < ix) {
	p = (U8*)SvPV(dst,dstlen);
	for (e = p + dstlen; p < e; p++)
	    *p = utf_to_i8_cp1047[*p];
    }
    XPUSHs(dst);


void
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
    STRLEN applen;
    U8 ucs[UTF8_MAXLEN + 1];
    STRLEN (*app_uv)(U8*, UV);
  PPCODE:
    if (UTF16_IS_SURROG(uv) && !VALID_UTF(uv))
	XSRETURN_UNDEF;

    dst = sv_2mortal(newSV(1));
    (void)SvPOK_only(dst);

    app_uv = app_uv_in[ix];
    applen = app_uv(ucs, uv);
    if (0 < applen) {
	sv_catpvn(dst, (char*)ucs, applen);
	XPUSHs(dst);
    }
    else
	XSRETURN_UNDEF;
