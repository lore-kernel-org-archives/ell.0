Content-Type: multipart/mixed; boundary="===============6255262656663694914=="
MIME-Version: 1.0
From: Gix, Brian <brian.gix@intel.com>
Subject: Re: Warn-to-error on -Werror=cast-align
Date: Tue, 07 Jan 2020 18:05:36 +0000
Message-ID: <6ef5bf6e5e264ced734dac92dcfdc5eb55e6498c.camel@intel.com>
In-Reply-To: <ac6ea44df69c53a6964aca5d7be03263c21bdfcd.camel@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6255262656663694914==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Tue, 2020-01-07 at 09:37 -0800, Brian Gix wrote:
> Hi Denis, Marcel, =

> =

> On Tue, 2020-01-07 at 09:51 -0600, Denis Kenzior wrote:
> > Hi Brian,
> > =

> > > Any opinion on this change?  It is causing us build fails on some pla=
tforms (including Raspberry PI 4).
> > > =

> > =

> > I would think this is a compiler false positive.  If there was indeed a=
n =

> > issue, then just casting to void as an intermediate step just hides it =

> > without fixing anything.

A quicker fix, that only applies when the member container being recovered =
is the first member, is to change
the macro to consider 0 octet offsets, which I believe most compilers will =
efficiently optimize:


diff --git a/ell/util.h b/ell/util.h
index 4f20ef0..d1d848b 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -35,10 +35,10 @@
 extern "C" {
 #endif
 =

-#define l_container_of(ptr, type, member) ({                           \
+#define l_container_of(ptr, type, member) (offsetof(type, member) ? ({ \
                const __typeof__(((type *) 0)->member) *__mptr =3D (ptr); \
                (type *)((char *) __mptr - offsetof(type, member));     \
-       })
+       }) : ((type *) ptr))
 =

 #define likely(x)   __builtin_expect(!!(x), 1)
 #define unlikely(x) __builtin_expect(!!(x), 0)
 =

<...>

--===============6255262656663694914==--

