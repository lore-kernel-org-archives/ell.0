Content-Type: multipart/mixed; boundary="===============2922457184646581781=="
MIME-Version: 1.0
From: Stotland, Inga <inga.stotland@intel.com>
Subject: Re: [PATCH] main: Add handler for SIGSEGV signal
Date: Tue, 26 Jan 2021 23:46:57 +0000
Message-ID: <fb1a8ad92aa6c9b5b8a5bae819882cecc2e1a577.camel@intel.com>
In-Reply-To: <B16AD30C-C72C-4E20-A1D5-9BDC126598E1@holtmann.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2922457184646581781==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Marcel,

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


I don't disagree that this is not enough.

However, this is the easiest way I could come up that allows a child to det=
ect a parent process crash.

Not very elegant as I had to add prctl() call to the child (but only in tes=
ting mode, so should not be awful).


Do you have better suggestions on to how to catch a segfault originating in=
 another process without modifying ell?


Best regards,

Inga

--===============2922457184646581781==
Content-Type: text/html
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="attachment.htm"

PGh0bWwgZGlyPSJsdHIiPg0KPGhlYWQ+DQo8bWV0YSBodHRwLWVxdWl2PSJDb250ZW50LVR5cGUi
IGNvbnRlbnQ9InRleHQvaHRtbDsgY2hhcnNldD11dGYtOCI+DQo8L2hlYWQ+DQo8Ym9keSBiZ2Nv
bG9yPSIjZmZmZmZmIiB0ZXh0PSIjMmUzNDM2IiBsaW5rPSIjNzM3MzczIiB2bGluaz0iIzJlMzQz
NiIgc3R5bGU9InRleHQtYWxpZ246bGVmdDsgZGlyZWN0aW9uOmx0cjsiPg0KPGRpdj5IaSBNYXJj
ZWwsPC9kaXY+DQo8ZGl2Pjxicj4NCjwvZGl2Pg0KPGRpdj5PbiBUdWUsIDIwMjEtMDEtMjYgYXQg
MTA6MDIgKzAxMDAsIE1hcmNlbCBIb2x0bWFubiB3cm90ZTo8L2Rpdj4NCjxibG9ja3F1b3RlIHR5
cGU9ImNpdGUiIHN0eWxlPSJtYXJnaW46MCAwIDAgLjhleDsgYm9yZGVyLWxlZnQ6MnB4ICM3Mjlm
Y2Ygc29saWQ7cGFkZGluZy1sZWZ0OjFleCI+DQo8cHJlPkhpIEluZ2EsPC9wcmU+DQo8cHJlPjxi
cj48L3ByZT4NCjxibG9ja3F1b3RlIHR5cGU9ImNpdGUiIHN0eWxlPSJtYXJnaW46MCAwIDAgLjhl
eDsgYm9yZGVyLWxlZnQ6MnB4ICM3MjlmY2Ygc29saWQ7cGFkZGluZy1sZWZ0OjFleCI+DQo8cHJl
PldoZW4gYW4gZWxsIG1haW4gbG9vcCBiYXNlZCBwcm9jZXNzIGlzIHNwdW4gb2ZmIGFzIGEgY2hp
bGQ8L3ByZT4NCjxwcmU+YW5kIHRoZSBwYXJlbnQgcHJvY2VzcyBkaWVzIGR1ZSB0byBhIHNlZ2Zh
dWx0LCB0aGUgY2hpbGQgcHJvY2VzczwvcHJlPg0KPHByZT5pcyBzdGlsbCBsZWZ0IHJ1bm5pbmcg
YW5kIG5lZWRzIHRvIGRldGVjdCB0aGUgc2VnZmF1bHQgY29uZGl0aW9uLjwvcHJlPg0KPHByZT5U
byBhZGRyZXNzIHRoaXMgbmVlZCwgYWRkIHdhdGNoIGFuZCBzaWduYWwgaGFuZGxlciBmb3IgU0lH
U0VHVi48L3ByZT4NCjxwcmU+LS0tPC9wcmU+DQo8cHJlPmVsbC9tYWluLmMgfCAxMSArKysrKysr
KysrKzwvcHJlPg0KPHByZT4xIGZpbGUgY2hhbmdlZCwgMTEgaW5zZXJ0aW9ucygrKTwvcHJlPg0K
PHByZT48YnI+PC9wcmU+DQo8cHJlPmRpZmYgLS1naXQgYS9lbGwvbWFpbi5jIGIvZWxsL21haW4u
YzwvcHJlPg0KPHByZT5pbmRleCBhNDc5Yjc0Li43MTJjZmI3IDEwMDY0NDwvcHJlPg0KPHByZT4t
LS0gYS9lbGwvbWFpbi5jPC9wcmU+DQo8cHJlPisrKyBiL2VsbC9tYWluLmM8L3ByZT4NCjxwcmU+
QEAgLTYxOSw2ICs2MTksMTQgQEAgc3RhdGljIHZvaWQgc2lndGVybV9oYW5kbGVyKHZvaWQgKnVz
ZXJfZGF0YSk8L3ByZT4NCjxwcmU+CQlkYXRhLSZndDtjYWxsYmFjayhTSUdURVJNLCBkYXRhLSZn
dDt1c2VyX2RhdGEpOzwvcHJlPg0KPHByZT59PC9wcmU+DQo8cHJlPjxicj48L3ByZT4NCjxwcmU+
K3N0YXRpYyB2b2lkIHNpZ3NlZ3ZfaGFuZGxlcih2b2lkICp1c2VyX2RhdGEpPC9wcmU+DQo8cHJl
Pit7PC9wcmU+DQo8cHJlPisJc3RydWN0IHNpZ25hbF9kYXRhICpkYXRhID0gdXNlcl9kYXRhOzwv
cHJlPg0KPHByZT4rPC9wcmU+DQo8cHJlPisJaWYgKGRhdGEtJmd0O2NhbGxiYWNrKTwvcHJlPg0K
PHByZT4rCQlkYXRhLSZndDtjYWxsYmFjayhTSUdTRUdWLCBkYXRhLSZndDt1c2VyX2RhdGEpOzwv
cHJlPg0KPHByZT4rfTwvcHJlPg0KPHByZT4rPC9wcmU+DQo8L2Jsb2NrcXVvdGU+DQo8cHJlPjxi
cj48L3ByZT4NCjxwcmU+YWN0dWFsbHkgdGhpcyBpcyBub3QgZW5vdWdoLiBJIG5ldmVyIGluY2x1
ZGVkIFNJR1NFR1YgaGVyZSBmb3IgdGhlIHNpbXBsZSByZWFzb24gc2luY2UgeW91IGhhdmUgdG8g
ZG8gYSBsb3Qgb2Ygd29yayB3aGVuIHRoYXQgc2lnbmFsIGhhcHBlbnMuPC9wcmU+DQo8cHJlPjxi
cj48L3ByZT4NCjxwcmU+V2hhdCB3ZSBuZWVkIHRvIGRvIGlzIHRvIGFkZCBwcm9wZXIgY2hpbGQg
c3Bhd25pbmcgaGFuZGxpbmcgdGhhdCBkb2VzIGFsbCB0aGUgbmFzdHkgc2lnbmFsIGhhbmRsaW5n
IGZvciB5b3UuIE90aGVyd2lzZSB5b3UgYXJlIGp1c3QgYWJvdXQgdG8gY3JlYXRlIHpvbWJpZXMu
IEZvciBub3cgaWYgeW91IG5lZWQgY2hpbGQgaGFuZGxpbmcsIHRoZW4gYWRkIHlvdXIgb3duIHNp
Z25hbCBoYW5kbGVyIGluc3RlYWQgdHJ5aW5nIHRvIG92ZXJsb2FkIGxfbWFpbl9ydW5fd2l0aF9z
aWduYWwgd2l0aCBpdC48L3ByZT4NCjwvYmxvY2txdW90ZT4NCjxwcmU+PGJyPjwvcHJlPg0KPHBy
ZT5JIGRvbid0IGRpc2FncmVlIHRoYXQgdGhpcyBpcyBub3QgZW5vdWdoLjwvcHJlPg0KPHByZT5I
b3dldmVyLCB0aGlzIGlzIHRoZSBlYXNpZXN0IHdheSBJIGNvdWxkIGNvbWUgdXAgdGhhdCBhbGxv
d3MgYSBjaGlsZCB0byBkZXRlY3QgYSBwYXJlbnQgcHJvY2VzcyBjcmFzaC48L3ByZT4NCjxwcmU+
Tm90IHZlcnkgZWxlZ2FudCBhcyBJIGhhZCB0byBhZGQgcHJjdGwoKSBjYWxsIHRvIHRoZSBjaGls
ZCAoYnV0IG9ubHkgaW4gdGVzdGluZyBtb2RlLCBzbyBzaG91bGQgbm90IGJlIGF3ZnVsKS48L3By
ZT4NCjxwcmU+PGJyPjwvcHJlPg0KPHByZT5EbyB5b3UgaGF2ZSBiZXR0ZXIgc3VnZ2VzdGlvbnMg
b24gdG8gaG93IHRvIGNhdGNoIGEgc2VnZmF1bHQgb3JpZ2luYXRpbmcgaW4gYW5vdGhlciBwcm9j
ZXNzIHdpdGhvdXQgbW9kaWZ5aW5nIGVsbD88L3ByZT4NCjxwcmU+PGJyPjwvcHJlPg0KPHByZT5C
ZXN0IHJlZ2FyZHMsPC9wcmU+DQo8cHJlPkluZ2E8L3ByZT4NCjwvYm9keT4NCjwvaHRtbD4NCg==

--===============2922457184646581781==--

