Content-Type: multipart/mixed; boundary="===============8842589116221593290=="
MIME-Version: 1.0
From: =?unknown-8bit?q?Micha=C5=82?= Lowas-Rzechonek <michal.lowas-rzechonek@silvair.com>
Subject: Re: [PATCH 0/5] Support C89 ELL builds
Date: Mon, 04 Mar 2019 22:15:04 +0100
Message-ID: <CACXRGxya9vWTQdrVEx_D3jMzuR8-T=q37+AOFvim1TRaFu0A6w@mail.gmail.com>
In-Reply-To: <9dccb3c7-9ae1-2c85-257d-594df08c6878@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8842589116221593290==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Just a question: is C89 compatibility a goal? C99 is nearly 20 y.o. I can't
see a reason to keep this, while at the same time target Linux.

On Mon, 4 Mar 2019, 20:23 Denis Kenzior, <denkenz@gmail.com> wrote:

> Hi Ossama,
>
> On 03/04/2019 12:42 PM, Ossama Othman wrote:
> > This patch set provides several simple changes to enable C89 support
> > in ELL.
> >
> > Ossama Othman (5):
> >    ell: Use __inline__ instead of inline for C89.
> >    ell: Do not use C99 '//' single line comment.
> >    settings: Explicitly enable strto{u}ll() for C89.
> >    string: Use __va_copy() for pre-C99 builds.
> >    unit: Remove C99 loop variable declaration.
> >
> >   ell/asn1-private.h       | 4 ++++
> >   ell/dbus.c               | 2 +-
> >   ell/netlink.c            | 2 +-
> >   ell/settings.c           | 4 ++++
> >   ell/string.c             | 4 ++++
> >   ell/utf8.h               | 4 ++++
> >   ell/util.h               | 4 ++++
> >   unit/test-dbus-message.c | 3 ++-
> >   8 files changed, 24 insertions(+), 3 deletions(-)
> >
>
> All applied, thanks.
>
> Regards,
> -Denis
> _______________________________________________
> ell mailing list
> ell(a)lists.01.org
> https://lists.01.org/mailman/listinfo/ell
>

--===============8842589116221593290==
Content-Type: text/html
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="attachment.html"

