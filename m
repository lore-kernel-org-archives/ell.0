Content-Type: multipart/mixed; boundary="===============1177492203246559128=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH] Restore support for clang and other non-GCC compilers
Date: Tue, 21 Sep 2021 17:36:10 -0500
Message-ID: <bb30e7a6-e799-3732-e18a-1a998ad62c44@gmail.com>
In-Reply-To: 20210919070743.5u7aqpchqefd5vev@nutty-noon.ad.darkkirb.de

--===============1177492203246559128==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Charlotte,

On 9/19/21 2:07 AM, Charlotte Delenk wrote:
> The _auto_-macro used in cert.c and tls.c uses a GCC extension that
> allows for nested functions. This is not supported by other compilers,
> including clang.
> =

> Compiling ell with these compilers will result error messages such as:
> =

> ../ell-0.44/ell/tls.c:1895:2: error: function definition is not allowed h=
ere
>          _auto_(l_certchain_free) struct l_certchain *certchain =3D NULL;
>          ^
> ../ell-0.44/ell/useful.h:71:2: note: expanded from macro '_auto_'
>          _AUTODESTRUCT(__COUNTER__, func)
>          ^
> ../ell-0.44/ell/useful.h:68:2: note: expanded from macro '_AUTODESTRUCT'
>          __AUTODESTRUCT(var, func)
>          ^
> ../ell-0.44/ell/useful.h:64:2: note: expanded from macro '__AUTODESTRUCT'
>          { func(*(void **) ptr); }                       \
>          ^
> ../ell-0.44/ell/tls.c:1895:2: error: use of undeclared identifier 'cleanu=
p_0'
> ../ell-0.44/ell/useful.h:71:2: note: expanded from macro '_auto_'
>          _AUTODESTRUCT(__COUNTER__, func)
>          ^
> ../ell-0.44/ell/useful.h:68:2: note: expanded from macro '_AUTODESTRUCT'
>          __AUTODESTRUCT(var, func)
>          ^
> ../ell-0.44/ell/useful.h:65:23: note: expanded from macro '__AUTODESTRUCT'
>          __attribute((cleanup(cleanup_ ## var)))
>                               ^
> =

> This patch will removes the _auto_ macro and implement its functionality
> manually in the two locations it is used.

The problem is that we like the _auto_ macro ;)  And getting rid of it in i=
wd =

isn't as easy.

> =

> It does not appear to be possible to replace this macro with a more
> compatible alternative that does not involve C++.
>

So what about doing something like this (attached).  This approach is a bit=
 less =

flexible than our current version since we have to declare extra destructor=
s, =

but maybe clang doesn't hate it?

> Signed-off-by: Charlotte Delenk <darkkirb(a)darkkirb.de>

Just FYI, we do not use S-o-b tags here.

> ---
>   ell/cert.c   |  6 +++++-
>   ell/tls.c    |  6 +++++-
>   ell/useful.h | 11 -----------
>   3 files changed, 10 insertions(+), 13 deletions(-)
> =


Regards,
-Denis

--===============1177492203246559128==
Content-Type: text/x-patch
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="0001-RFC-useful-Remove-nested-function-use.patch"

RnJvbSA4YWEyYjJiNThlNThjZThlM2E5NTE2MDI4NjdhMzdhYTMzMDk3YTM0IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBEZW5pcyBLZW56aW9yIDxkZW5rZW56QGdtYWlsLmNvbT4KRGF0
ZTogVHVlLCAyMSBTZXAgMjAyMSAxNzozMjowNiAtMDUwMApTdWJqZWN0OiBbUEFUQ0hdIFJGQzog
dXNlZnVsOiBSZW1vdmUgbmVzdGVkIGZ1bmN0aW9uIHVzZQoKLS0tCiBlbGwvY2VydC5oICAgIHwg
IDIgKysKIGVsbC9jbGVhbnVwLmggfCAyNyArKysrKysrKysrKysrKysrKysrKysrKysrKysKIGVs
bC9rZXkuaCAgICAgfCAgMyArKysKIGVsbC91c2VmdWwuaCAgfCAxMSArKystLS0tLS0tLQogNCBm
aWxlcyBjaGFuZ2VkLCAzNSBpbnNlcnRpb25zKCspLCA4IGRlbGV0aW9ucygtKQogY3JlYXRlIG1v
ZGUgMTAwNjQ0IGVsbC9jbGVhbnVwLmgKCmRpZmYgLS1naXQgYS9lbGwvY2VydC5oIGIvZWxsL2Nl
cnQuaAppbmRleCBmMzkxMGJiMzM4OTUuLjhkY2Q4ZTY0MTVhYSAxMDA2NDQKLS0tIGEvZWxsL2Nl
cnQuaAorKysgYi9lbGwvY2VydC5oCkBAIC0yOCw2ICsyOCw3IEBAIGV4dGVybiAiQyIgewogI2Vu
ZGlmCiAKICNpbmNsdWRlIDxzdGRkZWYuaD4KKyNpbmNsdWRlIDxlbGwvY2xlYW51cC5oPgogCiBz
dHJ1Y3QgbF9xdWV1ZTsKIHN0cnVjdCBsX2NlcnQ7CkBAIC00OSw2ICs1MCw3IEBAIGVudW0gbF9j
ZXJ0X2tleV90eXBlIGxfY2VydF9nZXRfcHVia2V5X3R5cGUoc3RydWN0IGxfY2VydCAqY2VydCk7
CiBzdHJ1Y3QgbF9rZXkgKmxfY2VydF9nZXRfcHVia2V5KHN0cnVjdCBsX2NlcnQgKmNlcnQpOwog
CiB2b2lkIGxfY2VydGNoYWluX2ZyZWUoc3RydWN0IGxfY2VydGNoYWluICpjaGFpbik7CitERUZJ
TkVfQ0xFQU5VUF9GVU5DKGxfY2VydGNoYWluX2ZyZWUpCiAKIHN0cnVjdCBsX2NlcnQgKmxfY2Vy
dGNoYWluX2dldF9sZWFmKHN0cnVjdCBsX2NlcnRjaGFpbiAqY2hhaW4pOwogdm9pZCBsX2NlcnRj
aGFpbl93YWxrX2Zyb21fbGVhZihzdHJ1Y3QgbF9jZXJ0Y2hhaW4gKmNoYWluLApkaWZmIC0tZ2l0
IGEvZWxsL2NsZWFudXAuaCBiL2VsbC9jbGVhbnVwLmgKbmV3IGZpbGUgbW9kZSAxMDA2NDQKaW5k
ZXggMDAwMDAwMDAwMDAwLi44OWIxOTgxNjAxNmYKLS0tIC9kZXYvbnVsbAorKysgYi9lbGwvY2xl
YW51cC5oCkBAIC0wLDAgKzEsMjcgQEAKKy8qCisgKgorICogIEVtYmVkZGVkIExpbnV4IGxpYnJh
cnkKKyAqCisgKiAgQ29weXJpZ2h0IChDKSAyMDIxICBJbnRlbCBDb3Jwb3JhdGlvbi4gQWxsIHJp
Z2h0cyByZXNlcnZlZC4KKyAqCisgKiAgVGhpcyBsaWJyYXJ5IGlzIGZyZWUgc29mdHdhcmU7IHlv
dSBjYW4gcmVkaXN0cmlidXRlIGl0IGFuZC9vcgorICogIG1vZGlmeSBpdCB1bmRlciB0aGUgdGVy
bXMgb2YgdGhlIEdOVSBMZXNzZXIgR2VuZXJhbCBQdWJsaWMKKyAqICBMaWNlbnNlIGFzIHB1Ymxp
c2hlZCBieSB0aGUgRnJlZSBTb2Z0d2FyZSBGb3VuZGF0aW9uOyBlaXRoZXIKKyAqICB2ZXJzaW9u
IDIuMSBvZiB0aGUgTGljZW5zZSwgb3IgKGF0IHlvdXIgb3B0aW9uKSBhbnkgbGF0ZXIgdmVyc2lv
bi4KKyAqCisgKiAgVGhpcyBsaWJyYXJ5IGlzIGRpc3RyaWJ1dGVkIGluIHRoZSBob3BlIHRoYXQg
aXQgd2lsbCBiZSB1c2VmdWwsCisgKiAgYnV0IFdJVEhPVVQgQU5ZIFdBUlJBTlRZOyB3aXRob3V0
IGV2ZW4gdGhlIGltcGxpZWQgd2FycmFudHkgb2YKKyAqICBNRVJDSEFOVEFCSUxJVFkgb3IgRklU
TkVTUyBGT1IgQSBQQVJUSUNVTEFSIFBVUlBPU0UuICBTZWUgdGhlIEdOVQorICogIExlc3NlciBH
ZW5lcmFsIFB1YmxpYyBMaWNlbnNlIGZvciBtb3JlIGRldGFpbHMuCisgKgorICogIFlvdSBzaG91
bGQgaGF2ZSByZWNlaXZlZCBhIGNvcHkgb2YgdGhlIEdOVSBMZXNzZXIgR2VuZXJhbCBQdWJsaWMK
KyAqICBMaWNlbnNlIGFsb25nIHdpdGggdGhpcyBsaWJyYXJ5OyBpZiBub3QsIHdyaXRlIHRvIHRo
ZSBGcmVlIFNvZnR3YXJlCisgKiAgRm91bmRhdGlvbiwgSW5jLiwgNTEgRnJhbmtsaW4gU3QsIEZp
ZnRoIEZsb29yLCBCb3N0b24sIE1BICAwMjExMC0xMzAxICBVU0EKKyAqCisgKi8KKworI3ByYWdt
YSBvbmNlCisKKyNkZWZpbmUgREVGSU5FX0NMRUFOVVBfRlVOQyhmdW5jKQkJCVwKKwlpbmxpbmUg
X19hdHRyaWJ1dGVfXygoYWx3YXlzX2lubGluZSkpCQlcCisJdm9pZCBmdW5jICMjIF9jbGVhbnVw
KHZvaWQgKnApIHsgZnVuYygqKHZvaWQgKiopIHApOyB9CmRpZmYgLS1naXQgYS9lbGwva2V5Lmgg
Yi9lbGwva2V5LmgKaW5kZXggZjFmOTVlMTExNzNhLi5mZjNkOWFiYmRhNGMgMTAwNjQ0Ci0tLSBh
L2VsbC9rZXkuaAorKysgYi9lbGwva2V5LmgKQEAgLTMwLDYgKzMwLDcgQEAgZXh0ZXJuICJDIiB7
CiAjaW5jbHVkZSA8c3RkZGVmLmg+CiAjaW5jbHVkZSA8c3RkYm9vbC5oPgogCisjaW5jbHVkZSA8
ZWxsL2NsZWFudXAuaD4KICNpbmNsdWRlIDxlbGwvY2hlY2tzdW0uaD4KIAogc3RydWN0IGxfa2V5
OwpAQCAtMTA4LDcgKzEwOSw5IEBAIGJvb2wgbF9rZXlyaW5nX3Jlc3RyaWN0KHN0cnVjdCBsX2tl
eXJpbmcgKmtleXJpbmcsIGVudW0gbF9rZXlyaW5nX3Jlc3RyaWN0aW9uIHJlCiAJCQljb25zdCBz
dHJ1Y3QgbF9rZXlyaW5nICp0cnVzdCk7CiAKIHZvaWQgbF9rZXlyaW5nX2ZyZWUoc3RydWN0IGxf
a2V5cmluZyAqa2V5cmluZyk7CitERUZJTkVfQ0xFQU5VUF9GVU5DKGxfa2V5cmluZ19mcmVlKQog
dm9pZCBsX2tleXJpbmdfZnJlZV9ub3Jldm9rZShzdHJ1Y3QgbF9rZXlyaW5nICprZXlyaW5nKTsK
K0RFRklORV9DTEVBTlVQX0ZVTkMobF9rZXlyaW5nX2ZyZWVfbm9yZXZva2UpCiAKIGJvb2wgbF9r
ZXlyaW5nX2xpbmsoc3RydWN0IGxfa2V5cmluZyAqa2V5cmluZywgY29uc3Qgc3RydWN0IGxfa2V5
ICprZXkpOwogCmRpZmYgLS1naXQgYS9lbGwvdXNlZnVsLmggYi9lbGwvdXNlZnVsLmgKaW5kZXgg
YjQ3ODNjZTM2NmNiLi40YzhiMjNlYWEyZDkgMTAwNjQ0Ci0tLSBhL2VsbC91c2VmdWwuaAorKysg
Yi9lbGwvdXNlZnVsLmgKQEAgLTU5LDE2ICs1OSwxMSBAQCBzdGF0aWMgaW5saW5lIHVuc2lnbmVk
IGNoYXIgYml0X2ZpZWxkKGNvbnN0IHVuc2lnbmVkIGNoYXIgb2N0LAogCV94IC8gX2Q7CQkJCQlc
CiB9KQogCi0jZGVmaW5lIF9fQVVUT0RFU1RSVUNUKHZhciwgZnVuYykJCQlcCi0Jdm9pZCBjbGVh
bnVwXyAjIyB2YXIodm9pZCAqcHRyKQkJCVwKLQl7IGZ1bmMoKih2b2lkICoqKSBwdHIpOyB9CQkJ
XAotCV9fYXR0cmlidXRlKChjbGVhbnVwKGNsZWFudXBfICMjIHZhcikpKQotCi0jZGVmaW5lIF9B
VVRPREVTVFJVQ1QodmFyLCBmdW5jKQkJCVwKLQlfX0FVVE9ERVNUUlVDVCh2YXIsIGZ1bmMpCisj
ZGVmaW5lIF9fQVVUT0RFU1RSVUNUKGZ1bmMpCQkJCVwKKwlfX2F0dHJpYnV0ZSgoY2xlYW51cChm
dW5jICMjIF9jbGVhbnVwKSkpCiAKICNkZWZpbmUgX2F1dG9fKGZ1bmMpCQkJCQlcCi0JX0FVVE9E
RVNUUlVDVChfX0NPVU5URVJfXywgZnVuYykKKwlfX0FVVE9ERVNUUlVDVChmdW5jKQogCiAvKgog
ICogVHJpY2sgdGhlIGNvbXBpbGVyIGludG8gdGhpbmtpbmcgdGhhdCB2YXIgbWlnaHQgYmUgY2hh
bmdlZCBzb21laG93IGJ5Ci0tIAoyLjI2LjMKCg==

--===============1177492203246559128==--

