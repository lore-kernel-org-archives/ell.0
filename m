Content-Type: multipart/mixed; boundary="===============4213126543773767120=="
MIME-Version: 1.0
From: =?unknown-8bit?q?Micha=C5=82?= Lowas-Rzechonek <michal.lowas-rzechonek@silvair.com>
Subject: Re: Warn-to-error on -Werror=cast-align
Date: Mon, 30 Dec 2019 08:44:02 +0100
Message-ID: <20191230074402.hdm63equduouznjw@kynes>
In-Reply-To: <e741508b7df80bb143ceb95d2dd31d70b522a439.camel@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4213126543773767120==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On 12/29, Gix, Brian wrote:
> In the BlueZ build, we apparently use stricter Warn to Error checking tha=
n what is currently set up for ELL.
> =

> I got my son a new Raspberry PI, and the first thing he tried to build wa=
s ELL and BlueZ...  On THAT PATFORM
> ONLY, Raspbian (Raspbian 10 (buster)) with kernel 4.19, we get failures b=
uilding ell/dbus.c.  Everything builds
> correctly in the ELL tree, using standard bootstrap-configure, however wh=
en using -Werror=3Dcast-align, I get the
> following (see below) build issues in dbus.c, genl.c, dhcp-transport.c, p=
lus a few unit tests...  In BlueZ
> these errors show up with the *default* build procedure:
> =

(...)
> ell/util.h:40:3: error: cast increases required alignment of target type =
[-Werror=3Dcast-align]
>    (type *)((char *) __mptr - offsetof(type, member)); \
>    ^
> ell/dbus.c:582:3: note: in expansion of macro =E2=80=98l_container_of=E2=
=80=99
>    l_container_of(dbus, struct l_dbus_classic, super);
>    ^~~~~~~~~~~~~~

FWIW, I've encountered that on iMX.6 as well. I've fixed that with:

diff --git a/ell/util.h b/ell/util.h
index 4f20ef0..fe7c7e2 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -37,7 +37,7 @@ extern "C" {
 =

 #define l_container_of(ptr, type, member) ({                           \
                const __typeof__(((type *) 0)->member) *__mptr =3D (ptr); \
-               (type *)((char *) __mptr - offsetof(type, member));     \
+               (type *)(void *)((char *) __mptr - offsetof(type, member));=
     \
        })
 =

 #define likely(x)   __builtin_expect(!!(x), 1)

But I'm not sure this is correct...

regards
-- =

Micha=C5=82 Lowas-Rzechonek <michal.lowas-rzechonek@silvair.com>
Silvair http://silvair.com
Jasnog=C3=B3rska 44, 31-358 Krakow, POLAND
--===============4213126543773767120==--

