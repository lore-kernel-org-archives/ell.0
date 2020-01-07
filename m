Content-Type: multipart/mixed; boundary="===============1230279063156294399=="
MIME-Version: 1.0
From: Gix, Brian <brian.gix@intel.com>
Subject: Re: Warn-to-error on -Werror=cast-align
Date: Tue, 07 Jan 2020 18:18:18 +0000
Message-ID: <b1ae840114c17afceb5347a4c1be6fac651b8f5f.camel@intel.com>
In-Reply-To: <6018104577b417880e4cb4bf828a300be0ea1f2b.camel@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1230279063156294399==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Tue, 2020-01-07 at 10:07 -0800, Brian Gix wrote:
> On Tue, 2020-01-07 at 11:56 -0600, Denis Kenzior wrote:
> > =


<...>

> > And really, why are we trying to fix something that isn't broken? :)
> =

> I guess I wasn't clear...   This is broken in BlueZ, which compiles every=
thing with -Werror=3Dcast-align,
> when compiling for ARM-8 architectures.
> =

> > Look carefully at what that macro is doing, it is casting to (char *) =

> > only for purposes of pointer arithmetic.  There's no possibility of any =

> > misalignment.  The compiler is just being silly.
> > =


If this is indeed the "compiler being silly" then this would seem to be an =
argument in *favor* of void-casting
the final macro output, before casting to the desired type...  This is Mich=
a=C5=82's original solution, and should
work pretty universally.  It is also what Marcel has signalled that he beli=
eves is acceptable.

--===============1230279063156294399==--

