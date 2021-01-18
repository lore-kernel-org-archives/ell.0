Content-Type: multipart/mixed; boundary="===============5401381991078335901=="
MIME-Version: 1.0
From: Stotland, Inga <inga.stotland@intel.com>
Subject: Re: [PATCH] cert: Fix warning of possible uninitialized var
Date: Mon, 18 Jan 2021 22:07:18 +0000
Message-ID: <f23c4455bd7b13c07a20aa6b486a859c41031ec1.camel@intel.com>
In-Reply-To: <6a7b320329c66f04246982ad2470b44d370412d4.camel@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5401381991078335901==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Mon, 2021-01-18 at 18:24 +0000, Gix, Brian wrote:

On Sat, 2021-01-16 at 07:28 +0000, Stotland, Inga wrote:

On Thu, 2021-01-14 at 23:53 +0100, Andrew Zaborowski wrote:

On Thu, 14 Jan 2021 at 22:35, Denis Kenzior <



<mailto:denkenz@gmail.com>

denkenz(a)gmail.com


 > wrote:

On 1/14/21 3:16 PM, Brian Gix wrote:

ell/cert-crypto.c: In function =E2=80=98cert_pkcs12_pbkdf=E2=80=99:

ell/cert-crypto.c:244:3: error: =E2=80=98bmpstring=E2=80=99 may be used uni=
nitialized in this function [-Werror=3Dmaybe-

uninitialized]

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



This does *not* fix the problen on "gcc (GCC) 9.3.1 20200408" unless *combi=
ned* with the change from Andrew:

        unsigned int p_len =3D password ? (passwd_len + hash->v - 1) & ~(ha=
sh->v - 1) : 0;

True, I forgot to metion that both changes were needed.




Or the part that uses bmpstring can be made conditional on password as well.


Best regard

_______________________________________________

ell mailing list --



<mailto:ell@lists.01.org>

ell(a)lists.01.org



To unsubscribe send an email to



<mailto:ell-leave@lists.01.org>

ell-leave(a)lists.01.org



--===============5401381991078335901==
Content-Type: text/html
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="attachment.htm"

