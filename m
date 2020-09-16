Content-Type: multipart/mixed; boundary="===============0283592731526116973=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/2] unit: Test l_settings_{get,set}_bytes
Date: Wed, 16 Sep 2020 03:11:08 +0200
Message-ID: <20200916011108.508987-2-andrew.zaborowski@intel.com>
In-Reply-To: <20200916011108.508987-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0283592731526116973==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-settings.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/unit/test-settings.c b/unit/test-settings.c
index fa3a533..a25197a 100644
--- a/unit/test-settings.c
+++ b/unit/test-settings.c
@@ -434,6 +434,8 @@ static void test_set_methods(const void *test_data)
 	bool b;
 	const char *v;
 	char *s;
+	uint8_t *bytes;
+	size_t len;
 =

 	settings =3D l_settings_new();
 =

@@ -503,6 +505,18 @@ static void test_set_methods(const void *test_data)
 	assert(v);
 	assert(!strcmp(v, "\\s\\\\Text\t\\n\\r\\\\"));
 =

+	/* Bytes test */
+	assert(l_settings_set_bytes(settings, "Main", "Bytes",
+					(uint8_t []) { 10, 11, 0, 12, 13 }, 5));
+	bytes =3D l_settings_get_bytes(settings, "Main", "Bytes", &len);
+	assert(bytes);
+	assert(len =3D=3D 5);
+	assert(!memcmp(bytes, (uint8_t []) { 10, 11, 0, 12, 13 }, 5));
+	l_free(bytes);
+	v =3D l_settings_get_value(settings, "Main", "Bytes");
+	assert(v);
+	assert(!strcmp(v, "0a0b000c0d"));
+
 	l_settings_free(settings);
 }
 =

-- =

2.25.1

--===============0283592731526116973==--

