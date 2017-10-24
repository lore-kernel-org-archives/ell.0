Content-Type: multipart/mixed; boundary="===============6688506650771670873=="
MIME-Version: 1.0
From: Othman, Ossama <ossama.othman@intel.com>
Subject: Re: Is l_genl instance returned by l_genl_new() fully usable?
Date: Tue, 24 Oct 2017 13:32:29 -0700
Message-ID: <CAPyD+=C39KzA_bkq8y-ORJtVODFfpuQ790B-RsP95D0uu403_w@mail.gmail.com>
In-Reply-To: <026bd2b3-8552-1548-a419-c52b962acdf9@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6688506650771670873==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Tue, Oct 24, 2017 at 1:13 PM, Denis Kenzior <denkenz@gmail.com> wrote:

> On 10/24/2017 02:55 PM, Othman, Ossama wrote:
>>
>> In l_genl_new_default(), the zero valued nl_pid field is set to a
>> non-zero value after the call to bind(), which is then assigned to l_gen=
l's
>> pid field for later use in can_write_data().  I don't know
>>
>
> Correct.  However note that we use the pid field to set the nlmsg_pid
> field.  Which the kernel never looks at as far as I can tell. Everything =
in
> the kernel uses the actual socket nl_pid, which makes sense anyway
> otherwise you could fake who you are.
>

Good point!

enough about the netlink implementation in the kernel to understand if the
>> nl_pid value assigned by the kernel during the call to bind() makes a
>> difference, but if it does wouldn't we need to keep the l_genl pid field
>> intact?
>>
>
> In theory you are correct.  However it doesn't appear that nlmsg_pid field
> is ever looked at.  Hence my earlier question of whether this tracking co=
de
> and the pid member value is even needed.
>

Based on the points you made it certainly seems like that tracking code and
l_genl pid member aren't needed.

Thanks Denis!
-Ossama

--===============6688506650771670873==
Content-Type: text/html
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="attachment.html"

