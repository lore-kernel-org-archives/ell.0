Content-Type: multipart/mixed; boundary="===============7773084344657405759=="
MIME-Version: 1.0
From: Othman, Ossama <ossama.othman@intel.com>
Subject: Re: Is l_genl instance returned by l_genl_new() fully usable?
Date: Tue, 24 Oct 2017 12:55:28 -0700
Message-ID: <CAPyD+=DrVWWynMDRohzcM91WFoTx5wqf3Q8MaTMBDhM+Fexm-g@mail.gmail.com>
In-Reply-To: <5b2cacb2-4932-5d93-6345-96d22cc788e4@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7773084344657405759==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Tue, Oct 24, 2017 at 10:44 AM, Denis Kenzior <denkenz@gmail.com> wrote:
>
> On 10/24/2017 12:13 PM, Othman, Ossama wrote:
>>
>> While looking at ELL's generic netlink code, I noticed that l_genl_new()
>> is part of the public API but it's not clear if the returned struct l_ge=
nl
>> instance is fully usable since its pid field isn't set as in
>> l_genl_new_default(), and since there's is no way to set it afterward.
>> This could result in the underlying sockaddr_nl nl_pid field being
>> different from l_genl's pid field (zero in this case).  Is that correct?
>>
>
> We don't actually use l_genl_new anywhere.  And it is not unit tested.
> However, looking at man 7 netlink, it states that nl_pid should be set to=
 0
> whenever the destination is in the kernel (which for us is always the case
> at the moment).  So I'm not sure that the pid field is even needed?  At
> least setting nl_pid to 0 in can_write_data doesn't seem to break anythin=
g.


In l_genl_new_default(), the zero valued nl_pid field is set to a non-zero
value after the call to bind(), which is then assigned to l_genl's pid
field for later use in can_write_data().  I don't know enough about the
netlink implementation in the kernel to understand if the nl_pid value
assigned by the kernel during the call to bind() makes a difference, but if
it does wouldn't we need to keep the l_genl pid field intact?

-Ossama

--===============7773084344657405759==
Content-Type: text/html
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="attachment.html"

