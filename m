Content-Type: multipart/mixed; boundary="===============5459693254852210888=="
MIME-Version: 1.0
From: Stotland, Inga <inga.stotland@intel.com>
Subject: Re: [PATCH 1/2] io: Do not call disconnect handler in destroyer
Date: Tue, 13 Oct 2020 21:11:39 +0000
Message-ID: <ca812ce9e923a60dce285d1a6f673a93d38b6973.camel@intel.com>
In-Reply-To: <caa00362-d4d1-5cb2-70a5-4d2d6d533c06@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5459693254852210888==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Tue, 2020-10-13 at 13:34 -0500, Denis Kenzior wrote:

Hi Inga,


On 10/12/20 5:13 PM, Inga Stotland wrote:

When a client is calling l_io_destroy() there is no need to inform

that same client that io has been disconnected.


Hmm... the client invoking l_io_destroy might be different from the one tha=
t set

the disconnect handler?  Also, I think this might break some clients.

ofono.git/plugins/mbim.c for example seems like it is affected due to how

mbim_device is implemented...



Removing the disconnect callback from l_io_destroy() eliminates the

need to zero out and preserve disconnect handler data when invoking

disconnect handler in io_closed().


Also, rename static function io_closed() to io_disconnected() to

reflect the actual functionality.


Is anything really broken due to the current behavior?

I guess not. I was just thrown off by the comment "in case the handler call=
s io_destroy" in io_closed().
Let's disregard this patch.



---

  ell/io.c | 32 +++++++++-----------------------

  1 file changed, 9 insertions(+), 23 deletions(-)



Regards,

-Denis

--===============5459693254852210888==
Content-Type: text/html
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="attachment.htm"

