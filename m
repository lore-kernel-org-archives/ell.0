Content-Type: multipart/mixed; boundary="===============3002451223605179422=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/2] dbus: Utility to look up UNIX_FDS field in raw header
Date: Wed, 11 May 2016 11:36:09 +0200
Message-ID: <1462959370-30764-3-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1462959370-30764-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3002451223605179422==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus-message.c | 17 +++++++++++++++++
 ell/dbus-private.h |  2 ++
 2 files changed, 19 insertions(+)

diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index 89aaacc..072a902 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -694,6 +694,23 @@ static bool valid_header(const struct dbus_header *hdr)
 	return true;
 }
 =

+unsigned int _dbus_message_unix_fds_from_header(const void *data, size_t s=
ize)
+{
+	struct l_dbus_message message;
+	uint32_t unix_fds;
+
+	message.header =3D (uint8_t *) data;
+	message.header_size =3D size;
+	message.body_size =3D 0;
+	message.sealed =3D true;
+
+	if (!get_header_field(&message, DBUS_MESSAGE_FIELD_UNIX_FDS,
+				'u', &unix_fds))
+		return 0;
+
+	return unix_fds;
+}
+
 struct l_dbus_message *dbus_message_from_blob(const void *data, size_t siz=
e,
 						int fds[], uint32_t num_fds)
 {
diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index 919639b..a4118c6 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -159,6 +159,8 @@ bool dbus_message_compare(struct l_dbus_message *messag=
e,
 bool _dbus_message_builder_mark(struct l_dbus_message_builder *builder);
 bool _dbus_message_builder_rewind(struct l_dbus_message_builder *builder);
 =

+unsigned int _dbus_message_unix_fds_from_header(const void *data, size_t s=
ize);
+
 const char *_dbus_signature_end(const char *signature);
 =

 bool _dbus_valid_object_path(const char *path);
-- =

2.7.4


--===============3002451223605179422==--

