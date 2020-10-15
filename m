Content-Type: multipart/mixed; boundary="===============4333670074569032392=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 04/14] dhcp-util: move iter APIs to dhcp-util
Date: Thu, 15 Oct 2020 10:17:21 -0700
Message-ID: <20201015171731.396538-4-prestwoj@gmail.com>
In-Reply-To: <20201015171731.396538-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4333670074569032392==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

These were already exposed for use elsewhere but dhcp-util
is a better home for these APIs.
---
 ell/dhcp-util.c | 160 ++++++++++++++++++++++++++++++++++++++++++++++++
 ell/dhcp.c      | 160 ------------------------------------------------
 2 files changed, 160 insertions(+), 160 deletions(-)

diff --git a/ell/dhcp-util.c b/ell/dhcp-util.c
index 44ab1e2..42979d1 100644
--- a/ell/dhcp-util.c
+++ b/ell/dhcp-util.c
@@ -158,3 +158,163 @@ uint8_t *_dhcp_message_builder_finalize(struct dhcp_m=
essage_builder *builder,
 =

 	return builder->start;
 }
+
+bool _dhcp_message_iter_init(struct dhcp_message_iter *iter,
+				const struct dhcp_message *message, size_t len)
+{
+	if (!message)
+		return false;
+
+	if (len < sizeof(struct dhcp_message))
+		return false;
+
+	if (L_BE32_TO_CPU(message->magic) !=3D DHCP_MAGIC)
+		return false;
+
+	memset(iter, 0, sizeof(*iter));
+	iter->message =3D message;
+	iter->message_len =3D len;
+	iter->max =3D len - sizeof(struct dhcp_message);
+	iter->options =3D message->options;
+	iter->can_overload =3D true;
+
+	return true;
+}
+
+static bool next_option(struct dhcp_message_iter *iter,
+				uint8_t *t, uint8_t *l, const void **v)
+{
+	uint8_t type;
+	uint8_t len;
+
+	while (iter->pos < iter->max) {
+		type =3D iter->options[iter->pos];
+
+		switch (type) {
+		case DHCP_OPTION_PAD:
+			iter->pos +=3D 1;
+			continue;
+		case DHCP_OPTION_END:
+			return false;
+		default:
+			break;
+		}
+
+		if (iter->pos + 2 >=3D iter->max)
+			return false;
+
+		len =3D iter->options[iter->pos + 1];
+
+		if (iter->pos + 2 + len > iter->max)
+			return false;
+
+		*t =3D type;
+		*l =3D len;
+		*v =3D &iter->options[iter->pos + 2];
+
+		iter->pos +=3D 2 + len;
+		return true;
+	}
+
+	return false;
+}
+
+bool _dhcp_message_iter_next(struct dhcp_message_iter *iter, uint8_t *type,
+				uint8_t *len, const void **data)
+{
+	bool r;
+	uint8_t t, l;
+	const void *v;
+
+	do {
+		r =3D next_option(iter, &t, &l, &v);
+		if (!r) {
+			iter->can_overload =3D false;
+
+			if (iter->overload_file) {
+				iter->options =3D iter->message->file;
+				iter->pos =3D 0;
+				iter->max =3D sizeof(iter->message->file);
+				iter->overload_file =3D false;
+				continue;
+			}
+
+			if (iter->overload_sname) {
+				iter->options =3D iter->message->sname;
+				iter->pos =3D 0;
+				iter->max =3D sizeof(iter->message->sname);
+				iter->overload_sname =3D false;
+				continue;
+			}
+
+			return r;
+		}
+
+		switch (t) {
+		case DHCP_OPTION_OVERLOAD:
+			if (l !=3D 1)
+				continue;
+
+			if (!iter->can_overload)
+				continue;
+
+			if (l_get_u8(v) & DHCP_OVERLOAD_FILE)
+				iter->overload_file =3D true;
+
+			if (l_get_u8(v) & DHCP_OVERLOAD_SNAME)
+				iter->overload_sname =3D true;
+
+			continue;
+		default:
+			if (type)
+				*type =3D t;
+
+			if (len)
+				*len =3D l;
+
+			if (data)
+				*data =3D v;
+			return r;
+		}
+	} while (true);
+
+	return false;
+}
+
+int _dhcp_option_append(uint8_t **buf, size_t *buflen, uint8_t code,
+					size_t optlen, const void *optval)
+{
+	if (!buf || !buflen)
+		return -EINVAL;
+
+	switch (code) {
+
+	case DHCP_OPTION_PAD:
+	case DHCP_OPTION_END:
+		if (*buflen < 1)
+			return -ENOBUFS;
+
+		(*buf)[0] =3D code;
+		*buf +=3D 1;
+		*buflen -=3D 1;
+		break;
+
+	default:
+		if (*buflen < optlen + 2)
+			return -ENOBUFS;
+
+		if (!optval)
+			return -EINVAL;
+
+		(*buf)[0] =3D code;
+		(*buf)[1] =3D optlen;
+		memcpy(&(*buf)[2], optval, optlen);
+
+		*buf +=3D optlen + 2;
+		*buflen -=3D (optlen + 2);
+
+		break;
+	}
+
+	return 0;
+}
diff --git a/ell/dhcp.c b/ell/dhcp.c
index d2be894..b7b6263 100644
--- a/ell/dhcp.c
+++ b/ell/dhcp.c
@@ -141,166 +141,6 @@ const char *_dhcp_option_to_string(uint8_t option)
 	}
 }
 =

