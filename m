Content-Type: multipart/mixed; boundary="===============8553881220512177431=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 1/3] tls: Flush record buffers on l_tls_close
Date: Thu, 26 May 2022 11:23:25 -0500
Message-ID: <4a6097a6-3c93-9975-b176-d51c08725741@gmail.com>
In-Reply-To: 20220526155657.63641-1-andrew.zaborowski@intel.com

--===============8553881220512177431==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 5/26/22 10:56, Andrew Zaborowski wrote:
> We probably don't want to handle data fragments we received before an
> l_tls_close if the TLS tunnel gets restarted in the future.
> ---
>   ell/tls.c | 3 +++
>   1 file changed, 3 insertions(+)
> =


All applied, thanks.

Regards,
-Denis

--===============8553881220512177431==--

