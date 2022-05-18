Content-Type: multipart/mixed; boundary="===============3941630114813959619=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH] dhcp: CLIENT_ENTER_STATE should log as INFO
Date: Wed, 18 May 2022 12:13:29 -0500
Message-ID: <c3652419-6050-fbd0-b41b-f2fed5886677@gmail.com>
In-Reply-To: 20220518165836.180763-1-mjohnson459@gmail.com

--===============3941630114813959619==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Michael,

On 5/18/22 11:58, Michael Johnson wrote:
> This was missed in the d5377c6. Now the state will only log when INFO or
> above is enabled.
> ---
>   ell/dhcp.c | 4 +---
>   1 file changed, 1 insertion(+), 3 deletions(-)
> =


Applied with a slight rewording of the commit description.

Regards,
-Denis

--===============3941630114813959619==--

