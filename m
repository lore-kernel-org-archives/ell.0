Content-Type: multipart/mixed; boundary="===============3936325683725918541=="
MIME-Version: 1.0
From: Stotland, Inga <inga.stotland@intel.com>
Subject: Re: [PATCH] [RFC PATCH] tester: Add framework for serialized test
 execution
Date: Tue, 09 Mar 2021 02:59:57 +0000
Message-ID: <81c964f66527a43023e0c973afc814b51ddea3be.camel@intel.com>
In-Reply-To: <36d7f7a7-c4d6-eff3-66cd-4654bfe96dcd@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3936325683725918541==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Mon, 2021-03-08 at 16:19 -0600, Denis Kenzior wrote:

Hi Inga,


On 3/5/21 3:37 PM, Inga Stotland wrote:

This adds a framework for running series of noninteractive tests

that are capable of executing more complex scenarios than a usual unit

test.


The framework enables staging of a test case processing:

- test pre-setup: can be used to prepare an initial testing environment

                   potentially common to between several test cases, e.g.,

                  put an emulator in a certain well known state.

- test setup: used to setup conditions specific for the test case

- test run: execute actual test case

- test teardown: Cleans up after test setup

- test post-teardown: Cleans up after test pre-setup


Additional command line options allow to run a selected group of tests

based either on a group prefix of the test name or a substring in test

description.

---

  Makefile.am  |   6 +-

  ell/tester.c | 786 +++++++++++++++++++++++++++++++++++++++++++++++++++

  ell/tester.h |  94 ++++++


Hmm, ell.sym entries?


  3 files changed, 884 insertions(+), 2 deletions(-)

  create mode 100644 ell/tester.c

  create mode 100644 ell/tester.h



<snip>


+

+static char *tester_name;

+

+static struct l_queue *test_list;

+static const struct l_queue_entry *test_entry;

+static struct timeval tester_start;

+

+static bool option_list;

+static const char *option_prefix;

+static const char *option_string;

+

+static bool terminated;

+


Curious.  This tester framework is part of the main ell library, so I would=
 have

assumed it is a 'class' so to speak.  But you use static vars here.  So is

l_tester only used from a dedicated binary?


If not, do the l_tester_* signatures need to be updated to take an l_tester

instance and appropriate constructors / destructors defined?


<snip>


+

+void *l_tester_get_data(void)


LIB_EXPORT?


+{

+       struct test_case *test;

+

+       if (!test_entry)

+               return NULL;

+

+       test =3D test_entry->data;

+

+       return test->user_data;

+}

+

+static double get_elapsed_time(struct timeval *base)

+{

+       static struct timeval now, elapsed;

+

+       gettimeofday(&now, NULL);

+       timersub(&now, base, &elapsed);

+


Have you considered using l_time* from ell/time.h?


+       return elapsed.tv_sec + ((double) elapsed.tv_usec) / 1000000;

+}

+


<snip>


The rest of the code seems straightforward and nothing else really jumped o=
ut at me.


Regards,

-Denis


Thanks for reviewing. Will work on v2.

Regards,

Inga

--===============3936325683725918541==
Content-Type: text/html
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="attachment.htm"

