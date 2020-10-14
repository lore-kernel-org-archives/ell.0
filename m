Content-Type: multipart/mixed; boundary="===============0767766495575065217=="
MIME-Version: 1.0
From: Stotland, Inga <inga.stotland@intel.com>
Subject: Re: [PATCH 2/2] io: Allow socket error to be retrieved on disconnect
Date: Wed, 14 Oct 2020 19:04:44 +0000
Message-ID: <9f657a594ca8a814b17d9211946a2777d497b1f0.camel@intel.com>
In-Reply-To: <826bf72b-49f2-ff93-9d85-2185ec876d39@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0767766495575065217==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,
On Tue, 2020-10-13 at 17:25 -0500, Denis Kenzior wrote:
<snip>



So the choices as I can see so far:


1) If EPOLLIN or EPOLLOUT are raised, allow calling read/write handlers eve=
n is

an error condition is encountered. This puts a burden on client

implementation to check for potential errors and may not be very compatible=
 with

the ell-based code that is already out there.


2) Keep the logic for read/write handlers, but allow error retrieval in

disconnect handler if it is set (basically, don't close the socket until

disconnect handler is called).

3) Any suggestions?


We could do a combination of 1 & 2: detect EPOLLIN|EPOLLHUP and call the re=
ad

callback first.  Not sure whether any other combination of EPOLLHUP might

happen, but they must be rare.  Then call the disconnect handler and let the

client deal with obtaining error conditions if they care to.

Sounds good.

Checking EPOLLIN first and , if set, calling read handler unconditionally i=
s easy enough.

There is one hairy issue with calling disconnect prior to removing or clear=
ing a watch:
Since ELL cannot prevent a client from calling l_io_destroy from a disconne=
ct handler, this may cause an unpredictable behavior  in subsequent call to=
 watch remove/clear.
If we preserve fd # locally prior to calling disconnect, this still does no=
t address the issue 100%: the same clinet that called l_io_destroy from the=
 disconnect handler may call l_io_new and a new fd may end up with the # th=
at was just "released".
And then we will call watch_remove()...

The only way I see around this is to add a strong warning comment to l_io_d=
estroy() that states that calling l_io_destroy directly from a disconnect h=
andler should be done only by using idle_oneshot construct, otherwise, the =
behavior is not guaranteed. What are your thoughts on this?






BTW, the actual case I am looking at from the user perspective is a situati=
on

when the pollfalgs are EPOLLOUT|EPOLLHUP|EPOLLERR

When using GLib, this triggers the write watch with the handler checking fo=
r the

error condition.


Curious.  How does that even make sense? EPOLLHUP should mean the other side

closed the socket, so writing to it is rather useless...  I would think EPO=
LLOUT

shouldn't even be set in this case.


I encountered this particular combination with a number of bluez tests (e.g=
., creating a connection with invalid parameters).

Probably has to do with sequence in which the epoll flags are set in those =
cases...


Regards,

Inga

--===============0767766495575065217==
Content-Type: text/html
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="attachment.htm"

