Content-Type: multipart/mixed; boundary="===============8322805493392888895=="
MIME-Version: 1.0
From: Stotland, Inga <inga.stotland@intel.com>
Subject: Re: [PATCH] cert: Fix warning of possible uninitialized var
Date: Sat, 16 Jan 2021 07:28:45 +0000
Message-ID: <df2ca0efff5133af5775b048352c87bf4780d932.camel@intel.com>
In-Reply-To: <CAOq732J-5oRBdqQX_TL_vf0hcE2ZPkuBq3K_=8-TkpLJp=mNTA@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8322805493392888895==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Thu, 2021-01-14 at 23:53 +0100, Andrew Zaborowski wrote:

On Thu, 14 Jan 2021 at 22:35, Denis Kenzior <

<mailto:denkenz@gmail.com>

denkenz(a)gmail.com

> wrote:

On 1/14/21 3:16 PM, Brian Gix wrote:

ell/cert-crypto.c: In function =E2=80=98cert_pkcs12_pbkdf=E2=80=99:

ell/cert-crypto.c:244:3: error: =E2=80=98bmpstring=E2=80=99 may be used uni=
nitialized in this function [-Werror=3Dmaybe-uninitialized]

   244 |   explicit_bzero(bmpstring, passwd_len);

       |   ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


What compiler are you seeing this on?

Not sure which version of the compiler Brian is using, but I encounter this=
 issue with:
gcc (GCC) 10.2.1 20201125 (Red Hat 10.2.1-9)



---

  ell/cert-crypto.c | 2 +-

  1 file changed, 1 insertion(+), 1 deletion(-)


diff --git a/ell/cert-crypto.c b/ell/cert-crypto.c

index 6eb4e14..b3d3000 100644

--- a/ell/cert-crypto.c

+++ b/ell/cert-crypto.c

