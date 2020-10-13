Content-Type: multipart/mixed; boundary="===============7123702247761259642=="
MIME-Version: 1.0
From: Stotland, Inga <inga.stotland@intel.com>
Subject: Re: [PATCH 2/2] io: Allow socket error to be retrieved on disconnect
Date: Tue, 13 Oct 2020 21:42:48 +0000
Message-ID: <b63d1878fc22804cc5147002d607bd2ea9946c97.camel@intel.com>
In-Reply-To: <508dd0df-3a6e-f229-5b53-03d1cc26e133@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7123702247761259642==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Tue, 2020-10-13 at 13:18 -0500, Denis Kenzior wrote:

Hi Inga,


On 10/12/20 5:13 PM, Inga Stotland wrote:

When encountering an error condition, first invoke disconnect handler

if it is set, and only then clear/remove the watch.


This allows the client to retrieve the the actual code for the socket

error (via getsockopt()). Otherwise, if the socket is closed

prior to invoking disconnect handler, the error code is lost.

---

  ell/io.c | 7 ++++---

  1 file changed, 4 insertions(+), 3 deletions(-)


diff --git a/ell/io.c b/ell/io.c

index 1fa5f0b..169dfb2 100644

--- a/ell/io.c

+++ b/ell/io.c

@@ -102,8 +102,9 @@ static void io_callback(int fd, uint32_t events, void *=
user_data)

        if (unlikely(events & (EPOLLERR | EPOLLHUP))) {

                l_util_debug(io->debug_handler, io->debug_data,

                                                "disconnect event <%p>", io=
);

-               watch_remove(io->fd, !io->close_on_destroy);

+

                io_disconnected(io);

+               watch_remove(io->fd, !io->close_on_destroy);


So you want to obtain ECONNREFUSED from the disconnect handler and not the =
read

handler like glib?


Another potential issue is that EPOLLHUP might come in (when TCP socket is =
EOFed

for example) and there might still be data left in the socket buffer.  So

strictly speaking the read watcher can continue existing, but the write wat=
cher

is no longer settable.  I think we sort of ignored this case since we have =
not

had to deal with connection oriented sockets...

It is my understanding that in glib, a typical  write watch is associated w=
ith EPOLLOUT | EPOLLERR
 and a typical read watch is associated with EPOLLOUT | EPOLLERR |EPOLLHUP

I am not sure we have to follow glib to the letter :), esp since ELL has re=
ad/write and disconnect handlers.

Currently, read and write handlers are invoked only if there's no error con=
dition encountered.
 I assumed that this is a design choice in ELL to simplify client's life: n=
o need to check for error condition
every time read/write handler is invoked.

Also, as the code is implemented currently, an error condition triggers the=
 io closure procedure and we never get to read/write handlers.
As you mentioned, we should at least allow EPOLLIN to be processed...

So the choices as I can see so far:

1) If EPOLLIN or EPOLLOUT are raised, allow calling read/write handlers eve=
n is an error condition is encountered. This puts a burden on client
implementation to check for potential errors and may not be very compatible=
 with the ell-based code that is already out there.

2) Keep the logic for read/write handlers, but allow error retrieval in dis=
connect handler if it is set (basically, don't close the socket until disco=
nnect handler is called).

3) Any suggestions?


BTW, the actual case I am looking at from the user perspective is a situati=
on when the pollfalgs are EPOLLOUT|EPOLLHUP|EPOLLERR
When using GLib, this triggers the write watch with the handler checking fo=
r the error condition.




                return;

        }



