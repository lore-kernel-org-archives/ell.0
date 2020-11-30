Content-Type: multipart/mixed; boundary="===============3329162798552742160=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] ell: add missing include in dhcp-server.
Date: Mon, 30 Nov 2020 13:06:40 -0600
Message-ID: <5e9e28b4-21be-d6d6-de99-d9c5780b508b@gmail.com>
In-Reply-To: <20201130171016.22457-1-ericonr@disroot.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3329162798552742160==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi =C3=89rico,

> =

> I would prefer adding `#include <linux/types>` directly in
> dhcp-private.h, but this patch follows the current style.

We prefer to not have #includes in -private.h files.  So the way you have i=
t is =

correct.

> =

>   ell/dhcp-server.c | 1 +
>   1 file changed, 1 insertion(+)
> =


Note that the patch seems to come through MIME encoded and doesn't apply vi=
a =

'git am'.

Regards,
-Denis
--===============3329162798552742160==--

