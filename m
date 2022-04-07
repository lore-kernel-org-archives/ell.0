Content-Type: multipart/mixed; boundary="===============6713867243023184042=="
MIME-Version: 1.0
From: wen zhang <zhw2101024 at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH]run unit tests on both OpenSSL-1.x and OpenSSL-3.x
Date: Thu, 07 Apr 2022 09:24:58 +0800
Message-ID: <CAKjfnjogWuHB1MmUqQOnVjiXvjHR-cPk_TMjgsjduQ=6JGVUbQ@mail.gmail.com>
In-Reply-To: 139b5e8-97c0-624c-ff3d-eaee4555498e@linux.intel.com

--===============6713867243023184042==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Mat Martineau <mathew.j.martineau(a)linux.intel.com> =E4=BA=8E2022=E5=B9=B4=
4=E6=9C=887=E6=97=A5=E5=91=A8=E5=9B=9B 06:15=E5=86=99=E9=81=93=EF=BC=9A

>
> On Tue, 29 Mar 2022, wen zhang wrote:
>
> > Some unit tests are breaking on systems with OpenSSL 3.x.
> > This patch detects the OpenSSL version, then if we are building Ell on
> > OpenSSL 3.x, the legacy module options will be appended to openssl
> commands.
>
> Hi Wen Zhang -
>
> I noticed that ELL is not building the unit tests on the Fedora 36 beta
> due to this OpenSSL 3 command line issue with the legacy providers.
>
> Unfortunately, your patch didn't work on Fedora 36. I see these lines
> added to the Makefile generated with the bootstrap-configure script:
>
> OPENSSL_LEGACY_OPTS =3D
> OPENSSL_LIBDIR =3D
>
> In addition, the openssl legacy provider options are not included in the
> openssl commands.
>
>
> Also, be sure to send patches using 'git send-email' so they do not use
> HTML or attachments. More patch submission guidelines are here:
> https://git.kernel.org/pub/scm/libs/ell/ell.git/tree/HACKING
>
>
> Thanks,
>
> --
> Mat Martineau
> Intel
>
Thanks for the feedback! And sorry for the noise.
I'm building ELL on one system built following LFS project. Maybe it's
different on Fedora 36.
I'll use git send-email next time.

--===============6713867243023184042==
Content-Type: text/html
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="attachment.htm"

