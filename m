Content-Type: multipart/mixed; boundary="===============7646185385095639792=="
MIME-Version: 1.0
From: James Prestwood <prestwoj at gmail.com>
To: ell at lists.01.org
Subject: Re: Unable to build ELL with OpenSSL 3
Date: Fri, 11 Mar 2022 08:31:53 -0800
Message-ID: <e3949e06c56d45b5da14d4d77e35420378d6d99f.camel@gmail.com>
In-Reply-To: CAKjfnjrT8C2_WOYSYDzPRXbOUsmR6_gbPchmfqvHeBdVKqTt=w@mail.gmail.com

--===============7646185385095639792==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi,

On Fri, 2022-03-11 at 16:52 +0800, wen zhang wrote:
> James Prestwood <prestwoj(a)gmail.com> =E4=BA=8E2022=E5=B9=B43=E6=9C=8810=
=E6=97=A5=E5=91=A8=E5=9B=9B 02:04=E5=86=99=E9=81=93=EF=BC=9A
> > Hi,
> > =

> > On Wed, 2022-03-09 at 18:36 +0800, wen zhang wrote:
> > > I tried to build ELL library on my system built following LFS
> > > 11.1, but the make command failed. Adding V=3D1 to the make command
> > > show one openssl command failed to finish.
> > > > openssl pkcs8 -in unit/cert-client-key-pkcs8.pem -out
> > > > unit/cert-client-key-pkcs8-v2-des.pem -topk8 -v2 des-cbc -v2prf
> > > > hmacWithSHA1 -passout pass:abc
> > > > =

> > > =

> > > Maybe something need to migrate from OpenSSL 1 to OpenSSL 3? =

> > =

> > =

> > So it appears DES was removed from OpenSSL3 as a built in module
> > [1]. I'm guessing there is some way to compile this in, but the
> > documentation also mentions some runtime legacy provider. So I
> > think you'll need to rebuild openssl with DES built in or figure
> > out a way to enable this provider. I'm thinking we do want to
> > support the default OpenSSL3 build at some point in the future, but
> > I'm not sure if our build system can enable this feature
> > automatically or not.=C2=A0
> > =

> > One thing to note is that OpenSSL is only used to verify ELL's
> > crypto APIs in unit testing. So this failure should not block you
> > from using the ELL API or IWD. And for IWD specifically all the
> > unit tests build with OpenSSL3 since none use DES.
> > =

> > Also, there is a mailing list specific to ELL=C2=A0ell(a)lists.01.org.
> > =

> > [1]=C2=A0https://wiki.openssl.org/index.php/OpenSSL_3.0#Providers
> > =

> > > _______________________________________________
> > > iwd mailing list -- iwd(a)lists.01.org
> > > To unsubscribe send an email to iwd-leave(a)lists.01.org
> > =

> > =

> > =

> =

> I added provider default and provider legacy into the openssl lines,
> and make command finished with no error.
> Here's my patch, maybe can be reviewed once there's another build
> environment with OpenSSL V3.

This seems to break OpenSSL 1.1:

pkcs8: Option unknown option -provider
pkcs8: Use -help for summary.
make[1]: *** [Makefile:3163: unit/cert-client-key-pkcs8-md5-des.pem]
Error 1

I'm not a build system expert but I'm thinking we need to detect the
OpenSSL version and generate the PEMs using two different recipes
depending on version. Or maybe someone else has ideas?

Also you're patch was just a diff. It applied fine but in order to
merge anything we will need an actual git commit (e.g. git format-
patch).

Thanks,
James

> _______________________________________________
> ell mailing list -- ell(a)lists.01.org
> To unsubscribe send an email to ell-leave(a)lists.01.org


--===============7646185385095639792==
Content-Type: text/html
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="attachment.htm"