@@ -194,7 +194,7 @@ uint8_t *cert_pkcs12_pbkdf(const char *password,

  {

      /* All lengths in bytes instead of bits */

      size_t passwd_len =3D password ? 2 * strlen(password) + 2 : 0;

-     uint8_t *bmpstring;

+     uint8_t *bmpstring =3D NULL;


So generally I don't like this type of fix because it just hides problems. =
 The

issues with bmpstring use seem to be a bit more complex than that.


      /* Documented as v(ceiling(s/v)), usually will just equal v */

      unsigned int s_len =3D (salt_len + hash->v - 1) & ~(hash->v - 1);

      /* Documented as p(ceiling(s/p)), usually will just equal v */



Andrew:


Why is p_len initialized to be non-zero.  In particular, this block:


         for (j =3D passwd_len; j < p_len; j +=3D passwd_len, ptr +=3D pass=
wd_len)

                 memcpy(ptr, bmpstring, passwd_len);


would seem to copy from an uninitialized bmpstring even if password is NULL.


It's not very obvious but p_len and passwd_len are both going to be 0

if password is NULL.  p_len becomes (v - 1) & ~(v - 1), I can see that

it's hard for the compiler to notice that.


Brian, can you check if perhaps initializing p_len this way fixes it:


unsigned int p_len =3D password ? (passwd_len + hash->v - 1) & ~(hash->v - =
1) : 0;

This change still does not fix the compiler problem.

However, the warning disappears if we move "for" loop inside the "if" claus=
e that immediately follows.

The way I see it, the for loop is not going to be executed if p_len is zero=
 anyway and this
chage appears to be safe since the comparisons are perfrmed on unsigned int=
egers.

-       for (j =3D passwd_len; j < p_len; j +=3D passwd_len, ptr +=3D passw=
d_len)
-               memcpy(ptr, bmpstring, passwd_len);

        if (p_len) {
+               for (j =3D passwd_len; j < p_len; j +=3D passwd_len, ptr +=
=3D passwd_len)
+                       memcpy(ptr, bmpstring, passwd_len);
                memcpy(ptr, bmpstring, p_len + passwd_len - j);




Or the part that uses bmpstring can be made conditional on password as well.


Best regard

_______________________________________________

ell mailing list --

<mailto:ell@lists.01.org>

ell(a)lists.01.org


To unsubscribe send an email to

<mailto:ell-leave@lists.01.org>

ell-leave(a)lists.01.org


--===============8322805493392888895==
Content-Type: text/html
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="attachment.htm"

PGh0bWwgZGlyPSJsdHIiPg0KPGhlYWQ+DQo8bWV0YSBodHRwLWVxdWl2PSJDb250ZW50LVR5cGUi
IGNvbnRlbnQ9InRleHQvaHRtbDsgY2hhcnNldD11dGYtOCI+DQo8L2hlYWQ+DQo8Ym9keSBzdHls
ZT0idGV4dC1hbGlnbjpsZWZ0OyBkaXJlY3Rpb246bHRyOyIgYmdjb2xvcj0iI2ZmZmZmZiIgdGV4
dD0iIzJlMzQzNiIgbGluaz0iIzczNzM3MyIgdmxpbms9IiMyZTM0MzYiPg0KPGRpdj5PbiBUaHUs
IDIwMjEtMDEtMTQgYXQgMjM6NTMgKzAxMDAsIEFuZHJldyBaYWJvcm93c2tpIHdyb3RlOjwvZGl2
Pg0KPGJsb2NrcXVvdGUgdHlwZT0iY2l0ZSIgc3R5bGU9Im1hcmdpbjowIDAgMCAuOGV4OyBib3Jk
ZXItbGVmdDoycHggIzcyOWZjZiBzb2xpZDtwYWRkaW5nLWxlZnQ6MWV4Ij4NCjxwcmU+T24gVGh1
LCAxNCBKYW4gMjAyMSBhdCAyMjozNSwgRGVuaXMgS2VuemlvciAmbHQ7PC9wcmU+DQo8YSBocmVm
PSJtYWlsdG86ZGVua2VuekBnbWFpbC5jb20iPg0KPHByZT5kZW5rZW56QGdtYWlsLmNvbTwvcHJl
Pg0KPC9hPg0KPHByZT4mZ3Q7IHdyb3RlOjwvcHJlPg0KPGJsb2NrcXVvdGUgdHlwZT0iY2l0ZSIg
c3R5bGU9Im1hcmdpbjowIDAgMCAuOGV4OyBib3JkZXItbGVmdDoycHggIzcyOWZjZiBzb2xpZDtw
YWRkaW5nLWxlZnQ6MWV4Ij4NCjxwcmU+T24gMS8xNC8yMSAzOjE2IFBNLCBCcmlhbiBHaXggd3Jv
dGU6PC9wcmU+DQo8YmxvY2txdW90ZSB0eXBlPSJjaXRlIiBzdHlsZT0ibWFyZ2luOjAgMCAwIC44
ZXg7IGJvcmRlci1sZWZ0OjJweCAjNzI5ZmNmIHNvbGlkO3BhZGRpbmctbGVmdDoxZXgiPg0KPHBy
ZT5lbGwvY2VydC1jcnlwdG8uYzogSW4gZnVuY3Rpb24g4oCYY2VydF9wa2NzMTJfcGJrZGbigJk6
PC9wcmU+DQo8cHJlPmVsbC9jZXJ0LWNyeXB0by5jOjI0NDozOiBlcnJvcjog4oCYYm1wc3RyaW5n
4oCZIG1heSBiZSB1c2VkIHVuaW5pdGlhbGl6ZWQgaW4gdGhpcyBmdW5jdGlvbiBbLVdlcnJvcj1t
YXliZS11bmluaXRpYWxpemVkXTwvcHJlPg0KPHByZT4gICAyNDQgfCAgIGV4cGxpY2l0X2J6ZXJv
KGJtcHN0cmluZywgcGFzc3dkX2xlbik7PC9wcmU+DQo8cHJlPiAgICAgICB8ICAgXn5+fn5+fn5+
fn5+fn5+fn5+fn5+fn5+fn5+fn5+fn5+fn5+fjwvcHJlPg0KPC9ibG9ja3F1b3RlPg0KPHByZT48
YnI+PC9wcmU+DQo8cHJlPldoYXQgY29tcGlsZXIgYXJlIHlvdSBzZWVpbmcgdGhpcyBvbj88L3By
ZT4NCjwvYmxvY2txdW90ZT4NCjwvYmxvY2txdW90ZT4NCjxkaXY+PGJyPg0KPC9kaXY+DQo8ZGl2
Pk5vdCBzdXJlIHdoaWNoIHZlcnNpb24gb2YgdGhlIGNvbXBpbGVyIEJyaWFuIGlzIHVzaW5nLCBi
dXQgSSBlbmNvdW50ZXIgdGhpcyBpc3N1ZSB3aXRoOjwvZGl2Pg0KPGRpdj5nY2MgKEdDQykgMTAu
Mi4xIDIwMjAxMTI1IChSZWQgSGF0IDEwLjIuMS05KTwvZGl2Pg0KPGRpdj48YnI+DQo8L2Rpdj4N
CjxibG9ja3F1b3RlIHR5cGU9ImNpdGUiIHN0eWxlPSJtYXJnaW46MCAwIDAgLjhleDsgYm9yZGVy
LWxlZnQ6MnB4ICM3MjlmY2Ygc29saWQ7cGFkZGluZy1sZWZ0OjFleCI+DQo8YmxvY2txdW90ZSB0
eXBlPSJjaXRlIiBzdHlsZT0ibWFyZ2luOjAgMCAwIC44ZXg7IGJvcmRlci1sZWZ0OjJweCAjNzI5
ZmNmIHNvbGlkO3BhZGRpbmctbGVmdDoxZXgiPg0KPHByZT48YnI+PC9wcmU+DQo8YmxvY2txdW90
ZSB0eXBlPSJjaXRlIiBzdHlsZT0ibWFyZ2luOjAgMCAwIC44ZXg7IGJvcmRlci1sZWZ0OjJweCAj
NzI5ZmNmIHNvbGlkO3BhZGRpbmctbGVmdDoxZXgiPg0KPHByZT4tLS08L3ByZT4NCjxwcmU+ICBl
bGwvY2VydC1jcnlwdG8uYyB8IDIgKy08L3ByZT4NCjxwcmU+ICAxIGZpbGUgY2hhbmdlZCwgMSBp
bnNlcnRpb24oKyksIDEgZGVsZXRpb24oLSk8L3ByZT4NCjxwcmU+PGJyPjwvcHJlPg0KPHByZT5k
aWZmIC0tZ2l0IGEvZWxsL2NlcnQtY3J5cHRvLmMgYi9lbGwvY2VydC1jcnlwdG8uYzwvcHJlPg0K
PHByZT5pbmRleCA2ZWI0ZTE0Li5iM2QzMDAwIDEwMDY0NDwvcHJlPg0KPHByZT4tLS0gYS9lbGwv
Y2VydC1jcnlwdG8uYzwvcHJlPg0KPHByZT4rKysgYi9lbGwvY2VydC1jcnlwdG8uYzwvcHJlPg0K
PHByZT5AQCAtMTk0LDcgKzE5NCw3IEBAIHVpbnQ4X3QgKmNlcnRfcGtjczEyX3Bia2RmKGNvbnN0
IGNoYXIgKnBhc3N3b3JkLDwvcHJlPg0KPHByZT4gIHs8L3ByZT4NCjxwcmU+ICAgICAgLyogQWxs
IGxlbmd0aHMgaW4gYnl0ZXMgaW5zdGVhZCBvZiBiaXRzICovPC9wcmU+DQo8cHJlPiAgICAgIHNp
emVfdCBwYXNzd2RfbGVuID0gcGFzc3dvcmQgPyAyICogc3RybGVuKHBhc3N3b3JkKSArIDIgOiAw
OzwvcHJlPg0KPHByZT4tICAgICB1aW50OF90ICpibXBzdHJpbmc7PC9wcmU+DQo8cHJlPisgICAg
IHVpbnQ4X3QgKmJtcHN0cmluZyA9IE5VTEw7PC9wcmU+DQo8L2Jsb2NrcXVvdGU+DQo8cHJlPjxi
cj48L3ByZT4NCjxwcmU+U28gZ2VuZXJhbGx5IEkgZG9uJ3QgbGlrZSB0aGlzIHR5cGUgb2YgZml4
IGJlY2F1c2UgaXQganVzdCBoaWRlcyBwcm9ibGVtcy4gIFRoZTwvcHJlPg0KPHByZT5pc3N1ZXMg
d2l0aCBibXBzdHJpbmcgdXNlIHNlZW0gdG8gYmUgYSBiaXQgbW9yZSBjb21wbGV4IHRoYW4gdGhh
dC48L3ByZT4NCjxwcmU+PGJyPjwvcHJlPg0KPGJsb2NrcXVvdGUgdHlwZT0iY2l0ZSIgc3R5bGU9
Im1hcmdpbjowIDAgMCAuOGV4OyBib3JkZXItbGVmdDoycHggIzcyOWZjZiBzb2xpZDtwYWRkaW5n
LWxlZnQ6MWV4Ij4NCjxwcmU+ICAgICAgLyogRG9jdW1lbnRlZCBhcyB2KGNlaWxpbmcocy92KSks
IHVzdWFsbHkgd2lsbCBqdXN0IGVxdWFsIHYgKi88L3ByZT4NCjxwcmU+ICAgICAgdW5zaWduZWQg
aW50IHNfbGVuID0gKHNhbHRfbGVuICsgaGFzaC0mZ3Q7diAtIDEpICZhbXA7IH4oaGFzaC0mZ3Q7
diAtIDEpOzwvcHJlPg0KPHByZT4gICAgICAvKiBEb2N1bWVudGVkIGFzIHAoY2VpbGluZyhzL3Ap
KSwgdXN1YWxseSB3aWxsIGp1c3QgZXF1YWwgdiAqLzwvcHJlPg0KPHByZT48YnI+PC9wcmU+DQo8
L2Jsb2NrcXVvdGU+DQo8cHJlPjxicj48L3ByZT4NCjxwcmU+QW5kcmV3OjwvcHJlPg0KPHByZT48
YnI+PC9wcmU+DQo8cHJlPldoeSBpcyBwX2xlbiBpbml0aWFsaXplZCB0byBiZSBub24temVyby4g
IEluIHBhcnRpY3VsYXIsIHRoaXMgYmxvY2s6PC9wcmU+DQo8cHJlPjxicj48L3ByZT4NCjxwcmU+
ICAgICAgICAgZm9yIChqID0gcGFzc3dkX2xlbjsgaiAmbHQ7IHBfbGVuOyBqICs9IHBhc3N3ZF9s
ZW4sIHB0ciArPSBwYXNzd2RfbGVuKTwvcHJlPg0KPHByZT4gICAgICAgICAgICAgICAgIG1lbWNw
eShwdHIsIGJtcHN0cmluZywgcGFzc3dkX2xlbik7PC9wcmU+DQo8cHJlPjxicj48L3ByZT4NCjxw
cmU+d291bGQgc2VlbSB0byBjb3B5IGZyb20gYW4gdW5pbml0aWFsaXplZCBibXBzdHJpbmcgZXZl
biBpZiBwYXNzd29yZCBpcyBOVUxMLjwvcHJlPg0KPC9ibG9ja3F1b3RlPg0KPHByZT48YnI+PC9w
cmU+DQo8cHJlPkl0J3Mgbm90IHZlcnkgb2J2aW91cyBidXQgcF9sZW4gYW5kIHBhc3N3ZF9sZW4g
YXJlIGJvdGggZ29pbmcgdG8gYmUgMDwvcHJlPg0KPHByZT5pZiBwYXNzd29yZCBpcyBOVUxMLiAg
cF9sZW4gYmVjb21lcyAodiAtIDEpICZhbXA7IH4odiAtIDEpLCBJIGNhbiBzZWUgdGhhdDwvcHJl
Pg0KPHByZT5pdCdzIGhhcmQgZm9yIHRoZSBjb21waWxlciB0byBub3RpY2UgdGhhdC48L3ByZT4N
CjxwcmU+PGJyPjwvcHJlPg0KPHByZT5CcmlhbiwgY2FuIHlvdSBjaGVjayBpZiBwZXJoYXBzIGlu
aXRpYWxpemluZyBwX2xlbiB0aGlzIHdheSBmaXhlcyBpdDo8L3ByZT4NCjxwcmU+PGJyPjwvcHJl
Pg0KPHByZT51bnNpZ25lZCBpbnQgcF9sZW4gPSBwYXNzd29yZCA/IChwYXNzd2RfbGVuICsgaGFz
aC0mZ3Q7diAtIDEpICZhbXA7IH4oaGFzaC0mZ3Q7diAtIDEpIDogMDs8L3ByZT4NCjwvYmxvY2tx
dW90ZT4NCjxkaXY+PGJyPg0KPC9kaXY+DQo8ZGl2PlRoaXMgY2hhbmdlIHN0aWxsIGRvZXMgbm90
IGZpeCB0aGUgY29tcGlsZXIgcHJvYmxlbS48L2Rpdj4NCjxkaXY+PGJyPg0KPC9kaXY+DQo8ZGl2
Pkhvd2V2ZXIsIHRoZSB3YXJuaW5nIGRpc2FwcGVhcnMgaWYgd2UgbW92ZSAmcXVvdDtmb3ImcXVv
dDsgbG9vcCBpbnNpZGUgdGhlICZxdW90O2lmJnF1b3Q7IGNsYXVzZSB0aGF0IGltbWVkaWF0ZWx5
IGZvbGxvd3MuPC9kaXY+DQo8ZGl2Pjxicj4NCjwvZGl2Pg0KPGRpdj5UaGUgd2F5IEkgc2VlIGl0
LCB0aGUgZm9yIGxvb3AgaXMgbm90IGdvaW5nIHRvIGJlIGV4ZWN1dGVkIGlmIHBfbGVuIGlzIHpl
cm8gYW55d2F5IGFuZCB0aGlzPC9kaXY+DQo8ZGl2PmNoYWdlIGFwcGVhcnMgdG8gYmUgc2FmZSBz
aW5jZSB0aGUgY29tcGFyaXNvbnMgYXJlIHBlcmZybWVkIG9uIHVuc2lnbmVkIGludGVnZXJzLjwv
ZGl2Pg0KPGRpdj48YnI+DQo8L2Rpdj4NCjxkaXY+LSZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZu
YnNwOyZuYnNwOyZuYnNwO2ZvciAoaiA9IHBhc3N3ZF9sZW47IGogJmx0OyBwX2xlbjsgaiArPSBw
YXNzd2RfbGVuLCBwdHIgKz0gcGFzc3dkX2xlbik8L2Rpdj4NCjxkaXY+LSZuYnNwOyZuYnNwOyZu
YnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNw
OyZuYnNwOyZuYnNwOyZuYnNwO21lbWNweShwdHIsIGJtcHN0cmluZywgcGFzc3dkX2xlbik7PC9k
aXY+DQo8ZGl2PiZuYnNwOzwvZGl2Pg0KPGRpdj4mbmJzcDsmbmJzcDsmbmJzcDsmbmJzcDsmbmJz
cDsmbmJzcDsmbmJzcDsmbmJzcDtpZiAocF9sZW4pIHs8L2Rpdj4NCjxkaXY+KyZuYnNwOyZuYnNw
OyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZu
YnNwOyZuYnNwOyZuYnNwOyZuYnNwO2ZvciAoaiA9IHBhc3N3ZF9sZW47IGogJmx0OyBwX2xlbjsg
aiArPSBwYXNzd2RfbGVuLCBwdHIgKz0gcGFzc3dkX2xlbik8L2Rpdj4NCjxkaXY+KyZuYnNwOyZu
YnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNw
OyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZu
YnNwOyZuYnNwOyZuYnNwO21lbWNweShwdHIsIGJtcHN0cmluZywgcGFzc3dkX2xlbik7PC9kaXY+
DQo8ZGl2PiZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZu
YnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwOyZuYnNwO21lbWNweShwdHIs
IGJtcHN0cmluZywgcF9sZW4gKyBwYXNzd2RfbGVuIC0gaik7PC9kaXY+DQo8ZGl2PjwvZGl2Pg0K
PGRpdj48YnI+DQo8L2Rpdj4NCjxkaXY+PGJyPg0KPC9kaXY+DQo8YmxvY2txdW90ZSB0eXBlPSJj
aXRlIiBzdHlsZT0ibWFyZ2luOjAgMCAwIC44ZXg7IGJvcmRlci1sZWZ0OjJweCAjNzI5ZmNmIHNv
bGlkO3BhZGRpbmctbGVmdDoxZXgiPg0KPHByZT48YnI+PC9wcmU+DQo8cHJlPk9yIHRoZSBwYXJ0
IHRoYXQgdXNlcyBibXBzdHJpbmcgY2FuIGJlIG1hZGUgY29uZGl0aW9uYWwgb24gcGFzc3dvcmQg
YXMgd2VsbC48L3ByZT4NCjxwcmU+PGJyPjwvcHJlPg0KPHByZT5CZXN0IHJlZ2FyZDwvcHJlPg0K
PHByZT5fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXzwvcHJl
Pg0KPHByZT5lbGwgbWFpbGluZyBsaXN0IC0tIDwvcHJlPg0KPGEgaHJlZj0ibWFpbHRvOmVsbEBs
aXN0cy4wMS5vcmciPg0KPHByZT5lbGxAbGlzdHMuMDEub3JnPC9wcmU+DQo8L2E+DQo8cHJlPjxi
cj48L3ByZT4NCjxwcmU+VG8gdW5zdWJzY3JpYmUgc2VuZCBhbiBlbWFpbCB0byA8L3ByZT4NCjxh
IGhyZWY9Im1haWx0bzplbGwtbGVhdmVAbGlzdHMuMDEub3JnIj4NCjxwcmU+ZWxsLWxlYXZlQGxp
c3RzLjAxLm9yZzwvcHJlPg0KPC9hPg0KPHByZT48YnI+PC9wcmU+DQo8L2Jsb2NrcXVvdGU+DQo8
L2JvZHk+DQo8L2h0bWw+DQo=

--===============8322805493392888895==--