PGRpdiBkaXI9Imx0ciI+SGkgRGVuaXMsPGRpdiBjbGFzcz0iZ21haWxfZXh0cmEiPjxicj48ZGl2
IGNsYXNzPSJnbWFpbF9xdW90ZSI+T24gVHVlLCBPY3QgMjQsIDIwMTcgYXQgMToxMyBQTSwgRGVu
aXMgS2VuemlvciA8c3BhbiBkaXI9Imx0ciI+Jmx0OzxhIGhyZWY9Im1haWx0bzpkZW5rZW56QGdt
YWlsLmNvbSIgdGFyZ2V0PSJfYmxhbmsiPmRlbmtlbnpAZ21haWwuY29tPC9hPiZndDs8L3NwYW4+
IHdyb3RlOjxicj48YmxvY2txdW90ZSBjbGFzcz0iZ21haWxfcXVvdGUiIHN0eWxlPSJtYXJnaW46
MCAwIDAgLjhleDtib3JkZXItbGVmdDoxcHggI2NjYyBzb2xpZDtwYWRkaW5nLWxlZnQ6MWV4Ij5P
biAxMC8yNC8yMDE3IDAyOjU1IFBNLCBPdGhtYW4sIE9zc2FtYSB3cm90ZTo8YmxvY2txdW90ZSBj
bGFzcz0iZ21haWxfcXVvdGUiIHN0eWxlPSJtYXJnaW46MCAwIDAgLjhleDtib3JkZXItbGVmdDox
cHggI2NjYyBzb2xpZDtwYWRkaW5nLWxlZnQ6MWV4Ij4KSW4gbF9nZW5sX25ld19kZWZhdWx0KCks
IHRoZSB6ZXJvIHZhbHVlZCBubF9waWQgZmllbGQgaXMgc2V0IHRvIGEgbm9uLXplcm8gdmFsdWUg
YWZ0ZXIgdGhlIGNhbGwgdG8gYmluZCgpLCB3aGljaCBpcyB0aGVuIGFzc2lnbmVkIHRvIGxfZ2Vu
bCYjMzk7cyBwaWQgZmllbGQgZm9yIGxhdGVyIHVzZSBpbiBjYW5fd3JpdGVfZGF0YSgpLsKgIEkg
ZG9uJiMzOTt0IGtub3cgPGJyPgo8L2Jsb2NrcXVvdGU+Cjxicj4KQ29ycmVjdC7CoCBIb3dldmVy
IG5vdGUgdGhhdCB3ZSB1c2UgdGhlIHBpZCBmaWVsZCB0byBzZXQgdGhlIG5sbXNnX3BpZCBmaWVs
ZC7CoCBXaGljaCB0aGUga2VybmVsIG5ldmVyIGxvb2tzIGF0IGFzIGZhciBhcyBJIGNhbiB0ZWxs
LiBFdmVyeXRoaW5nIGluIHRoZSBrZXJuZWwgdXNlcyB0aGUgYWN0dWFsIHNvY2tldCBubF9waWQs
IHdoaWNoIG1ha2VzIHNlbnNlIGFueXdheSBvdGhlcndpc2UgeW91IGNvdWxkIGZha2Ugd2hvIHlv
dSBhcmUuPGJyPjwvYmxvY2txdW90ZT48ZGl2Pjxicj48L2Rpdj48ZGl2Pkdvb2QgcG9pbnQhPC9k
aXY+PGRpdj48YnI+PC9kaXY+PGJsb2NrcXVvdGUgY2xhc3M9ImdtYWlsX3F1b3RlIiBzdHlsZT0i
bWFyZ2luOjAgMCAwIC44ZXg7Ym9yZGVyLWxlZnQ6MXB4ICNjY2Mgc29saWQ7cGFkZGluZy1sZWZ0
OjFleCI+CjxibG9ja3F1b3RlIGNsYXNzPSJnbWFpbF9xdW90ZSIgc3R5bGU9Im1hcmdpbjowIDAg
MCAuOGV4O2JvcmRlci1sZWZ0OjFweCAjY2NjIHNvbGlkO3BhZGRpbmctbGVmdDoxZXgiPgplbm91
Z2ggYWJvdXQgdGhlIG5ldGxpbmsgaW1wbGVtZW50YXRpb24gaW4gdGhlIGtlcm5lbCB0byB1bmRl
cnN0YW5kIGlmIHRoZSBubF9waWQgdmFsdWUgYXNzaWduZWQgYnkgdGhlIGtlcm5lbCBkdXJpbmcg
dGhlIGNhbGwgdG8gYmluZCgpIG1ha2VzIGEgZGlmZmVyZW5jZSwgYnV0IGlmIGl0IGRvZXMgd291
bGRuJiMzOTt0IHdlIG5lZWQgdG8ga2VlcCB0aGUgbF9nZW5sIHBpZCBmaWVsZCBpbnRhY3Q/PGJy
Pgo8L2Jsb2NrcXVvdGU+Cjxicj4KSW4gdGhlb3J5IHlvdSBhcmUgY29ycmVjdC7CoCBIb3dldmVy
IGl0IGRvZXNuJiMzOTt0IGFwcGVhciB0aGF0IG5sbXNnX3BpZCBmaWVsZCBpcyBldmVyIGxvb2tl
ZCBhdC7CoCBIZW5jZSBteSBlYXJsaWVyIHF1ZXN0aW9uIG9mIHdoZXRoZXIgdGhpcyB0cmFja2lu
ZyBjb2RlIGFuZCB0aGUgcGlkIG1lbWJlciB2YWx1ZSBpcyBldmVuIG5lZWRlZC48YnI+PC9ibG9j
a3F1b3RlPjxkaXY+PGJyPjwvZGl2PjxkaXY+QmFzZWQgb24gdGhlIHBvaW50cyB5b3UgbWFkZSBp
dCBjZXJ0YWlubHkgc2VlbXMgbGlrZSB0aGF0IHRyYWNraW5nIGNvZGUgYW5kIGxfZ2VubCBwaWQg
bWVtYmVyIGFyZW4mIzM5O3QgbmVlZGVkLjwvZGl2PjxkaXY+PGJyPjwvZGl2PjxkaXY+VGhhbmtz
IERlbmlzITwvZGl2PjxkaXY+LU9zc2FtYTwvZGl2PjwvZGl2PjwvZGl2PjwvZGl2Pgo=

--===============6688506650771670873==--

