Content-Type: multipart/mixed; boundary="===============3104428468091565478=="
MIME-Version: 1.0
From: Othman, Ossama <ossama.othman@intel.com>
Subject: Re: [PATCH] build: Add -ldl to LIBS as needed.
Date: Fri, 30 Nov 2018 09:56:06 -0800
Message-ID: <CAPyD+=BeOAJNGugbdrG=vsKjiB2-0qcX9wdf4+QzZ0hg8UkVNQ@mail.gmail.com>
In-Reply-To: <nycvar.YFH.7.76.1811292346250.28476@n3.vanv.qr>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3104428468091565478==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Jan,

On Thu, Nov 29, 2018 at 2:49 PM Jan Engelhardt <jengelh@inai.de> wrote:
> On Thursday 2018-11-29 22:46, Ossama Othman wrote:
> >
> >Lastly, only add "-ldl" to the library flags in ELL's pkg-config file
> >(ell.pc) when necessary.
> >index 4fc933b..65ea88e 100644
> >--- a/ell/ell.pc.in
> >+++ b/ell/ell.pc.in
> >@@ -6,5 +6,5 @@ includedir=3D@includedir@
> > Name: ELL
> > Description: Embedded Linux library
> > Version: @VERSION@
> >-Libs: -L${libdir} -lell -ldl
> >+Libs: -L${libdir} -lell @LIBS@
> > Cflags: -I${includedir}
>
> The change does not correspond to the claim. "-ldl" will still always
> end up in the .pc (on Linux/glibc), even though it's already
> recorded in the .so file.
>
> This ought to be
>
>   Libs.private: @LIBS@
>
> instead.

By "when necessary" I was referring to the AC_SEARCH_LIBS macro
behavior of not adding the library in question to LIBS if the function
can be resolved at link-time without the library, e.g. if dlopen() can
be resolved without explicitly linking "-ldl".  However, you make a
good point.  I'll submit a revised patch with a clarification, as well
as your suggested change.  Thanks for the tip!

-Ossama

--===============3104428468091565478==--

