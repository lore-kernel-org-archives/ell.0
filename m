Content-Type: multipart/mixed; boundary="===============4446421078613345079=="
MIME-Version: 1.0
From: Othman, Ossama <ossama.othman@intel.com>
Subject: Re: [PATCH] genl: Fix casting error
Date: Mon, 17 Jul 2017 13:09:54 -0700
Message-ID: <CAPyD+=Cnze=NJA=PE9tMjgoqvvygukgVt6POh+Sdx=BjrBwBdQ@mail.gmail.com>
In-Reply-To: <0734F1C385189A4F8523BB7BB31464D78E2709E3@fmsmsx111.amr.corp.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4446421078613345079==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Tim,

On Fri, Jul 14, 2017 at 1:57 PM, Kourt, Tim A <tim.a.kourt@intel.com> wro=
te:
>
> > NLMSG_OK() expects an int for the second argument.  Assuming truncation
> isn't an issue here, wouldn't it be better to cast to an int instead?
>
>
>
> The uint32_t was used to keep the consistency with the other usages of
> NLMSG_OK() within ELL and thereafter IWD. Maybe it is time to fix all of
> them.
>

I did some digging into the NLMSG_OK() macro and found several patches and
discussions related to this very same issue.  It looks like everyone does
indeed cast to an unsigned integer, even though the documentation states
that the type is int.  Patches to "fix" the issue with the macro have all
been rejected, too. Consistency wins.  :)

-Ossama

--===============4446421078613345079==
Content-Type: text/html
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="attachment.html"

PGRpdiBkaXI9Imx0ciI+SGkgVGltLDxkaXYgY2xhc3M9ImdtYWlsX2V4dHJhIj48YnI+PGRpdiBj
bGFzcz0iZ21haWxfcXVvdGUiPk9uIEZyaSwgSnVsIDE0LCAyMDE3IGF0IDE6NTcgUE0sIEtvdXJ0
LCBUaW0gQSA8c3BhbiBkaXI9Imx0ciI+Jmx0OzxhIGhyZWY9Im1haWx0bzp0aW0uYS5rb3VydEBp
bnRlbC5jb20iIHRhcmdldD0iX2JsYW5rIj50aW0uYS5rb3VydEBpbnRlbC5jb208L2E+Jmd0Ozwv
c3Bhbj4gd3JvdGU6PGJsb2NrcXVvdGUgY2xhc3M9ImdtYWlsX3F1b3RlIiBzdHlsZT0ibWFyZ2lu
OjAgMCAwIC44ZXg7Ym9yZGVyLWxlZnQ6MXB4ICNjY2Mgc29saWQ7cGFkZGluZy1sZWZ0OjFleCI+
PGRpdiBsYW5nPSJFTi1VUyIgbGluaz0iYmx1ZSIgdmxpbms9InB1cnBsZSI+PGRpdiBjbGFzcz0i
bV8tMjA4MjM4NjQ2OTIwNjc3NTU2V29yZFNlY3Rpb24xIj48c3BhbiBjbGFzcz0iIj4KPHAgY2xh
c3M9Ik1zb05vcm1hbCI+Jmd0OyBOTE1TR19PSygpIGV4cGVjdHMgYW4gaW50IGZvciB0aGUgc2Vj
b25kIGFyZ3VtZW50LsKgIEFzc3VtaW5nIHRydW5jYXRpb24gaXNuJiMzOTt0IGFuIGlzc3VlIGhl
cmUsIHdvdWxkbiYjMzk7dCBpdCBiZSBiZXR0ZXIgdG8gY2FzdCB0byBhbiBpbnQgaW5zdGVhZD88
c3BhbiBzdHlsZT0iY29sb3I6IzFmNDk3ZCI+PHU+PC91Pjx1PjwvdT48L3NwYW4+PC9wPgo8cCBj
bGFzcz0iTXNvTm9ybWFsIj48c3BhbiBzdHlsZT0iZm9udC1zaXplOjExLjBwdDtmb250LWZhbWls
eTomcXVvdDtDYWxpYnJpJnF1b3Q7LHNhbnMtc2VyaWY7Y29sb3I6IzFmNDk3ZCI+PHU+PC91PsKg
PHU+PC91Pjwvc3Bhbj48L3A+Cjwvc3Bhbj48cCBjbGFzcz0iTXNvTm9ybWFsIj48c3BhbiBzdHls
ZT0iZm9udC1zaXplOjExLjBwdDtmb250LWZhbWlseTomcXVvdDtDYWxpYnJpJnF1b3Q7LHNhbnMt
c2VyaWY7Y29sb3I6IzFmNDk3ZCI+VGhlIHVpbnQzMl90IHdhcyB1c2VkIHRvIGtlZXAgdGhlIGNv
bnNpc3RlbmN5IHdpdGggdGhlIG90aGVyIHVzYWdlcyBvZiBOTE1TR19PSygpIHdpdGhpbiBFTEwg
YW5kIHRoZXJlYWZ0ZXIgSVdELiBNYXliZSBpdCBpcyB0aW1lIHRvIGZpeCBhbGwgb2YgdGhlbS48
YnI+PC9zcGFuPjwvcD48L2Rpdj48L2Rpdj48L2Jsb2NrcXVvdGU+PGRpdj48YnI+PC9kaXY+PGRp
dj5JIGRpZCBzb21lIGRpZ2dpbmcgaW50byB0aGUgTkxNU0dfT0soKSBtYWNybyBhbmQgZm91bmQg
c2V2ZXJhbCBwYXRjaGVzIGFuZCBkaXNjdXNzaW9ucyByZWxhdGVkIHRvIHRoaXMgdmVyeSBzYW1l
IGlzc3VlLsKgIEl0IGxvb2tzIGxpa2UgZXZlcnlvbmUgZG9lcyBpbmRlZWQgY2FzdCB0byBhbiB1
bnNpZ25lZCBpbnRlZ2VyLCBldmVuIHRob3VnaCB0aGUgZG9jdW1lbnRhdGlvbiBzdGF0ZXMgdGhh
dCB0aGUgdHlwZSBpcyBpbnQuwqAgUGF0Y2hlcyB0byAmcXVvdDtmaXgmcXVvdDsgdGhlIGlzc3Vl
IHdpdGggdGhlIG1hY3JvIGhhdmUgYWxsIGJlZW4gcmVqZWN0ZWQsIHRvby4gQ29uc2lzdGVuY3kg
d2lucy4gwqA6KTwvZGl2PjxkaXY+PGJyPjwvZGl2PjxkaXY+LU9zc2FtYTwvZGl2PjxkaXY+PGJy
PjwvZGl2PjxkaXY+PGJyPjwvZGl2PjwvZGl2PjwvZGl2PjwvZGl2Pgo=

--===============4446421078613345079==--

