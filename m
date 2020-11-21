Content-Type: multipart/mixed; boundary="===============7934129295191533890=="
MIME-Version: 1.0
From: Phil <philip.hodges@bluewin.ch>
Subject: Re: ctype.h undefined behaviour on signed char platforms, needs cast
 to (unsigned char)
Date: Sat, 21 Nov 2020 23:49:54 +0100
Message-ID: <6174F377-F1D9-40D1-9DD5-567AFD638B17@bluewin.ch>
In-Reply-To: <CAOq732JoZTuL5+TUOepNsp0HAZDmxw8fqGBw48K--w83fYtgbQ@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7934129295191533890==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The defect is already in HEAD and not just in that patch: ell/util.c calls =
isprint and toupper without a cast.

[My quick search for ctype did not find the macro definitions in "utf8.h". =
I didn't bother to look for the reserved identifiers to[a-z]+ and is[a-z]+ =
because it is quite fiddly to refine the regexp to not also match a lot of =
other identifiers. So I had no idea that the l_ascii_is* macros in utf8.h e=
ven existed, thanks for the tip. But utf8.h is only a partial replacement f=
or <ctype.h> because there are no l_ascii_to* variants, and the names are o=
ff-putting, it looks like they are just for ascii not utf8. What value do t=
hey add to the ctype originals anyway, apart from providing the cast?]

That validation won't help on affected platforms where char is signed 8 bit=
 because every char <=3D 127.

This defect is common, I have seen it in several projects. It will quite li=
kely happen again and again until it becomes standard practice to have@l=
east one static analysis tool in the build chain that can detect both exist=
ing and new STR37-C defects. The undefined behaviour may well be benign on =
most platforms, which may explain why it is low priority, but the standard =
does not guarantee that, so we are stuck with having to add an ugly non-obv=
ious cast or roll our own with the cast built-in.


> On 21 Nov 2020, at 21:57, Andrew Zaborowski <andrew.zaborowski@intel.co=
m> wrote:
> =

> On Sat, 21 Nov 2020 at 21:31, Denis Kenzior <denkenz@gmail.com> wrote:
>> On 11/21/20 3:52 AM, Phil wrote:
>>> Just a little reminder that a cast to (unsigned char) is needed when pa=
ssing a possibly negative char to ctype functions like isalnum, isspace. Pa=
ssing anything other than positive or -1 is undefined behaviour, on platfor=
ms where char is signed.
> =

> Ok, good point.  In this case the chars haven't been validated to be <=3D=
 127.
> =

>>> =

>>> One way to find them all is to build from time to time with ctype.h inc=
lude commented out. Static review tools may also help.
>>> =

>>> +#include <ctype.h>
>>> +             while (base64_len && isspace(*base64)) {
>> =

>> Thanks.  But I'm confused..? ell shouldn't even be using these functions=
 in the
>> first place.  We have our own l_ascii versions which cast already.  And =
I don't
>> see any uses of them in git HEAD...
>> =

>> Or are you referring to Andrew's patch set? In which case, you might wan=
t to
>> reply to the relevant thread...
> =

> Thanks for both comments.  No need to reply separately, I noted it and
> will fix it.
> =

> Best regards
> _______________________________________________
> ell mailing list -- ell(a)lists.01.org
> To unsubscribe send an email to ell-leave(a)lists.01.org

--===============7934129295191533890==--

