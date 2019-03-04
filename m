Content-Type: multipart/mixed; boundary="===============5929211608808784872=="
MIME-Version: 1.0
From: Othman, Ossama <ossama.othman@intel.com>
Subject: Re: [PATCH 0/5] Support C89 ELL builds
Date: Mon, 04 Mar 2019 13:58:25 -0800
Message-ID: <CAPyD+=DEcQSqxN1yyJqdPyBt2Rq8_GG_N6y8YgrMUXt27=Xixw@mail.gmail.com>
In-Reply-To: <CACXRGxya9vWTQdrVEx_D3jMzuR8-T=q37+AOFvim1TRaFu0A6w@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5929211608808784872==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Micha=C5=82,

Part of the motivation of this patch set was to make the code more closely
conform to ELL's coding style, which disallows some C99 features.
Explicitly building ELL with C89 (CFLAGS=3D-std=3Dc89) helped expose some of
style violations.  Getting ELL to work with C89 was also trivial, so I
submitted patches accordingly.

-Ossama

On Mon, Mar 4, 2019 at 1:15 PM Micha=C5=82 Lowas-Rzechonek <
michal.lowas-rzechonek@silvair.com> wrote:

> Just a question: is C89 compatibility a goal? C99 is nearly 20 y.o. I
> can't see a reason to keep this, while at the same time target Linux.
>
> On Mon, 4 Mar 2019, 20:23 Denis Kenzior, <denkenz@gmail.com> wrote:
>
>> Hi Ossama,
>>
>> On 03/04/2019 12:42 PM, Ossama Othman wrote:
>> > This patch set provides several simple changes to enable C89 support
>> > in ELL.
>> >
>> > Ossama Othman (5):
>> >    ell: Use __inline__ instead of inline for C89.
>> >    ell: Do not use C99 '//' single line comment.
>> >    settings: Explicitly enable strto{u}ll() for C89.
>> >    string: Use __va_copy() for pre-C99 builds.
>> >    unit: Remove C99 loop variable declaration.
>> >
>> >   ell/asn1-private.h       | 4 ++++
>> >   ell/dbus.c               | 2 +-
>> >   ell/netlink.c            | 2 +-
>> >   ell/settings.c           | 4 ++++
>> >   ell/string.c             | 4 ++++
>> >   ell/utf8.h               | 4 ++++
>> >   ell/util.h               | 4 ++++
>> >   unit/test-dbus-message.c | 3 ++-
>> >   8 files changed, 24 insertions(+), 3 deletions(-)
>> >
>>
>> All applied, thanks.
>>
>> Regards,
>> -Denis
>> _______________________________________________
>> ell mailing list
>> ell(a)lists.01.org
>> https://lists.01.org/mailman/listinfo/ell
>>
>

--===============5929211608808784872==
Content-Type: text/html
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="attachment.html"

