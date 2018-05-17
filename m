Content-Type: multipart/mixed; boundary="===============6940520618584143900=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] dhcp-transport: define _GNU_SOURCE
Date: Thu, 17 May 2018 10:34:17 -0500
Message-ID: <a8719c91-ab9a-eb35-c3c0-1882fe8390da@gmail.com>
In-Reply-To: <20180517110855.24429-1-johnz@posteo.net>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6940520618584143900==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi John,

On 05/17/2018 06:08 AM, John wrote:
> the source, dest, len, check naming for the udphdr struct is not avaible
> on non GLIBC libc's like MUSL without defining _GNU_SOURCE
> ---
>   ell/dhcp-transport.c | 1 +
>   1 file changed, 1 insertion(+)
> =


These look fine, but could you add some form of last name to your author =

info? We use a simplified form of Linux Kernel patch submission =

guidelines but still require a full name for acceptance.

Regards,
-Denis

--===============6940520618584143900==--

