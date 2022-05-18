Content-Type: multipart/mixed; boundary="===============6216257199061278548=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 17/17] icmp6: Ignore bad prefixes per RFC4862
Date: Wed, 18 May 2022 14:02:56 -0500
Message-ID: <18279cb7-f9a9-56f5-d943-e0d7d45a012e@gmail.com>
In-Reply-To: 20220513224713.1447773-17-andrew.zaborowski@intel.com

--===============6216257199061278548==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 5/13/22 17:47, Andrew Zaborowski wrote:
> "Silently ignore" Prefix Information options with a preferred time
> longer than valid time and those matching the link-local prefix as
> mandated by RFC4862 Section 5.5.3.  These prefixes are also invalid
> according to RFC4861.
> ---
>   ell/icmp6.c | 32 ++++++++++++++++++++++++++++++--
>   1 file changed, 30 insertions(+), 2 deletions(-)
> =


Applied, thanks.

Regards,
-Denis

--===============6216257199061278548==--

