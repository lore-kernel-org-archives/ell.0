Content-Type: multipart/mixed; boundary="===============1283195126135544627=="
MIME-Version: 1.0
From: Szymon Janc <szymon.janc@codecoup.pl>
Subject: [PATCH] dbus: Fix array handling in
 l_dbus_message_builder_append_from_iter
Date: Tue, 28 Nov 2017 16:06:42 +0100
Message-ID: <20171128150642.28634-1-szymon.janc@codecoup.pl>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1283195126135544627==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

For array it is needed to iterate over its elements rather than
signature.
---
 ell/dbus-message.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index c23113e..7653c03 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -1907,9 +1907,13 @@ LIB_EXPORT bool l_dbus_message_builder_append_from_i=
ter(
 						container_type, signature))
 		return false;
 =

-	while (iter.sig_pos < iter.sig_len)
-		if (!l_dbus_message_builder_append_from_iter(builder, &iter))
-			return false;
+	if (container_type =3D=3D DBUS_CONTAINER_TYPE_ARRAY)
+		while(l_dbus_message_builder_append_from_iter(builder, &iter));
+	else
+		while (iter.sig_pos < iter.sig_len)
+			if (!l_dbus_message_builder_append_from_iter(builder,
+									&iter))
+				return false;
 =

 	if (!l_dbus_message_builder_leave_container(builder,
 						container_type))
-- =

2.14.3


--===============1283195126135544627==--

