Content-Type: multipart/mixed; boundary="===============4740340391843584394=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: ctype.h undefined behaviour on signed char platforms, needs cast
 to (unsigned char)
Date: Sun, 22 Nov 2020 00:18:13 +0100
Message-ID: <CAOq732+x4g5-D=vXJNTgC=TT-Y4Y6axmoXWbMGH3QYLc5FvivA@mail.gmail.com>
In-Reply-To: <6174F377-F1D9-40D1-9DD5-567AFD638B17@bluewin.ch>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4740340391843584394==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Sat, 21 Nov 2020 at 23:50, Phil <philip.hodges@bluewin.ch> wrote:
> The defect is already in HEAD and not just in that patch: ell/util.c call=
s isprint and toupper without a cast.

The isprint() parameter is an unsigned char, but the first toupper
call could in theory be passed unchecked char values...

>
> [My quick search for ctype did not find the macro definitions in "utf8.h"=
. I didn't bother to look for the reserved identifiers to[a-z]+ and is[a-z]=
+ because it is quite fiddly to refine the regexp to not also match a lot o=
f other identifiers. So I had no idea that the l_ascii_is* macros in utf8.h=
 even existed, thanks for the tip. But utf8.h is only a partial replacement=
 for <ctype.h> because there are no l_ascii_to* variants, and the names are=
 off-putting, it looks like they are just for ascii not utf8. What value do=
 they add to the ctype originals anyway, apart from providing the cast?]
>
> That validation won't help on affected platforms where char is signed 8 b=
it because every char <=3D 127.

Right, I didn't mean comparing char values against 127.  Just that a
valid PEM file doesn't contain values > 127 but at that point in the
code we've not enforced this yet.

Best regards
--===============4740340391843584394==--

