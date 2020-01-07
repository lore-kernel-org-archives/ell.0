Content-Type: multipart/mixed; boundary="===============6421393958378751464=="
MIME-Version: 1.0
From: Gix, Brian <brian.gix@intel.com>
Subject: Re: Warn-to-error on -Werror=cast-align
Date: Tue, 07 Jan 2020 18:07:50 +0000
Message-ID: <6018104577b417880e4cb4bf828a300be0ea1f2b.camel@intel.com>
In-Reply-To: <d9685ec4-7e07-32c7-6672-8cba31f46d87@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6421393958378751464==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Tue, 2020-01-07 at 11:56 -0600, Denis Kenzior wrote:
> Hi Brian,
> =

> > So because super is the first member, the "recovered container pointer"=
 should *always* be equal to the
> > original pointer, and because the structure is *private to ell/dbus.c*,=
 we can work around this warning by
> > not
> > using l_container_of(), and instead simply casting the point directly i=
n the 4 places the macro is used.
> > The
> > only time this would not work is if a compiler decides to re-arrange th=
e members of the container
> > structure.
> =

> Unless of course the compiler decides to reorder the structure elements =

> somehow.  So you'd also need to make the structure packed or play some =

> other tricks and hope no-one rearranges the structure in the future.
> =

> Also, l_container_of is used in iwd.
> =

> And really, why are we trying to fix something that isn't broken? :)

I guess I wasn't clear...   This is broken in BlueZ, which compiles everyth=
ing with -Werror=3Dcast-align,
when compiling for ARM-8 architectures.

> =

> Look carefully at what that macro is doing, it is casting to (char *) =

> only for purposes of pointer arithmetic.  There's no possibility of any =

> misalignment.  The compiler is just being silly.
> =

> Regards,
> -Denis

--===============6421393958378751464==--