@@ -123,8 +124,8 @@ static void io_callback(int fd, uint32_t events, void *=
user_data)



                        if (watch_modify(io->fd, io->events, false) =3D=3D =
-EBADF) {


So this condition is hit when fd was close()-d by the read/write callback...


                                io->close_on_destroy =3D false;

-                               watch_clear(io->fd);

                                io_disconnected(io);

+                               watch_clear(io->fd);


Since in patch 1 your intent is not to invoke the disconnect callback when =
the

client invokes io_destroy, should we treat this part the same way?


Note that since the fd is already closed, I'm not sure invoking io_disconne=
cted

prior to watch_clear makes sense anyway.  The fd is gone and you'll just ge=
t a

-EBADFD.  Better to have io_get_fd return -1.


Agree



                                return;

                        }

                }

@@ -146,8 +147,8 @@ static void io_callback(int fd, uint32_t events, void *=
user_data)



                        if (watch_modify(io->fd, io->events, false) =3D=3D =
-EBADF) {

                                io->close_on_destroy =3D false;

-                               watch_clear(io->fd);

                                io_disconnected(io);

+                               watch_clear(io->fd);


As above


                                return;

                        }

                }



Regards,

-Denis

--===============7123702247761259642==
Content-Type: text/html
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="attachment.htm"

