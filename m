Content-Type: multipart/mixed; boundary="===============6880420067388983836=="
MIME-Version: 1.0
From: Stotland, Inga <inga.stotland@intel.com>
Subject: Re: [PATCH] main: Add handler for SIGSEGV signal
Date: Wed, 27 Jan 2021 17:53:32 +0000
Message-ID: <9570522c88808d3d1a5ec2204c9f762ff1b089c3.camel@intel.com>
In-Reply-To: <B16AD30C-C72C-4E20-A1D5-9BDC126598E1@holtmann.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6880420067388983836==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Tue, 2021-01-26 at 10:02 +0100, Marcel Holtmann wrote:

Hi Inga,


When an ell main loop based process is spun off as a child

and the parent process dies due to a segfault, the child process

is still left running and needs to detect the segfault condition.

To address this need, add watch and signal handler for SIGSEGV.

---

ell/main.c | 11 +++++++++++

1 file changed, 11 insertions(+)


diff --git a/ell/main.c b/ell/main.c

index a479b74..712cfb7 100644

--- a/ell/main.c

+++ b/ell/main.c

@@ -619,6 +619,14 @@ static void sigterm_handler(void *user_data)

                data->callback(SIGTERM, data->user_data);

}


+static void sigsegv_handler(void *user_data)

+{

+       struct signal_data *data =3D user_data;

+

+       if (data->callback)

+               data->callback(SIGSEGV, data->user_data);

+}

+


actually this is not enough. I never included SIGSEGV here for the simple r=
eason since you have to do a lot of work when that signal happens.


What we need to do is to add proper child spawning handling that does all t=
he nasty signal handling for you. Otherwise you are just about to create zo=
mbies. For now if you need child handling, then add your own signal handler=
 instead trying to overload l_main_run_with_signal with it.



We may want to revert this commit. It's harmless, but adds extra code to el=
l.

There's a way to deal with the segfault situation across the processes with=
out involving ell (thank you Phil for the suggestion).


Sorry for the churn.


Best Regards,


Inga


--===============6880420067388983836==
Content-Type: text/html
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="attachment.htm"

