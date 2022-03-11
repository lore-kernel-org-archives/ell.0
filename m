Content-Type: multipart/mixed; boundary="===============6750170388810316250=="
MIME-Version: 1.0
From: wen zhang <zhw2101024 at gmail.com>
To: ell at lists.01.org
Subject: Re: Unable to build ELL with OpenSSL 3
Date: Sat, 12 Mar 2022 00:46:45 +0800
Message-ID: <CAKjfnjppV2OoJ5gsFLEb58qorn0fRLYo9-AD05NThTjR9fzvvw@mail.gmail.com>
In-Reply-To: e3949e06c56d45b5da14d4d77e35420378d6d99f.camel@gmail.com

--===============6750170388810316250==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

James Prestwood <prestwoj(a)gmail.com> =E4=BA=8E2022=E5=B9=B43=E6=9C=8812=
=E6=97=A5=E5=91=A8=E5=85=AD 00:31=E5=86=99=E9=81=93=EF=BC=9A

> Hi,
>
> On Fri, 2022-03-11 at 16:52 +0800, wen zhang wrote:
>
> James Prestwood <prestwoj(a)gmail.com> =E4=BA=8E2022=E5=B9=B43=E6=9C=8810=
=E6=97=A5=E5=91=A8=E5=9B=9B 02:04=E5=86=99=E9=81=93=EF=BC=9A
>
> Hi,
>
> On Wed, 2022-03-09 at 18:36 +0800, wen zhang wrote:
>
> I tried to build ELL library on my system built following LFS 11.1
> <https://www.linuxfromscratch.org/lfs/view/stable-systemd/>, but the make
> command failed. Adding V=3D1 to the make command show one openssl command
> failed to finish.
>
> openssl pkcs8 -in unit/cert-client-key-pkcs8.pem -out
> unit/cert-client-key-pkcs8-v2-des.pem -topk8 -v2 des-cbc -v2prf
> hmacWithSHA1 -passout pass:abc
>
> Maybe something need to migrate from OpenSSL 1 to OpenSSL 3?
>
>
> So it appears DES was removed from OpenSSL3 as a built in module [1]. I'm
> guessing there is some way to compile this in, but the documentation also
> mentions some runtime legacy provider. So I think you'll need to rebuild
> openssl with DES built in or figure out a way to enable this provider. I'm
> thinking we do want to support the default OpenSSL3 build at some point in
> the future, but I'm not sure if our build system can enable this feature
> automatically or not.
>
> One thing to note is that OpenSSL is only used to verify ELL's crypto APIs
> in unit testing. So this failure should not block you from using the ELL
> API or IWD. And for IWD specifically all the unit tests build with OpenSS=
L3
> since none use DES.
>
> Also, there is a mailing list specific to ELL ell(a)lists.01.org.
> <ell(a)lists.01.org>
>
> [1] https://wiki.openssl.org/index.php/OpenSSL_3.0#Providers
>
> _______________________________________________
> iwd mailing list -- iwd(a)lists.01.org
> To unsubscribe send an email to iwd-leave(a)lists.01.org
>
>
>
> I added provider default and provider legacy into the openssl lines, and
> make command finished with no error.
> Here's my patch, maybe can be reviewed once there's another build
> environment with OpenSSL V3.
>
>
> This seems to break OpenSSL 1.1:
>
> pkcs8: Option unknown option -provider
> pkcs8: Use -help for summary.
> make[1]: *** [Makefile:3163: unit/cert-client-key-pkcs8-md5-des.pem] Error
> 1
>
> I'm not a build system expert but I'm thinking we need to detect the
> OpenSSL version and generate the PEMs using two different recipes dependi=
ng
> on version. Or maybe someone else has ideas?
>
> Also you're patch was just a diff. It applied fine but in order to merge
> anything we will need an actual git commit (e.g. git format-patch).
>
> Thanks,
> James
>
> _______________________________________________
> ell mailing list -- ell(a)lists.01.org
> To unsubscribe send an email to ell-leave(a)lists.01.org
>
>
> Thanks, I just realized that openssl is only used when maintainer mode is
enabled.
Autotools is a little complex for me, I'll try to submit a patch but may
take some days.

