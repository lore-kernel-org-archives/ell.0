Content-Type: multipart/mixed; boundary="===============0296000223056321802=="
MIME-Version: 1.0
From: =?unknown-8bit?q?Micha=C5=82?= Lowas-Rzechonek <michal.lowas-rzechonek@silvair.com>
Subject: Re: [PATCH 0/5] Support C89 ELL builds
Date: Tue, 05 Mar 2019 07:57:11 +0100
Message-ID: <CACXRGxzR-XORyw-C+qGW3tdC3+FKhiLFpkN9ZuM0vYsSCPCw=A@mail.gmail.com>
In-Reply-To: <CAPyD+=DEcQSqxN1yyJqdPyBt2Rq8_GG_N6y8YgrMUXt27=Xixw@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0296000223056321802==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Yeah, I get that! My question was mostly to Denis, about the overall policy.

On Mon, 4 Mar 2019, 22:58 Othman, Ossama, <ossama.othman@intel.com> wrote:

> Hi Micha=C5=82,
>
> Part of the motivation of this patch set was to make the code more closely
> conform to ELL's coding style, which disallows some C99 features.
> Explicitly building ELL with C89 (CFLAGS=3D-std=3Dc89) helped expose some=
 of
> style violations.  Getting ELL to work with C89 was also trivial, so I
> submitted patches accordingly.
>
> -Ossama
>
> On Mon, Mar 4, 2019 at 1:15 PM Micha=C5=82 Lowas-Rzechonek <
> michal.lowas-rzechonek(a)silvair.com> wrote:
>
>> Just a question: is C89 compatibility a goal? C99 is nearly 20 y.o. I
>> can't see a reason to keep this, while at the same time target Linux.
>>
>> On Mon, 4 Mar 2019, 20:23 Denis Kenzior, <denkenz@gmail.com> wrote:
>>
>>> Hi Ossama,
>>>
>>> On 03/04/2019 12:42 PM, Ossama Othman wrote:
>>> > This patch set provides several simple changes to enable C89 support
>>> > in ELL.
>>> >
>>> > Ossama Othman (5):
>>> >    ell: Use __inline__ instead of inline for C89.
>>> >    ell: Do not use C99 '//' single line comment.
>>> >    settings: Explicitly enable strto{u}ll() for C89.
>>> >    string: Use __va_copy() for pre-C99 builds.
>>> >    unit: Remove C99 loop variable declaration.
>>> >
>>> >   ell/asn1-private.h       | 4 ++++
>>> >   ell/dbus.c               | 2 +-
>>> >   ell/netlink.c            | 2 +-
>>> >   ell/settings.c           | 4 ++++
>>> >   ell/string.c             | 4 ++++
>>> >   ell/utf8.h               | 4 ++++
>>> >   ell/util.h               | 4 ++++
>>> >   unit/test-dbus-message.c | 3 ++-
>>> >   8 files changed, 24 insertions(+), 3 deletions(-)
>>> >
>>>
>>> All applied, thanks.
>>>
>>> Regards,
>>> -Denis
>>> _______________________________________________
>>> ell mailing list
>>> ell(a)lists.01.org
>>> https://lists.01.org/mailman/listinfo/ell
>>>
>>

--===============0296000223056321802==
Content-Type: text/html
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="attachment.html"