PGh0bWwgZGlyPSJsdHIiPg0KPGhlYWQ+DQo8bWV0YSBodHRwLWVxdWl2PSJDb250ZW50LVR5cGUi
IGNvbnRlbnQ9InRleHQvaHRtbDsgY2hhcnNldD11dGYtOCI+DQo8L2hlYWQ+DQo8Ym9keSBzdHls
ZT0idGV4dC1hbGlnbjpsZWZ0OyBkaXJlY3Rpb246bHRyOyIgYmdjb2xvcj0iI2ZmZmZmZiIgdGV4
dD0iIzJlMzQzNiIgbGluaz0iIzczNzM3MyIgdmxpbms9IiMyZTM0MzYiPg0KPGRpdj5IaSBEZW5p
cyw8L2Rpdj4NCjxkaXY+PGJyPg0KPC9kaXY+DQo8ZGl2Pk9uIFR1ZSwgMjAyMS0wMS0yNiBhdCAx
MDowMiArMDEwMCwgTWFyY2VsIEhvbHRtYW5uIHdyb3RlOjwvZGl2Pg0KPGJsb2NrcXVvdGUgdHlw
ZT0iY2l0ZSIgc3R5bGU9Im1hcmdpbjowIDAgMCAuOGV4OyBib3JkZXItbGVmdDoycHggIzcyOWZj
ZiBzb2xpZDtwYWRkaW5nLWxlZnQ6MWV4Ij4NCjxwcmU+SGkgSW5nYSw8L3ByZT4NCjxwcmU+PGJy
PjwvcHJlPg0KPGJsb2NrcXVvdGUgdHlwZT0iY2l0ZSIgc3R5bGU9Im1hcmdpbjowIDAgMCAuOGV4
OyBib3JkZXItbGVmdDoycHggIzcyOWZjZiBzb2xpZDtwYWRkaW5nLWxlZnQ6MWV4Ij4NCjxwcmU+
V2hlbiBhbiBlbGwgbWFpbiBsb29wIGJhc2VkIHByb2Nlc3MgaXMgc3B1biBvZmYgYXMgYSBjaGls
ZDwvcHJlPg0KPHByZT5hbmQgdGhlIHBhcmVudCBwcm9jZXNzIGRpZXMgZHVlIHRvIGEgc2VnZmF1
bHQsIHRoZSBjaGlsZCBwcm9jZXNzPC9wcmU+DQo8cHJlPmlzIHN0aWxsIGxlZnQgcnVubmluZyBh
bmQgbmVlZHMgdG8gZGV0ZWN0IHRoZSBzZWdmYXVsdCBjb25kaXRpb24uPC9wcmU+DQo8cHJlPlRv
IGFkZHJlc3MgdGhpcyBuZWVkLCBhZGQgd2F0Y2ggYW5kIHNpZ25hbCBoYW5kbGVyIGZvciBTSUdT
RUdWLjwvcHJlPg0KPHByZT4tLS08L3ByZT4NCjxwcmU+ZWxsL21haW4uYyB8IDExICsrKysrKysr
KysrPC9wcmU+DQo8cHJlPjEgZmlsZSBjaGFuZ2VkLCAxMSBpbnNlcnRpb25zKCspPC9wcmU+DQo8
cHJlPjxicj48L3ByZT4NCjxwcmU+ZGlmZiAtLWdpdCBhL2VsbC9tYWluLmMgYi9lbGwvbWFpbi5j
PC9wcmU+DQo8cHJlPmluZGV4IGE0NzliNzQuLjcxMmNmYjcgMTAwNjQ0PC9wcmU+DQo8cHJlPi0t
LSBhL2VsbC9tYWluLmM8L3ByZT4NCjxwcmU+KysrIGIvZWxsL21haW4uYzwvcHJlPg0KPHByZT5A
QCAtNjE5LDYgKzYxOSwxNCBAQCBzdGF0aWMgdm9pZCBzaWd0ZXJtX2hhbmRsZXIodm9pZCAqdXNl
cl9kYXRhKTwvcHJlPg0KPHByZT4JCWRhdGEtJmd0O2NhbGxiYWNrKFNJR1RFUk0sIGRhdGEtJmd0
O3VzZXJfZGF0YSk7PC9wcmU+DQo8cHJlPn08L3ByZT4NCjxwcmU+PGJyPjwvcHJlPg0KPHByZT4r
c3RhdGljIHZvaWQgc2lnc2Vndl9oYW5kbGVyKHZvaWQgKnVzZXJfZGF0YSk8L3ByZT4NCjxwcmU+
K3s8L3ByZT4NCjxwcmU+KwlzdHJ1Y3Qgc2lnbmFsX2RhdGEgKmRhdGEgPSB1c2VyX2RhdGE7PC9w
cmU+DQo8cHJlPis8L3ByZT4NCjxwcmU+KwlpZiAoZGF0YS0mZ3Q7Y2FsbGJhY2spPC9wcmU+DQo8
cHJlPisJCWRhdGEtJmd0O2NhbGxiYWNrKFNJR1NFR1YsIGRhdGEtJmd0O3VzZXJfZGF0YSk7PC9w
cmU+DQo8cHJlPit9PC9wcmU+DQo8cHJlPis8L3ByZT4NCjwvYmxvY2txdW90ZT4NCjxwcmU+PGJy
PjwvcHJlPg0KPHByZT5hY3R1YWxseSB0aGlzIGlzIG5vdCBlbm91Z2guIEkgbmV2ZXIgaW5jbHVk
ZWQgU0lHU0VHViBoZXJlIGZvciB0aGUgc2ltcGxlIHJlYXNvbiBzaW5jZSB5b3UgaGF2ZSB0byBk
byBhIGxvdCBvZiB3b3JrIHdoZW4gdGhhdCBzaWduYWwgaGFwcGVucy48L3ByZT4NCjxwcmU+PGJy
PjwvcHJlPg0KPHByZT5XaGF0IHdlIG5lZWQgdG8gZG8gaXMgdG8gYWRkIHByb3BlciBjaGlsZCBz
cGF3bmluZyBoYW5kbGluZyB0aGF0IGRvZXMgYWxsIHRoZSBuYXN0eSBzaWduYWwgaGFuZGxpbmcg
Zm9yIHlvdS4gT3RoZXJ3aXNlIHlvdSBhcmUganVzdCBhYm91dCB0byBjcmVhdGUgem9tYmllcy4g
Rm9yIG5vdyBpZiB5b3UgbmVlZCBjaGlsZCBoYW5kbGluZywgdGhlbiBhZGQgeW91ciBvd24gc2ln
bmFsIGhhbmRsZXIgaW5zdGVhZCB0cnlpbmcgdG8gb3ZlcmxvYWQgbF9tYWluX3J1bl93aXRoX3Np
Z25hbCB3aXRoIGl0LjwvcHJlPg0KPHByZT48YnI+PC9wcmU+DQo8L2Jsb2NrcXVvdGU+DQo8cHJl
Pjxicj48L3ByZT4NCjxwcmU+V2UgbWF5IHdhbnQgdG8gcmV2ZXJ0IHRoaXMgY29tbWl0LiBJdCdz
IGhhcm1sZXNzLCBidXQgYWRkcyBleHRyYSBjb2RlIHRvIGVsbC48L3ByZT4NCjxwcmU+VGhlcmUn
cyBhIHdheSB0byBkZWFsIHdpdGggdGhlIHNlZ2ZhdWx0IHNpdHVhdGlvbiBhY3Jvc3MgdGhlIHBy
b2Nlc3NlcyB3aXRob3V0IGludm9sdmluZyBlbGwgKHRoYW5rIHlvdSBQaGlsIGZvciB0aGUgc3Vn
Z2VzdGlvbikuPC9wcmU+DQo8cHJlPjxicj48L3ByZT4NCjxwcmU+U29ycnkgZm9yIHRoZSBjaHVy
bi48L3ByZT4NCjxwcmU+PGJyPjwvcHJlPg0KPHByZT5CZXN0IFJlZ2FyZHMsPC9wcmU+DQo8cHJl
Pjxicj48L3ByZT4NCjxwcmU+SW5nYTwvcHJlPg0KPHByZT48YnI+PC9wcmU+DQo8L2JvZHk+DQo8
L2h0bWw+DQo=

--===============6880420067388983836==--