PGRpdiBkaXI9Imx0ciI+PGRpdiBkaXI9Imx0ciI+TWF0IE1hcnRpbmVhdSAmbHQ7PGEgaHJlZj0i
bWFpbHRvOm1hdGhldy5qLm1hcnRpbmVhdUBsaW51eC5pbnRlbC5jb20iPm1hdGhldy5qLm1hcnRp
bmVhdUBsaW51eC5pbnRlbC5jb208L2E+Jmd0OyDkuo4yMDIy5bm0NOaciDfml6Xlkajlm5sgMDY6
MTXlhpnpgZPvvJo8YnI+PC9kaXY+PGRpdiBjbGFzcz0iZ21haWxfcXVvdGUiPjxibG9ja3F1b3Rl
IGNsYXNzPSJnbWFpbF9xdW90ZSIgc3R5bGU9Im1hcmdpbjowcHggMHB4IDBweCAwLjhleDtib3Jk
ZXItbGVmdDoxcHggc29saWQgcmdiKDIwNCwyMDQsMjA0KTtwYWRkaW5nLWxlZnQ6MWV4Ij48YnI+
Ck9uIFR1ZSwgMjkgTWFyIDIwMjIsIHdlbiB6aGFuZyB3cm90ZTo8YnI+Cjxicj4KJmd0OyBTb21l
IHVuaXQgdGVzdHMgYXJlIGJyZWFraW5nIG9uIHN5c3RlbXMgd2l0aCBPcGVuU1NMIDMueC48YnI+
CiZndDsgVGhpcyBwYXRjaCBkZXRlY3RzIHRoZSBPcGVuU1NMIHZlcnNpb24sIHRoZW4gaWYgd2Ug
YXJlIGJ1aWxkaW5nIEVsbCBvbjxicj4KJmd0OyBPcGVuU1NMIDMueCwgdGhlIGxlZ2FjeSBtb2R1
bGUgb3B0aW9ucyB3aWxsIGJlIGFwcGVuZGVkIHRvIG9wZW5zc2wgY29tbWFuZHMuPGJyPgo8YnI+
CkhpIFdlbiBaaGFuZyAtPGJyPgo8YnI+Ckkgbm90aWNlZCB0aGF0IEVMTCBpcyBub3QgYnVpbGRp
bmcgdGhlIHVuaXQgdGVzdHMgb24gdGhlIEZlZG9yYSAzNiBiZXRhIDxicj4KZHVlIHRvIHRoaXMg
T3BlblNTTCAzIGNvbW1hbmQgbGluZSBpc3N1ZSB3aXRoIHRoZSBsZWdhY3kgcHJvdmlkZXJzLjxi
cj4KPGJyPgpVbmZvcnR1bmF0ZWx5LCB5b3VyIHBhdGNoIGRpZG4mIzM5O3Qgd29yayBvbiBGZWRv
cmEgMzYuIEkgc2VlIHRoZXNlIGxpbmVzIDxicj4KYWRkZWQgdG8gdGhlIE1ha2VmaWxlIGdlbmVy
YXRlZCB3aXRoIHRoZSBib290c3RyYXAtY29uZmlndXJlIHNjcmlwdDo8YnI+Cjxicj4KT1BFTlNT
TF9MRUdBQ1lfT1BUUyA9PGJyPgpPUEVOU1NMX0xJQkRJUiA9PGJyPgo8YnI+CkluIGFkZGl0aW9u
LCB0aGUgb3BlbnNzbCBsZWdhY3kgcHJvdmlkZXIgb3B0aW9ucyBhcmUgbm90IGluY2x1ZGVkIGlu
IHRoZSA8YnI+Cm9wZW5zc2wgY29tbWFuZHMuPGJyPgo8YnI+Cjxicj4KQWxzbywgYmUgc3VyZSB0
byBzZW5kIHBhdGNoZXMgdXNpbmcgJiMzOTtnaXQgc2VuZC1lbWFpbCYjMzk7IHNvIHRoZXkgZG8g
bm90IHVzZSA8YnI+CkhUTUwgb3IgYXR0YWNobWVudHMuIE1vcmUgcGF0Y2ggc3VibWlzc2lvbiBn
dWlkZWxpbmVzIGFyZSBoZXJlOiA8YnI+CjxhIGhyZWY9Imh0dHBzOi8vZ2l0Lmtlcm5lbC5vcmcv
cHViL3NjbS9saWJzL2VsbC9lbGwuZ2l0L3RyZWUvSEFDS0lORyIgcmVsPSJub3JlZmVycmVyIiB0
YXJnZXQ9Il9ibGFuayI+aHR0cHM6Ly9naXQua2VybmVsLm9yZy9wdWIvc2NtL2xpYnMvZWxsL2Vs
bC5naXQvdHJlZS9IQUNLSU5HPC9hPjxicj4KPGJyPgo8YnI+ClRoYW5rcyw8YnI+Cjxicj4KLS08
YnI+Ck1hdCBNYXJ0aW5lYXU8YnI+CkludGVsPGJyPjwvYmxvY2txdW90ZT48ZGl2PjxkaXY+VGhh
bmtzIGZvciB0aGUgZmVlZGJhY2shIEFuZCBzb3JyeSBmb3IgdGhlIG5vaXNlLjxicj48L2Rpdj48
ZGl2PkkmIzM5O20gYnVpbGRpbmcgRUxMIG9uIG9uZSBzeXN0ZW0gYnVpbHQgZm9sbG93aW5nIExG
UyBwcm9qZWN0LiBNYXliZSBpdCYjMzk7cyBkaWZmZXJlbnQgb24gRmVkb3JhIDM2LjwvZGl2Pjxk
aXY+SSYjMzk7bGwgdXNlIGdpdCBzZW5kLWVtYWlsIG5leHQgdGltZS48YnI+PC9kaXY+wqA8L2Rp
dj48L2Rpdj48L2Rpdj4K

--===============6713867243023184042==--