PGRpdiBkaXI9Imx0ciI+SGkgTWljaGHFgiw8ZGl2Pjxicj48L2Rpdj48ZGl2PlBhcnQgb2YgdGhl
IG1vdGl2YXRpb24gb2YgdGhpcyBwYXRjaCBzZXQgd2FzIHRvIG1ha2UgdGhlIGNvZGUgbW9yZSBj
bG9zZWx5IGNvbmZvcm0gdG8gRUxMJiMzOTtzIGNvZGluZyBzdHlsZSwgd2hpY2ggZGlzYWxsb3dz
IHNvbWUgQzk5IGZlYXR1cmVzLsKgIEV4cGxpY2l0bHkgYnVpbGRpbmcgRUxMIHdpdGggQzg5IChD
RkxBR1M9LXN0ZD1jODkpIGhlbHBlZCBleHBvc2Ugc29tZSBvZiBzdHlsZSB2aW9sYXRpb25zLsKg
IEdldHRpbmcgRUxMIHRvIHdvcmsgd2l0aCBDODkgd2FzIGFsc28gdHJpdmlhbCwgc28gSSBzdWJt
aXR0ZWQgcGF0Y2hlcyBhY2NvcmRpbmdseS48L2Rpdj48ZGl2Pjxicj48L2Rpdj48ZGl2Pi1Pc3Nh
bWE8L2Rpdj48L2Rpdj48YnI+PGRpdiBjbGFzcz0iZ21haWxfcXVvdGUiPjxkaXYgZGlyPSJsdHIi
IGNsYXNzPSJnbWFpbF9hdHRyIj5PbiBNb24sIE1hciA0LCAyMDE5IGF0IDE6MTUgUE0gTWljaGHF
giBMb3dhcy1SemVjaG9uZWsgJmx0OzxhIGhyZWY9Im1haWx0bzptaWNoYWwubG93YXMtcnplY2hv
bmVrQHNpbHZhaXIuY29tIiB0YXJnZXQ9Il9ibGFuayI+bWljaGFsLmxvd2FzLXJ6ZWNob25la0Bz
aWx2YWlyLmNvbTwvYT4mZ3Q7IHdyb3RlOjxicj48L2Rpdj48YmxvY2txdW90ZSBjbGFzcz0iZ21h
aWxfcXVvdGUiIHN0eWxlPSJtYXJnaW46MHB4IDBweCAwcHggMC44ZXg7Ym9yZGVyLWxlZnQ6MXB4
IHNvbGlkIHJnYigyMDQsMjA0LDIwNCk7cGFkZGluZy1sZWZ0OjFleCI+PGRpdiBkaXI9ImF1dG8i
Pkp1c3QgYSBxdWVzdGlvbjogaXMgQzg5IGNvbXBhdGliaWxpdHkgYSBnb2FsPyBDOTkgaXMgbmVh
cmx5IDIwIHkuby4gSSBjYW4mIzM5O3Qgc2VlIGEgcmVhc29uIHRvIGtlZXAgdGhpcywgd2hpbGUg
YXQgdGhlIHNhbWUgdGltZSB0YXJnZXQgTGludXguPC9kaXY+PGJyPjxkaXYgY2xhc3M9ImdtYWls
X3F1b3RlIj48ZGl2IGRpcj0ibHRyIiBjbGFzcz0iZ21haWxfYXR0ciI+T24gTW9uLCA0IE1hciAy
MDE5LCAyMDoyMyBEZW5pcyBLZW56aW9yLCAmbHQ7PGEgaHJlZj0ibWFpbHRvOmRlbmtlbnpAZ21h
aWwuY29tIiB0YXJnZXQ9Il9ibGFuayI+ZGVua2VuekBnbWFpbC5jb208L2E+Jmd0OyB3cm90ZTo8
YnI+PC9kaXY+PGJsb2NrcXVvdGUgY2xhc3M9ImdtYWlsX3F1b3RlIiBzdHlsZT0ibWFyZ2luOjBw
eCAwcHggMHB4IDAuOGV4O2JvcmRlci1sZWZ0OjFweCBzb2xpZCByZ2IoMjA0LDIwNCwyMDQpO3Bh
ZGRpbmctbGVmdDoxZXgiPkhpIE9zc2FtYSw8YnI+Cjxicj4KT24gMDMvMDQvMjAxOSAxMjo0MiBQ
TSwgT3NzYW1hIE90aG1hbiB3cm90ZTo8YnI+CiZndDsgVGhpcyBwYXRjaCBzZXQgcHJvdmlkZXMg
c2V2ZXJhbCBzaW1wbGUgY2hhbmdlcyB0byBlbmFibGUgQzg5IHN1cHBvcnQ8YnI+CiZndDsgaW4g
RUxMLjxicj4KJmd0OyA8YnI+CiZndDsgT3NzYW1hIE90aG1hbiAoNSk6PGJyPgomZ3Q7wqAgwqAg
ZWxsOiBVc2UgX19pbmxpbmVfXyBpbnN0ZWFkIG9mIGlubGluZSBmb3IgQzg5Ljxicj4KJmd0O8Kg
IMKgIGVsbDogRG8gbm90IHVzZSBDOTkgJiMzOTsvLyYjMzk7IHNpbmdsZSBsaW5lIGNvbW1lbnQu
PGJyPgomZ3Q7wqAgwqAgc2V0dGluZ3M6IEV4cGxpY2l0bHkgZW5hYmxlIHN0cnRve3V9bGwoKSBm
b3IgQzg5Ljxicj4KJmd0O8KgIMKgIHN0cmluZzogVXNlIF9fdmFfY29weSgpIGZvciBwcmUtQzk5
IGJ1aWxkcy48YnI+CiZndDvCoCDCoCB1bml0OiBSZW1vdmUgQzk5IGxvb3AgdmFyaWFibGUgZGVj
bGFyYXRpb24uPGJyPgomZ3Q7IDxicj4KJmd0O8KgIMKgZWxsL2FzbjEtcHJpdmF0ZS5owqAgwqAg
wqAgwqB8IDQgKysrKzxicj4KJmd0O8KgIMKgZWxsL2RidXMuY8KgIMKgIMKgIMKgIMKgIMKgIMKg
IMKgfCAyICstPGJyPgomZ3Q7wqAgwqBlbGwvbmV0bGluay5jwqAgwqAgwqAgwqAgwqAgwqAgfCAy
ICstPGJyPgomZ3Q7wqAgwqBlbGwvc2V0dGluZ3MuY8KgIMKgIMKgIMKgIMKgIMKgfCA0ICsrKys8
YnI+CiZndDvCoCDCoGVsbC9zdHJpbmcuY8KgIMKgIMKgIMKgIMKgIMKgIMKgfCA0ICsrKys8YnI+
CiZndDvCoCDCoGVsbC91dGY4LmjCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoHwgNCArKysrPGJyPgom
Z3Q7wqAgwqBlbGwvdXRpbC5owqAgwqAgwqAgwqAgwqAgwqAgwqAgwqB8IDQgKysrKzxicj4KJmd0
O8KgIMKgdW5pdC90ZXN0LWRidXMtbWVzc2FnZS5jIHwgMyArKy08YnI+CiZndDvCoCDCoDggZmls
ZXMgY2hhbmdlZCwgMjQgaW5zZXJ0aW9ucygrKSwgMyBkZWxldGlvbnMoLSk8YnI+CiZndDsgPGJy
Pgo8YnI+CkFsbCBhcHBsaWVkLCB0aGFua3MuPGJyPgo8YnI+ClJlZ2FyZHMsPGJyPgotRGVuaXM8
YnI+Cl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fPGJyPgpl
bGwgbWFpbGluZyBsaXN0PGJyPgo8YSBocmVmPSJtYWlsdG86ZWxsQGxpc3RzLjAxLm9yZyIgcmVs
PSJub3JlZmVycmVyIiB0YXJnZXQ9Il9ibGFuayI+ZWxsQGxpc3RzLjAxLm9yZzwvYT48YnI+Cjxh
IGhyZWY9Imh0dHBzOi8vbGlzdHMuMDEub3JnL21haWxtYW4vbGlzdGluZm8vZWxsIiByZWw9Im5v
cmVmZXJyZXIgbm9yZWZlcnJlciIgdGFyZ2V0PSJfYmxhbmsiPmh0dHBzOi8vbGlzdHMuMDEub3Jn
L21haWxtYW4vbGlzdGluZm8vZWxsPC9hPjxicj4KPC9ibG9ja3F1b3RlPjwvZGl2Pgo8L2Jsb2Nr
cXVvdGU+PC9kaXY+Cg==

--===============5929211608808784872==--

