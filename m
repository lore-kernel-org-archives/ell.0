Content-Type: multipart/mixed; boundary="===============0774687994677725653=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 2/2] io: Allow socket error to be retrieved on disconnect
Date: Tue, 13 Oct 2020 17:25:41 -0500
Message-ID: <826bf72b-49f2-ff93-9d85-2185ec876d39@gmail.com>
In-Reply-To: <b63d1878fc22804cc5147002d607bd2ea9946c97.camel@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0774687994677725653==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Inga,

<snip>

>> So you want to obtain ECONNREFUSED from the disconnect handler and not t=
he read
>> handler like glib?
>>
>> Another potential issue is that EPOLLHUP might come in (when TCP socket =
is EOFed
>> for example) and there might still be data left in the socket buffer.  So
>> strictly speaking the read watcher can continue existing, but the write =
watcher
>> is no longer settable.  I think we sort of ignored this case since we ha=
ve not
>> had to deal with connection oriented sockets...
> =

> It is my understanding that in glib, a typical =C2=A0write watch is assoc=
iated with =

> EPOLLOUT | EPOLLERR
>  =C2=A0and a typical read watch is associated with EPOLLOUT | EPOLLERR |E=
POLLHUP
> =


Right.  Probably to catch the HUP.

> I am not sure we have to follow glib to the letter :), esp since ELL has =

> read/write and disconnect handlers.

That's fine with me.  Just pointing out the possibility that this can happe=
n.  I =

think by custom we try to drain all data from a socket in a read_watch call=
back. =

  But this might not always be possible.
> =

> Currently, read and write handlers are invoked only if there's no error =

> condition encountered.
>  =C2=A0I assumed that this is a design choice in ELL to simplify client's=
 life: no =

> need to check for error condition
> every time read/write handler is invoked.

Right.

> =

> Also, as the code is implemented currently, an error condition triggers t=
he io =

> closure procedure and we never get to read/write handlers.
> As you mentioned, we should at least allow EPOLLIN to be processed...

Right.  I think in theory it is possible to have both EPOLLIN and EPOLLHUP =
set.

> =

> So the choices as I can see so far:
> =

> 1) If EPOLLIN or EPOLLOUT are raised, allow calling read/write handlers e=
ven is =

> an error condition is encountered. This puts a burden on client
> implementation to check for potential errors and may not be very compatib=
le with =

> the ell-based code that is already out there.
> =

> 2) Keep the logic for read/write handlers, but allow error retrieval in =

> disconnect handler if it is set (basically, don't close the socket until =

> disconnect handler is called).
> 3) Any suggestions?

We could do a combination of 1 & 2: detect EPOLLIN|EPOLLHUP and call the re=
ad =

callback first.  Not sure whether any other combination of EPOLLHUP might =

happen, but they must be rare.  Then call the disconnect handler and let th=
e =

client deal with obtaining error conditions if they care to.

> =

> =

> BTW, the actual case I am looking at from the user perspective is a situa=
tion =

> when the pollfalgs are EPOLLOUT|EPOLLHUP|EPOLLERR
> When using GLib, this triggers the write watch with the handler checking =
for the =

> error condition.

Curious.  How does that even make sense? EPOLLHUP should mean the other sid=
e =

closed the socket, so writing to it is rather useless...  I would think EPO=
LLOUT =

shouldn't even be set in this case.

Regards,
-Denis
--===============0774687994677725653==--

