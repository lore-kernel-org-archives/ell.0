Content-Type: multipart/mixed; boundary="===============4165209893280788129=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH v5 09/12] unit: update dhcp test to use new builder APIs
Date: Mon, 19 Oct 2020 16:28:11 -0700
Message-ID: <20201019232814.1541221-9-prestwoj@gmail.com>
In-Reply-To: <20201019232814.1541221-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4165209893280788129==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-dhcp.c | 83 +++++++++++++++++++++---------------------------
 1 file changed, 37 insertions(+), 46 deletions(-)

diff --git a/unit/test-dhcp.c b/unit/test-dhcp.c
index 6ae8d71..955ed29 100644
--- a/unit/test-dhcp.c
+++ b/unit/test-dhcp.c
@@ -33,7 +33,7 @@
 #include <ell/ell.h>
 #include "ell/dhcp-private.h"
 =

-static bool verbose =3D false;
+static bool verbose =3D true;
 static uint8_t client_packet[1024];
 static size_t client_packet_len;
 =

@@ -365,9 +365,13 @@ static void test_option_8(const void *data)
 =

 static void test_option_set(const void *data)
 {
-	static uint8_t result[64] =3D {'A', 'B', 'C', 'D' };
+	struct dhcp_message_builder builder;
+	struct dhcp_message *message;
+	size_t outlen;
+	uint8_t *msg_out;
+	unsigned int i;
+	static uint8_t result[sizeof(struct dhcp_message) + 64];
 	static uint8_t options[64] =3D {
-			'A', 'B', 'C', 'D',
 			160, 2, 0x11, 0x12,
 			0,
 			31, 8, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38,
@@ -377,51 +381,38 @@ static void test_option_set(const void *data)
 			255
 	};
 =

-	size_t len, oldlen;
-	int pos, i;
-	uint8_t *opt;
+	message =3D (struct dhcp_message *)result;
 =

-	assert(_dhcp_option_append(NULL, NULL, 0, 0, NULL) =3D=3D -EINVAL);
-
-	len =3D 0;
-	opt =3D &result[0];
-	assert(_dhcp_option_append(&opt, NULL, 0, 0, NULL) =3D=3D -EINVAL);
-	assert(opt =3D=3D &result[0] && len =3D=3D 0);
-
-	assert(_dhcp_option_append(&opt, &len, 0, 0, NULL) =3D=3D -ENOBUFS);
-	assert(opt =3D=3D &result[0] && len =3D=3D 0);
-
-	opt =3D &result[4];
-	len =3D 1;
-	assert(_dhcp_option_append(&opt, &len, 0, 0, NULL) >=3D 0);
-	assert(opt =3D=3D &result[5] && len =3D=3D 0);
-
-	pos =3D 4;
-	len =3D 60;
-	while (pos < 64 && options[pos] !=3D 255) {
-		opt =3D &result[pos];
-		oldlen =3D len;
-
-		assert(_dhcp_option_append(&opt, &len, options[pos],
-						options[pos + 1],
-						&options[pos + 2]) >=3D 0);
-
-		if (options[pos] =3D=3D 0) {
-			assert(opt =3D=3D &result[pos + 1]);
-			assert(len =3D=3D oldlen - 1);
-			pos++;
-		} else {
-			assert(opt =3D=3D &result[pos + 2 + options[pos + 1]]);
-			assert(len =3D=3D oldlen - 2 - options[pos + 1]);
-			pos +=3D 2 + options[pos + 1];
-		}
-	}
+	/* test a few failure conditions */
+	assert(!_dhcp_message_builder_init(NULL, NULL, 0, 0));
+	assert(!_dhcp_message_builder_init(&builder, message, 0, 0));
+
+	_dhcp_message_builder_init(&builder, message, sizeof(result),
+					DHCP_MESSAGE_TYPE_DISCOVER);
+	_dhcp_message_builder_append(&builder, 160, 2, options + 2);
+	_dhcp_message_builder_append(&builder, 0, 0, NULL);
+	_dhcp_message_builder_append(&builder, 31, 8, options + 7);
+	_dhcp_message_builder_append(&builder, 0, 0, NULL);
+	_dhcp_message_builder_append(&builder, 55, 3, options + 18);
+	_dhcp_message_builder_append(&builder, 17, 7, options + 23);
+	msg_out =3D _dhcp_message_builder_finalize(&builder, &outlen);
 =

-	for (i =3D 0; i < pos; i++) {
-		if (verbose)
-			l_info("%2d: 0x%02x(0x%02x)\n",
-					i, result[i], options[i]);
-		assert(result[i] =3D=3D options[i]);
+	/*
+	 * The builde APIs automatically append the type passed in during init
+	 * so we can skip over that in order to test the expected static data
+	 */
+
+	msg_out +=3D sizeof(struct dhcp_message) + 3;
+
+	for (i =3D 0; i < outlen - sizeof(struct dhcp_message); i++) {
+		if (msg_out[i] !=3D options[i]) {
+			if (verbose) {
+				l_info("byte[%d] did not match 0x%02x 0x%02x",
+					i, msg_out[i], options[i]);
+			}
+
+			assert(false);
+		}
 	}
 }
 =

-- =

2.26.2

--===============4165209893280788129==--