PGRpdiBkaXI9ImF1dG8iPkp1c3QgYSBxdWVzdGlvbjogaXMgQzg5IGNvbXBhdGliaWxpdHkgYSBn
b2FsPyBDOTkgaXMgbmVhcmx5IDIwIHkuby4gSSBjYW4mIzM5O3Qgc2VlIGEgcmVhc29uIHRvIGtl
ZXAgdGhpcywgd2hpbGUgYXQgdGhlIHNhbWUgdGltZSB0YXJnZXQgTGludXguPC9kaXY+PGJyPjxk
aXYgY2xhc3M9ImdtYWlsX3F1b3RlIj48ZGl2IGRpcj0ibHRyIiBjbGFzcz0iZ21haWxfYXR0ciI+
T24gTW9uLCA0IE1hciAyMDE5LCAyMDoyMyBEZW5pcyBLZW56aW9yLCAmbHQ7PGEgaHJlZj0ibWFp
bHRvOmRlbmtlbnpAZ21haWwuY29tIj5kZW5rZW56QGdtYWlsLmNvbTwvYT4mZ3Q7IHdyb3RlOjxi
cj48L2Rpdj48YmxvY2txdW90ZSBjbGFzcz0iZ21haWxfcXVvdGUiIHN0eWxlPSJtYXJnaW46MCAw
IDAgLjhleDtib3JkZXItbGVmdDoxcHggI2NjYyBzb2xpZDtwYWRkaW5nLWxlZnQ6MWV4Ij5IaSBP
c3NhbWEsPGJyPgo8YnI+Ck9uIDAzLzA0LzIwMTkgMTI6NDIgUE0sIE9zc2FtYSBPdGhtYW4gd3Jv
dGU6PGJyPgomZ3Q7IFRoaXMgcGF0Y2ggc2V0IHByb3ZpZGVzIHNldmVyYWwgc2ltcGxlIGNoYW5n
ZXMgdG8gZW5hYmxlIEM4OSBzdXBwb3J0PGJyPgomZ3Q7IGluIEVMTC48YnI+CiZndDsgPGJyPgom
Z3Q7IE9zc2FtYSBPdGhtYW4gKDUpOjxicj4KJmd0O8KgIMKgIGVsbDogVXNlIF9faW5saW5lX18g
aW5zdGVhZCBvZiBpbmxpbmUgZm9yIEM4OS48YnI+CiZndDvCoCDCoCBlbGw6IERvIG5vdCB1c2Ug
Qzk5ICYjMzk7Ly8mIzM5OyBzaW5nbGUgbGluZSBjb21tZW50Ljxicj4KJmd0O8KgIMKgIHNldHRp
bmdzOiBFeHBsaWNpdGx5IGVuYWJsZSBzdHJ0b3t1fWxsKCkgZm9yIEM4OS48YnI+CiZndDvCoCDC
oCBzdHJpbmc6IFVzZSBfX3ZhX2NvcHkoKSBmb3IgcHJlLUM5OSBidWlsZHMuPGJyPgomZ3Q7wqAg
wqAgdW5pdDogUmVtb3ZlIEM5OSBsb29wIHZhcmlhYmxlIGRlY2xhcmF0aW9uLjxicj4KJmd0OyA8
YnI+CiZndDvCoCDCoGVsbC9hc24xLXByaXZhdGUuaMKgIMKgIMKgIMKgfCA0ICsrKys8YnI+CiZn
dDvCoCDCoGVsbC9kYnVzLmPCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoHwgMiArLTxicj4KJmd0O8Kg
IMKgZWxsL25ldGxpbmsuY8KgIMKgIMKgIMKgIMKgIMKgIHwgMiArLTxicj4KJmd0O8KgIMKgZWxs
L3NldHRpbmdzLmPCoCDCoCDCoCDCoCDCoCDCoHwgNCArKysrPGJyPgomZ3Q7wqAgwqBlbGwvc3Ry
aW5nLmPCoCDCoCDCoCDCoCDCoCDCoCDCoHwgNCArKysrPGJyPgomZ3Q7wqAgwqBlbGwvdXRmOC5o
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqB8IDQgKysrKzxicj4KJmd0O8KgIMKgZWxsL3V0aWwuaMKg
IMKgIMKgIMKgIMKgIMKgIMKgIMKgfCA0ICsrKys8YnI+CiZndDvCoCDCoHVuaXQvdGVzdC1kYnVz
LW1lc3NhZ2UuYyB8IDMgKystPGJyPgomZ3Q7wqAgwqA4IGZpbGVzIGNoYW5nZWQsIDI0IGluc2Vy
dGlvbnMoKyksIDMgZGVsZXRpb25zKC0pPGJyPgomZ3Q7IDxicj4KPGJyPgpBbGwgYXBwbGllZCwg
dGhhbmtzLjxicj4KPGJyPgpSZWdhcmRzLDxicj4KLURlbmlzPGJyPgpfX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXzxicj4KZWxsIG1haWxpbmcgbGlzdDxicj4K
PGEgaHJlZj0ibWFpbHRvOmVsbEBsaXN0cy4wMS5vcmciIHRhcmdldD0iX2JsYW5rIiByZWw9Im5v
cmVmZXJyZXIiPmVsbEBsaXN0cy4wMS5vcmc8L2E+PGJyPgo8YSBocmVmPSJodHRwczovL2xpc3Rz
LjAxLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2VsbCIgcmVsPSJub3JlZmVycmVyIG5vcmVmZXJyZXIi
IHRhcmdldD0iX2JsYW5rIj5odHRwczovL2xpc3RzLjAxLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2Vs
bDwvYT48YnI+CjwvYmxvY2txdW90ZT48L2Rpdj4K

--===============8842589116221593290==--

