Content-Type: multipart/mixed; boundary="===============1748201371979523289=="
MIME-Version: 1.0
From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH v1] ell/ell.sym: add missing
 l_genl_family_set_unicast_handler
Date: Sat, 10 Nov 2018 17:43:16 +0100
Message-ID: <AC3C8583-55C0-4652-9E2A-8F2A82838FAF@holtmann.org>
In-Reply-To: <20181109230202.954-1-ps.report@gmx.net>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1748201371979523289==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Peter,

> Fixes iwd compile failure:
> =

>  src/netdev.o: In function `netdev_set_nl80211':
>  netdev.c:(.text+0x6f04): undefined reference to `l_genl_family_set_unica=
st_handler=E2=80=99

we renamed it from l_genl_set_unicast_handler and it would be useful if you=
 also remove this name and not just the new one.

> Signed-off-by: Peter Seiderer <ps.report@gmx.net>

No signed-off-by for patches please.

Regards

Marcel


--===============1748201371979523289==--

