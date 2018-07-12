Content-Type: multipart/mixed; boundary="===============3922812847723486804=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dhcp: include if_arp.h from libc instead of linux headers
Date: Thu, 12 Jul 2018 11:13:24 -0500
Message-ID: <65b45321-f64c-9c01-49cb-5998e5789d8f@gmail.com>
In-Reply-To: <81df296b-695f-2c6e-2d8b-653f6b1684e6@geanix.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3922812847723486804==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Martin,

On 07/12/2018 03:30 AM, Martin Hundeb=C3=B8ll wrote:
> Compilation with musl libc fails due to redefinition of 'struct
> arp{req,req_old,hdr}' in linux/if_arp.h, since it is already defined and
> included in net/if_arp.h (through net/ethernet.h -> net/if_ether.h).
> =

> The only symbols used from if_arp.h is ARPHRD_ETHER, so it should be
> safe to avoid the compile error by including the if_arp.h header from
> the c-library instead.
> =

> Signed-off-by: Martin Hundeb=C3=B8ll <martin@geanix.com>

No Signed-off-by please

> ---
>  =C2=A0ell/dhcp.c | 2 +-
>  =C2=A01 file changed, 1 insertion(+), 1 deletion(-)
> =


This patch doesn't apply.  Can you rebase & resubmit?

Regards,
-Denis


--===============3922812847723486804==--