-bool _dhcp_message_iter_init(struct dhcp_message_iter *iter,
-				const struct dhcp_message *message, size_t len)
-{
-	if (!message)
-		return false;
-
-	if (len < sizeof(struct dhcp_message))
-		return false;
-
-	if (L_BE32_TO_CPU(message->magic) !=3D DHCP_MAGIC)
-		return false;
-
-	memset(iter, 0, sizeof(*iter));
-	iter->message =3D message;
-	iter->message_len =3D len;
-	iter->max =3D len - sizeof(struct dhcp_message);
-	iter->options =3D message->options;
-	iter->can_overload =3D true;
-
-	return true;
-}
-
-static bool next_option(struct dhcp_message_iter *iter,
-				uint8_t *t, uint8_t *l, const void **v)
-{
-	uint8_t type;
-	uint8_t len;
-
-	while (iter->pos < iter->max) {
-		type =3D iter->options[iter->pos];
-
-		switch (type) {
-		case DHCP_OPTION_PAD:
-			iter->pos +=3D 1;
-			continue;
-		case DHCP_OPTION_END:
-			return false;
-		default:
-			break;
-		}
-
-		if (iter->pos + 2 >=3D iter->max)
-			return false;
-
-		len =3D iter->options[iter->pos + 1];
-
-		if (iter->pos + 2 + len > iter->max)
-			return false;
-
-		*t =3D type;
-		*l =3D len;
-		*v =3D &iter->options[iter->pos + 2];
-
-		iter->pos +=3D 2 + len;
-		return true;
-	}
-
-	return false;
-}
-
-bool _dhcp_message_iter_next(struct dhcp_message_iter *iter, uint8_t *type,
-				uint8_t *len, const void **data)
-{
-	bool r;
-	uint8_t t, l;
-	const void *v;
-
-	do {
-		r =3D next_option(iter, &t, &l, &v);
-		if (!r) {
-			iter->can_overload =3D false;
-
-			if (iter->overload_file) {
-				iter->options =3D iter->message->file;
-				iter->pos =3D 0;
-				iter->max =3D sizeof(iter->message->file);
-				iter->overload_file =3D false;
-				continue;
-			}
-
-			if (iter->overload_sname) {
-				iter->options =3D iter->message->sname;
-				iter->pos =3D 0;
-				iter->max =3D sizeof(iter->message->sname);
-				iter->overload_sname =3D false;
-				continue;
-			}
-
-			return r;
-		}
-
-		switch (t) {
-		case DHCP_OPTION_OVERLOAD:
-			if (l !=3D 1)
-				continue;
-
-			if (!iter->can_overload)
-				continue;
-
-			if (l_get_u8(v) & DHCP_OVERLOAD_FILE)
-				iter->overload_file =3D true;
-
-			if (l_get_u8(v) & DHCP_OVERLOAD_SNAME)
-				iter->overload_sname =3D true;
-
-			continue;
-		default:
-			if (type)
-				*type =3D t;
-
-			if (len)
-				*len =3D l;
-
-			if (data)
-				*data =3D v;
-			return r;
-		}
-	} while (true);
-
-	return false;
-}
-
-int _dhcp_option_append(uint8_t **buf, size_t *buflen, uint8_t code,
-					size_t optlen, const void *optval)
-{
-	if (!buf || !buflen)
-		return -EINVAL;
-
-	switch (code) {
-
-	case DHCP_OPTION_PAD:
-	case DHCP_OPTION_END:
-		if (*buflen < 1)
-			return -ENOBUFS;
-
-		(*buf)[0] =3D code;
-		*buf +=3D 1;
-		*buflen -=3D 1;
-		break;
-
-	default:
-		if (*buflen < optlen + 2)
-			return -ENOBUFS;
-
-		if (!optval)
-			return -EINVAL;
-
-		(*buf)[0] =3D code;
-		(*buf)[1] =3D optlen;
-		memcpy(&(*buf)[2], optval, optlen);
-
-		*buf +=3D optlen + 2;
-		*buflen -=3D (optlen + 2);
-
-		break;
-	}
-
-	return 0;
-}
-
 static void dhcp_message_set_address_type(struct dhcp_message *message,
 						uint8_t addr_type,
 						uint8_t addr_len)
-- =

2.26.2

--===============4333670074569032392==--

