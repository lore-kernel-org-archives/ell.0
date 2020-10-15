Content-Type: multipart/mixed; boundary="===============6498774541482458297=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 02/14] dhcp-util: add dhcp message builder APIs
Date: Thu, 15 Oct 2020 10:17:19 -0700
Message-ID: <20201015171731.396538-2-prestwoj@gmail.com>
In-Reply-To: <20201015171731.396538-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6498774541482458297==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

A new file was added, dhcp-util.c. Some enums/constant values
were moved from dhcp.c into dhcp-private.h for use with the
new builder APIs.
---
 Makefile.am        |   1 +
 ell/dhcp-private.h |  33 ++++++++++
 ell/dhcp-util.c    | 160 +++++++++++++++++++++++++++++++++++++++++++++
 ell/dhcp.c         |  16 -----
 4 files changed, 194 insertions(+), 16 deletions(-)
 create mode 100644 ell/dhcp-util.c

diff --git a/Makefile.am b/Makefile.am
index 9b3e3c9..beba535 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -127,6 +127,7 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
 			ell/dhcp6.c \
 			ell/dhcp6-transport.c \
 			ell/dhcp6-lease.c \
+			ell/dhcp-util.c \
 			ell/cert.c \
 			ell/cert-private.h \
 			ell/ecc-private.h \
diff --git a/ell/dhcp-private.h b/ell/dhcp-private.h
index a75bb8b..3aa89fb 100644
--- a/ell/dhcp-private.h
+++ b/ell/dhcp-private.h
@@ -27,6 +27,17 @@ enum {
 	DHCP_PORT_CLIENT =3D 68,
 };
 =

