Content-Type: multipart/mixed; boundary="===============3498389653024231109=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: ctype.h undefined behaviour on signed char platforms, needs cast
 to (unsigned char)
Date: Sat, 21 Nov 2020 21:57:33 +0100
Message-ID: <CAOq732JoZTuL5+TUOepNsp0HAZDmxw8fqGBw48K--w83fYtgbQ@mail.gmail.com>
In-Reply-To: <1734cdf4-f0e0-dcf5-622c-5290b6838474@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3498389653024231109==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Sat, 21 Nov 2020 at 21:31, Denis Kenzior <denkenz@gmail.com> wrote:
> On 11/21/20 3:52 AM, Phil wrote:
> > Just a little reminder that a cast to (unsigned char) is needed when pa=
ssing a possibly negative char to ctype functions like isalnum, isspace. Pa=
ssing anything other than positive or -1 is undefined behaviour, on platfor=
ms where char is signed.

Ok, good point.  In this case the chars haven't been validated to be <=3D 1=
27.

> >
> > One way to find them all is to build from time to time with ctype.h inc=
lude commented out. Static review tools may also help.
> >
> > +#include <ctype.h>
> > +             while (base64_len && isspace(*base64)) {
>
> Thanks.  But I'm confused..? ell shouldn't even be using these functions =
in the
> first place.  We have our own l_ascii versions which cast already.  And I=
 don't
> see any uses of them in git HEAD...
>
> Or are you referring to Andrew's patch set? In which case, you might want=
 to
> reply to the relevant thread...

Thanks for both comments.  No need to reply separately, I noted it and
will fix it.

Best regards
--===============3498389653024231109==--

