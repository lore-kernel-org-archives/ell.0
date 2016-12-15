Content-Type: multipart/mixed; boundary="===============4383612636673580764=="
MIME-Version: 1.0
From: Markus Ongyerth <ell@ongy.net>
Subject: Re: [PATCH 1/4] autotools: Only used -Wcast-align with gcc
Date: Thu, 15 Dec 2016 08:48:57 +0100
Message-ID: <0550e404dbfde87d854d0dcf0441ae3b@localhost>
In-Reply-To: <876A9361-B751-4FA5-BF3D-245576450505@holtmann.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4383612636673580764==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Marcel,

On 2016/12=E6=9C=88/15 07:57, Marcel Holtmann wrote:
> Hi Markus,
> =

> > clang can currently not compile NLMSG_NEXT with -Wcast-align.
> > I asked about this in #llvm on irc.oftc.net, where I was told the best
> > solution is to disable -Wcast-align for now.
> =

> can we get a little bit more background on this. I had also some issues w=
ith native gcc usage on Raspberry PI. And yes, the netlink macros are some =
offenders.
> =

I was mostly going of an answer I got in irc, (I was told it's ok to quote):

/**************************************************************************=
*/
2016-12-14 17:47:14	dblaikie	ongy: Judging by the docs - and this is a bit =

of a guess, GCC is more conservative with this warning, restricting it to o=
nly =

platforms where it would be an illegal instruction (I haven't actually test=
ed =

this, because I don't have a GCC cross compiler and don't remember which =

targets have this behavior - x86 just has reduced performance)
/**************************************************************************=
*/

The docs they reference here are probably [1] . Here the relevant lines are:

/**************************************************************************=
*/
-Wcast-align
Warn whenever a pointer is cast such that the required alignment of the tar=
get
is increased. For example, warn if a char * is cast to an int * on machines =

where integers can only be accessed at two- or four-byte boundaries. =

/**************************************************************************=
*/

Judging from [2] this is the case on older ARM processors.
If I read this correctly, The Raspberry PI should support unaligned access =
(at =

least version 2 and 3). It may be worth to see what architecture gcc target=
s =

and make it more specific.


[1] https://gcc.gnu.org/onlinedocs/gcc/Warning-Options.html
[2] http://infocenter.arm.com/help/index.jsp?topic=3D/com.arm.doc.faqs/ka15=
414.html
> > ---
> > acinclude.m4 | 4 +++-
> > 1 file changed, 3 insertions(+), 1 deletion(-)
> > =

> > diff --git a/acinclude.m4 b/acinclude.m4
> > index 8aab4ee..b1dbabe 100644
> > --- a/acinclude.m4
> > +++ b/acinclude.m4
> > @@ -58,6 +58,8 @@ AC_DEFUN([COMPILER_FLAGS], [
> > 		CFLAGS+=3D" -Wdeclaration-after-statement"
> > 		CFLAGS+=3D" -Wmissing-declarations"
> > 		CFLAGS+=3D" -Wredundant-decls"
> > -		CFLAGS+=3D" -Wcast-align"
> > +		if ( $CC -v 2>/dev/null | grep "gcc version" ); then
> > +			CFLAGS+=3D" -Wcast-align"
> > +		fi
> =

> Are you sure there is not a better autoconf macro for checking if we use =
gcc vs clang.

No I'm not. I'm not really familiar with autotools. This is what came up wh=
en =

I searched for compiler specific option in autotools, there may be a better =

way.

Regards,
  Markus

--===============4383612636673580764==--

