Content-Type: multipart/mixed; boundary="===============1095089727856097623=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/3] unit: Update genl tests after l_genl_msg_to_data removal
Date: Fri, 08 Jan 2021 02:13:24 +0100
Message-ID: <20210108011324.1551320-3-andrew.zaborowski@intel.com>
In-Reply-To: <20210108011324.1551320-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1095089727856097623==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-genl-msg.c | 33 +++++++++++++++++++++++++--------
 1 file changed, 25 insertions(+), 8 deletions(-)

diff --git a/unit/test-genl-msg.c b/unit/test-genl-msg.c
index 1653da1..ed286cc 100644
--- a/unit/test-genl-msg.c
+++ b/unit/test-genl-msg.c
@@ -101,8 +101,9 @@ static void build_set_station(const void *data)
 		{ 0x24, 0xa2, 0xe1, 0xec, 0x17, 0x04 };
 	static uint32_t flags[] =3D { 2, 2 };
 	struct l_genl_msg *msg;
-	const void *raw;
+	void *raw;
 	size_t size;
+	const struct l_buf *buf;
 =

 	msg =3D l_genl_msg_new_sized(18, 512);
 	assert(msg);
@@ -111,7 +112,8 @@ static void build_set_station(const void *data)
 	assert(l_genl_msg_append_attr(msg, 6, 6, mac));
 	assert(l_genl_msg_append_attr(msg, 67, 8, flags));
 =

-	raw =3D l_genl_msg_to_data(msg, 0x17, 0x05, 0x550d538b, 3604, &size);
+	buf =3D l_genl_msg_get_buf(msg, 0x17, 0x05, 0x550d538b, 3604);
+	raw =3D l_buf_get_data(buf, &size);
 =

 	if (do_print) {
 		l_util_hexdump(false, raw, size, do_debug, "[MSG] ");
@@ -122,6 +124,7 @@ static void build_set_station(const void *data)
 	assert(size =3D=3D sizeof(set_station_request));
 	assert(!memcmp(raw, set_station_request, size));
 =

+	l_free(raw);
 	l_genl_msg_unref(msg);
 }
 =

@@ -215,8 +218,9 @@ static void build_set_rekey_offload(const void *data)
 	static const unsigned char replay_counter[] =3D {
 		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01 };
 	struct l_genl_msg *msg;
-	const void *raw;
+	void *raw;
 	size_t size;
+	const struct l_buf *buf;
 =

 	msg =3D l_genl_msg_new_sized(79, 0);
 	assert(msg);
@@ -229,8 +233,9 @@ static void build_set_rekey_offload(const void *data)
 	assert(l_genl_msg_append_attr(msg, 3, 8, replay_counter));
 	assert(l_genl_msg_leave_nested(msg));
 =

-	raw =3D l_genl_msg_to_data(msg, 0x1b, 0x05, 0x53e1a359, 0xe74002ba,
-					&size);
+	buf =3D l_genl_msg_get_buf(msg, 0x1b, 0x05, 0x53e1a359, 0xe74002ba);
+	raw =3D l_buf_get_data(buf, &size);
+
 	if (do_print) {
 		l_util_hexdump(false, raw, size, do_debug, "[MSG] ");
 		l_util_hexdump(true, set_rekey_offload_request, size,
@@ -240,6 +245,7 @@ static void build_set_rekey_offload(const void *data)
 	assert(size =3D=3D sizeof(set_rekey_offload_request));
 	assert(!memcmp(raw, set_rekey_offload_request, size));
 =

+	l_free(raw);
 	l_genl_msg_unref(msg);
 }
 =

@@ -335,8 +341,9 @@ static void build_libnl_nested(const void *data)
 {
 	static uint32_t index =3D 1;
 	struct l_genl_msg *msg;
-	const void *raw;
+	void *raw;
 	size_t size;
+	const struct l_buf *buf;
 =

 	msg =3D l_genl_msg_new_sized(1, 16);
 	assert(msg);
@@ -352,8 +359,9 @@ static void build_libnl_nested(const void *data)
 	assert(l_genl_msg_leave_nested(msg));
 	assert(l_genl_msg_leave_nested(msg));
 =

-	raw =3D l_genl_msg_to_data(msg, 0x15, 0x05, 0x55130572, 0x0c406877,
-					&size);
+	buf =3D l_genl_msg_get_buf(msg, 0x15, 0x05, 0x55130572, 0x0c406877);
+	raw =3D l_buf_get_data(buf, &size);
+
 	if (do_print) {
 		l_util_hexdump(false, raw, size, do_debug, "[MSG] ");
 		l_util_hexdump(true, libnl_nested, sizeof(libnl_nested),
@@ -363,6 +371,7 @@ static void build_libnl_nested(const void *data)
 	assert(size =3D=3D sizeof(libnl_nested));
 	assert(!memcmp(raw, libnl_nested, size));
 =

+	l_free(raw);
 	l_genl_msg_unref(msg);
 }
 =

@@ -393,6 +402,8 @@ static void test_append_attrv(const void *data)
 	uint16_t attr_type;
 	uint16_t attr_len;
 	const void *attr_payload;
+	void *raw;
+	size_t size;
 =

 	assert(L_ARRAY_SIZE(iov) =3D=3D num_blocks);
 =

@@ -400,6 +411,12 @@ static void test_append_attrv(const void *data)
 	assert(msg);
 =

 	assert(l_genl_msg_append_attrv(msg, type, iov, L_ARRAY_SIZE(iov)));
+	raw =3D l_buf_get_data(l_genl_msg_get_buf(msg, 0, 0, 0, 0), &size);
+	l_genl_msg_unref(msg);
+
+	msg =3D l_genl_msg_new_from_data(raw, size);
+	l_free(raw);
+	assert(msg);
 	assert(l_genl_attr_init(&attr, msg));
 	assert(l_genl_attr_next(&attr, &attr_type, &attr_len, &attr_payload));
 =

-- =

2.27.0

--===============1095089727856097623==--

