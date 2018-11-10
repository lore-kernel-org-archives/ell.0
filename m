Content-Type: multipart/mixed; boundary="===============1022831315885833852=="
MIME-Version: 1.0
From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH v2] ell/ell.sym: add missing
 l_genl_family_set_unicast_handler
Date: Sat, 10 Nov 2018 19:14:08 +0100
Message-ID: <61ED4A7C-0934-40FD-BA2E-83B54FF25317@holtmann.org>
In-Reply-To: <20181110174447.4226-1-ps.report@gmx.net>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1022831315885833852==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Peter,

> Add l_genl_family_set_unicast_handler (and remove legacy
> l_genl_set_unicast_handler).
> =

> Fixes iwd compile failure:
> =

>  src/netdev.o: In function `netdev_set_nl80211':
>  netdev.c:(.text+0x6f04): undefined reference to `l_genl_family_set_unica=
st_handler'
> ---
> Changes v1 -> v2:
>  - remove legacy l_genl_set_unicast_handler (suggested by Marcel Holtmann)
>  - remove Signed-off-by line (suggested by Marcel Holtmann )
> ---
> ell/ell.sym | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)

patch has been applied.

Regards

Marcel


--===============1022831315885833852==--

