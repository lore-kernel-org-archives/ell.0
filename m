Content-Type: multipart/mixed; boundary="===============8311052079143466481=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [PATCH 4/4] unit: Add a message builder unit test for genl
Date: Tue, 10 Mar 2015 13:14:30 +0200
Message-ID: <1425986070-8808-5-git-send-email-tomasz.bursztyka@linux.intel.com>
In-Reply-To: <1425986070-8808-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8311052079143466481==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This tests quickly 2 mesasges, one with a nested attribute and one
without.
---
 unit/test-genl.c | 136 +++++++++++++++++++++++++++++++++++++++++++++++----=
----
 1 file changed, 117 insertions(+), 19 deletions(-)

diff --git a/unit/test-genl.c b/unit/test-genl.c
index 1764133..b5801f4 100644
--- a/unit/test-genl.c
+++ b/unit/test-genl.c
@@ -24,37 +24,135 @@
 #include <config.h>
 #endif
 =

-#include <sys/socket.h>
+#include <assert.h>
+#include <linux/if_ether.h>
+#include <linux/nl80211.h>
 =

 #include <ell/ell.h>
+#include <ell/genl-private.h>
 =

-static void do_debug(const char *str, void *user_data)
-{
-	const char *prefix =3D user_data;
+struct key_builder {
+	uint32_t index;
+	uint8_t key_index;
+	uint8_t mac[ETH_ALEN];
+	const char *tk;
+	size_t tk_len;
+	const char *rsc;
+	size_t rsc_len;
+	uint32_t cipher;
+	bool multicast;
+	const char *verification;
+	uint32_t verification_len;
+};
 =

-	l_info("%s%s", prefix, str);
-}
+static struct key_builder nl80211_nested_key =3D {
+	.index =3D 2,
+	.key_index =3D 1,
+	.tk =3D "\x6f\xe8\x7a\x88\x52\x3a\x9f\x8a"
+		"\x10\x2f\x8d\x2d\x99\xd8\xab\xbf",
+	.tk_len =3D 16,
+	.rsc =3D "\x0c\x00\x00\x00\x00\x00",
+	.rsc_len =3D 6,
+	.cipher =3D 0x000FAC04,
+	.multicast =3D true,
+	.verification =3D "\x00\x00\x00\x00\x00\x00\x00\x00"
+			"\x00\x00\x00\x00\x00\x00\x00\x00"
+			"\x00\x00\x00\x00\x08\x00\x03\x00"
+			"\x02\x00\x00\x00\x14\x00\x07\x00"
+			"\x6f\xe8\x7a\x88\x52\x3a\x9f\x8a"
+			"\x10\x2f\x8d\x2d\x99\xd8\xab\xbf"
+			"\x08\x00\x09\x00\x04\xac\x0f\x00"
+			"\x0a\x00\x0a\x00\x0c\x00\x00\x00"
+			"\x00\x00\x00\x00\x08\x00\x6e\x00"
+			"\x04\x00\x02\x00\x05\x00\x08\x00"
+			"\x01\x00\x00\x00",
+	.verification_len =3D 84,
+};
 =

-static void idle_callback(void *user_data)
-{
-	l_main_quit();
-}
+static struct key_builder nl80211_key =3D {
+	.index =3D 2,
+	.key_index =3D 0,
+	.mac =3D { 0xA0, 0x88, 0xB4, 0x21, 0xE2, 0xC8 },
+	.tk =3D "\x4a\x8c\x82\x09\x4c\xb8\x84\x55"
+		"\x3b\xdd\x28\xd2\xa1\x82\x17\xe4",
+	.tk_len =3D 16,
+	.rsc =3D "\x00\x00\x00\x00\x00\x00",
+	.rsc_len =3D 6,
+	.cipher =3D 0x000FAC04,
+	.verification =3D "\x00\x00\x00\x00\x00\x00\x00\x00"
+			"\x00\x00\x00\x00\x00\x00\x00\x00"
+			"\x00\x00\x00\x00\x08\x00\x03\x00"
+			"\x02\x00\x00\x00\x14\x00\x07\x00"
+			"\x4a\x8c\x82\x09\x4c\xb8\x84\x55"
+			"\x3b\xdd\x28\xd2\xa1\x82\x17\xe4"
+			"\x08\x00\x09\x00\x04\xac\x0f\x00"
+			"\x0a\x00\x0a\x00\x00\x00\x00\x00"
+			"\x00\x00\x00\x00\x0a\x00\x06\x00"
+			"\xa0\x88\xb4\x21\xe2\xc8\x00\x00"
+			"\x05\x00\x08\x00\x00\x00\x00\x00",
+	.verification_len =3D 88,
+};
 =

-int main(int argc, char *argv[])
+static void test_genl_msg_builder(const void *data)
 {
-	struct l_genl *genl;
+	const struct key_builder *key =3D data;
+	struct l_genl_msg *msg;
+	struct l_genl_msg_builder *builder;
+	const void *raw;
+	uint32_t len;
+	int r;
+
+	msg =3D l_genl_msg_new_sized(NL80211_CMD_NEW_KEY, 512);
+	assert(msg);
+
+	builder =3D l_genl_msg_builder_new(msg);
+	assert(builder);
 =

-	l_log_set_stderr();
+	/* Build the message */
+	l_genl_msg_builder_append_attribute(builder, NL80211_ATTR_IFINDEX,
+							4, &key->index);
+	l_genl_msg_builder_append_attribute(builder, NL80211_ATTR_KEY_DATA,
+							key->tk_len, key->tk);
+	l_genl_msg_builder_append_attribute(builder, NL80211_ATTR_KEY_CIPHER,
+							4, &key->cipher);
 =

-	genl =3D l_genl_new_default();
+	if (key->rsc && key->rsc_len)
+		l_genl_msg_builder_append_attribute(builder,
+							NL80211_ATTR_KEY_SEQ,
+							key->rsc_len,
+							key->rsc);
+	if (key->multicast) {
+		l_genl_msg_builder_enter_nested(builder,
+					NL80211_ATTR_KEY_DEFAULT_TYPES);
+		l_genl_msg_builder_append_attribute(builder,
+					NL80211_KEY_DEFAULT_TYPE_MULTICAST,
+					0, NULL);
+		l_genl_msg_builder_leave_nested(builder);
+	} else
+		l_genl_msg_builder_append_attribute(builder,
+					NL80211_ATTR_MAC, ETH_ALEN, key->mac);
 =

-	l_genl_set_debug(genl, do_debug, "[GENL] ", NULL);
+	l_genl_msg_builder_append_attribute(builder, NL80211_ATTR_KEY_IDX,
+							1, &key->key_index);
 =

-	l_idle_oneshot(idle_callback, NULL, NULL);
+	msg =3D l_genl_msg_builder_finalize(builder);
+	assert(msg);
 =

-	l_main_run();
+	raw =3D _genl_msg_get_as_raw_data(msg, &len);
+	assert((len =3D=3D key->verification_len));
+
+	r =3D memcmp(raw, key->verification, key->verification_len);
+	assert(!r);
+
+	l_genl_msg_builder_destroy(builder);
+}
+
+int main(int argc, char *argv[])
+{
+	l_test_init(&argc, &argv);
 =

-	l_genl_unref(genl);
+	l_test_add("nested msg", test_genl_msg_builder, &nl80211_nested_key);
+	l_test_add("normal msg", test_genl_msg_builder, &nl80211_key);
 =

-	return 0;
+	return l_test_run();
 }
-- =

2.0.5


--===============8311052079143466481==--