PGh0bWwgZGlyPSJsdHIiPg0KPGhlYWQ+DQo8bWV0YSBodHRwLWVxdWl2PSJDb250ZW50LVR5cGUi
IGNvbnRlbnQ9InRleHQvaHRtbDsgY2hhcnNldD11dGYtOCI+DQo8L2hlYWQ+DQo8Ym9keSBzdHls
ZT0idGV4dC1hbGlnbjpsZWZ0OyBkaXJlY3Rpb246bHRyOyIgYmdjb2xvcj0iI2ZmZmZmZiIgdGV4
dD0iIzJlMzQzNiIgbGluaz0iIzczNzM3MyIgdmxpbms9IiMyZTM0MzYiPg0KPGRpdj5IaSBEZW5p
cywmbmJzcDs8L2Rpdj4NCjxkaXY+T24gVHVlLCAyMDIwLTEwLTEzIGF0IDE3OjI1IC0wNTAwLCBE
ZW5pcyBLZW56aW9yIHdyb3RlOjwvZGl2Pg0KPGRpdj4mbHQ7c25pcCZndDs8L2Rpdj4NCjxibG9j
a3F1b3RlIHR5cGU9ImNpdGUiIHN0eWxlPSJtYXJnaW46MCAwIDAgLjhleDsgYm9yZGVyLWxlZnQ6
MnB4ICM3MjlmY2Ygc29saWQ7cGFkZGluZy1sZWZ0OjFleCI+DQo8cHJlPjxicj48L3ByZT4NCjxi
bG9ja3F1b3RlIHR5cGU9ImNpdGUiIHN0eWxlPSJtYXJnaW46MCAwIDAgLjhleDsgYm9yZGVyLWxl
ZnQ6MnB4ICM3MjlmY2Ygc29saWQ7cGFkZGluZy1sZWZ0OjFleCI+DQo8cHJlPjxicj48L3ByZT4N
CjxwcmU+U28gdGhlIGNob2ljZXMgYXMgSSBjYW4gc2VlIHNvIGZhcjo8L3ByZT4NCjxwcmU+PGJy
PjwvcHJlPg0KPHByZT4xKSBJZiBFUE9MTElOIG9yIEVQT0xMT1VUIGFyZSByYWlzZWQsIGFsbG93
IGNhbGxpbmcgcmVhZC93cml0ZSBoYW5kbGVycyBldmVuIGlzIDwvcHJlPg0KPHByZT5hbiBlcnJv
ciBjb25kaXRpb24gaXMgZW5jb3VudGVyZWQuIFRoaXMgcHV0cyBhIGJ1cmRlbiBvbiBjbGllbnQ8
L3ByZT4NCjxwcmU+aW1wbGVtZW50YXRpb24gdG8gY2hlY2sgZm9yIHBvdGVudGlhbCBlcnJvcnMg
YW5kIG1heSBub3QgYmUgdmVyeSBjb21wYXRpYmxlIHdpdGggPC9wcmU+DQo8cHJlPnRoZSBlbGwt
YmFzZWQgY29kZSB0aGF0IGlzIGFscmVhZHkgb3V0IHRoZXJlLjwvcHJlPg0KPHByZT48YnI+PC9w
cmU+DQo8cHJlPjIpIEtlZXAgdGhlIGxvZ2ljIGZvciByZWFkL3dyaXRlIGhhbmRsZXJzLCBidXQg
YWxsb3cgZXJyb3IgcmV0cmlldmFsIGluIDwvcHJlPg0KPHByZT5kaXNjb25uZWN0IGhhbmRsZXIg
aWYgaXQgaXMgc2V0IChiYXNpY2FsbHksIGRvbid0IGNsb3NlIHRoZSBzb2NrZXQgdW50aWwgPC9w
cmU+DQo8cHJlPmRpc2Nvbm5lY3QgaGFuZGxlciBpcyBjYWxsZWQpLjwvcHJlPg0KPHByZT4zKSBB
bnkgc3VnZ2VzdGlvbnM/PC9wcmU+DQo8L2Jsb2NrcXVvdGU+DQo8cHJlPjxicj48L3ByZT4NCjxw
cmU+V2UgY291bGQgZG8gYSBjb21iaW5hdGlvbiBvZiAxICZhbXA7IDI6IGRldGVjdCBFUE9MTElO
fEVQT0xMSFVQIGFuZCBjYWxsIHRoZSByZWFkIDwvcHJlPg0KPHByZT5jYWxsYmFjayBmaXJzdC4g
IE5vdCBzdXJlIHdoZXRoZXIgYW55IG90aGVyIGNvbWJpbmF0aW9uIG9mIEVQT0xMSFVQIG1pZ2h0
IDwvcHJlPg0KPHByZT5oYXBwZW4sIGJ1dCB0aGV5IG11c3QgYmUgcmFyZS4gIFRoZW4gY2FsbCB0
aGUgZGlzY29ubmVjdCBoYW5kbGVyIGFuZCBsZXQgdGhlIDwvcHJlPg0KPHByZT5jbGllbnQgZGVh
bCB3aXRoIG9idGFpbmluZyBlcnJvciBjb25kaXRpb25zIGlmIHRoZXkgY2FyZSB0by48L3ByZT4N
CjwvYmxvY2txdW90ZT4NCjxkaXY+PGJyPg0KPC9kaXY+DQo8ZGl2PlNvdW5kcyBnb29kLjwvZGl2
Pg0KPGRpdj48YnI+DQo8L2Rpdj4NCjxkaXY+Q2hlY2tpbmcgRVBPTExJTiBmaXJzdCBhbmQgLCBp
ZiBzZXQsIGNhbGxpbmcgcmVhZCBoYW5kbGVyIHVuY29uZGl0aW9uYWxseSBpcyBlYXN5IGVub3Vn
aC48L2Rpdj4NCjxkaXY+PGJyPg0KPC9kaXY+DQo8ZGl2PlRoZXJlIGlzIG9uZSBoYWlyeSBpc3N1
ZSB3aXRoIGNhbGxpbmcgZGlzY29ubmVjdCBwcmlvciB0byByZW1vdmluZyBvciBjbGVhcmluZyBh
IHdhdGNoOjwvZGl2Pg0KPGRpdj5TaW5jZSBFTEwgY2Fubm90IHByZXZlbnQgYSBjbGllbnQgZnJv
bSBjYWxsaW5nIGxfaW9fZGVzdHJveSBmcm9tIGEgZGlzY29ubmVjdCBoYW5kbGVyLCB0aGlzIG1h
eSBjYXVzZSBhbiB1bnByZWRpY3RhYmxlIGJlaGF2aW9yICZuYnNwO2luIHN1YnNlcXVlbnQgY2Fs
bCB0byB3YXRjaCByZW1vdmUvY2xlYXIuPC9kaXY+DQo8ZGl2PklmIHdlIHByZXNlcnZlIGZkICMg
bG9jYWxseSBwcmlvciB0byBjYWxsaW5nIGRpc2Nvbm5lY3QsIHRoaXMgc3RpbGwgZG9lcyBub3Qg
YWRkcmVzcyB0aGUgaXNzdWUgMTAwJTogdGhlIHNhbWUgY2xpbmV0IHRoYXQgY2FsbGVkIGxfaW9f
ZGVzdHJveSBmcm9tIHRoZSBkaXNjb25uZWN0IGhhbmRsZXIgbWF5IGNhbGwgbF9pb19uZXcgYW5k
IGEgbmV3IGZkIG1heSBlbmQgdXAgd2l0aCB0aGUgIyB0aGF0IHdhcyBqdXN0ICZxdW90O3JlbGVh
c2VkJnF1b3Q7LjwvZGl2Pg0KPGRpdj5BbmQgdGhlbiB3ZSB3aWxsIGNhbGwgd2F0Y2hfcmVtb3Zl
KCkuLi4mbmJzcDs8L2Rpdj4NCjxkaXY+PGJyPg0KPC9kaXY+DQo8ZGl2PlRoZSBvbmx5IHdheSBJ
IHNlZSBhcm91bmQgdGhpcyBpcyB0byBhZGQgYSBzdHJvbmcgd2FybmluZyBjb21tZW50IHRvIGxf
aW9fZGVzdHJveSgpIHRoYXQgc3RhdGVzIHRoYXQgY2FsbGluZyBsX2lvX2Rlc3Ryb3kgZGlyZWN0
bHkgZnJvbSBhIGRpc2Nvbm5lY3QgaGFuZGxlciBzaG91bGQgYmUgZG9uZSBvbmx5IGJ5IHVzaW5n
IGlkbGVfb25lc2hvdCBjb25zdHJ1Y3QsIG90aGVyd2lzZSwgdGhlIGJlaGF2aW9yIGlzIG5vdCBn
dWFyYW50ZWVkLg0KIFdoYXQgYXJlIHlvdXIgdGhvdWdodHMgb24gdGhpcz88L2Rpdj4NCjxkaXY+
PGJyPg0KPC9kaXY+DQo8ZGl2Pjxicj4NCjwvZGl2Pg0KPGJsb2NrcXVvdGUgdHlwZT0iY2l0ZSIg
c3R5bGU9Im1hcmdpbjowIDAgMCAuOGV4OyBib3JkZXItbGVmdDoycHggIzcyOWZjZiBzb2xpZDtw
YWRkaW5nLWxlZnQ6MWV4Ij4NCjxwcmU+PGJyPjwvcHJlPg0KPGJsb2NrcXVvdGUgdHlwZT0iY2l0
ZSIgc3R5bGU9Im1hcmdpbjowIDAgMCAuOGV4OyBib3JkZXItbGVmdDoycHggIzcyOWZjZiBzb2xp
ZDtwYWRkaW5nLWxlZnQ6MWV4Ij4NCjxwcmU+PGJyPjwvcHJlPg0KPHByZT48YnI+PC9wcmU+DQo8
cHJlPkJUVywgdGhlIGFjdHVhbCBjYXNlIEkgYW0gbG9va2luZyBhdCBmcm9tIHRoZSB1c2VyIHBl
cnNwZWN0aXZlIGlzIGEgc2l0dWF0aW9uIDwvcHJlPg0KPHByZT53aGVuIHRoZSBwb2xsZmFsZ3Mg
YXJlIEVQT0xMT1VUfEVQT0xMSFVQfEVQT0xMRVJSPC9wcmU+DQo8cHJlPldoZW4gdXNpbmcgR0xp
YiwgdGhpcyB0cmlnZ2VycyB0aGUgd3JpdGUgd2F0Y2ggd2l0aCB0aGUgaGFuZGxlciBjaGVja2lu
ZyBmb3IgdGhlIDwvcHJlPg0KPHByZT5lcnJvciBjb25kaXRpb24uPC9wcmU+DQo8L2Jsb2NrcXVv
dGU+DQo8cHJlPjxicj48L3ByZT4NCjxwcmU+Q3VyaW91cy4gIEhvdyBkb2VzIHRoYXQgZXZlbiBt
YWtlIHNlbnNlPyBFUE9MTEhVUCBzaG91bGQgbWVhbiB0aGUgb3RoZXIgc2lkZSA8L3ByZT4NCjxw
cmU+Y2xvc2VkIHRoZSBzb2NrZXQsIHNvIHdyaXRpbmcgdG8gaXQgaXMgcmF0aGVyIHVzZWxlc3Mu
Li4gIEkgd291bGQgdGhpbmsgRVBPTExPVVQgPC9wcmU+DQo8cHJlPnNob3VsZG4ndCBldmVuIGJl
IHNldCBpbiB0aGlzIGNhc2UuPC9wcmU+DQo8L2Jsb2NrcXVvdGU+DQo8cHJlPjxicj48L3ByZT4N
CjxwcmU+SSBlbmNvdW50ZXJlZCB0aGlzIHBhcnRpY3VsYXIgY29tYmluYXRpb24gd2l0aCBhIG51
bWJlciBvZiBibHVleiB0ZXN0cyAoZS5nLiwgY3JlYXRpbmcgYSBjb25uZWN0aW9uIHdpdGggaW52
YWxpZCBwYXJhbWV0ZXJzKS48L3ByZT4NCjxwcmU+UHJvYmFibHkgaGFzIHRvIGRvIHdpdGggc2Vx
dWVuY2UgaW4gd2hpY2ggdGhlIGVwb2xsIGZsYWdzIGFyZSBzZXQgaW4gdGhvc2UgY2FzZXMuLi48
L3ByZT4NCjxwcmU+PGJyPjwvcHJlPg0KPHByZT5SZWdhcmRzLDwvcHJlPg0KPHByZT5JbmdhPC9w
cmU+DQo8L2JvZHk+DQo8L2h0bWw+DQo=

--===============0767766495575065217==--

