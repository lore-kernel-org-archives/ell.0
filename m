Content-Type: multipart/mixed; boundary="===============2829141026366015175=="
MIME-Version: 1.0
From: James Prestwood <prestwoj at gmail.com>
To: ell at lists.01.org
Subject: Re: Unable to build ELL with OpenSSL 3
Date: Wed, 09 Mar 2022 10:04:33 -0800
Message-ID: <c1597d43bd76de5df8d7db5e10721941e053f779.camel@gmail.com>
In-Reply-To: CAKjfnjpsLZ+amJ4ywTP=bpKt-YmoBLqV4cppNJcSrQXmNGQ5Bg@mail.gmail.com

--===============2829141026366015175==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi,

On Wed, 2022-03-09 at 18:36 +0800, wen zhang wrote:
> I tried to build ELL library on my system built following LFS 11.1,
> but the make command failed. Adding V=3D1 to the make command show one
> openssl command failed to finish.
> > openssl pkcs8 -in unit/cert-client-key-pkcs8.pem -out unit/cert-
> > client-key-pkcs8-v2-des.pem -topk8 -v2 des-cbc -v2prf hmacWithSHA1
> > -passout pass:abc
> > =

> =

> Maybe something need to migrate from OpenSSL 1 to OpenSSL 3? =


So it appears DES was removed from OpenSSL3 as a built in module [1].
I'm guessing there is some way to compile this in, but the
documentation also mentions some runtime legacy provider. So I think
you'll need to rebuild openssl with DES built in or figure out a way to
enable this provider. I'm thinking we do want to support the default
OpenSSL3 build at some point in the future, but I'm not sure if our
build system can enable this feature automatically or not.=C2=A0

One thing to note is that OpenSSL is only used to verify ELL's crypto
APIs in unit testing. So this failure should not block you from using
the ELL API or IWD. And for IWD specifically all the unit tests build
with OpenSSL3 since none use DES.

Also, there is a mailing list specific to ELL=C2=A0ell(a)lists.01.org.

[1]=C2=A0https://wiki.openssl.org/index.php/OpenSSL_3.0#Providers

> _______________________________________________
> iwd mailing list -- iwd(a)lists.01.org
> To unsubscribe send an email to iwd-leave(a)lists.01.org


--===============2829141026366015175==
Content-Type: text/html
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="attachment.htm"

