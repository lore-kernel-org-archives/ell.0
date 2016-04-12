Content-Type: multipart/mixed; boundary="===============8189200861159436172=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH v2 07/11] gvariant: Utility to build GVariant message out of
 header+body
Date: Tue, 12 Apr 2016 03:56:11 +0200
Message-ID: <1460426175-25501-7-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1460426175-25501-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8189200861159436172==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Build a single parseable GVariant blob out of the header blob,
the body blob and the signature string.
---
 ell/gvariant-private.h |  4 ++++
 ell/gvariant-util.c    | 46 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 50 insertions(+)

diff --git a/ell/gvariant-private.h b/ell/gvariant-private.h
index f8f1313..592ee8f 100644
--- a/ell/gvariant-private.h
+++ b/ell/gvariant-private.h
@@ -63,3 +63,7 @@ bool _gvariant_builder_leave_variant(struct dbus_builder =
*builder);
 bool _gvariant_builder_enter_array(struct dbus_builder *builder,
 					const char *signature);
 bool _gvariant_builder_leave_array(struct dbus_builder *builder);
+
+void _gvariant_message_build_contents(size_t header_end, const void *body,
+					size_t body_size, const char *signature,
+					uint8_t *out_buf, size_t *out_size);
diff --git a/ell/gvariant-util.c b/ell/gvariant-util.c
index 0baf1c6..fa1ca45 100644
--- a/ell/gvariant-util.c
+++ b/ell/gvariant-util.c
@@ -1317,3 +1317,49 @@ char *_gvariant_builder_finish(struct dbus_builder *=
builder,
 =

 	return signature;
 }
+
+/*
+ * Write the part of a GVariant message after the header + padding, i.e.
+ * starting at first byte of the body variant, into a buffer.  This includ=
es
+ * the variant with its signature and the framing offset of the header
+ * fields array.
+ */
+void _gvariant_message_build_contents(size_t header_end, const void *body,
+					size_t body_size, const char *signature,
+					uint8_t *out_buf, size_t *out_size)
+{
+	size_t size;
+	size_t offset_size;
+	size_t pos;
+
+	if (!signature)
+		signature =3D "";
+
+	size =3D body_size + 1 +			/* Body plus zero byte */
+		strlen(signature) + 2 +		/* Msg signature plus '()' */
+		(signature[0] =3D=3D '\0' ? 1 : 0);	/* Zero byte for empty struct */
+
+	offset_size =3D offset_length(align_len(header_end, 8) + size, 1);
+	size +=3D offset_size;
+
+	if (out_size)
+		*out_size =3D size;
+
+	if (!out_buf)
+		return;
+
+	if (signature[0] !=3D '\0') {
+		memcpy(out_buf, body, body_size);
+		pos =3D body_size;
+	} else {
+		out_buf[0] =3D 0;
+		pos =3D 1;
+	}
+
+	out_buf[pos++] =3D 0;
+	out_buf[pos++] =3D '(';
+	memcpy(out_buf + pos, signature, strlen(signature));
+	pos +=3D strlen(signature);
+	out_buf[pos++] =3D ')';
+	write_word_le(out_buf + pos, header_end, offset_size);
+}
-- =

2.5.0


--===============8189200861159436172==--

