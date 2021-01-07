Content-Type: multipart/mixed; boundary="===============0371751030695641650=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/8] util: Add L_IN_SET macros
Date: Thu, 07 Jan 2021 14:01:55 -0600
Message-ID: <29dbd5bc-be44-dcda-ff06-973ebace2092@gmail.com>
In-Reply-To: <20210106195446.1428769-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0371751030695641650==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 1/6/21 1:54 PM, Andrew Zaborowski wrote:
> This can be used with enum types or ints as in L_IN_SET(-err, EIO, EINVAL=
).
> I'm also adding an L_IN_STRSET() for string comparisons.  This
> macro is not equivalent to (x =3D=3D (val1) || x =3D=3D (val2) || ...)
> because val2 will be evaluated even if (x =3D=3D (val1)) was true.  There
> seems to be no way to avoid that without adding another numbr of macros
> dependent on the maximum number of arguments expected.  The "x" in the
> above example is evaluated once.
> =

> We may have to add a warning about everything being cast to the type of
> the "x", I'm not sure how important of a problem this is.
> ---
>   ell/util.h | 20 ++++++++++++++++++++
>   1 file changed, 20 insertions(+)
> =


Patches 1-4 and 7 applied thanks.

Regards,
-Denis
--===============0371751030695641650==--