PGh0bWw+PGhlYWQ+PC9oZWFkPjxib2R5PjxkaXY+SGksPC9kaXY+PGRpdj48YnI+PC9kaXY+PGRp
dj5PbiBGcmksIDIwMjItMDMtMTEgYXQgMTY6NTIgKzA4MDAsIHdlbiB6aGFuZyB3cm90ZTo8L2Rp
dj48YmxvY2txdW90ZSB0eXBlPSJjaXRlIiBzdHlsZT0ibWFyZ2luOjAgMCAwIC44ZXg7IGJvcmRl
ci1sZWZ0OjJweCAjNzI5ZmNmIHNvbGlkO3BhZGRpbmctbGVmdDoxZXgiPjxkaXYgZGlyPSJsdHIi
PjxkaXYgZGlyPSJsdHIiPkphbWVzIFByZXN0d29vZCAmbHQ7PGEgaHJlZj0ibWFpbHRvOnByZXN0
d29qQGdtYWlsLmNvbSI+cHJlc3R3b2pAZ21haWwuY29tPC9hPiZndDsg5LqOMjAyMuW5tDPmnIgx
MOaXpeWRqOWbmyAwMjowNOWGmemBk++8mjxicj48L2Rpdj48ZGl2IGNsYXNzPSJnbWFpbF9xdW90
ZSI+PGJsb2NrcXVvdGUgdHlwZT0iY2l0ZSIgc3R5bGU9Im1hcmdpbjowIDAgMCAuOGV4OyBib3Jk
ZXItbGVmdDoycHggIzcyOWZjZiBzb2xpZDtwYWRkaW5nLWxlZnQ6MWV4Ij48ZGl2PjxkaXY+SGks
PC9kaXY+PGRpdj48YnI+PC9kaXY+PGRpdj5PbiBXZWQsIDIwMjItMDMtMDkgYXQgMTg6MzYgKzA4
MDAsIHdlbiB6aGFuZyB3cm90ZTo8L2Rpdj48YmxvY2txdW90ZSB0eXBlPSJjaXRlIiBzdHlsZT0i
bWFyZ2luOjAgMCAwIC44ZXg7IGJvcmRlci1sZWZ0OjJweCAjNzI5ZmNmIHNvbGlkO3BhZGRpbmct
bGVmdDoxZXgiPjxkaXYgZGlyPSJsdHIiPjxkaXY+SSB0cmllZCB0byBidWlsZCBFTEwgbGlicmFy
eSBvbiBteSBzeXN0ZW0gYnVpbHQgZm9sbG93aW5nIDxhIGhyZWY9Imh0dHBzOi8vd3d3LmxpbnV4
ZnJvbXNjcmF0Y2gub3JnL2xmcy92aWV3L3N0YWJsZS1zeXN0ZW1kLyIgdGFyZ2V0PSJfYmxhbmsi
PkxGUyAxMS4xPC9hPiwgYnV0IHRoZSBtYWtlIGNvbW1hbmQgZmFpbGVkLiBBZGRpbmcgVj0xIHRv
IHRoZSBtYWtlIGNvbW1hbmQgc2hvdyBvbmUgb3BlbnNzbCBjb21tYW5kIGZhaWxlZCB0byBmaW5p
c2guPC9kaXY+PGJsb2NrcXVvdGUgdHlwZT0iY2l0ZSIgc3R5bGU9Im1hcmdpbjowIDAgMCAuOGV4
OyBib3JkZXItbGVmdDoycHggIzcyOWZjZiBzb2xpZDtwYWRkaW5nLWxlZnQ6MWV4Ij48ZGl2Pm9w
ZW5zc2wgcGtjczggLWluIHVuaXQvY2VydC1jbGllbnQta2V5LXBrY3M4LnBlbSAtb3V0IHVuaXQv
Y2VydC1jbGllbnQta2V5LXBrY3M4LXYyLWRlcy5wZW0gLXRvcGs4IC12MiBkZXMtY2JjIC12MnBy
ZiBobWFjV2l0aFNIQTEgLXBhc3NvdXQgcGFzczphYmM8L2Rpdj48ZGl2Pjxicj48L2Rpdj48L2Js
b2NrcXVvdGU+PGRpdj5NYXliZSBzb21ldGhpbmcgbmVlZCB0byBtaWdyYXRlIGZyb20gT3BlblNT
TCAxIHRvIE9wZW5TU0wgMz8gPGJyPjwvZGl2PjwvZGl2PjwvYmxvY2txdW90ZT48ZGl2Pjxicj48
L2Rpdj48ZGl2PlNvIGl0IGFwcGVhcnMgREVTIHdhcyByZW1vdmVkIGZyb20gT3BlblNTTDMgYXMg
YSBidWlsdCBpbiBtb2R1bGUgWzFdLiBJJ20gZ3Vlc3NpbmcgdGhlcmUgaXMgc29tZSB3YXkgdG8g
Y29tcGlsZSB0aGlzIGluLCBidXQgdGhlIGRvY3VtZW50YXRpb24gYWxzbyBtZW50aW9ucyBzb21l
IHJ1bnRpbWUgbGVnYWN5IHByb3ZpZGVyLiBTbyBJIHRoaW5rIHlvdSdsbCBuZWVkIHRvIHJlYnVp
bGQgb3BlbnNzbCB3aXRoIERFUyBidWlsdCBpbiBvciBmaWd1cmUgb3V0IGEgd2F5IHRvIGVuYWJs
ZSB0aGlzIHByb3ZpZGVyLiBJJ20gdGhpbmtpbmcgd2UgZG8gd2FudCB0byBzdXBwb3J0IHRoZSBk
ZWZhdWx0IE9wZW5TU0wzIGJ1aWxkIGF0IHNvbWUgcG9pbnQgaW4gdGhlIGZ1dHVyZSwgYnV0IEkn
bSBub3Qgc3VyZSBpZiBvdXIgYnVpbGQgc3lzdGVtIGNhbiBlbmFibGUgdGhpcyBmZWF0dXJlIGF1
dG9tYXRpY2FsbHkgb3Igbm90LiZuYnNwOzwvZGl2PjxkaXY+PGJyPjwvZGl2PjxkaXY+T25lIHRo
aW5nIHRvIG5vdGUgaXMgdGhhdCBPcGVuU1NMIGlzIG9ubHkgdXNlZCB0byB2ZXJpZnkgRUxMJ3Mg
Y3J5cHRvIEFQSXMgaW4gdW5pdCB0ZXN0aW5nLiBTbyB0aGlzIGZhaWx1cmUgc2hvdWxkIG5vdCBi
bG9jayB5b3UgZnJvbSB1c2luZyB0aGUgRUxMIEFQSSBvciBJV0QuIEFuZCBmb3IgSVdEIHNwZWNp
ZmljYWxseSBhbGwgdGhlIHVuaXQgdGVzdHMgYnVpbGQgd2l0aCBPcGVuU1NMMyBzaW5jZSBub25l
IHVzZSBERVMuPC9kaXY+PGRpdj48YnI+PC9kaXY+PGRpdj5BbHNvLCB0aGVyZSBpcyBhIG1haWxp
bmcgbGlzdCBzcGVjaWZpYyB0byBFTEwmbmJzcDs8YSBocmVmPSJtYWlsdG86ZWxsQGxpc3RzLjAx
Lm9yZyIgdGl0bGU9IkNsaWNrIHRvIG1haWwgZWxsQGxpc3RzLjAxLm9yZyIgc3R5bGU9IndoaXRl
LXNwYWNlOm5vd3JhcCIgdGFyZ2V0PSJfYmxhbmsiPmVsbEBsaXN0cy4wMS5vcmcuPC9hPjwvZGl2
PjxkaXY+PGJyPjwvZGl2PjxkaXY+WzFdJm5ic3A7PGEgaHJlZj0iaHR0cHM6Ly93aWtpLm9wZW5z
c2wub3JnL2luZGV4LnBocC9PcGVuU1NMXzMuMCNQcm92aWRlcnMiIHRhcmdldD0iX2JsYW5rIj5o
dHRwczovL3dpa2kub3BlbnNzbC5vcmcvaW5kZXgucGhwL09wZW5TU0xfMy4wI1Byb3ZpZGVyczwv
YT48L2Rpdj48ZGl2Pjxicj48L2Rpdj48YmxvY2txdW90ZSB0eXBlPSJjaXRlIiBzdHlsZT0ibWFy
Z2luOjAgMCAwIC44ZXg7IGJvcmRlci1sZWZ0OjJweCAjNzI5ZmNmIHNvbGlkO3BhZGRpbmctbGVm
dDoxZXgiPjxkaXY+X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X188YnI+PC9kaXY+PGRpdj5pd2QgbWFpbGluZyBsaXN0IC0tIDxhIGhyZWY9Im1haWx0bzppd2RA
bGlzdHMuMDEub3JnIiB0YXJnZXQ9Il9ibGFuayI+aXdkQGxpc3RzLjAxLm9yZzwvYT48YnI+PC9k
aXY+PGRpdj5UbyB1bnN1YnNjcmliZSBzZW5kIGFuIGVtYWlsIHRvIDxhIGhyZWY9Im1haWx0bzpp
d2QtbGVhdmVAbGlzdHMuMDEub3JnIiB0YXJnZXQ9Il9ibGFuayI+aXdkLWxlYXZlQGxpc3RzLjAx
Lm9yZzwvYT48YnI+PC9kaXY+PC9ibG9ja3F1b3RlPjxkaXY+PGJyPjwvZGl2PjwvZGl2Pjxicj48
L2Jsb2NrcXVvdGU+PGRpdj5JIGFkZGVkIHByb3ZpZGVyIGRlZmF1bHQgYW5kIHByb3ZpZGVyIGxl
Z2FjeSBpbnRvIHRoZSBvcGVuc3NsIGxpbmVzLCBhbmQgbWFrZSBjb21tYW5kIGZpbmlzaGVkIHdp
dGggbm8gZXJyb3IuPC9kaXY+PGRpdj5IZXJlJ3MgbXkgcGF0Y2gsIG1heWJlIGNhbiBiZSByZXZp
ZXdlZCBvbmNlIHRoZXJlJ3MgYW5vdGhlciBidWlsZCBlbnZpcm9ubWVudCB3aXRoIE9wZW5TU0wg
VjMuPC9kaXY+PC9kaXY+PC9kaXY+PC9ibG9ja3F1b3RlPjxkaXY+PGJyPjwvZGl2PjxkaXY+VGhp
cyBzZWVtcyB0byBicmVhayBPcGVuU1NMIDEuMTo8L2Rpdj48ZGl2Pjxicj48L2Rpdj48ZGl2PnBr
Y3M4OiBPcHRpb24gdW5rbm93biBvcHRpb24gLXByb3ZpZGVyPC9kaXY+PGRpdj5wa2NzODogVXNl
IC1oZWxwIGZvciBzdW1tYXJ5LjwvZGl2PjxkaXY+bWFrZVsxXTogKioqIFtNYWtlZmlsZTozMTYz
OiB1bml0L2NlcnQtY2xpZW50LWtleS1wa2NzOC1tZDUtZGVzLnBlbV0gRXJyb3IgMTwvZGl2Pjxk
aXY+PGJyPjwvZGl2PjxkaXY+SSdtIG5vdCBhIGJ1aWxkIHN5c3RlbSBleHBlcnQgYnV0IEknbSB0
aGlua2luZyB3ZSBuZWVkIHRvIGRldGVjdCB0aGUgT3BlblNTTCB2ZXJzaW9uIGFuZCBnZW5lcmF0
ZSB0aGUgUEVNcyB1c2luZyB0d28gZGlmZmVyZW50IHJlY2lwZXMgZGVwZW5kaW5nIG9uIHZlcnNp
b24uIE9yIG1heWJlIHNvbWVvbmUgZWxzZSBoYXMgaWRlYXM/PC9kaXY+PGRpdj48YnI+PC9kaXY+
PGRpdj5BbHNvIHlvdSdyZSBwYXRjaCB3YXMganVzdCBhIGRpZmYuIEl0IGFwcGxpZWQgZmluZSBi
dXQgaW4gb3JkZXIgdG8gbWVyZ2UgYW55dGhpbmcgd2Ugd2lsbCBuZWVkIGFuIGFjdHVhbCBnaXQg
Y29tbWl0IChlLmcuIGdpdCBmb3JtYXQtcGF0Y2gpLjwvZGl2PjxkaXY+PGJyPjwvZGl2PjxkaXY+
VGhhbmtzLDxicj48L2Rpdj48ZGl2PkphbWVzPC9kaXY+PGRpdj48YnI+PC9kaXY+PGJsb2NrcXVv
dGUgdHlwZT0iY2l0ZSIgc3R5bGU9Im1hcmdpbjowIDAgMCAuOGV4OyBib3JkZXItbGVmdDoycHgg
IzcyOWZjZiBzb2xpZDtwYWRkaW5nLWxlZnQ6MWV4Ij48ZGl2Pl9fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fPGJyPjwvZGl2PjxkaXY+ZWxsIG1haWxpbmcgbGlz
dCAtLSA8YSBocmVmPSJtYWlsdG86ZWxsQGxpc3RzLjAxLm9yZyI+ZWxsQGxpc3RzLjAxLm9yZzwv
YT48YnI+PC9kaXY+PGRpdj5UbyB1bnN1YnNjcmliZSBzZW5kIGFuIGVtYWlsIHRvIDxhIGhyZWY9
Im1haWx0bzplbGwtbGVhdmVAbGlzdHMuMDEub3JnIj5lbGwtbGVhdmVAbGlzdHMuMDEub3JnPC9h
Pjxicj48L2Rpdj48L2Jsb2NrcXVvdGU+PGRpdj48YnI+PC9kaXY+PGRpdj48c3Bhbj48L3NwYW4+
PC9kaXY+PC9ib2R5PjwvaHRtbD4K

--===============7646185385095639792==--

