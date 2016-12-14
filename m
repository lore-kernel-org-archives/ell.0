Content-Type: multipart/mixed; boundary="===============4920291259261631238=="
MIME-Version: 1.0
From: ell@ongy.net
Subject: [PATCH 3/4] dbus: Add missing dereference on assign
Date: Wed, 14 Dec 2016 23:51:20 +0100
Message-ID: <20161214225121.9439-4-ell@ongy.net>
In-Reply-To: <20161214225121.9439-1-ell@ongy.net>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4920291259261631238==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

From: Markus Ongyerth <ongy@ongy.net>

---
 ell/dbus.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/dbus.c b/ell/dbus.c
index 2c04ec9..5318794 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -480,7 +480,7 @@ static bool auth_read_handler(struct l_io *io, void *us=
er_data)
 =

 	l_util_hexdump(true, ptr, len, dbus->debug_handler, dbus->debug_data);
 =

-	end =3D '\0';
+	*end =3D '\0';
 =

 	switch (classic->auth_state) {
 	case WAITING_FOR_OK:
-- =

2.10.2


--===============4920291259261631238==--

