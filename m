Content-Type: multipart/mixed; boundary="===============6868643393416872740=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 2/2] io: Allow socket error to be retrieved on disconnect
Date: Thu, 15 Oct 2020 11:34:14 -0500
Message-ID: <809faa5c-0497-7e70-a922-c7579c7436ce@gmail.com>
In-Reply-To: <9f657a594ca8a814b17d9211946a2777d497b1f0.camel@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6868643393416872740==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Inga,

On 10/14/20 2:04 PM, Stotland, Inga wrote:
> Hi Denis,
> On Tue, 2020-10-13 at 17:25 -0500, Denis Kenzior wrote:
> <snip>
>>
>>>
>>> So the choices as I can see so far:
>>>
>>> 1) If EPOLLIN or EPOLLOUT are raised, allow calling read/write handlers=
 even is
>>> an error condition is encountered. This puts a burden on client
>>> implementation to check for potential errors and may not be very compat=
ible with
>>> the ell-based code that is already out there.
>>>
>>> 2) Keep the logic for read/write handlers, but allow error retrieval in
>>> disconnect handler if it is set (basically, don't close the socket until
>>> disconnect handler is called).
>>> 3) Any suggestions?
>>
>> We could do a combination of 1 & 2: detect EPOLLIN|EPOLLHUP and call the=
 read
>> callback first.  Not sure whether any other combination of EPOLLHUP might
>> happen, but they must be rare.  Then call the disconnect handler and let=
 the
>> client deal with obtaining error conditions if they care to.
> =

> Sounds good.
> =

> Checking EPOLLIN first and , if set, calling read handler unconditionally=
 is =

> easy enough.
> =

> There is one hairy issue with calling disconnect prior to removing or cle=
aring a =

> watch:
> Since ELL cannot prevent a client from calling l_io_destroy from a discon=
nect =

> handler, this may cause an unpredictable behavior =C2=A0in subsequent cal=
l to watch =

> remove/clear.

We've resorted to using a flag marking the object as destroyed for cases li=
ke =

this.  See iwd.git/src/watchlist.h for an example.  It is then used to unwi=
nd =

the callback stack and clean up gracefully.  I think we tried to avoid doin=
g =

this in io.c, but maybe we can't...

> If we preserve fd # locally prior to calling disconnect, this still does =
not =

> address the issue 100%: the same clinet that called l_io_destroy from the =

> disconnect handler may call l_io_new and a new fd may end up with the # t=
hat was =

> just "released".
> And then we will call watch_remove()...

Yes, but there's nothing we can do about that.

> =

> The only way I see around this is to add a strong warning comment to =

> l_io_destroy() that states that calling l_io_destroy directly from a disc=
onnect =

> handler should be done only by using idle_oneshot construct, otherwise, t=
he =

> behavior is not guaranteed. What are your thoughts on this?
> =


I think we can work around the l_io_destroy issue, so I rather not resort t=
o =

requiring l_idle_add.  But, l_idle_add is a valid strategy.  I think it is =
a =

good idea to make the user aware of this strategy in the documentation.

Regards,
-Denis
--===============6868643393416872740==--