PGRpdiBkaXI9Imx0ciI+SGkgRGVuaXMsPGRpdiBjbGFzcz0iZ21haWxfZXh0cmEiPjxicj48ZGl2
IGNsYXNzPSJnbWFpbF9xdW90ZSI+T24gVHVlLCBPY3QgMjQsIDIwMTcgYXQgMTA6NDQgQU0sIERl
bmlzIEtlbnppb3IgPHNwYW4gZGlyPSJsdHIiPiZsdDs8YSBocmVmPSJtYWlsdG86ZGVua2VuekBn
bWFpbC5jb20iIHRhcmdldD0iX2JsYW5rIj5kZW5rZW56QGdtYWlsLmNvbTwvYT4mZ3Q7PC9zcGFu
PiB3cm90ZTo8YmxvY2txdW90ZSBjbGFzcz0iZ21haWxfcXVvdGUiIHN0eWxlPSJtYXJnaW46MCAw
IDAgLjhleDtib3JkZXItbGVmdDoxcHggI2NjYyBzb2xpZDtwYWRkaW5nLWxlZnQ6MWV4Ij48c3Bh
biBjbGFzcz0iIj4KT24gMTAvMjQvMjAxNyAxMjoxMyBQTSwgT3RobWFuLCBPc3NhbWEgd3JvdGU6
PGJsb2NrcXVvdGUgY2xhc3M9ImdtYWlsX3F1b3RlIiBzdHlsZT0ibWFyZ2luOjAgMCAwIC44ZXg7
Ym9yZGVyLWxlZnQ6MXB4ICNjY2Mgc29saWQ7cGFkZGluZy1sZWZ0OjFleCI+CldoaWxlIGxvb2tp
bmcgYXQgRUxMJiMzOTtzIGdlbmVyaWMgbmV0bGluayBjb2RlLCBJIG5vdGljZWQgdGhhdCBsX2dl
bmxfbmV3KCkgaXMgcGFydCBvZiB0aGUgcHVibGljIEFQSSBidXQgaXQmIzM5O3Mgbm90IGNsZWFy
IGlmIHRoZSByZXR1cm5lZCBzdHJ1Y3QgbF9nZW5sIGluc3RhbmNlIGlzIGZ1bGx5IHVzYWJsZSBz
aW5jZSBpdHMgcGlkIGZpZWxkIGlzbiYjMzk7dCBzZXQgYXMgaW4gbF9nZW5sX25ld19kZWZhdWx0
KCksIGFuZCBzaW5jZSB0aGVyZSYjMzk7cyBpcyBubyB3YXkgdG8gc2V0IGl0IGFmdGVyd2FyZC7C
oCBUaGlzIGNvdWxkIHJlc3VsdCBpbiB0aGUgdW5kZXJseWluZyBzb2NrYWRkcl9ubCBubF9waWQg
ZmllbGQgYmVpbmcgZGlmZmVyZW50IGZyb20gbF9nZW5sJiMzOTtzIHBpZCBmaWVsZCAoemVybyBp
biB0aGlzIGNhc2UpLsKgIElzIHRoYXQgY29ycmVjdD88YnI+CjwvYmxvY2txdW90ZT4KPGJyPjwv
c3Bhbj4KV2UgZG9uJiMzOTt0IGFjdHVhbGx5IHVzZSBsX2dlbmxfbmV3IGFueXdoZXJlLsKgIEFu
ZCBpdCBpcyBub3QgdW5pdCB0ZXN0ZWQuIEhvd2V2ZXIsIGxvb2tpbmcgYXQgbWFuIDcgbmV0bGlu
aywgaXQgc3RhdGVzIHRoYXQgbmxfcGlkIHNob3VsZCBiZSBzZXQgdG8gMCB3aGVuZXZlciB0aGUg
ZGVzdGluYXRpb24gaXMgaW4gdGhlIGtlcm5lbCAod2hpY2ggZm9yIHVzIGlzIGFsd2F5cyB0aGUg
Y2FzZSBhdCB0aGUgbW9tZW50KS7CoCBTbyBJJiMzOTttIG5vdCBzdXJlIHRoYXQgdGhlIHBpZCBm
aWVsZCBpcyBldmVuIG5lZWRlZD/CoCBBdCBsZWFzdCBzZXR0aW5nIG5sX3BpZCB0byAwIGluIGNh
bl93cml0ZV9kYXRhIGRvZXNuJiMzOTt0IHNlZW0gdG8gYnJlYWsgYW55dGhpbmcuPC9ibG9ja3F1
b3RlPjxkaXY+PGJyPkluIGxfZ2VubF9uZXdfZGVmYXVsdCgpLCB0aGUgemVybyB2YWx1ZWQgbmxf
cGlkIGZpZWxkIGlzIHNldCB0byBhIG5vbi16ZXJvIHZhbHVlIGFmdGVyIHRoZSBjYWxsIHRvIGJp
bmQoKSwgd2hpY2ggaXMgdGhlbiBhc3NpZ25lZCB0byBsX2dlbmwmIzM5O3MgcGlkIGZpZWxkIGZv
ciBsYXRlciB1c2UgaW4gY2FuX3dyaXRlX2RhdGEoKS7CoCBJIGRvbiYjMzk7dCBrbm93IGVub3Vn
aCBhYm91dCB0aGUgbmV0bGluayBpbXBsZW1lbnRhdGlvbiBpbiB0aGUga2VybmVsIHRvIHVuZGVy
c3RhbmQgaWYgdGhlIG5sX3BpZCB2YWx1ZSBhc3NpZ25lZCBieSB0aGUga2VybmVsIGR1cmluZyB0
aGUgY2FsbCB0byBiaW5kKCkgbWFrZXMgYSBkaWZmZXJlbmNlLCBidXQgaWYgaXQgZG9lcyB3b3Vs
ZG4mIzM5O3Qgd2UgbmVlZCB0byBrZWVwIHRoZSBsX2dlbmwgcGlkIGZpZWxkIGludGFjdD88L2Rp
dj48ZGl2Pjxicj48L2Rpdj48ZGl2Pi1Pc3NhbWE8L2Rpdj48ZGl2Pjxicj48L2Rpdj48ZGl2Pjxi
cj48L2Rpdj48L2Rpdj48L2Rpdj48L2Rpdj4K

--===============7773084344657405759==--

