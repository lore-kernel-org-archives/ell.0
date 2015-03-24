Content-Type: multipart/mixed; boundary="===============8680617952362643374=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 2/2] unit: Add unit test to build set rekey offload
Date: Tue, 24 Mar 2015 07:36:08 -0500
Message-ID: <1427200568-23220-2-git-send-email-denkenz@gmail.com>
In-Reply-To: <1427200568-23220-1-git-send-email-denkenz@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8680617952362643374==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-genl-msg.c | 44 +++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 43 insertions(+), 1 deletion(-)

diff --git a/unit/test-genl-msg.c b/unit/test-genl-msg.c
index f9ebf21..e052f33 100644
--- a/unit/test-genl-msg.c
+++ b/unit/test-genl-msg.c
@@ -31,7 +31,7 @@
 =

 #include "ell/genl-private.h"
 =

-static bool do_print =3D false;
+static bool do_print =3D true;
 =

 static void do_debug(const char *str, void *user_data)
 {
@@ -204,6 +204,46 @@ static void parse_set_rekey_offload(const void *data)
 	l_genl_msg_unref(msg);
 }
 =

+static void build_set_rekey_offload(const void *data)
+{
+	static uint32_t index =3D 3;
+	static const unsigned char kek[] =3D {
+		0x2f, 0x82, 0xbb, 0x0d, 0x93, 0x56, 0x60, 0x4b,
+		0xb1, 0x55, 0x1c, 0x85, 0xc0, 0xeb, 0x32, 0x8b };
+	static const unsigned char kck[] =3D {
+		0x43, 0x25, 0xcf, 0x08, 0x0b, 0x92, 0xa7, 0x2d,
+		0x86, 0xdc, 0x43, 0x21, 0xd6, 0x0c, 0x12, 0x03 };
+	static const unsigned char replay_counter[] =3D {
+		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01 };
+	struct l_genl_msg *msg;
+	const void *raw;
+	size_t size;
+
+	msg =3D l_genl_msg_new_sized(79, 512);
+	assert(msg);
+
+	assert(l_genl_msg_append_attr(msg, 3, 4, &index));
+
+	assert(l_genl_msg_enter_nested(msg, 122));
+	assert(l_genl_msg_append_attr(msg, 1, 16, kek));
+	assert(l_genl_msg_append_attr(msg, 2, 16, kck));
+	assert(l_genl_msg_append_attr(msg, 3, 8, replay_counter));
+	assert(l_genl_msg_leave_nested(msg));
+
+	raw =3D _genl_msg_as_bytes(msg, 0x1b, 0x05, 0x53e1a359, 0xe74002ba,
+					&size);
+	if (do_print) {
+		l_util_hexdump(false, raw, size, do_debug, "[MSG] ");
+		l_util_hexdump(true, set_rekey_offload_request, size,
+					do_debug, "[MSG] ");
+	}
+
+	assert(size =3D=3D sizeof(set_rekey_offload_request));
+	assert(!memcmp(raw, set_rekey_offload_request, size));
+
+	l_genl_msg_unref(msg);
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_add("Parse Set Station Request", parse_set_station, NULL);
@@ -211,6 +251,8 @@ int main(int argc, char *argv[])
 				parse_set_rekey_offload, NULL);
 =

 	l_test_add("Build Set Station Request", build_set_station, NULL);
+	l_test_add("Build Set Rekey Offload Request",
+				build_set_rekey_offload, NULL);
 =

 	return l_test_run();
 }
-- =

2.0.4


--===============8680617952362643374==--

