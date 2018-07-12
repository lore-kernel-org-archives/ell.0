Content-Type: multipart/mixed; boundary="===============4736001494560018184=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCHv2] dhcp: include if_arp.h from libc instead of linux
 headers
Date: Thu, 12 Jul 2018 13:00:59 -0500
Message-ID: <7ee75334-9c90-e8cb-1d8d-37aeb91e33c8@gmail.com>
In-Reply-To: <20180712173125.1075-1-martin@geanix.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4736001494560018184==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Martin,

On 07/12/2018 12:31 PM, Martin Hundeb=C3=B8ll wrote:
> Compilation with musl libc fails due to redefinition of 'struct
> arp{req,req_old,hdr}' in linux/if_arp.h, since it is already defined and
> included in net/if_arp.h (through net/ethernet.h -> net/if_ether.h).
> =

> The only symbols used from if_arp.h is ARPHRD_ETHER, so it should be
> safe to avoid the compile error by including the if_arp.h header from
> the c-library instead.
> =


Applied, thanks.

Regards,
-Denis


--===============4736001494560018184==--

