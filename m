Content-Type: multipart/mixed; boundary="===============3033106116790160246=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dhcp.c: include net/ethernet.h before linux headers
Date: Thu, 17 May 2018 17:07:38 -0500
Message-ID: <cf061e96-8811-6c92-7061-fc577dc69176@gmail.com>
In-Reply-To: <20180517220123.26055-1-johnz@posteo.net>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3033106116790160246==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi John,

On 05/17/2018 05:01 PM, John Zimmermann wrote:
> to fix compilation on systems with MUSL libc since MUSL a few argp
> structs exists in MUSL libc headers and kernel headers. Including libc
> headers before lets libc_compat.h take care of that.
> ---
>   ell/dhcp.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> =


Applied, thanks.

Regards,
-Denis


--===============3033106116790160246==--

