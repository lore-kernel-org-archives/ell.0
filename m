Content-Type: multipart/mixed; boundary="===============2909290420641179682=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH v2 1/2] base64: refactor l_base64_decode and validate
 bytes consumed
Date: Thu, 17 Feb 2022 15:56:22 -0600
Message-ID: <fcadf4f9-fb4c-7227-def5-24ae64a21666@gmail.com>
In-Reply-To: 20220217201305.2065223-1-prestwoj@gmail.com

--===============2909290420641179682==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 2/17/22 14:13, James Prestwood wrote:
> The way the base64 data was being validated was accurate, but included a
> second loop to iterate the padding. There was nothing wrong with this but
> for more concise/readable code the padding can be calculated and validated
> all after the first loop by incrementing pad_len when '=3D' is found rath=
er
> than breaking out. The valid base64 character check did need a slight
> modification to also check that pad_len has not been incremented, which
> ensures there is no data after the padding (prior this was done by the
> second, pad checking, loop).
> =

> Then, after the loop, pad_len has been calculated and can be checked agai=
nst
> what was expected based on the valid base64 characters found.
> =

> This refactoring also makes checking the bytes consumed much easier since
> the first loop iterates until the very end of the base64 data (including
> padding).
> ---
>   ell/base64.c | 41 ++++++++++++++++++++++-------------------
>   1 file changed, 22 insertions(+), 19 deletions(-)
> =

> v2:
>   * Fix issue in calculating the end of the base64 data (caused test-pem =
to
>     fail). This was because whitespace was not taken into account which
>     could exist between the base64 and padding. Instead the end of the
>     base64 data is now saved when the first pad byte is found. This allows
>     the second loop to use this as its end condition.
> =


Applied, thanks.

Regards,
-Denis

--===============2909290420641179682==--