PGh0bWwgZGlyPSJsdHIiPg0KPGhlYWQ+DQo8bWV0YSBodHRwLWVxdWl2PSJDb250ZW50LVR5cGUi
IGNvbnRlbnQ9InRleHQvaHRtbDsgY2hhcnNldD11dGYtOCI+DQo8L2hlYWQ+DQo8Ym9keSBzdHls
ZT0idGV4dC1hbGlnbjpsZWZ0OyBkaXJlY3Rpb246bHRyOyIgYmdjb2xvcj0iI2ZmZmZmZiIgdGV4
dD0iIzJlMzQzNiIgbGluaz0iIzczNzM3MyIgdmxpbms9IiMyZTM0MzYiPg0KPGRpdj5IaSBEZW5p
cyw8L2Rpdj4NCjxkaXY+PGJyPg0KPC9kaXY+DQo8ZGl2Pk9uIFR1ZSwgMjAyMC0xMC0xMyBhdCAx
MzoxOCAtMDUwMCwgRGVuaXMgS2VuemlvciB3cm90ZTo8L2Rpdj4NCjxibG9ja3F1b3RlIHR5cGU9
ImNpdGUiIHN0eWxlPSJtYXJnaW46MCAwIDAgLjhleDsgYm9yZGVyLWxlZnQ6MnB4ICM3MjlmY2Yg
c29saWQ7cGFkZGluZy1sZWZ0OjFleCI+DQo8cHJlPkhpIEluZ2EsPC9wcmU+DQo8cHJlPjxicj48
L3ByZT4NCjxwcmU+T24gMTAvMTIvMjAgNToxMyBQTSwgSW5nYSBTdG90bGFuZCB3cm90ZTo8L3By
ZT4NCjxibG9ja3F1b3RlIHR5cGU9ImNpdGUiIHN0eWxlPSJtYXJnaW46MCAwIDAgLjhleDsgYm9y
ZGVyLWxlZnQ6MnB4ICM3MjlmY2Ygc29saWQ7cGFkZGluZy1sZWZ0OjFleCI+DQo8cHJlPldoZW4g
ZW5jb3VudGVyaW5nIGFuIGVycm9yIGNvbmRpdGlvbiwgZmlyc3QgaW52b2tlIGRpc2Nvbm5lY3Qg
aGFuZGxlcjwvcHJlPg0KPHByZT5pZiBpdCBpcyBzZXQsIGFuZCBvbmx5IHRoZW4gY2xlYXIvcmVt
b3ZlIHRoZSB3YXRjaC48L3ByZT4NCjxwcmU+PGJyPjwvcHJlPg0KPHByZT5UaGlzIGFsbG93cyB0
aGUgY2xpZW50IHRvIHJldHJpZXZlIHRoZSB0aGUgYWN0dWFsIGNvZGUgZm9yIHRoZSBzb2NrZXQ8
L3ByZT4NCjxwcmU+ZXJyb3IgKHZpYSBnZXRzb2Nrb3B0KCkpLiBPdGhlcndpc2UsIGlmIHRoZSBz
b2NrZXQgaXMgY2xvc2VkPC9wcmU+DQo8cHJlPnByaW9yIHRvIGludm9raW5nIGRpc2Nvbm5lY3Qg
aGFuZGxlciwgdGhlIGVycm9yIGNvZGUgaXMgbG9zdC48L3ByZT4NCjxwcmU+LS0tPC9wcmU+DQo8
cHJlPiAgZWxsL2lvLmMgfCA3ICsrKystLS08L3ByZT4NCjxwcmU+ICAxIGZpbGUgY2hhbmdlZCwg
NCBpbnNlcnRpb25zKCspLCAzIGRlbGV0aW9ucygtKTwvcHJlPg0KPHByZT48YnI+PC9wcmU+DQo8
cHJlPmRpZmYgLS1naXQgYS9lbGwvaW8uYyBiL2VsbC9pby5jPC9wcmU+DQo8cHJlPmluZGV4IDFm
YTVmMGIuLjE2OWRmYjIgMTAwNjQ0PC9wcmU+DQo8cHJlPi0tLSBhL2VsbC9pby5jPC9wcmU+DQo8
cHJlPisrKyBiL2VsbC9pby5jPC9wcmU+DQo8cHJlPkBAIC0xMDIsOCArMTAyLDkgQEAgc3RhdGlj
IHZvaWQgaW9fY2FsbGJhY2soaW50IGZkLCB1aW50MzJfdCBldmVudHMsIHZvaWQgKnVzZXJfZGF0
YSk8L3ByZT4NCjxwcmU+ICAJaWYgKHVubGlrZWx5KGV2ZW50cyAmYW1wOyAoRVBPTExFUlIgfCBF
UE9MTEhVUCkpKSB7PC9wcmU+DQo8cHJlPiAgCQlsX3V0aWxfZGVidWcoaW8tJmd0O2RlYnVnX2hh
bmRsZXIsIGlvLSZndDtkZWJ1Z19kYXRhLDwvcHJlPg0KPHByZT4gIAkJCQkJCSZxdW90O2Rpc2Nv
bm5lY3QgZXZlbnQgJmx0OyVwJmd0OyZxdW90OywgaW8pOzwvcHJlPg0KPHByZT4tCQl3YXRjaF9y
ZW1vdmUoaW8tJmd0O2ZkLCAhaW8tJmd0O2Nsb3NlX29uX2Rlc3Ryb3kpOzwvcHJlPg0KPHByZT4r
PC9wcmU+DQo8cHJlPiAgCQlpb19kaXNjb25uZWN0ZWQoaW8pOzwvcHJlPg0KPHByZT4rCQl3YXRj
aF9yZW1vdmUoaW8tJmd0O2ZkLCAhaW8tJmd0O2Nsb3NlX29uX2Rlc3Ryb3kpOzwvcHJlPg0KPC9i
bG9ja3F1b3RlPg0KPHByZT48YnI+PC9wcmU+DQo8cHJlPlNvIHlvdSB3YW50IHRvIG9idGFpbiBF
Q09OTlJFRlVTRUQgZnJvbSB0aGUgZGlzY29ubmVjdCBoYW5kbGVyIGFuZCBub3QgdGhlIHJlYWQg
PC9wcmU+DQo8cHJlPmhhbmRsZXIgbGlrZSBnbGliPzwvcHJlPg0KPHByZT48YnI+PC9wcmU+DQo8
cHJlPkFub3RoZXIgcG90ZW50aWFsIGlzc3VlIGlzIHRoYXQgRVBPTExIVVAgbWlnaHQgY29tZSBp
biAod2hlbiBUQ1Agc29ja2V0IGlzIEVPRmVkIDwvcHJlPg0KPHByZT5mb3IgZXhhbXBsZSkgYW5k
IHRoZXJlIG1pZ2h0IHN0aWxsIGJlIGRhdGEgbGVmdCBpbiB0aGUgc29ja2V0IGJ1ZmZlci4gIFNv
IDwvcHJlPg0KPHByZT5zdHJpY3RseSBzcGVha2luZyB0aGUgcmVhZCB3YXRjaGVyIGNhbiBjb250
aW51ZSBleGlzdGluZywgYnV0IHRoZSB3cml0ZSB3YXRjaGVyIDwvcHJlPg0KPHByZT5pcyBubyBs
b25nZXIgc2V0dGFibGUuICBJIHRoaW5rIHdlIHNvcnQgb2YgaWdub3JlZCB0aGlzIGNhc2Ugc2lu
Y2Ugd2UgaGF2ZSBub3QgPC9wcmU+DQo8cHJlPmhhZCB0byBkZWFsIHdpdGggY29ubmVjdGlvbiBv
cmllbnRlZCBzb2NrZXRzLi4uPC9wcmU+DQo8L2Jsb2NrcXVvdGU+DQo8ZGl2Pjxicj4NCjwvZGl2
Pg0KPGRpdj5JdCBpcyBteSB1bmRlcnN0YW5kaW5nIHRoYXQgaW4gZ2xpYiwgYSB0eXBpY2FsICZu
YnNwO3dyaXRlIHdhdGNoIGlzIGFzc29jaWF0ZWQgd2l0aCBFUE9MTE9VVCB8IEVQT0xMRVJSPC9k
aXY+DQo8ZGl2PiZuYnNwO2FuZCBhIHR5cGljYWwgcmVhZCB3YXRjaCBpcyBhc3NvY2lhdGVkIHdp
dGggRVBPTExPVVQgfCBFUE9MTEVSUiB8RVBPTExIVVA8L2Rpdj4NCjxkaXY+PGJyPg0KPC9kaXY+
DQo8ZGl2PkkgYW0gbm90IHN1cmUgd2UgaGF2ZSB0byBmb2xsb3cgZ2xpYiB0byB0aGUgbGV0dGVy
IDopLCBlc3Agc2luY2UgRUxMIGhhcyByZWFkL3dyaXRlIGFuZCBkaXNjb25uZWN0IGhhbmRsZXJz
LjwvZGl2Pg0KPGRpdj48YnI+DQo8L2Rpdj4NCjxkaXY+Q3VycmVudGx5LCByZWFkIGFuZCB3cml0
ZSBoYW5kbGVycyBhcmUgaW52b2tlZCBvbmx5IGlmIHRoZXJlJ3Mgbm8gZXJyb3IgY29uZGl0aW9u
IGVuY291bnRlcmVkLjwvZGl2Pg0KPGRpdj4mbmJzcDtJIGFzc3VtZWQgdGhhdCB0aGlzIGlzIGEg
ZGVzaWduIGNob2ljZSBpbiBFTEwgdG8gc2ltcGxpZnkgY2xpZW50J3MgbGlmZTogbm8gbmVlZCB0
byBjaGVjayBmb3IgZXJyb3IgY29uZGl0aW9uPC9kaXY+DQo8ZGl2PmV2ZXJ5IHRpbWUgcmVhZC93
cml0ZSBoYW5kbGVyIGlzIGludm9rZWQuPC9kaXY+DQo8ZGl2Pjxicj4NCjwvZGl2Pg0KPGRpdj5B
bHNvLCBhcyB0aGUgY29kZSBpcyBpbXBsZW1lbnRlZCBjdXJyZW50bHksIGFuIGVycm9yIGNvbmRp
dGlvbiB0cmlnZ2VycyB0aGUgaW8gY2xvc3VyZSBwcm9jZWR1cmUgYW5kIHdlIG5ldmVyIGdldCB0
byByZWFkL3dyaXRlIGhhbmRsZXJzLjwvZGl2Pg0KPGRpdj5BcyB5b3UgbWVudGlvbmVkLCB3ZSBz
aG91bGQgYXQgbGVhc3QgYWxsb3cgRVBPTExJTiB0byBiZSBwcm9jZXNzZWQuLi48L2Rpdj4NCjxk
aXY+PGJyPg0KPC9kaXY+DQo8ZGl2PlNvIHRoZSBjaG9pY2VzIGFzIEkgY2FuIHNlZSBzbyBmYXI6
PC9kaXY+DQo8ZGl2Pjxicj4NCjwvZGl2Pg0KPGRpdj4xKSBJZiBFUE9MTElOIG9yIEVQT0xMT1VU
IGFyZSByYWlzZWQsIGFsbG93IGNhbGxpbmcgcmVhZC93cml0ZSBoYW5kbGVycyBldmVuIGlzIGFu
IGVycm9yIGNvbmRpdGlvbiBpcyBlbmNvdW50ZXJlZC4gVGhpcyBwdXRzIGEgYnVyZGVuIG9uIGNs
aWVudDwvZGl2Pg0KPGRpdj5pbXBsZW1lbnRhdGlvbiB0byBjaGVjayBmb3IgcG90ZW50aWFsIGVy
cm9ycyBhbmQgbWF5IG5vdCBiZSB2ZXJ5IGNvbXBhdGlibGUgd2l0aCB0aGUgZWxsLWJhc2VkIGNv
ZGUgdGhhdCBpcyBhbHJlYWR5IG91dCB0aGVyZS48L2Rpdj4NCjxkaXY+PGJyPg0KPC9kaXY+DQo8
ZGl2PjIpIEtlZXAgdGhlIGxvZ2ljIGZvciByZWFkL3dyaXRlIGhhbmRsZXJzLCBidXQgYWxsb3cg
ZXJyb3IgcmV0cmlldmFsIGluIGRpc2Nvbm5lY3QgaGFuZGxlciBpZiBpdCBpcyBzZXQgKGJhc2lj
YWxseSwgZG9uJ3QgY2xvc2UgdGhlIHNvY2tldCB1bnRpbCBkaXNjb25uZWN0IGhhbmRsZXIgaXMg
Y2FsbGVkKS48L2Rpdj4NCjxkaXY+Jm5ic3A7PC9kaXY+DQo8ZGl2PjMpIEFueSBzdWdnZXN0aW9u
cz88L2Rpdj4NCjxkaXY+PGJyPg0KPC9kaXY+DQo8ZGl2Pjxicj4NCjwvZGl2Pg0KPGRpdj4NCjxk
aXY+QlRXLCB0aGUgYWN0dWFsIGNhc2UgSSBhbSBsb29raW5nIGF0IGZyb20gdGhlIHVzZXIgcGVy
c3BlY3RpdmUgaXMgYSBzaXR1YXRpb24gd2hlbiB0aGUgcG9sbGZhbGdzIGFyZSBFUE9MTE9VVHxF
UE9MTEhVUHxFUE9MTEVSUjwvZGl2Pg0KPGRpdj5XaGVuIHVzaW5nIEdMaWIsIHRoaXMgdHJpZ2dl
cnMgdGhlIHdyaXRlIHdhdGNoIHdpdGggdGhlIGhhbmRsZXIgY2hlY2tpbmcgZm9yIHRoZSBlcnJv
ciBjb25kaXRpb24uPC9kaXY+DQo8ZGl2Pjxicj4NCjwvZGl2Pg0KPGRpdj48YnI+DQo8L2Rpdj4N
CjwvZGl2Pg0KPGJsb2NrcXVvdGUgdHlwZT0iY2l0ZSIgc3R5bGU9Im1hcmdpbjowIDAgMCAuOGV4
OyBib3JkZXItbGVmdDoycHggIzcyOWZjZiBzb2xpZDtwYWRkaW5nLWxlZnQ6MWV4Ij4NCjxwcmU+
PGJyPjwvcHJlPg0KPGJsb2NrcXVvdGUgdHlwZT0iY2l0ZSIgc3R5bGU9Im1hcmdpbjowIDAgMCAu
OGV4OyBib3JkZXItbGVmdDoycHggIzcyOWZjZiBzb2xpZDtwYWRkaW5nLWxlZnQ6MWV4Ij4NCjxw
cmU+ICAJCXJldHVybjs8L3ByZT4NCjxwcmU+ICAJfTwvcHJlPg0KPHByZT4gIDwvcHJlPg0KPHBy
ZT5AQCAtMTIzLDggKzEyNCw4IEBAIHN0YXRpYyB2b2lkIGlvX2NhbGxiYWNrKGludCBmZCwgdWlu
dDMyX3QgZXZlbnRzLCB2b2lkICp1c2VyX2RhdGEpPC9wcmU+DQo8cHJlPiAgPC9wcmU+DQo8cHJl
PiAgCQkJaWYgKHdhdGNoX21vZGlmeShpby0mZ3Q7ZmQsIGlvLSZndDtldmVudHMsIGZhbHNlKSA9
PSAtRUJBREYpIHs8L3ByZT4NCjwvYmxvY2txdW90ZT4NCjxwcmU+PGJyPjwvcHJlPg0KPHByZT5T
byB0aGlzIGNvbmRpdGlvbiBpcyBoaXQgd2hlbiBmZCB3YXMgY2xvc2UoKS1kIGJ5IHRoZSByZWFk
L3dyaXRlIGNhbGxiYWNrLi4uPC9wcmU+DQo8cHJlPjxicj48L3ByZT4NCjxibG9ja3F1b3RlIHR5
cGU9ImNpdGUiIHN0eWxlPSJtYXJnaW46MCAwIDAgLjhleDsgYm9yZGVyLWxlZnQ6MnB4ICM3Mjlm
Y2Ygc29saWQ7cGFkZGluZy1sZWZ0OjFleCI+DQo8cHJlPiAgCQkJCWlvLSZndDtjbG9zZV9vbl9k
ZXN0cm95ID0gZmFsc2U7PC9wcmU+DQo8cHJlPi0JCQkJd2F0Y2hfY2xlYXIoaW8tJmd0O2ZkKTs8
L3ByZT4NCjxwcmU+ICAJCQkJaW9fZGlzY29ubmVjdGVkKGlvKTs8L3ByZT4NCjxwcmU+KwkJCQl3
YXRjaF9jbGVhcihpby0mZ3Q7ZmQpOzwvcHJlPg0KPC9ibG9ja3F1b3RlPg0KPHByZT48YnI+PC9w
cmU+DQo8cHJlPlNpbmNlIGluIHBhdGNoIDEgeW91ciBpbnRlbnQgaXMgbm90IHRvIGludm9rZSB0
aGUgZGlzY29ubmVjdCBjYWxsYmFjayB3aGVuIHRoZSA8L3ByZT4NCjxwcmU+Y2xpZW50IGludm9r
ZXMgaW9fZGVzdHJveSwgc2hvdWxkIHdlIHRyZWF0IHRoaXMgcGFydCB0aGUgc2FtZSB3YXk/PC9w
cmU+DQo8cHJlPjxicj48L3ByZT4NCjxwcmU+Tm90ZSB0aGF0IHNpbmNlIHRoZSBmZCBpcyBhbHJl
YWR5IGNsb3NlZCwgSSdtIG5vdCBzdXJlIGludm9raW5nIGlvX2Rpc2Nvbm5lY3RlZCA8L3ByZT4N
CjxwcmU+cHJpb3IgdG8gd2F0Y2hfY2xlYXIgbWFrZXMgc2Vuc2UgYW55d2F5LiAgVGhlIGZkIGlz
IGdvbmUgYW5kIHlvdSdsbCBqdXN0IGdldCBhIDwvcHJlPg0KPHByZT4tRUJBREZELiAgQmV0dGVy
IHRvIGhhdmUgaW9fZ2V0X2ZkIHJldHVybiAtMS48L3ByZT4NCjwvYmxvY2txdW90ZT4NCjxkaXY+
PGJyPg0KPC9kaXY+DQo8ZGl2Pjxicj4NCjwvZGl2Pg0KPGRpdj5BZ3JlZTwvZGl2Pg0KPGRpdj48
YnI+DQo8L2Rpdj4NCjxibG9ja3F1b3RlIHR5cGU9ImNpdGUiIHN0eWxlPSJtYXJnaW46MCAwIDAg
LjhleDsgYm9yZGVyLWxlZnQ6MnB4ICM3MjlmY2Ygc29saWQ7cGFkZGluZy1sZWZ0OjFleCI+DQo8
cHJlPjxicj48L3ByZT4NCjxibG9ja3F1b3RlIHR5cGU9ImNpdGUiIHN0eWxlPSJtYXJnaW46MCAw
IDAgLjhleDsgYm9yZGVyLWxlZnQ6MnB4ICM3MjlmY2Ygc29saWQ7cGFkZGluZy1sZWZ0OjFleCI+
DQo8cHJlPiAgCQkJCXJldHVybjs8L3ByZT4NCjxwcmU+ICAJCQl9PC9wcmU+DQo8cHJlPiAgCQl9
PC9wcmU+DQo8cHJlPkBAIC0xNDYsOCArMTQ3LDggQEAgc3RhdGljIHZvaWQgaW9fY2FsbGJhY2so
aW50IGZkLCB1aW50MzJfdCBldmVudHMsIHZvaWQgKnVzZXJfZGF0YSk8L3ByZT4NCjxwcmU+ICA8
L3ByZT4NCjxwcmU+ICAJCQlpZiAod2F0Y2hfbW9kaWZ5KGlvLSZndDtmZCwgaW8tJmd0O2V2ZW50
cywgZmFsc2UpID09IC1FQkFERikgezwvcHJlPg0KPHByZT4gIAkJCQlpby0mZ3Q7Y2xvc2Vfb25f
ZGVzdHJveSA9IGZhbHNlOzwvcHJlPg0KPHByZT4tCQkJCXdhdGNoX2NsZWFyKGlvLSZndDtmZCk7
PC9wcmU+DQo8cHJlPiAgCQkJCWlvX2Rpc2Nvbm5lY3RlZChpbyk7PC9wcmU+DQo8cHJlPisJCQkJ
d2F0Y2hfY2xlYXIoaW8tJmd0O2ZkKTs8L3ByZT4NCjwvYmxvY2txdW90ZT4NCjxwcmU+PGJyPjwv
cHJlPg0KPHByZT5BcyBhYm92ZTwvcHJlPg0KPHByZT48YnI+PC9wcmU+DQo8YmxvY2txdW90ZSB0
eXBlPSJjaXRlIiBzdHlsZT0ibWFyZ2luOjAgMCAwIC44ZXg7IGJvcmRlci1sZWZ0OjJweCAjNzI5
ZmNmIHNvbGlkO3BhZGRpbmctbGVmdDoxZXgiPg0KPHByZT4gIAkJCQlyZXR1cm47PC9wcmU+DQo8
cHJlPiAgCQkJfTwvcHJlPg0KPHByZT4gIAkJfTwvcHJlPg0KPHByZT48YnI+PC9wcmU+DQo8L2Js
b2NrcXVvdGU+DQo8cHJlPjxicj48L3ByZT4NCjxwcmU+UmVnYXJkcyw8L3ByZT4NCjxwcmU+LURl
bmlzPC9wcmU+DQo8L2Jsb2NrcXVvdGU+DQo8L2JvZHk+DQo8L2h0bWw+DQo=

--===============7123702247761259642==--

