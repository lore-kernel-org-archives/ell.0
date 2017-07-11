Content-Type: multipart/mixed; boundary="===============5301631329483552287=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 2/5] unit: Better coverage of escaped characters in settings
 strings
Date: Tue, 11 Jul 2017 16:04:58 -0700
Message-ID: <20170711230501.5419-3-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20170711230501.5419-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5301631329483552287==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-settings.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/unit/test-settings.c b/unit/test-settings.c
index 674f7fe..04e073e 100644
--- a/unit/test-settings.c
+++ b/unit/test-settings.c
@@ -244,6 +244,16 @@ static void test_set_methods(const void *test_data)
 	assert(v);
 	assert(!strcmp(v, "\\s\\s\\tFoobar"));
 =

+	assert(l_settings_set_string(settings, "Main", "Escapes",
+					" \\Text\t\n\r\\"));
+	s =3D l_settings_get_string(settings, "Main", "Escapes");
+	assert(s);
+	assert(!strcmp(s, " \\Text\t\n\r\\"));
+	l_free(s);
+	v =3D l_settings_get_value(settings, "Main", "Escapes");
+	assert(v);
+	assert(!strcmp(v, "\\s\\\\Text\t\\n\\r\\\\"));
+
 	l_settings_free(settings);
 }
 =

-- =

2.13.2


--===============5301631329483552287==--

