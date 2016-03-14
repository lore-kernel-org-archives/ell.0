Content-Type: multipart/mixed; boundary="===============2209632729929388080=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 04/20] dbus: Fix _dbus_kernel_calculate_bloom for multiple
 arguments.
Date: Mon, 14 Mar 2016 04:41:20 +0100
Message-ID: <1457926896-9843-4-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1457926896-9843-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2209632729929388080==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

It seems that l_dbus_message_iter_get_type can't be used to get the
value of a single argument and be called repeatedly, it might crash if
the number and types of call arguments don't match the message arguments.
Also try to support the string arguments that come after non-string
arguments in the bloom filter.
---
 ell/dbus-message.c | 38 ++++++++++++++++++++++++++++----------
 1 file changed, 28 insertions(+), 10 deletions(-)

diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index f223c70..a123a8a 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -1412,9 +1412,12 @@ bool _dbus_kernel_calculate_bloom(struct l_dbus_mess=
age *message,
 	const char *signature;
 	void *body;
 	size_t body_size;
-	struct l_dbus_message_iter iter;
+	struct l_dbus_message_iter iter, tmp;
 	uint8_t argn;
 	char buf[256];
+	bool (*skip_entry)(struct l_dbus_message_iter *);
+	bool (*get_basic)(struct l_dbus_message_iter *, char, void *);
+	char type;
 =

 	/* The string "interface:" suffixed by the interface name */
 	attr =3D l_dbus_message_get_interface(message);
@@ -1458,17 +1461,32 @@ bool _dbus_kernel_calculate_bloom(struct l_dbus_mes=
sage *message,
 =

 	body =3D _dbus_message_get_body(message, &body_size);
 =

-	if (_dbus_message_is_gvariant(message))
-		_gvariant_iter_init(&iter, message, signature, NULL,
-					body, body_size);
-	else
+	if (_dbus_message_is_gvariant(message)) {
+		if (!_gvariant_iter_init(&iter, message, signature, NULL,
+						body, body_size))
+			return false;
+
+		skip_entry =3D _gvariant_iter_skip_entry;
+		get_basic =3D _gvariant_iter_next_entry_basic;
+	} else {
 		_dbus1_iter_init(&iter, message, signature, NULL,
-				body, body_size);
+					body, body_size);
+
+		skip_entry =3D _dbus1_iter_skip_entry;
+		get_basic =3D _dbus1_iter_next_entry_basic;
+	}
 =

 	argn =3D 0;
 =

-	while (*signature =3D=3D 's' || *signature =3D=3D 'o' || *signature =3D=
=3D 'g') {
-		if (!message_iter_next_entry(&iter, &attr))
+	do {
+		type =3D l_dbus_message_iter_get_type(&iter);
+		if (!strchr("sog", type))
+			goto next;
+
+		/* Don't let get_basic move iter->pos without moving sig_pos */
+		memcpy(&tmp, &iter, sizeof(tmp));
+
+		if (!get_basic(&tmp, type, &attr))
 			return false;
 =

 		sprintf(buf, "arg%hhu", argn);
@@ -1482,9 +1500,9 @@ bool _dbus_kernel_calculate_bloom(struct l_dbus_messa=
ge *message,
 		_dbus_kernel_bloom_add_parents(filter, f_size, num_hash, buf,
 						attr, '.');
 =

+next:
 		argn +=3D 1;
-		signature +=3D 1;
-	}
+	} while (skip_entry(&iter));
 =

 	return true;
 }
-- =

2.5.0


--===============2209632729929388080==--

