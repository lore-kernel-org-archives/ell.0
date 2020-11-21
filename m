Content-Type: multipart/mixed; boundary="===============4304015469280581044=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: ctype.h undefined behaviour on signed char platforms, needs cast
 to (unsigned char)
Date: Sat, 21 Nov 2020 14:29:39 -0600
Message-ID: <1734cdf4-f0e0-dcf5-622c-5290b6838474@gmail.com>
In-Reply-To: <75C926A4-7EC8-4392-BB83-69A143D2FD4F@bluewin.ch>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4304015469280581044==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Phil,

On 11/21/20 3:52 AM, Phil wrote:
> Just a little reminder that a cast to (unsigned char) is needed when pass=
ing a possibly negative char to ctype functions like isalnum, isspace. Pass=
ing anything other than positive or -1 is undefined behaviour, on platforms=
 where char is signed.
> =

> One way to find them all is to build from time to time with ctype.h inclu=
de commented out. Static review tools may also help.
> =

> +#include <ctype.h>
> +		while (base64_len && isspace(*base64)) {

Thanks.  But I'm confused..? ell shouldn't even be using these functions in=
 the =

first place.  We have our own l_ascii versions which cast already.  And I d=
on't =

see any uses of them in git HEAD...

Or are you referring to Andrew's patch set? In which case, you might want t=
o =

reply to the relevant thread...

Regards,
-Denis
--===============4304015469280581044==--