PGh0bWwgZGlyPSJsdHIiPg0KPGhlYWQ+DQo8bWV0YSBodHRwLWVxdWl2PSJDb250ZW50LVR5cGUi
IGNvbnRlbnQ9InRleHQvaHRtbDsgY2hhcnNldD11dGYtOCI+DQo8L2hlYWQ+DQo8Ym9keSBzdHls
ZT0idGV4dC1hbGlnbjpsZWZ0OyBkaXJlY3Rpb246bHRyOyIgYmdjb2xvcj0iI2ZmZmZmZiIgdGV4
dD0iIzJlMzQzNiIgbGluaz0iIzczNzM3MyIgdmxpbms9IiMyZTM0MzYiPg0KPGRpdj5IaSBEZW5p
cyw8L2Rpdj4NCjxkaXY+PGJyPg0KPC9kaXY+DQo8ZGl2Pk9uIFR1ZSwgMjAyMC0xMC0xMyBhdCAx
MzozNCAtMDUwMCwgRGVuaXMgS2VuemlvciB3cm90ZTo8L2Rpdj4NCjxibG9ja3F1b3RlIHR5cGU9
ImNpdGUiIHN0eWxlPSJtYXJnaW46MCAwIDAgLjhleDsgYm9yZGVyLWxlZnQ6MnB4ICM3MjlmY2Yg
c29saWQ7cGFkZGluZy1sZWZ0OjFleCI+DQo8cHJlPkhpIEluZ2EsPC9wcmU+DQo8cHJlPjxicj48
L3ByZT4NCjxwcmU+T24gMTAvMTIvMjAgNToxMyBQTSwgSW5nYSBTdG90bGFuZCB3cm90ZTo8L3By
ZT4NCjxibG9ja3F1b3RlIHR5cGU9ImNpdGUiIHN0eWxlPSJtYXJnaW46MCAwIDAgLjhleDsgYm9y
ZGVyLWxlZnQ6MnB4ICM3MjlmY2Ygc29saWQ7cGFkZGluZy1sZWZ0OjFleCI+DQo8cHJlPldoZW4g
YSBjbGllbnQgaXMgY2FsbGluZyBsX2lvX2Rlc3Ryb3koKSB0aGVyZSBpcyBubyBuZWVkIHRvIGlu
Zm9ybTwvcHJlPg0KPHByZT50aGF0IHNhbWUgY2xpZW50IHRoYXQgaW8gaGFzIGJlZW4gZGlzY29u
bmVjdGVkLjwvcHJlPg0KPC9ibG9ja3F1b3RlPg0KPHByZT48YnI+PC9wcmU+DQo8cHJlPkhtbS4u
LiB0aGUgY2xpZW50IGludm9raW5nIGxfaW9fZGVzdHJveSBtaWdodCBiZSBkaWZmZXJlbnQgZnJv
bSB0aGUgb25lIHRoYXQgc2V0IDwvcHJlPg0KPHByZT50aGUgZGlzY29ubmVjdCBoYW5kbGVyPyAg
QWxzbywgSSB0aGluayB0aGlzIG1pZ2h0IGJyZWFrIHNvbWUgY2xpZW50cy4gPC9wcmU+DQo8cHJl
Pm9mb25vLmdpdC9wbHVnaW5zL21iaW0uYyBmb3IgZXhhbXBsZSBzZWVtcyBsaWtlIGl0IGlzIGFm
ZmVjdGVkIGR1ZSB0byBob3cgPC9wcmU+DQo8cHJlPm1iaW1fZGV2aWNlIGlzIGltcGxlbWVudGVk
Li4uPC9wcmU+DQo8cHJlPjxicj48L3ByZT4NCjxibG9ja3F1b3RlIHR5cGU9ImNpdGUiIHN0eWxl
PSJtYXJnaW46MCAwIDAgLjhleDsgYm9yZGVyLWxlZnQ6MnB4ICM3MjlmY2Ygc29saWQ7cGFkZGlu
Zy1sZWZ0OjFleCI+DQo8cHJlPjxicj48L3ByZT4NCjxwcmU+UmVtb3ZpbmcgdGhlIGRpc2Nvbm5l
Y3QgY2FsbGJhY2sgZnJvbSBsX2lvX2Rlc3Ryb3koKSBlbGltaW5hdGVzIHRoZTwvcHJlPg0KPHBy
ZT5uZWVkIHRvIHplcm8gb3V0IGFuZCBwcmVzZXJ2ZSBkaXNjb25uZWN0IGhhbmRsZXIgZGF0YSB3
aGVuIGludm9raW5nPC9wcmU+DQo8cHJlPmRpc2Nvbm5lY3QgaGFuZGxlciBpbiBpb19jbG9zZWQo
KS48L3ByZT4NCjxwcmU+PGJyPjwvcHJlPg0KPHByZT5BbHNvLCByZW5hbWUgc3RhdGljIGZ1bmN0
aW9uIGlvX2Nsb3NlZCgpIHRvIGlvX2Rpc2Nvbm5lY3RlZCgpIHRvPC9wcmU+DQo8cHJlPnJlZmxl
Y3QgdGhlIGFjdHVhbCBmdW5jdGlvbmFsaXR5LjwvcHJlPg0KPC9ibG9ja3F1b3RlPg0KPHByZT48
YnI+PC9wcmU+DQo8cHJlPklzIGFueXRoaW5nIHJlYWxseSBicm9rZW4gZHVlIHRvIHRoZSBjdXJy
ZW50IGJlaGF2aW9yPzwvcHJlPg0KPC9ibG9ja3F1b3RlPg0KPGRpdj48YnI+DQo8L2Rpdj4NCjxk
aXY+SSBndWVzcyBub3QuIEkgd2FzIGp1c3QgdGhyb3duIG9mZiBieSB0aGUgY29tbWVudCAmcXVv
dDtpbiBjYXNlIHRoZSBoYW5kbGVyIGNhbGxzIGlvX2Rlc3Ryb3kmcXVvdDsgaW4gaW9fY2xvc2Vk
KCkuPC9kaXY+DQo8ZGl2PkxldCdzIGRpc3JlZ2FyZCB0aGlzIHBhdGNoLjwvZGl2Pg0KPGRpdj48
YnI+DQo8L2Rpdj4NCjxibG9ja3F1b3RlIHR5cGU9ImNpdGUiIHN0eWxlPSJtYXJnaW46MCAwIDAg
LjhleDsgYm9yZGVyLWxlZnQ6MnB4ICM3MjlmY2Ygc29saWQ7cGFkZGluZy1sZWZ0OjFleCI+DQo8
cHJlPjxicj48L3ByZT4NCjxibG9ja3F1b3RlIHR5cGU9ImNpdGUiIHN0eWxlPSJtYXJnaW46MCAw
IDAgLjhleDsgYm9yZGVyLWxlZnQ6MnB4ICM3MjlmY2Ygc29saWQ7cGFkZGluZy1sZWZ0OjFleCI+
DQo8cHJlPi0tLTwvcHJlPg0KPHByZT4gIGVsbC9pby5jIHwgMzIgKysrKysrKysrLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS08L3ByZT4NCjxwcmU+ICAxIGZpbGUgY2hhbmdlZCwgOSBpbnNlcnRpb25z
KCspLCAyMyBkZWxldGlvbnMoLSk8L3ByZT4NCjxwcmU+PGJyPjwvcHJlPg0KPC9ibG9ja3F1b3Rl
Pg0KPHByZT48YnI+PC9wcmU+DQo8cHJlPlJlZ2FyZHMsPC9wcmU+DQo8cHJlPi1EZW5pczwvcHJl
Pg0KPC9ibG9ja3F1b3RlPg0KPC9ib2R5Pg0KPC9odG1sPg0K

--===============5459693254852210888==--