+enum dhcp_message_type {
+	DHCP_MESSAGE_TYPE_DISCOVER =3D 1,
+	DHCP_MESSAGE_TYPE_OFFER =3D 2,
+	DHCP_MESSAGE_TYPE_REQUEST =3D 3,
+	DHCP_MESSAGE_TYPE_DECLINE =3D 4,
+	DHCP_MESSAGE_TYPE_ACK =3D 5,
+	DHCP_MESSAGE_TYPE_NAK =3D 6,
+	DHCP_MESSAGE_TYPE_RELEASE =3D 7,
+	DHCP_MESSAGE_TYPE_INFORM =3D 8,
+};
+
 /* RFC 2131, Table 1 */
 enum dhcp_op_code {
 	DHCP_OP_CODE_BOOTREQUEST =3D 1,
@@ -35,6 +46,11 @@ enum dhcp_op_code {
 =

 #define DHCP_MAGIC 0x63825363
 =

+/* RFC 2132, Section 9.6. DHCP Message Type */
+#define DHCP_OPTION_MESSAGE_TYPE 53
+#define DHCP_OPTION_PAD 0 /* RFC 2132, Section 3.1 */
+#define DHCP_OPTION_END 255 /* RFC 2132, Section 3.2 */
+
 /* RFC 2131, Figure 1 */
 struct dhcp_message {
 	uint8_t op;
@@ -126,3 +142,20 @@ struct l_dhcp_lease {
 struct l_dhcp_lease *_dhcp_lease_new(void);
 void _dhcp_lease_free(struct l_dhcp_lease *lease);
 struct l_dhcp_lease *_dhcp_lease_parse_options(struct dhcp_message_iter *i=
ter);
+
+struct dhcp_message_builder {
+	unsigned int max;
+	uint8_t *pos;
+	uint8_t *start;
+};
+
+bool _dhcp_message_builder_init(struct dhcp_message_builder *builder,
+				struct dhcp_message *message,
+				size_t len, uint8_t type);
+bool _dhcp_message_builder_append(struct dhcp_message_builder *builder,
+					uint8_t code, size_t optlen,
+					const void *optval);
+bool _dhcp_message_builder_append_prl(struct dhcp_message_builder *builder,
+					const unsigned long *reqopts);
+uint8_t *_dhcp_message_builder_finalize(struct dhcp_message_builder *build=
er,
+					size_t *outlen);
diff --git a/ell/dhcp-util.c b/ell/dhcp-util.c
new file mode 100644
index 0000000..44ab1e2
--- /dev/null
+++ b/ell/dhcp-util.c
@@ -0,0 +1,160 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2020  Intel Corporation. All rights reserved.
+ *
+ *  This library is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU Lesser General Public
+ *  License as published by the Free Software Foundation; either
+ *  version 2.1 of the License, or (at your option) any later version.
+ *
+ *  This library is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ *  Lesser General Public License for more details.
+ *
+ *  You should have received a copy of the GNU Lesser General Public
+ *  License along with this library; if not, write to the Free Software
+ *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 =
 USA
+ *
+ */
+#include <stdint.h>
+#include <linux/types.h>
+#include <errno.h>
+#include <stdbool.h>
+#include <stddef.h>
+#include <string.h>
+#include <arpa/inet.h>
+
+#include "dhcp-private.h"
+#include "private.h"
+
+#define BITS_PER_LONG (sizeof(unsigned long) * 8)
+
+static void dhcp_init_header(struct dhcp_message *message, uint8_t type)
+{
+	switch (type) {
+	case DHCP_MESSAGE_TYPE_OFFER:
+	case DHCP_MESSAGE_TYPE_NAK:
+	case DHCP_MESSAGE_TYPE_ACK:
+		message->op =3D DHCP_OP_CODE_BOOTREPLY;
+		break;
+	default:
+		message->op =3D DHCP_OP_CODE_BOOTREQUEST;
+		break;
+	}
+
+	message->htype =3D 1;
+	message->hlen =3D 6;
+	message->magic =3D htonl(DHCP_MAGIC);
+	message->options[0] =3D DHCP_OPTION_END;
+}
+
+#define LEN_CHECK(builder, next) \
+	if (builder->pos - builder->start + next > builder->max) \
+		return false;
+
+bool _dhcp_message_builder_append(struct dhcp_message_builder *builder,
+					uint8_t code, size_t optlen,
+					const void *optval)
+{
+	switch (code) {
+	case DHCP_OPTION_PAD:
+	case DHCP_OPTION_END:
+		LEN_CHECK(builder, 1);
+
+		builder->pos[0] =3D code;
+		builder->pos +=3D 1;
+		break;
+	default:
+		LEN_CHECK(builder, optlen + 2);
+
+		builder->pos[0] =3D code;
+		builder->pos[1] =3D optlen;
+		memcpy(builder->pos + 2, optval, optlen);
+
+		builder->pos +=3D optlen + 2;
+		break;
+	}
+
+	return true;
+}
+
+bool _dhcp_message_builder_append_prl(struct dhcp_message_builder *builder,
+					const unsigned long *reqopts)
+{
+	uint8_t optlen =3D 0;
+	unsigned int i;
+	unsigned int j;
+
+	for (i =3D 0; i < 256 / BITS_PER_LONG; i++)
+		optlen +=3D __builtin_popcountl(reqopts[i]);
+
+	/*
+	 * This function assumes that there's enough space to put the PRL
+	 * into the buffer without resorting to file or sname overloading
+	 */
+	LEN_CHECK(builder, optlen + 2U);
+
+	i =3D 0;
+	builder->pos[i++] =3D DHCP_OPTION_PARAMETER_REQUEST_LIST;
+	builder->pos[i++] =3D optlen;
+
+	for (j =3D 0; j < 256; j++) {
+		if (reqopts[j / BITS_PER_LONG] & 1UL << (j % BITS_PER_LONG)) {
+			builder->pos[i++] =3D j;
+		}
+	}
+
+	builder->pos +=3D optlen + 2;
+
+	return true;
+}
+
+bool _dhcp_message_builder_init(struct dhcp_message_builder *builder,
+				struct dhcp_message *message,
+				size_t len, uint8_t type)
+{
+	if (!builder || !message || !len)
+		return false;
+
+	builder->max =3D len;
+	builder->pos =3D (uint8_t *) message->options;
+	builder->start =3D (uint8_t *) message;
+
+	dhcp_init_header(message, type);
+
+	return _dhcp_message_builder_append(builder, DHCP_OPTION_MESSAGE_TYPE,
+						1, &type);
+}
+
+static inline int dhcp_message_optimize(struct dhcp_message *message,
+					const uint8_t *end)
+{
+	/*
+	 * Don't bother sending a full sized dhcp_message as it is most likely
+	 * mostly zeros.  Instead truncate it at DHCP_OPTION_END and align to
+	 * the nearest 4 byte boundary.  Many implementations expect a packet
+	 * of a certain size or it is filtered, so we cap the length in
+	 * accordance to RFC 1542:
+	 * "The IP Total Length and UDP Length must be large enough to contain
+	 * the minimal BOOTP header of 300 octets"
+	 */
+	size_t len =3D align_len(end - (uint8_t *) message, 4);
+	if (len < 300)
+		len =3D 300;
+
+	return len;
+}
+
+uint8_t *_dhcp_message_builder_finalize(struct dhcp_message_builder *build=
er,
+					size_t *outlen)
+{
+	_dhcp_message_builder_append(builder, DHCP_OPTION_END, 0, NULL);
+
+	*outlen =3D dhcp_message_optimize((struct dhcp_message *)builder->start,
+				builder->pos);
+
+	return builder->start;
+}
diff --git a/ell/dhcp.c b/ell/dhcp.c
index fd548b5..097bf3d 100644
--- a/ell/dhcp.c
+++ b/ell/dhcp.c
@@ -50,9 +50,6 @@
 =

 #define BITS_PER_LONG (sizeof(unsigned long) * 8)
 =

-#define DHCP_OPTION_PAD 0 /* RFC 2132, Section 3.1 */
-#define DHCP_OPTION_END 255 /* RFC 2132, Section 3.2 */
-
 /* RFC 2132, Section 9.3. Option Overload */
 #define DHCP_OPTION_OVERLOAD 52
 enum dhcp_option_overload {
@@ -61,19 +58,6 @@ enum dhcp_option_overload {
 	DHCP_OVERLOAD_BOTH =3D 3,
 };
 =

-/* RFC 2132, Section 9.6. DHCP Message Type */
-#define DHCP_OPTION_MESSAGE_TYPE 53
-enum dhcp_message_type {
-	DHCP_MESSAGE_TYPE_DISCOVER =3D 1,
-	DHCP_MESSAGE_TYPE_OFFER =3D 2,
-	DHCP_MESSAGE_TYPE_REQUEST =3D 3,
-	DHCP_MESSAGE_TYPE_DECLINE =3D 4,
-	DHCP_MESSAGE_TYPE_ACK =3D 5,
-	DHCP_MESSAGE_TYPE_NAK =3D 6,
-	DHCP_MESSAGE_TYPE_RELEASE =3D 7,
-	DHCP_MESSAGE_TYPE_INFORM =3D 8,
-};
-
 #define DHCP_OPTION_PARAMETER_REQUEST_LIST 55 /* Section 9.8 */
 #define DHCP_OPTION_MAXIMUM_MESSAGE_SIZE 57 /* Section 9.10 */
 #define DHCP_OPTION_CLIENT_IDENTIFIER 61 /* Section 9.14 */
-- =

2.26.2

--===============6498774541482458297==--