PGh0bWwgZGlyPSJsdHIiPg0KPGhlYWQ+DQo8bWV0YSBodHRwLWVxdWl2PSJDb250ZW50LVR5cGUi
IGNvbnRlbnQ9InRleHQvaHRtbDsgY2hhcnNldD11dGYtOCI+DQo8L2hlYWQ+DQo8Ym9keSBzdHls
ZT0idGV4dC1hbGlnbjpsZWZ0OyBkaXJlY3Rpb246bHRyOyIgYmdjb2xvcj0iI2ZmZmZmZiIgdGV4
dD0iIzJlMzQzNiIgbGluaz0iIzczNzM3MyIgdmxpbms9IiMyZTM0MzYiPg0KPGRpdj5PbiBNb24s
IDIwMjEtMDEtMTggYXQgMTg6MjQgKzAwMDAsIEdpeCwgQnJpYW4gd3JvdGU6PC9kaXY+DQo8Ymxv
Y2txdW90ZSB0eXBlPSJjaXRlIiBzdHlsZT0ibWFyZ2luOjAgMCAwIC44ZXg7IGJvcmRlci1sZWZ0
OjJweCAjNzI5ZmNmIHNvbGlkO3BhZGRpbmctbGVmdDoxZXgiPg0KPHByZT5PbiBTYXQsIDIwMjEt
MDEtMTYgYXQgMDc6MjggKzAwMDAsIFN0b3RsYW5kLCBJbmdhIHdyb3RlOjwvcHJlPg0KPGJsb2Nr
cXVvdGUgdHlwZT0iY2l0ZSIgc3R5bGU9Im1hcmdpbjowIDAgMCAuOGV4OyBib3JkZXItbGVmdDoy
cHggIzcyOWZjZiBzb2xpZDtwYWRkaW5nLWxlZnQ6MWV4Ij4NCjxwcmU+T24gVGh1LCAyMDIxLTAx
LTE0IGF0IDIzOjUzICswMTAwLCBBbmRyZXcgWmFib3Jvd3NraSB3cm90ZTo8L3ByZT4NCjxibG9j
a3F1b3RlIHR5cGU9ImNpdGUiIHN0eWxlPSJtYXJnaW46MCAwIDAgLjhleDsgYm9yZGVyLWxlZnQ6
MnB4ICM3MjlmY2Ygc29saWQ7cGFkZGluZy1sZWZ0OjFleCI+DQo8cHJlPk9uIFRodSwgMTQgSmFu
IDIwMjEgYXQgMjI6MzUsIERlbmlzIEtlbnppb3IgJmx0OzwvcHJlPg0KPHByZT4gPC9wcmU+DQo8
YSBocmVmPSJtYWlsdG86ZGVua2VuekBnbWFpbC5jb20iPg0KPHByZT5kZW5rZW56QGdtYWlsLmNv
bTwvcHJlPg0KPC9hPg0KPHByZT48YnI+PC9wcmU+DQo8cHJlPiAmZ3Q7IHdyb3RlOjwvcHJlPg0K
PGJsb2NrcXVvdGUgdHlwZT0iY2l0ZSIgc3R5bGU9Im1hcmdpbjowIDAgMCAuOGV4OyBib3JkZXIt
bGVmdDoycHggIzcyOWZjZiBzb2xpZDtwYWRkaW5nLWxlZnQ6MWV4Ij4NCjxwcmU+T24gMS8xNC8y
MSAzOjE2IFBNLCBCcmlhbiBHaXggd3JvdGU6PC9wcmU+DQo8YmxvY2txdW90ZSB0eXBlPSJjaXRl
IiBzdHlsZT0ibWFyZ2luOjAgMCAwIC44ZXg7IGJvcmRlci1sZWZ0OjJweCAjNzI5ZmNmIHNvbGlk
O3BhZGRpbmctbGVmdDoxZXgiPg0KPHByZT5lbGwvY2VydC1jcnlwdG8uYzogSW4gZnVuY3Rpb24g
4oCYY2VydF9wa2NzMTJfcGJrZGbigJk6PC9wcmU+DQo8cHJlPmVsbC9jZXJ0LWNyeXB0by5jOjI0
NDozOiBlcnJvcjog4oCYYm1wc3RyaW5n4oCZIG1heSBiZSB1c2VkIHVuaW5pdGlhbGl6ZWQgaW4g
dGhpcyBmdW5jdGlvbiBbLVdlcnJvcj1tYXliZS08L3ByZT4NCjxwcmU+dW5pbml0aWFsaXplZF08
L3ByZT4NCjxwcmU+ICAgMjQ0IHwgICBleHBsaWNpdF9iemVybyhibXBzdHJpbmcsIHBhc3N3ZF9s
ZW4pOzwvcHJlPg0KPHByZT4gICAgICAgfCAgIF5+fn5+fn5+fn5+fn5+fn5+fn5+fn5+fn5+fn5+
fn5+fn5+fn48L3ByZT4NCjwvYmxvY2txdW90ZT4NCjxwcmU+PGJyPjwvcHJlPg0KPHByZT5XaGF0
IGNvbXBpbGVyIGFyZSB5b3Ugc2VlaW5nIHRoaXMgb24/PC9wcmU+DQo8L2Jsb2NrcXVvdGU+DQo8
L2Jsb2NrcXVvdGU+DQo8cHJlPjxicj48L3ByZT4NCjxwcmU+Tm90IHN1cmUgd2hpY2ggdmVyc2lv
biBvZiB0aGUgY29tcGlsZXIgQnJpYW4gaXMgdXNpbmcsIGJ1dCBJIGVuY291bnRlciB0aGlzIGlz
c3VlIHdpdGg6PC9wcmU+DQo8cHJlPmdjYyAoR0NDKSAxMC4yLjEgMjAyMDExMjUgKFJlZCBIYXQg
MTAuMi4xLTkpPC9wcmU+DQo8cHJlPjxicj48L3ByZT4NCjxibG9ja3F1b3RlIHR5cGU9ImNpdGUi
IHN0eWxlPSJtYXJnaW46MCAwIDAgLjhleDsgYm9yZGVyLWxlZnQ6MnB4ICM3MjlmY2Ygc29saWQ7
cGFkZGluZy1sZWZ0OjFleCI+DQo8YmxvY2txdW90ZSB0eXBlPSJjaXRlIiBzdHlsZT0ibWFyZ2lu
OjAgMCAwIC44ZXg7IGJvcmRlci1sZWZ0OjJweCAjNzI5ZmNmIHNvbGlkO3BhZGRpbmctbGVmdDox
ZXgiPg0KPGJsb2NrcXVvdGUgdHlwZT0iY2l0ZSIgc3R5bGU9Im1hcmdpbjowIDAgMCAuOGV4OyBi
b3JkZXItbGVmdDoycHggIzcyOWZjZiBzb2xpZDtwYWRkaW5nLWxlZnQ6MWV4Ij4NCjxwcmU+LS0t
PC9wcmU+DQo8cHJlPiAgZWxsL2NlcnQtY3J5cHRvLmMgfCAyICstPC9wcmU+DQo8cHJlPiAgMSBm
aWxlIGNoYW5nZWQsIDEgaW5zZXJ0aW9uKCspLCAxIGRlbGV0aW9uKC0pPC9wcmU+DQo8cHJlPjxi
cj48L3ByZT4NCjxwcmU+ZGlmZiAtLWdpdCBhL2VsbC9jZXJ0LWNyeXB0by5jIGIvZWxsL2NlcnQt
Y3J5cHRvLmM8L3ByZT4NCjxwcmU+aW5kZXggNmViNGUxNC4uYjNkMzAwMCAxMDA2NDQ8L3ByZT4N
CjxwcmU+LS0tIGEvZWxsL2NlcnQtY3J5cHRvLmM8L3ByZT4NCjxwcmU+KysrIGIvZWxsL2NlcnQt
Y3J5cHRvLmM8L3ByZT4NCjxwcmU+QEAgLTE5NCw3ICsxOTQsNyBAQCB1aW50OF90ICpjZXJ0X3Br
Y3MxMl9wYmtkZihjb25zdCBjaGFyICpwYXNzd29yZCw8L3ByZT4NCjxwcmU+ICB7PC9wcmU+DQo8
cHJlPiAgICAgIC8qIEFsbCBsZW5ndGhzIGluIGJ5dGVzIGluc3RlYWQgb2YgYml0cyAqLzwvcHJl
Pg0KPHByZT4gICAgICBzaXplX3QgcGFzc3dkX2xlbiA9IHBhc3N3b3JkID8gMiAqIHN0cmxlbihw
YXNzd29yZCkgKyAyIDogMDs8L3ByZT4NCjxwcmU+LSAgICAgdWludDhfdCAqYm1wc3RyaW5nOzwv
cHJlPg0KPHByZT4rICAgICB1aW50OF90ICpibXBzdHJpbmcgPSBOVUxMOzwvcHJlPg0KPC9ibG9j
a3F1b3RlPg0KPHByZT48YnI+PC9wcmU+DQo8cHJlPlNvIGdlbmVyYWxseSBJIGRvbid0IGxpa2Ug
dGhpcyB0eXBlIG9mIGZpeCBiZWNhdXNlIGl0IGp1c3QgaGlkZXMgcHJvYmxlbXMuICBUaGU8L3By
ZT4NCjxwcmU+aXNzdWVzIHdpdGggYm1wc3RyaW5nIHVzZSBzZWVtIHRvIGJlIGEgYml0IG1vcmUg
Y29tcGxleCB0aGFuIHRoYXQuPC9wcmU+DQo8cHJlPjxicj48L3ByZT4NCjxibG9ja3F1b3RlIHR5
cGU9ImNpdGUiIHN0eWxlPSJtYXJnaW46MCAwIDAgLjhleDsgYm9yZGVyLWxlZnQ6MnB4ICM3Mjlm
Y2Ygc29saWQ7cGFkZGluZy1sZWZ0OjFleCI+DQo8cHJlPiAgICAgIC8qIERvY3VtZW50ZWQgYXMg
dihjZWlsaW5nKHMvdikpLCB1c3VhbGx5IHdpbGwganVzdCBlcXVhbCB2ICovPC9wcmU+DQo8cHJl
PiAgICAgIHVuc2lnbmVkIGludCBzX2xlbiA9IChzYWx0X2xlbiArIGhhc2gtJmd0O3YgLSAxKSAm
YW1wOyB+KGhhc2gtJmd0O3YgLSAxKTs8L3ByZT4NCjxwcmU+ICAgICAgLyogRG9jdW1lbnRlZCBh
cyBwKGNlaWxpbmcocy9wKSksIHVzdWFsbHkgd2lsbCBqdXN0IGVxdWFsIHYgKi88L3ByZT4NCjxw
cmU+PGJyPjwvcHJlPg0KPC9ibG9ja3F1b3RlPg0KPHByZT48YnI+PC9wcmU+DQo8cHJlPkFuZHJl
dzo8L3ByZT4NCjxwcmU+PGJyPjwvcHJlPg0KPHByZT5XaHkgaXMgcF9sZW4gaW5pdGlhbGl6ZWQg
dG8gYmUgbm9uLXplcm8uICBJbiBwYXJ0aWN1bGFyLCB0aGlzIGJsb2NrOjwvcHJlPg0KPHByZT48
YnI+PC9wcmU+DQo8cHJlPiAgICAgICAgIGZvciAoaiA9IHBhc3N3ZF9sZW47IGogJmx0OyBwX2xl
bjsgaiArPSBwYXNzd2RfbGVuLCBwdHIgKz0gcGFzc3dkX2xlbik8L3ByZT4NCjxwcmU+ICAgICAg
ICAgICAgICAgICBtZW1jcHkocHRyLCBibXBzdHJpbmcsIHBhc3N3ZF9sZW4pOzwvcHJlPg0KPHBy
ZT48YnI+PC9wcmU+DQo8cHJlPndvdWxkIHNlZW0gdG8gY29weSBmcm9tIGFuIHVuaW5pdGlhbGl6
ZWQgYm1wc3RyaW5nIGV2ZW4gaWYgcGFzc3dvcmQgaXMgTlVMTC48L3ByZT4NCjwvYmxvY2txdW90
ZT4NCjxwcmU+PGJyPjwvcHJlPg0KPHByZT5JdCdzIG5vdCB2ZXJ5IG9idmlvdXMgYnV0IHBfbGVu
IGFuZCBwYXNzd2RfbGVuIGFyZSBib3RoIGdvaW5nIHRvIGJlIDA8L3ByZT4NCjxwcmU+aWYgcGFz
c3dvcmQgaXMgTlVMTC4gIHBfbGVuIGJlY29tZXMgKHYgLSAxKSAmYW1wOyB+KHYgLSAxKSwgSSBj
YW4gc2VlIHRoYXQ8L3ByZT4NCjxwcmU+aXQncyBoYXJkIGZvciB0aGUgY29tcGlsZXIgdG8gbm90
aWNlIHRoYXQuPC9wcmU+DQo8cHJlPjxicj48L3ByZT4NCjxwcmU+QnJpYW4sIGNhbiB5b3UgY2hl
Y2sgaWYgcGVyaGFwcyBpbml0aWFsaXppbmcgcF9sZW4gdGhpcyB3YXkgZml4ZXMgaXQ6PC9wcmU+
DQo8cHJlPjxicj48L3ByZT4NCjxwcmU+dW5zaWduZWQgaW50IHBfbGVuID0gcGFzc3dvcmQgPyAo
cGFzc3dkX2xlbiArIGhhc2gtJmd0O3YgLSAxKSAmYW1wOyB+KGhhc2gtJmd0O3YgLSAxKSA6IDA7
PC9wcmU+DQo8L2Jsb2NrcXVvdGU+DQo8cHJlPjxicj48L3ByZT4NCjxwcmU+VGhpcyBjaGFuZ2Ug
c3RpbGwgZG9lcyBub3QgZml4IHRoZSBjb21waWxlciBwcm9ibGVtLjwvcHJlPg0KPHByZT48YnI+
PC9wcmU+DQo8cHJlPkhvd2V2ZXIsIHRoZSB3YXJuaW5nIGRpc2FwcGVhcnMgaWYgd2UgbW92ZSAm
cXVvdDtmb3ImcXVvdDsgbG9vcCBpbnNpZGUgdGhlICZxdW90O2lmJnF1b3Q7IGNsYXVzZSB0aGF0
IGltbWVkaWF0ZWx5IGZvbGxvd3MuPC9wcmU+DQo8cHJlPjxicj48L3ByZT4NCjxwcmU+VGhlIHdh
eSBJIHNlZSBpdCwgdGhlIGZvciBsb29wIGlzIG5vdCBnb2luZyB0byBiZSBleGVjdXRlZCBpZiBw
X2xlbiBpcyB6ZXJvIGFueXdheSBhbmQgdGhpczwvcHJlPg0KPHByZT5jaGFnZSBhcHBlYXJzIHRv
IGJlIHNhZmUgc2luY2UgdGhlIGNvbXBhcmlzb25zIGFyZSBwZXJmcm1lZCBvbiB1bnNpZ25lZCBp
bnRlZ2Vycy48L3ByZT4NCjxwcmU+PGJyPjwvcHJlPg0KPHByZT4tICAgICAgIGZvciAoaiA9IHBh
c3N3ZF9sZW47IGogJmx0OyBwX2xlbjsgaiArPSBwYXNzd2RfbGVuLCBwdHIgKz0gcGFzc3dkX2xl
bik8L3ByZT4NCjxwcmU+LSAgICAgICAgICAgICAgIG1lbWNweShwdHIsIGJtcHN0cmluZywgcGFz
c3dkX2xlbik7PC9wcmU+DQo8cHJlPiA8L3ByZT4NCjxwcmU+ICAgICAgICBpZiAocF9sZW4pIHs8
L3ByZT4NCjxwcmU+KyAgICAgICAgICAgICAgIGZvciAoaiA9IHBhc3N3ZF9sZW47IGogJmx0OyBw
X2xlbjsgaiArPSBwYXNzd2RfbGVuLCBwdHIgKz0gcGFzc3dkX2xlbik8L3ByZT4NCjxwcmU+KyAg
ICAgICAgICAgICAgICAgICAgICAgbWVtY3B5KHB0ciwgYm1wc3RyaW5nLCBwYXNzd2RfbGVuKTs8
L3ByZT4NCjxwcmU+ICAgICAgICAgICAgICAgIG1lbWNweShwdHIsIGJtcHN0cmluZywgcF9sZW4g
KyBwYXNzd2RfbGVuIC0gaik7PC9wcmU+DQo8cHJlPjxicj48L3ByZT4NCjwvYmxvY2txdW90ZT4N
CjxwcmU+PGJyPjwvcHJlPg0KPHByZT5UaGlzIGRvZXMgKm5vdCogZml4IHRoZSBwcm9ibGVuIG9u
ICZxdW90O2djYyAoR0NDKSA5LjMuMSAyMDIwMDQwOCZxdW90OyB1bmxlc3MgKmNvbWJpbmVkKiB3
aXRoIHRoZSBjaGFuZ2UgZnJvbSBBbmRyZXc6PC9wcmU+DQo8cHJlPgl1bnNpZ25lZCBpbnQgcF9s
ZW4gPSBwYXNzd29yZCA/IChwYXNzd2RfbGVuICsgaGFzaC0mZ3Q7diAtIDEpICZhbXA7IH4oaGFz
aC0mZ3Q7diAtIDEpIDogMDs8L3ByZT4NCjwvYmxvY2txdW90ZT4NCjxkaXY+PGJyPg0KPC9kaXY+
DQo8ZGl2PlRydWUsIEkgZm9yZ290IHRvIG1ldGlvbiB0aGF0IGJvdGggY2hhbmdlcyB3ZXJlIG5l
ZWRlZC48L2Rpdj4NCjxkaXY+PGJyPg0KPC9kaXY+DQo8YmxvY2txdW90ZSB0eXBlPSJjaXRlIiBz
dHlsZT0ibWFyZ2luOjAgMCAwIC44ZXg7IGJvcmRlci1sZWZ0OjJweCAjNzI5ZmNmIHNvbGlkO3Bh
ZGRpbmctbGVmdDoxZXgiPg0KPHByZT48YnI+PC9wcmU+DQo8YmxvY2txdW90ZSB0eXBlPSJjaXRl
IiBzdHlsZT0ibWFyZ2luOjAgMCAwIC44ZXg7IGJvcmRlci1sZWZ0OjJweCAjNzI5ZmNmIHNvbGlk
O3BhZGRpbmctbGVmdDoxZXgiPg0KPHByZT48YnI+PC9wcmU+DQo8YmxvY2txdW90ZSB0eXBlPSJj
aXRlIiBzdHlsZT0ibWFyZ2luOjAgMCAwIC44ZXg7IGJvcmRlci1sZWZ0OjJweCAjNzI5ZmNmIHNv
bGlkO3BhZGRpbmctbGVmdDoxZXgiPg0KPHByZT5PciB0aGUgcGFydCB0aGF0IHVzZXMgYm1wc3Ry
aW5nIGNhbiBiZSBtYWRlIGNvbmRpdGlvbmFsIG9uIHBhc3N3b3JkIGFzIHdlbGwuPC9wcmU+DQo8
cHJlPjxicj48L3ByZT4NCjxwcmU+QmVzdCByZWdhcmQ8L3ByZT4NCjxwcmU+X19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX188L3ByZT4NCjxwcmU+ZWxsIG1haWxp
bmcgbGlzdCAtLSA8L3ByZT4NCjxwcmU+IDwvcHJlPg0KPGEgaHJlZj0ibWFpbHRvOmVsbEBsaXN0
cy4wMS5vcmciPg0KPHByZT5lbGxAbGlzdHMuMDEub3JnPC9wcmU+DQo8L2E+DQo8cHJlPjxicj48
L3ByZT4NCjxwcmU+PGJyPjwvcHJlPg0KPHByZT5UbyB1bnN1YnNjcmliZSBzZW5kIGFuIGVtYWls
IHRvIDwvcHJlPg0KPHByZT4gPC9wcmU+DQo8YSBocmVmPSJtYWlsdG86ZWxsLWxlYXZlQGxpc3Rz
LjAxLm9yZyI+DQo8cHJlPmVsbC1sZWF2ZUBsaXN0cy4wMS5vcmc8L3ByZT4NCjwvYT4NCjxwcmU+
PGJyPjwvcHJlPg0KPHByZT48YnI+PC9wcmU+DQo8L2Jsb2NrcXVvdGU+DQo8L2Jsb2NrcXVvdGU+
DQo8L2Jsb2NrcXVvdGU+DQo8L2JvZHk+DQo8L2h0bWw+DQo=

--===============5401381991078335901==--