PGh0bWwgZGlyPSJsdHIiPg0KPGhlYWQ+DQo8bWV0YSBodHRwLWVxdWl2PSJDb250ZW50LVR5cGUi
IGNvbnRlbnQ9InRleHQvaHRtbDsgY2hhcnNldD11dGYtOCI+DQo8L2hlYWQ+DQo8Ym9keSBzdHls
ZT0idGV4dC1hbGlnbjpsZWZ0OyBkaXJlY3Rpb246bHRyOyIgYmdjb2xvcj0iI2ZmZmZmZiIgdGV4
dD0iIzJlMzQzNiIgbGluaz0iIzczNzM3MyIgdmxpbms9IiMyZTM0MzYiPg0KPGRpdj5IaSBEZW5p
cyw8L2Rpdj4NCjxkaXY+PGJyPg0KPC9kaXY+DQo8ZGl2Pk9uIE1vbiwgMjAyMS0wMy0wOCBhdCAx
NjoxOSAtMDYwMCwgRGVuaXMgS2VuemlvciB3cm90ZTo8L2Rpdj4NCjxibG9ja3F1b3RlIHR5cGU9
ImNpdGUiIHN0eWxlPSJtYXJnaW46MCAwIDAgLjhleDsgYm9yZGVyLWxlZnQ6MnB4ICM3MjlmY2Yg
c29saWQ7cGFkZGluZy1sZWZ0OjFleCI+DQo8cHJlPkhpIEluZ2EsPC9wcmU+DQo8cHJlPjxicj48
L3ByZT4NCjxwcmU+T24gMy81LzIxIDM6MzcgUE0sIEluZ2EgU3RvdGxhbmQgd3JvdGU6PC9wcmU+
DQo8YmxvY2txdW90ZSB0eXBlPSJjaXRlIiBzdHlsZT0ibWFyZ2luOjAgMCAwIC44ZXg7IGJvcmRl
ci1sZWZ0OjJweCAjNzI5ZmNmIHNvbGlkO3BhZGRpbmctbGVmdDoxZXgiPg0KPHByZT5UaGlzIGFk
ZHMgYSBmcmFtZXdvcmsgZm9yIHJ1bm5pbmcgc2VyaWVzIG9mIG5vbmludGVyYWN0aXZlIHRlc3Rz
PC9wcmU+DQo8cHJlPnRoYXQgYXJlIGNhcGFibGUgb2YgZXhlY3V0aW5nIG1vcmUgY29tcGxleCBz
Y2VuYXJpb3MgdGhhbiBhIHVzdWFsIHVuaXQ8L3ByZT4NCjxwcmU+dGVzdC48L3ByZT4NCjxwcmU+
PGJyPjwvcHJlPg0KPHByZT5UaGUgZnJhbWV3b3JrIGVuYWJsZXMgc3RhZ2luZyBvZiBhIHRlc3Qg
Y2FzZSBwcm9jZXNzaW5nOjwvcHJlPg0KPHByZT4tIHRlc3QgcHJlLXNldHVwOiBjYW4gYmUgdXNl
ZCB0byBwcmVwYXJlIGFuIGluaXRpYWwgdGVzdGluZyBlbnZpcm9ubWVudDwvcHJlPg0KPHByZT4g
ICAgICAgICAgICAgICAgICAgcG90ZW50aWFsbHkgY29tbW9uIHRvIGJldHdlZW4gc2V2ZXJhbCB0
ZXN0IGNhc2VzLCBlLmcuLDwvcHJlPg0KPHByZT4JCSAgcHV0IGFuIGVtdWxhdG9yIGluIGEgY2Vy
dGFpbiB3ZWxsIGtub3duIHN0YXRlLjwvcHJlPg0KPHByZT4tIHRlc3Qgc2V0dXA6IHVzZWQgdG8g
c2V0dXAgY29uZGl0aW9ucyBzcGVjaWZpYyBmb3IgdGhlIHRlc3QgY2FzZTwvcHJlPg0KPHByZT4t
IHRlc3QgcnVuOiBleGVjdXRlIGFjdHVhbCB0ZXN0IGNhc2U8L3ByZT4NCjxwcmU+LSB0ZXN0IHRl
YXJkb3duOiBDbGVhbnMgdXAgYWZ0ZXIgdGVzdCBzZXR1cDwvcHJlPg0KPHByZT4tIHRlc3QgcG9z
dC10ZWFyZG93bjogQ2xlYW5zIHVwIGFmdGVyIHRlc3QgcHJlLXNldHVwPC9wcmU+DQo8cHJlPjxi
cj48L3ByZT4NCjxwcmU+QWRkaXRpb25hbCBjb21tYW5kIGxpbmUgb3B0aW9ucyBhbGxvdyB0byBy
dW4gYSBzZWxlY3RlZCBncm91cCBvZiB0ZXN0czwvcHJlPg0KPHByZT5iYXNlZCBlaXRoZXIgb24g
YSBncm91cCBwcmVmaXggb2YgdGhlIHRlc3QgbmFtZSBvciBhIHN1YnN0cmluZyBpbiB0ZXN0PC9w
cmU+DQo8cHJlPmRlc2NyaXB0aW9uLjwvcHJlPg0KPHByZT4tLS08L3ByZT4NCjxwcmU+ICBNYWtl
ZmlsZS5hbSAgfCAgIDYgKy08L3ByZT4NCjxwcmU+ICBlbGwvdGVzdGVyLmMgfCA3ODYgKysrKysr
KysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrPC9wcmU+DQo8cHJl
PiAgZWxsL3Rlc3Rlci5oIHwgIDk0ICsrKysrKzwvcHJlPg0KPC9ibG9ja3F1b3RlPg0KPHByZT48
YnI+PC9wcmU+DQo8cHJlPkhtbSwgZWxsLnN5bSBlbnRyaWVzPzwvcHJlPg0KPHByZT48YnI+PC9w
cmU+DQo8YmxvY2txdW90ZSB0eXBlPSJjaXRlIiBzdHlsZT0ibWFyZ2luOjAgMCAwIC44ZXg7IGJv
cmRlci1sZWZ0OjJweCAjNzI5ZmNmIHNvbGlkO3BhZGRpbmctbGVmdDoxZXgiPg0KPHByZT4gIDMg
ZmlsZXMgY2hhbmdlZCwgODg0IGluc2VydGlvbnMoKyksIDIgZGVsZXRpb25zKC0pPC9wcmU+DQo8
cHJlPiAgY3JlYXRlIG1vZGUgMTAwNjQ0IGVsbC90ZXN0ZXIuYzwvcHJlPg0KPHByZT4gIGNyZWF0
ZSBtb2RlIDEwMDY0NCBlbGwvdGVzdGVyLmg8L3ByZT4NCjxwcmU+PGJyPjwvcHJlPg0KPC9ibG9j
a3F1b3RlPg0KPHByZT48YnI+PC9wcmU+DQo8cHJlPiZsdDtzbmlwJmd0OzwvcHJlPg0KPHByZT48
YnI+PC9wcmU+DQo8YmxvY2txdW90ZSB0eXBlPSJjaXRlIiBzdHlsZT0ibWFyZ2luOjAgMCAwIC44
ZXg7IGJvcmRlci1sZWZ0OjJweCAjNzI5ZmNmIHNvbGlkO3BhZGRpbmctbGVmdDoxZXgiPg0KPHBy
ZT4rPC9wcmU+DQo8cHJlPitzdGF0aWMgY2hhciAqdGVzdGVyX25hbWU7PC9wcmU+DQo8cHJlPis8
L3ByZT4NCjxwcmU+K3N0YXRpYyBzdHJ1Y3QgbF9xdWV1ZSAqdGVzdF9saXN0OzwvcHJlPg0KPHBy
ZT4rc3RhdGljIGNvbnN0IHN0cnVjdCBsX3F1ZXVlX2VudHJ5ICp0ZXN0X2VudHJ5OzwvcHJlPg0K
PHByZT4rc3RhdGljIHN0cnVjdCB0aW1ldmFsIHRlc3Rlcl9zdGFydDs8L3ByZT4NCjxwcmU+Kzwv
cHJlPg0KPHByZT4rc3RhdGljIGJvb2wgb3B0aW9uX2xpc3Q7PC9wcmU+DQo8cHJlPitzdGF0aWMg
Y29uc3QgY2hhciAqb3B0aW9uX3ByZWZpeDs8L3ByZT4NCjxwcmU+K3N0YXRpYyBjb25zdCBjaGFy
ICpvcHRpb25fc3RyaW5nOzwvcHJlPg0KPHByZT4rPC9wcmU+DQo8cHJlPitzdGF0aWMgYm9vbCB0
ZXJtaW5hdGVkOzwvcHJlPg0KPHByZT4rPC9wcmU+DQo8L2Jsb2NrcXVvdGU+DQo8cHJlPjxicj48
L3ByZT4NCjxwcmU+Q3VyaW91cy4gIFRoaXMgdGVzdGVyIGZyYW1ld29yayBpcyBwYXJ0IG9mIHRo
ZSBtYWluIGVsbCBsaWJyYXJ5LCBzbyBJIHdvdWxkIGhhdmUgPC9wcmU+DQo8cHJlPmFzc3VtZWQg
aXQgaXMgYSAnY2xhc3MnIHNvIHRvIHNwZWFrLiAgQnV0IHlvdSB1c2Ugc3RhdGljIHZhcnMgaGVy
ZS4gIFNvIGlzIDwvcHJlPg0KPHByZT5sX3Rlc3RlciBvbmx5IHVzZWQgZnJvbSBhIGRlZGljYXRl
ZCBiaW5hcnk/PC9wcmU+DQo8cHJlPjxicj48L3ByZT4NCjxwcmU+SWYgbm90LCBkbyB0aGUgbF90
ZXN0ZXJfKiBzaWduYXR1cmVzIG5lZWQgdG8gYmUgdXBkYXRlZCB0byB0YWtlIGFuIGxfdGVzdGVy
IDwvcHJlPg0KPHByZT5pbnN0YW5jZSBhbmQgYXBwcm9wcmlhdGUgY29uc3RydWN0b3JzIC8gZGVz
dHJ1Y3RvcnMgZGVmaW5lZD88L3ByZT4NCjxwcmU+PGJyPjwvcHJlPg0KPHByZT4mbHQ7c25pcCZn
dDs8L3ByZT4NCjxwcmU+PGJyPjwvcHJlPg0KPGJsb2NrcXVvdGUgdHlwZT0iY2l0ZSIgc3R5bGU9
Im1hcmdpbjowIDAgMCAuOGV4OyBib3JkZXItbGVmdDoycHggIzcyOWZjZiBzb2xpZDtwYWRkaW5n
LWxlZnQ6MWV4Ij4NCjxwcmU+KzwvcHJlPg0KPHByZT4rdm9pZCAqbF90ZXN0ZXJfZ2V0X2RhdGEo
dm9pZCk8L3ByZT4NCjwvYmxvY2txdW90ZT4NCjxwcmU+PGJyPjwvcHJlPg0KPHByZT5MSUJfRVhQ
T1JUPzwvcHJlPg0KPHByZT48YnI+PC9wcmU+DQo8YmxvY2txdW90ZSB0eXBlPSJjaXRlIiBzdHls
ZT0ibWFyZ2luOjAgMCAwIC44ZXg7IGJvcmRlci1sZWZ0OjJweCAjNzI5ZmNmIHNvbGlkO3BhZGRp
bmctbGVmdDoxZXgiPg0KPHByZT4rezwvcHJlPg0KPHByZT4rCXN0cnVjdCB0ZXN0X2Nhc2UgKnRl
c3Q7PC9wcmU+DQo8cHJlPis8L3ByZT4NCjxwcmU+KwlpZiAoIXRlc3RfZW50cnkpPC9wcmU+DQo8
cHJlPisJCXJldHVybiBOVUxMOzwvcHJlPg0KPHByZT4rPC9wcmU+DQo8cHJlPisJdGVzdCA9IHRl
c3RfZW50cnktJmd0O2RhdGE7PC9wcmU+DQo8cHJlPis8L3ByZT4NCjxwcmU+KwlyZXR1cm4gdGVz
dC0mZ3Q7dXNlcl9kYXRhOzwvcHJlPg0KPHByZT4rfTwvcHJlPg0KPHByZT4rPC9wcmU+DQo8cHJl
PitzdGF0aWMgZG91YmxlIGdldF9lbGFwc2VkX3RpbWUoc3RydWN0IHRpbWV2YWwgKmJhc2UpPC9w
cmU+DQo8cHJlPit7PC9wcmU+DQo8cHJlPisJc3RhdGljIHN0cnVjdCB0aW1ldmFsIG5vdywgZWxh
cHNlZDs8L3ByZT4NCjxwcmU+KzwvcHJlPg0KPHByZT4rCWdldHRpbWVvZmRheSgmYW1wO25vdywg
TlVMTCk7PC9wcmU+DQo8cHJlPisJdGltZXJzdWIoJmFtcDtub3csIGJhc2UsICZhbXA7ZWxhcHNl
ZCk7PC9wcmU+DQo8cHJlPis8L3ByZT4NCjwvYmxvY2txdW90ZT4NCjxwcmU+PGJyPjwvcHJlPg0K
PHByZT5IYXZlIHlvdSBjb25zaWRlcmVkIHVzaW5nIGxfdGltZSogZnJvbSBlbGwvdGltZS5oPzwv
cHJlPg0KPHByZT48YnI+PC9wcmU+DQo8YmxvY2txdW90ZSB0eXBlPSJjaXRlIiBzdHlsZT0ibWFy
Z2luOjAgMCAwIC44ZXg7IGJvcmRlci1sZWZ0OjJweCAjNzI5ZmNmIHNvbGlkO3BhZGRpbmctbGVm
dDoxZXgiPg0KPHByZT4rCXJldHVybiBlbGFwc2VkLnR2X3NlYyArICgoZG91YmxlKSBlbGFwc2Vk
LnR2X3VzZWMpIC8gMTAwMDAwMDs8L3ByZT4NCjxwcmU+K308L3ByZT4NCjxwcmU+KzwvcHJlPg0K
PC9ibG9ja3F1b3RlPg0KPHByZT48YnI+PC9wcmU+DQo8cHJlPiZsdDtzbmlwJmd0OzwvcHJlPg0K
PHByZT48YnI+PC9wcmU+DQo8cHJlPlRoZSByZXN0IG9mIHRoZSBjb2RlIHNlZW1zIHN0cmFpZ2h0
Zm9yd2FyZCBhbmQgbm90aGluZyBlbHNlIHJlYWxseSBqdW1wZWQgb3V0IGF0IG1lLjwvcHJlPg0K
PHByZT48YnI+PC9wcmU+DQo8cHJlPlJlZ2FyZHMsPC9wcmU+DQo8cHJlPi1EZW5pczwvcHJlPg0K
PC9ibG9ja3F1b3RlPg0KPGRpdj48YnI+DQo8L2Rpdj4NCjxkaXY+PGJyPg0KPC9kaXY+DQo8ZGl2
PlRoYW5rcyBmb3IgcmV2aWV3aW5nLiBXaWxsIHdvcmsgb24gdjIuPC9kaXY+DQo8ZGl2Pjxicj4N
CjwvZGl2Pg0KPGRpdj5SZWdhcmRzLDwvZGl2Pg0KPGRpdj48YnI+DQo8L2Rpdj4NCjxkaXY+SW5n
YTwvZGl2Pg0KPC9ib2R5Pg0KPC9odG1sPg0K

--===============3936325683725918541==--

