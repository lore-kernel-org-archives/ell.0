Content-Type: multipart/mixed; boundary="===============4019140786950461952=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: ctype.h undefined behaviour on signed char platforms, needs cast
 to (unsigned char)
Date: Sat, 21 Nov 2020 21:23:38 -0600
Message-ID: <b1bf6af2-5163-65b7-6fa1-71d3e7640f4b@gmail.com>
In-Reply-To: <6174F377-F1D9-40D1-9DD5-567AFD638B17@bluewin.ch>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4019140786950461952==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Phil,

On 11/21/20 4:49 PM, Phil wrote:
> The defect is already in HEAD and not just in that patch: ell/util.c call=
s isprint and toupper without a cast.

Ok, now I gotcha.  I thought I eradicated all uses of ctype.h, but guess we =

still had some hiding.  Thanks for pointing this out.

I removed these in commit ef25e0072d283217fc12e422f628f1af0920242a.

> =

> [My quick search for ctype did not find the macro definitions in "utf8.h"=
. I didn't bother to look for the reserved identifiers to[a-z]+ and is[a-z]=
+ because it is quite fiddly to refine the regexp to not also match a lot o=
f other identifiers. So I had no idea that the l_ascii_is* macros in utf8.h=
 even existed, thanks for the tip. But utf8.h is only a partial replacement=
 for <ctype.h> because there are no l_ascii_to* variants, and the names are=
 off-putting, it looks like they are just for ascii not utf8. What value do=
 they add to the ctype originals anyway, apart from providing the cast?]

So to answer your question about why the l_ascii stuff is in utf8...  ascii=
 is a =

subset of utf8, so it seemed logical and didn't seem worth it to add anothe=
r header.

We avoid ctype.h 'originals' like the plague because they're locale based, =
which =

we do not ever need or want.  Then there's the casting issue that you alrea=
dy =

pointed out.  It is also too easy to forget that the behavior changes depen=
ding =

on locale, which can lead to subtle bugs.

Regards,
-Denis
--===============4019140786950461952==--