PGRpdiBkaXI9ImF1dG8iPlllYWgsIEkgZ2V0IHRoYXQhIE15IHF1ZXN0aW9uIHdhcyBtb3N0bHkg
dG8gRGVuaXMsIGFib3V0IHRoZSBvdmVyYWxsIHBvbGljeS48L2Rpdj48YnI+PGRpdiBjbGFzcz0i
Z21haWxfcXVvdGUiPjxkaXYgZGlyPSJsdHIiIGNsYXNzPSJnbWFpbF9hdHRyIj5PbiBNb24sIDQg
TWFyIDIwMTksIDIyOjU4IE90aG1hbiwgT3NzYW1hLCAmbHQ7PGEgaHJlZj0ibWFpbHRvOm9zc2Ft
YS5vdGhtYW5AaW50ZWwuY29tIiB0YXJnZXQ9Il9ibGFuayIgcmVsPSJub3JlZmVycmVyIj5vc3Nh
bWEub3RobWFuQGludGVsLmNvbTwvYT4mZ3Q7IHdyb3RlOjxicj48L2Rpdj48YmxvY2txdW90ZSBj
bGFzcz0iZ21haWxfcXVvdGUiIHN0eWxlPSJtYXJnaW46MCAwIDAgLjhleDtib3JkZXItbGVmdDox
cHggI2NjYyBzb2xpZDtwYWRkaW5nLWxlZnQ6MWV4Ij48ZGl2IGRpcj0ibHRyIj5IaSBNaWNoYcWC
LDxkaXY+PGJyPjwvZGl2PjxkaXY+UGFydCBvZiB0aGUgbW90aXZhdGlvbiBvZiB0aGlzIHBhdGNo
IHNldCB3YXMgdG8gbWFrZSB0aGUgY29kZSBtb3JlIGNsb3NlbHkgY29uZm9ybSB0byBFTEwmIzM5
O3MgY29kaW5nIHN0eWxlLCB3aGljaCBkaXNhbGxvd3Mgc29tZSBDOTkgZmVhdHVyZXMuwqAgRXhw
bGljaXRseSBidWlsZGluZyBFTEwgd2l0aCBDODkgKENGTEFHUz0tc3RkPWM4OSkgaGVscGVkIGV4
cG9zZSBzb21lIG9mIHN0eWxlIHZpb2xhdGlvbnMuwqAgR2V0dGluZyBFTEwgdG8gd29yayB3aXRo
IEM4OSB3YXMgYWxzbyB0cml2aWFsLCBzbyBJIHN1Ym1pdHRlZCBwYXRjaGVzIGFjY29yZGluZ2x5
LjwvZGl2PjxkaXY+PGJyPjwvZGl2PjxkaXY+LU9zc2FtYTwvZGl2PjwvZGl2Pjxicj48ZGl2IGNs
YXNzPSJnbWFpbF9xdW90ZSI+PGRpdiBkaXI9Imx0ciIgY2xhc3M9ImdtYWlsX2F0dHIiPk9uIE1v
biwgTWFyIDQsIDIwMTkgYXQgMToxNSBQTSBNaWNoYcWCIExvd2FzLVJ6ZWNob25layAmbHQ7PGEg
aHJlZj0ibWFpbHRvOm1pY2hhbC5sb3dhcy1yemVjaG9uZWtAc2lsdmFpci5jb20iIHJlbD0ibm9y
ZWZlcnJlciBub3JlZmVycmVyIiB0YXJnZXQ9Il9ibGFuayI+bWljaGFsLmxvd2FzLXJ6ZWNob25l
a0BzaWx2YWlyLmNvbTwvYT4mZ3Q7IHdyb3RlOjxicj48L2Rpdj48YmxvY2txdW90ZSBjbGFzcz0i
Z21haWxfcXVvdGUiIHN0eWxlPSJtYXJnaW46MHB4IDBweCAwcHggMC44ZXg7Ym9yZGVyLWxlZnQ6
MXB4IHNvbGlkIHJnYigyMDQsMjA0LDIwNCk7cGFkZGluZy1sZWZ0OjFleCI+PGRpdiBkaXI9ImF1
dG8iPkp1c3QgYSBxdWVzdGlvbjogaXMgQzg5IGNvbXBhdGliaWxpdHkgYSBnb2FsPyBDOTkgaXMg
bmVhcmx5IDIwIHkuby4gSSBjYW4mIzM5O3Qgc2VlIGEgcmVhc29uIHRvIGtlZXAgdGhpcywgd2hp
bGUgYXQgdGhlIHNhbWUgdGltZSB0YXJnZXQgTGludXguPC9kaXY+PGJyPjxkaXYgY2xhc3M9Imdt
YWlsX3F1b3RlIj48ZGl2IGRpcj0ibHRyIiBjbGFzcz0iZ21haWxfYXR0ciI+T24gTW9uLCA0IE1h
ciAyMDE5LCAyMDoyMyBEZW5pcyBLZW56aW9yLCAmbHQ7PGEgaHJlZj0ibWFpbHRvOmRlbmtlbnpA
Z21haWwuY29tIiByZWw9Im5vcmVmZXJyZXIgbm9yZWZlcnJlciIgdGFyZ2V0PSJfYmxhbmsiPmRl
bmtlbnpAZ21haWwuY29tPC9hPiZndDsgd3JvdGU6PGJyPjwvZGl2PjxibG9ja3F1b3RlIGNsYXNz
PSJnbWFpbF9xdW90ZSIgc3R5bGU9Im1hcmdpbjowcHggMHB4IDBweCAwLjhleDtib3JkZXItbGVm
dDoxcHggc29saWQgcmdiKDIwNCwyMDQsMjA0KTtwYWRkaW5nLWxlZnQ6MWV4Ij5IaSBPc3NhbWEs
PGJyPgo8YnI+Ck9uIDAzLzA0LzIwMTkgMTI6NDIgUE0sIE9zc2FtYSBPdGhtYW4gd3JvdGU6PGJy
PgomZ3Q7IFRoaXMgcGF0Y2ggc2V0IHByb3ZpZGVzIHNldmVyYWwgc2ltcGxlIGNoYW5nZXMgdG8g
ZW5hYmxlIEM4OSBzdXBwb3J0PGJyPgomZ3Q7IGluIEVMTC48YnI+CiZndDsgPGJyPgomZ3Q7IE9z
c2FtYSBPdGhtYW4gKDUpOjxicj4KJmd0O8KgIMKgIGVsbDogVXNlIF9faW5saW5lX18gaW5zdGVh
ZCBvZiBpbmxpbmUgZm9yIEM4OS48YnI+CiZndDvCoCDCoCBlbGw6IERvIG5vdCB1c2UgQzk5ICYj
Mzk7Ly8mIzM5OyBzaW5nbGUgbGluZSBjb21tZW50Ljxicj4KJmd0O8KgIMKgIHNldHRpbmdzOiBF
eHBsaWNpdGx5IGVuYWJsZSBzdHJ0b3t1fWxsKCkgZm9yIEM4OS48YnI+CiZndDvCoCDCoCBzdHJp
bmc6IFVzZSBfX3ZhX2NvcHkoKSBmb3IgcHJlLUM5OSBidWlsZHMuPGJyPgomZ3Q7wqAgwqAgdW5p
dDogUmVtb3ZlIEM5OSBsb29wIHZhcmlhYmxlIGRlY2xhcmF0aW9uLjxicj4KJmd0OyA8YnI+CiZn
dDvCoCDCoGVsbC9hc24xLXByaXZhdGUuaMKgIMKgIMKgIMKgfCA0ICsrKys8YnI+CiZndDvCoCDC
oGVsbC9kYnVzLmPCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoHwgMiArLTxicj4KJmd0O8KgIMKgZWxs
L25ldGxpbmsuY8KgIMKgIMKgIMKgIMKgIMKgIHwgMiArLTxicj4KJmd0O8KgIMKgZWxsL3NldHRp
bmdzLmPCoCDCoCDCoCDCoCDCoCDCoHwgNCArKysrPGJyPgomZ3Q7wqAgwqBlbGwvc3RyaW5nLmPC
oCDCoCDCoCDCoCDCoCDCoCDCoHwgNCArKysrPGJyPgomZ3Q7wqAgwqBlbGwvdXRmOC5owqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqB8IDQgKysrKzxicj4KJmd0O8KgIMKgZWxsL3V0aWwuaMKgIMKgIMKg
IMKgIMKgIMKgIMKgIMKgfCA0ICsrKys8YnI+CiZndDvCoCDCoHVuaXQvdGVzdC1kYnVzLW1lc3Nh
Z2UuYyB8IDMgKystPGJyPgomZ3Q7wqAgwqA4IGZpbGVzIGNoYW5nZWQsIDI0IGluc2VydGlvbnMo
KyksIDMgZGVsZXRpb25zKC0pPGJyPgomZ3Q7IDxicj4KPGJyPgpBbGwgYXBwbGllZCwgdGhhbmtz
Ljxicj4KPGJyPgpSZWdhcmRzLDxicj4KLURlbmlzPGJyPgpfX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fXzxicj4KZWxsIG1haWxpbmcgbGlzdDxicj4KPGEgaHJl
Zj0ibWFpbHRvOmVsbEBsaXN0cy4wMS5vcmciIHJlbD0ibm9yZWZlcnJlciBub3JlZmVycmVyIG5v
cmVmZXJyZXIiIHRhcmdldD0iX2JsYW5rIj5lbGxAbGlzdHMuMDEub3JnPC9hPjxicj4KPGEgaHJl
Zj0iaHR0cHM6Ly9saXN0cy4wMS5vcmcvbWFpbG1hbi9saXN0aW5mby9lbGwiIHJlbD0ibm9yZWZl
cnJlciBub3JlZmVycmVyIG5vcmVmZXJyZXIgbm9yZWZlcnJlciIgdGFyZ2V0PSJfYmxhbmsiPmh0
dHBzOi8vbGlzdHMuMDEub3JnL21haWxtYW4vbGlzdGluZm8vZWxsPC9hPjxicj4KPC9ibG9ja3F1
b3RlPjwvZGl2Pgo8L2Jsb2NrcXVvdGU+PC9kaXY+CjwvYmxvY2txdW90ZT48L2Rpdj4K

--===============0296000223056321802==--

