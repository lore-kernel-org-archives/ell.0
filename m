Content-Type: multipart/mixed; boundary="===============5864944886513401970=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: Warn-to-error on -Werror=cast-align
Date: Tue, 07 Jan 2020 11:56:34 -0600
Message-ID: <d9685ec4-7e07-32c7-6672-8cba31f46d87@gmail.com>
In-Reply-To: <ac6ea44df69c53a6964aca5d7be03263c21bdfcd.camel@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5864944886513401970==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Brian,

> So because super is the first member, the "recovered container pointer" s=
hould *always* be equal to the
> original pointer, and because the structure is *private to ell/dbus.c*, w=
e can work around this warning by not
> using l_container_of(), and instead simply casting the point directly in =
the 4 places the macro is used. The
> only time this would not work is if a compiler decides to re-arrange the =
members of the container structure.

Unless of course the compiler decides to reorder the structure elements =

somehow.  So you'd also need to make the structure packed or play some =

other tricks and hope no-one rearranges the structure in the future.

Also, l_container_of is used in iwd.

And really, why are we trying to fix something that isn't broken? :)

Look carefully at what that macro is doing, it is casting to (char *) =

only for purposes of pointer arithmetic.  There's no possibility of any =

misalignment.  The compiler is just being silly.

Regards,
-Denis
--===============5864944886513401970==--