PGh0bWw+PGhlYWQ+PC9oZWFkPjxib2R5PjxkaXY+SGksPC9kaXY+PGRpdj48YnI+PC9kaXY+PGRp
dj5PbiBXZWQsIDIwMjItMDMtMDkgYXQgMTg6MzYgKzA4MDAsIHdlbiB6aGFuZyB3cm90ZTo8L2Rp
dj48YmxvY2txdW90ZSB0eXBlPSJjaXRlIiBzdHlsZT0ibWFyZ2luOjAgMCAwIC44ZXg7IGJvcmRl
ci1sZWZ0OjJweCAjNzI5ZmNmIHNvbGlkO3BhZGRpbmctbGVmdDoxZXgiPjxkaXYgZGlyPSJsdHIi
PjxkaXY+SSB0cmllZCB0byBidWlsZCBFTEwgbGlicmFyeSBvbiBteSBzeXN0ZW0gYnVpbHQgZm9s
bG93aW5nIDxhIGhyZWY9Imh0dHBzOi8vd3d3LmxpbnV4ZnJvbXNjcmF0Y2gub3JnL2xmcy92aWV3
L3N0YWJsZS1zeXN0ZW1kLyI+TEZTIDExLjE8L2E+LCBidXQgdGhlIG1ha2UgY29tbWFuZCBmYWls
ZWQuIEFkZGluZyBWPTEgdG8gdGhlIG1ha2UgY29tbWFuZCBzaG93IG9uZSBvcGVuc3NsIGNvbW1h
bmQgZmFpbGVkIHRvIGZpbmlzaC48L2Rpdj48YmxvY2txdW90ZSB0eXBlPSJjaXRlIiBzdHlsZT0i
bWFyZ2luOjAgMCAwIC44ZXg7IGJvcmRlci1sZWZ0OjJweCAjNzI5ZmNmIHNvbGlkO3BhZGRpbmct
bGVmdDoxZXgiPjxkaXY+b3BlbnNzbCBwa2NzOCAtaW4gdW5pdC9jZXJ0LWNsaWVudC1rZXktcGtj
czgucGVtIC1vdXQgdW5pdC9jZXJ0LWNsaWVudC1rZXktcGtjczgtdjItZGVzLnBlbSAtdG9wazgg
LXYyIGRlcy1jYmMgLXYycHJmIGhtYWNXaXRoU0hBMSAtcGFzc291dCBwYXNzOmFiYzwvZGl2Pjxi
cj48L2Jsb2NrcXVvdGU+PGRpdj5NYXliZSBzb21ldGhpbmcgbmVlZCB0byBtaWdyYXRlIGZyb20g
T3BlblNTTCAxIHRvIE9wZW5TU0wgMz8gPGJyPjwvZGl2PjwvZGl2PjwvYmxvY2txdW90ZT48ZGl2
Pjxicj48L2Rpdj48ZGl2PlNvIGl0IGFwcGVhcnMgREVTIHdhcyByZW1vdmVkIGZyb20gT3BlblNT
TDMgYXMgYSBidWlsdCBpbiBtb2R1bGUgWzFdLiBJJ20gZ3Vlc3NpbmcgdGhlcmUgaXMgc29tZSB3
YXkgdG8gY29tcGlsZSB0aGlzIGluLCBidXQgdGhlIGRvY3VtZW50YXRpb24gYWxzbyBtZW50aW9u
cyBzb21lIHJ1bnRpbWUgbGVnYWN5IHByb3ZpZGVyLiBTbyBJIHRoaW5rIHlvdSdsbCBuZWVkIHRv
IHJlYnVpbGQgb3BlbnNzbCB3aXRoIERFUyBidWlsdCBpbiBvciBmaWd1cmUgb3V0IGEgd2F5IHRv
IGVuYWJsZSB0aGlzIHByb3ZpZGVyLiBJJ20gdGhpbmtpbmcgd2UgZG8gd2FudCB0byBzdXBwb3J0
IHRoZSBkZWZhdWx0IE9wZW5TU0wzIGJ1aWxkIGF0IHNvbWUgcG9pbnQgaW4gdGhlIGZ1dHVyZSwg
YnV0IEknbSBub3Qgc3VyZSBpZiBvdXIgYnVpbGQgc3lzdGVtIGNhbiBlbmFibGUgdGhpcyBmZWF0
dXJlIGF1dG9tYXRpY2FsbHkgb3Igbm90LiZuYnNwOzwvZGl2PjxkaXY+PGJyPjwvZGl2PjxkaXY+
T25lIHRoaW5nIHRvIG5vdGUgaXMgdGhhdCBPcGVuU1NMIGlzIG9ubHkgdXNlZCB0byB2ZXJpZnkg
RUxMJ3MgY3J5cHRvIEFQSXMgaW4gdW5pdCB0ZXN0aW5nLiBTbyB0aGlzIGZhaWx1cmUgc2hvdWxk
IG5vdCBibG9jayB5b3UgZnJvbSB1c2luZyB0aGUgRUxMIEFQSSBvciBJV0QuIEFuZCBmb3IgSVdE
IHNwZWNpZmljYWxseSBhbGwgdGhlIHVuaXQgdGVzdHMgYnVpbGQgd2l0aCBPcGVuU1NMMyBzaW5j
ZSBub25lIHVzZSBERVMuPC9kaXY+PGRpdj48YnI+PC9kaXY+PGRpdj5BbHNvLCB0aGVyZSBpcyBh
IG1haWxpbmcgbGlzdCBzcGVjaWZpYyB0byBFTEwmbmJzcDs8YSBocmVmPSJtYWlsdG86ZWxsQGxp
c3RzLjAxLm9yZyIgdGl0bGU9IkNsaWNrIHRvIG1haWwgZWxsQGxpc3RzLjAxLm9yZyIgc3R5bGU9
IndoaXRlLXNwYWNlOiBub3dyYXA7Ij5lbGxAbGlzdHMuMDEub3JnLjwvYT48L2Rpdj48ZGl2Pjxi
cj48L2Rpdj48ZGl2PlsxXSZuYnNwOzxhIGhyZWY9Imh0dHBzOi8vd2lraS5vcGVuc3NsLm9yZy9p
bmRleC5waHAvT3BlblNTTF8zLjAjUHJvdmlkZXJzIj5odHRwczovL3dpa2kub3BlbnNzbC5vcmcv
aW5kZXgucGhwL09wZW5TU0xfMy4wI1Byb3ZpZGVyczwvYT48L2Rpdj48ZGl2Pjxicj48L2Rpdj48
YmxvY2txdW90ZSB0eXBlPSJjaXRlIiBzdHlsZT0ibWFyZ2luOjAgMCAwIC44ZXg7IGJvcmRlci1s
ZWZ0OjJweCAjNzI5ZmNmIHNvbGlkO3BhZGRpbmctbGVmdDoxZXgiPjxkaXY+X19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX188YnI+PC9kaXY+PGRpdj5pd2QgbWFp
bGluZyBsaXN0IC0tIDxhIGhyZWY9Im1haWx0bzppd2RAbGlzdHMuMDEub3JnIj5pd2RAbGlzdHMu
MDEub3JnPC9hPjxicj48L2Rpdj48ZGl2PlRvIHVuc3Vic2NyaWJlIHNlbmQgYW4gZW1haWwgdG8g
PGEgaHJlZj0ibWFpbHRvOml3ZC1sZWF2ZUBsaXN0cy4wMS5vcmciPml3ZC1sZWF2ZUBsaXN0cy4w
MS5vcmc8L2E+PGJyPjwvZGl2PjwvYmxvY2txdW90ZT48ZGl2Pjxicj48L2Rpdj48ZGl2PjxzcGFu
Pjwvc3Bhbj48L2Rpdj48L2JvZHk+PC9odG1sPgo=

--===============2829141026366015175==--

