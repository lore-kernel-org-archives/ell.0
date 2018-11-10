Content-Type: multipart/mixed; boundary="===============4809948361257633581=="
MIME-Version: 1.0
From: Peter Seiderer <ps.report@gmx.net>
Subject: Re: [PATCH v1] ell/ell.sym: add missing
 l_genl_family_set_unicast_handler
Date: Sat, 10 Nov 2018 18:42:31 +0100
Message-ID: <20181110184231.4876bb7f@gmx.net>
In-Reply-To: <AC3C8583-55C0-4652-9E2A-8F2A82838FAF@holtmann.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4809948361257633581==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hello Marcel,

On Sat, 10 Nov 2018 17:43:16 +0100, Marcel Holtmann <marcel@holtmann.org>=
 wrote:

> Hi Peter,
> =

> > Fixes iwd compile failure:
> > =

> >  src/netdev.o: In function `netdev_set_nl80211':
> >  netdev.c:(.text+0x6f04): undefined reference to `l_genl_family_set_uni=
cast_handler=E2=80=99  =

> =

> we renamed it from l_genl_set_unicast_handler and it would be useful if y=
ou also remove this name and not just the new one.

O.k. will do...
> =

> > Signed-off-by: Peter Seiderer <ps.report@gmx.net>  =

> =

> No signed-off-by for patches please.
> =


O.k....updated patch follows...

Regards,
Peter

> Regards
> =

> Marcel
> =



--===============4809948361257633581==--

