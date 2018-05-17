Content-Type: multipart/mixed; boundary="===============5237195510387107799=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] dhcp-transport: define _GNU_SOURCE
Date: Thu, 17 May 2018 17:06:38 -0500
Message-ID: <015d78c4-f65b-39f8-512b-ab5050aadfcd@gmail.com>
In-Reply-To: <20180517215637.15765-1-johnz@posteo.net>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5237195510387107799==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi John,

On 05/17/2018 04:56 PM, John Zimmermann wrote:
> the source, dest, len, check naming for the udphdr struct is not avaible
> on non GLIBC libc's like MUSL without defining _GNU_SOURCE
> ---
>   ell/dhcp-transport.c | 1 +
>   1 file changed, 1 insertion(+)
> =


Applied, thanks.

Regards,
-Denis


--===============5237195510387107799==--