--===============6750170388810316250==
Content-Type: text/html
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="attachment.htm"

PGRpdiBkaXI9Imx0ciI+PGRpdiBkaXI9Imx0ciI+SmFtZXMgUHJlc3R3b29kICZsdDs8YSBocmVm
PSJtYWlsdG86cHJlc3R3b2pAZ21haWwuY29tIj5wcmVzdHdvakBnbWFpbC5jb208L2E+Jmd0OyDk
uo4yMDIy5bm0M+aciDEy5pel5ZGo5YWtIDAwOjMx5YaZ6YGT77yaPGJyPjwvZGl2PjxkaXYgY2xh
c3M9ImdtYWlsX3F1b3RlIj48YmxvY2txdW90ZSBjbGFzcz0iZ21haWxfcXVvdGUiIHN0eWxlPSJt
YXJnaW46MHB4IDBweCAwcHggMC44ZXg7Ym9yZGVyLWxlZnQ6MXB4IHNvbGlkIHJnYigyMDQsMjA0
LDIwNCk7cGFkZGluZy1sZWZ0OjFleCI+PGRpdj48ZGl2PkhpLDwvZGl2PjxkaXY+PGJyPjwvZGl2
PjxkaXY+T24gRnJpLCAyMDIyLTAzLTExIGF0IDE2OjUyICswODAwLCB3ZW4gemhhbmcgd3JvdGU6
PC9kaXY+PGJsb2NrcXVvdGUgdHlwZT0iY2l0ZSIgc3R5bGU9Im1hcmdpbjowcHggMHB4IDBweCAw
LjhleDtib3JkZXItbGVmdDoycHggc29saWQgcmdiKDExNCwxNTksMjA3KTtwYWRkaW5nLWxlZnQ6
MWV4Ij48ZGl2IGRpcj0ibHRyIj48ZGl2IGRpcj0ibHRyIj5KYW1lcyBQcmVzdHdvb2QgJmx0Ozxh
IGhyZWY9Im1haWx0bzpwcmVzdHdvakBnbWFpbC5jb20iIHRhcmdldD0iX2JsYW5rIj5wcmVzdHdv
akBnbWFpbC5jb208L2E+Jmd0OyDkuo4yMDIy5bm0M+aciDEw5pel5ZGo5ZubIDAyOjA05YaZ6YGT
77yaPGJyPjwvZGl2PjxkaXYgY2xhc3M9ImdtYWlsX3F1b3RlIj48YmxvY2txdW90ZSB0eXBlPSJj
aXRlIiBzdHlsZT0ibWFyZ2luOjBweCAwcHggMHB4IDAuOGV4O2JvcmRlci1sZWZ0OjJweCBzb2xp
ZCByZ2IoMTE0LDE1OSwyMDcpO3BhZGRpbmctbGVmdDoxZXgiPjxkaXY+PGRpdj5IaSw8L2Rpdj48
ZGl2Pjxicj48L2Rpdj48ZGl2Pk9uIFdlZCwgMjAyMi0wMy0wOSBhdCAxODozNiArMDgwMCwgd2Vu
IHpoYW5nIHdyb3RlOjwvZGl2PjxibG9ja3F1b3RlIHR5cGU9ImNpdGUiIHN0eWxlPSJtYXJnaW46
MHB4IDBweCAwcHggMC44ZXg7Ym9yZGVyLWxlZnQ6MnB4IHNvbGlkIHJnYigxMTQsMTU5LDIwNyk7
cGFkZGluZy1sZWZ0OjFleCI+PGRpdiBkaXI9Imx0ciI+PGRpdj5JIHRyaWVkIHRvIGJ1aWxkIEVM
TCBsaWJyYXJ5IG9uIG15IHN5c3RlbSBidWlsdCBmb2xsb3dpbmcgPGEgaHJlZj0iaHR0cHM6Ly93
d3cubGludXhmcm9tc2NyYXRjaC5vcmcvbGZzL3ZpZXcvc3RhYmxlLXN5c3RlbWQvIiB0YXJnZXQ9
Il9ibGFuayI+TEZTIDExLjE8L2E+LCBidXQgdGhlIG1ha2UgY29tbWFuZCBmYWlsZWQuIEFkZGlu
ZyBWPTEgdG8gdGhlIG1ha2UgY29tbWFuZCBzaG93IG9uZSBvcGVuc3NsIGNvbW1hbmQgZmFpbGVk
IHRvIGZpbmlzaC48L2Rpdj48YmxvY2txdW90ZSB0eXBlPSJjaXRlIiBzdHlsZT0ibWFyZ2luOjBw
eCAwcHggMHB4IDAuOGV4O2JvcmRlci1sZWZ0OjJweCBzb2xpZCByZ2IoMTE0LDE1OSwyMDcpO3Bh
ZGRpbmctbGVmdDoxZXgiPjxkaXY+b3BlbnNzbCBwa2NzOCAtaW4gdW5pdC9jZXJ0LWNsaWVudC1r
ZXktcGtjczgucGVtIC1vdXQgdW5pdC9jZXJ0LWNsaWVudC1rZXktcGtjczgtdjItZGVzLnBlbSAt
dG9wazggLXYyIGRlcy1jYmMgLXYycHJmIGhtYWNXaXRoU0hBMSAtcGFzc291dCBwYXNzOmFiYzwv
ZGl2PjxkaXY+PGJyPjwvZGl2PjwvYmxvY2txdW90ZT48ZGl2Pk1heWJlIHNvbWV0aGluZyBuZWVk
IHRvIG1pZ3JhdGUgZnJvbSBPcGVuU1NMIDEgdG8gT3BlblNTTCAzPyA8YnI+PC9kaXY+PC9kaXY+
PC9ibG9ja3F1b3RlPjxkaXY+PGJyPjwvZGl2PjxkaXY+U28gaXQgYXBwZWFycyBERVMgd2FzIHJl
bW92ZWQgZnJvbSBPcGVuU1NMMyBhcyBhIGJ1aWx0IGluIG1vZHVsZSBbMV0uIEkmIzM5O20gZ3Vl
c3NpbmcgdGhlcmUgaXMgc29tZSB3YXkgdG8gY29tcGlsZSB0aGlzIGluLCBidXQgdGhlIGRvY3Vt
ZW50YXRpb24gYWxzbyBtZW50aW9ucyBzb21lIHJ1bnRpbWUgbGVnYWN5IHByb3ZpZGVyLiBTbyBJ
IHRoaW5rIHlvdSYjMzk7bGwgbmVlZCB0byByZWJ1aWxkIG9wZW5zc2wgd2l0aCBERVMgYnVpbHQg
aW4gb3IgZmlndXJlIG91dCBhIHdheSB0byBlbmFibGUgdGhpcyBwcm92aWRlci4gSSYjMzk7bSB0
aGlua2luZyB3ZSBkbyB3YW50IHRvIHN1cHBvcnQgdGhlIGRlZmF1bHQgT3BlblNTTDMgYnVpbGQg
YXQgc29tZSBwb2ludCBpbiB0aGUgZnV0dXJlLCBidXQgSSYjMzk7bSBub3Qgc3VyZSBpZiBvdXIg
YnVpbGQgc3lzdGVtIGNhbiBlbmFibGUgdGhpcyBmZWF0dXJlIGF1dG9tYXRpY2FsbHkgb3Igbm90
LsKgPC9kaXY+PGRpdj48YnI+PC9kaXY+PGRpdj5PbmUgdGhpbmcgdG8gbm90ZSBpcyB0aGF0IE9w
ZW5TU0wgaXMgb25seSB1c2VkIHRvIHZlcmlmeSBFTEwmIzM5O3MgY3J5cHRvIEFQSXMgaW4gdW5p
dCB0ZXN0aW5nLiBTbyB0aGlzIGZhaWx1cmUgc2hvdWxkIG5vdCBibG9jayB5b3UgZnJvbSB1c2lu
ZyB0aGUgRUxMIEFQSSBvciBJV0QuIEFuZCBmb3IgSVdEIHNwZWNpZmljYWxseSBhbGwgdGhlIHVu
aXQgdGVzdHMgYnVpbGQgd2l0aCBPcGVuU1NMMyBzaW5jZSBub25lIHVzZSBERVMuPC9kaXY+PGRp
dj48YnI+PC9kaXY+PGRpdj5BbHNvLCB0aGVyZSBpcyBhIG1haWxpbmcgbGlzdCBzcGVjaWZpYyB0
byBFTEzCoDxhIGhyZWY9Im1haWx0bzplbGxAbGlzdHMuMDEub3JnIiB0aXRsZT0iQ2xpY2sgdG8g
bWFpbCBlbGxAbGlzdHMuMDEub3JnIiBzdHlsZT0id2hpdGUtc3BhY2U6bm93cmFwIiB0YXJnZXQ9
Il9ibGFuayI+ZWxsQGxpc3RzLjAxLm9yZy48L2E+PC9kaXY+PGRpdj48YnI+PC9kaXY+PGRpdj5b
MV3CoDxhIGhyZWY9Imh0dHBzOi8vd2lraS5vcGVuc3NsLm9yZy9pbmRleC5waHAvT3BlblNTTF8z
LjAjUHJvdmlkZXJzIiB0YXJnZXQ9Il9ibGFuayI+aHR0cHM6Ly93aWtpLm9wZW5zc2wub3JnL2lu
ZGV4LnBocC9PcGVuU1NMXzMuMCNQcm92aWRlcnM8L2E+PC9kaXY+PGRpdj48YnI+PC9kaXY+PGJs
b2NrcXVvdGUgdHlwZT0iY2l0ZSIgc3R5bGU9Im1hcmdpbjowcHggMHB4IDBweCAwLjhleDtib3Jk
ZXItbGVmdDoycHggc29saWQgcmdiKDExNCwxNTksMjA3KTtwYWRkaW5nLWxlZnQ6MWV4Ij48ZGl2
Pl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fPGJyPjwvZGl2
PjxkaXY+aXdkIG1haWxpbmcgbGlzdCAtLSA8YSBocmVmPSJtYWlsdG86aXdkQGxpc3RzLjAxLm9y
ZyIgdGFyZ2V0PSJfYmxhbmsiPml3ZEBsaXN0cy4wMS5vcmc8L2E+PGJyPjwvZGl2PjxkaXY+VG8g
dW5zdWJzY3JpYmUgc2VuZCBhbiBlbWFpbCB0byA8YSBocmVmPSJtYWlsdG86aXdkLWxlYXZlQGxp
c3RzLjAxLm9yZyIgdGFyZ2V0PSJfYmxhbmsiPml3ZC1sZWF2ZUBsaXN0cy4wMS5vcmc8L2E+PGJy
PjwvZGl2PjwvYmxvY2txdW90ZT48ZGl2Pjxicj48L2Rpdj48L2Rpdj48YnI+PC9ibG9ja3F1b3Rl
PjxkaXY+SSBhZGRlZCBwcm92aWRlciBkZWZhdWx0IGFuZCBwcm92aWRlciBsZWdhY3kgaW50byB0
aGUgb3BlbnNzbCBsaW5lcywgYW5kIG1ha2UgY29tbWFuZCBmaW5pc2hlZCB3aXRoIG5vIGVycm9y
LjwvZGl2PjxkaXY+SGVyZSYjMzk7cyBteSBwYXRjaCwgbWF5YmUgY2FuIGJlIHJldmlld2VkIG9u
Y2UgdGhlcmUmIzM5O3MgYW5vdGhlciBidWlsZCBlbnZpcm9ubWVudCB3aXRoIE9wZW5TU0wgVjMu
PC9kaXY+PC9kaXY+PC9kaXY+PC9ibG9ja3F1b3RlPjxkaXY+PGJyPjwvZGl2PjxkaXY+VGhpcyBz
ZWVtcyB0byBicmVhayBPcGVuU1NMIDEuMTo8L2Rpdj48ZGl2Pjxicj48L2Rpdj48ZGl2PnBrY3M4
OiBPcHRpb24gdW5rbm93biBvcHRpb24gLXByb3ZpZGVyPC9kaXY+PGRpdj5wa2NzODogVXNlIC1o
ZWxwIGZvciBzdW1tYXJ5LjwvZGl2PjxkaXY+bWFrZVsxXTogKioqIFtNYWtlZmlsZTozMTYzOiB1
bml0L2NlcnQtY2xpZW50LWtleS1wa2NzOC1tZDUtZGVzLnBlbV0gRXJyb3IgMTwvZGl2PjxkaXY+
PGJyPjwvZGl2PjxkaXY+SSYjMzk7bSBub3QgYSBidWlsZCBzeXN0ZW0gZXhwZXJ0IGJ1dCBJJiMz
OTttIHRoaW5raW5nIHdlIG5lZWQgdG8gZGV0ZWN0IHRoZSBPcGVuU1NMIHZlcnNpb24gYW5kIGdl
bmVyYXRlIHRoZSBQRU1zIHVzaW5nIHR3byBkaWZmZXJlbnQgcmVjaXBlcyBkZXBlbmRpbmcgb24g
dmVyc2lvbi4gT3IgbWF5YmUgc29tZW9uZSBlbHNlIGhhcyBpZGVhcz88L2Rpdj48ZGl2Pjxicj48
L2Rpdj48ZGl2PkFsc28geW91JiMzOTtyZSBwYXRjaCB3YXMganVzdCBhIGRpZmYuIEl0IGFwcGxp
ZWQgZmluZSBidXQgaW4gb3JkZXIgdG8gbWVyZ2UgYW55dGhpbmcgd2Ugd2lsbCBuZWVkIGFuIGFj
dHVhbCBnaXQgY29tbWl0IChlLmcuIGdpdCBmb3JtYXQtcGF0Y2gpLjwvZGl2PjxkaXY+PGJyPjwv
ZGl2PjxkaXY+VGhhbmtzLDxicj48L2Rpdj48ZGl2PkphbWVzPC9kaXY+PGRpdj48YnI+PC9kaXY+
PGJsb2NrcXVvdGUgdHlwZT0iY2l0ZSIgc3R5bGU9Im1hcmdpbjowcHggMHB4IDBweCAwLjhleDti
b3JkZXItbGVmdDoycHggc29saWQgcmdiKDExNCwxNTksMjA3KTtwYWRkaW5nLWxlZnQ6MWV4Ij48
ZGl2Pl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fPGJyPjwv
ZGl2PjxkaXY+ZWxsIG1haWxpbmcgbGlzdCAtLSA8YSBocmVmPSJtYWlsdG86ZWxsQGxpc3RzLjAx
Lm9yZyIgdGFyZ2V0PSJfYmxhbmsiPmVsbEBsaXN0cy4wMS5vcmc8L2E+PGJyPjwvZGl2PjxkaXY+
VG8gdW5zdWJzY3JpYmUgc2VuZCBhbiBlbWFpbCB0byA8YSBocmVmPSJtYWlsdG86ZWxsLWxlYXZl
QGxpc3RzLjAxLm9yZyIgdGFyZ2V0PSJfYmxhbmsiPmVsbC1sZWF2ZUBsaXN0cy4wMS5vcmc8L2E+
PGJyPjwvZGl2PjwvYmxvY2txdW90ZT48ZGl2Pjxicj48L2Rpdj48L2Rpdj48L2Jsb2NrcXVvdGU+
PGRpdj5UaGFua3MsIEkganVzdCByZWFsaXplZCB0aGF0IG9wZW5zc2wgaXMgb25seSB1c2VkIHdo
ZW4gbWFpbnRhaW5lciBtb2RlIGlzIGVuYWJsZWQuPC9kaXY+PGRpdj5BdXRvdG9vbHMgaXMgYSBs
aXR0bGUgY29tcGxleCBmb3IgbWUsIEkmIzM5O2xsIHRyeSB0byBzdWJtaXQgYSBwYXRjaCBidXQg
bWF5IHRha2Ugc29tZSBkYXlzLjxicj48L2Rpdj48L2Rpdj48L2Rpdj4K

--===============6750170388810316250==--

