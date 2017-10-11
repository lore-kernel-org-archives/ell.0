Content-Type: multipart/mixed; boundary="===============2059566385815138986=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 2/2] unit: Added test for l_genl_msg_append_attrv()
Date: Wed, 11 Oct 2017 15:12:39 -0700
Message-ID: <20171011221239.8656-3-ossama.othman@intel.com>
In-Reply-To: <20171011221239.8656-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2059566385815138986==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-genl-msg.c | 47 +++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 47 insertions(+)

diff --git a/unit/test-genl-msg.c b/unit/test-genl-msg.c
index 49de707..50068e9 100644
--- a/unit/test-genl-msg.c
+++ b/unit/test-genl-msg.c
@@ -366,6 +366,50 @@ static void build_libnl_nested(const void *data)
 	l_genl_msg_unref(msg);
 }
 =

+static void test_append_attrv(const void *data)
+{
+	static const int num_blocks =3D 3;
+	unsigned char * const payload =3D set_station_request;
+	const size_t total_len =3D L_ARRAY_SIZE(set_station_request);
+	const size_t block_len =3D total_len / num_blocks;
+	const struct iovec iov[] =3D {
+	    {
+		.iov_base =3D payload,
+		.iov_len  =3D block_len
+	    },
+	    {
+		.iov_base =3D payload + block_len,
+		.iov_len  =3D block_len
+	    },
+	    {
+		.iov_base =3D payload + block_len * 2,
+		.iov_len  =3D total_len - block_len * 2
+	    }
+	};
+
+	struct l_genl_msg *msg;
+	const uint16_t type =3D 2;
+	struct l_genl_attr attr;
+	uint16_t attr_type;
+	uint16_t attr_len;
+	const void *attr_payload;
+
+	assert(L_ARRAY_SIZE(iov) =3D=3D num_blocks);
+
+	msg =3D l_genl_msg_new_sized(1, NLA_HDRLEN + NLA_ALIGN(total_len));
+	assert(msg);
+
+	assert(l_genl_msg_append_attrv(msg, type, iov, L_ARRAY_SIZE(iov)));
+	assert(l_genl_attr_init(&attr, msg));
+	assert(l_genl_attr_next(&attr, &attr_type, &attr_len, &attr_payload));
+
+        assert(type =3D=3D attr_type);
+        assert(total_len =3D=3D attr_len);
+        assert(memcmp(payload, attr_payload, total_len) =3D=3D 0);
+
+	l_genl_msg_unref(msg);
+}
+
 int main(int argc, char *argv[])
 {
 	bool little_endian;
@@ -396,6 +440,9 @@ int main(int argc, char *argv[])
 	l_test_add("Build libnl-generated Example with Nesting",
 				build_libnl_nested, NULL);
 =

+	l_test_add("Test l_genl_msg_append_attrv",
+				test_append_attrv, NULL);
+
 done:
 	return l_test_run();
 }
-- =

2.11.0


--===============2059566385815138986==--

