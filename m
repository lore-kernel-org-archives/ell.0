Content-Type: multipart/mixed; boundary="===============4444125653494649260=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 2/4] unit: Separate tests for different kinds of invalid genl
 names
Date: Wed, 27 Sep 2017 17:22:03 -0700
Message-ID: <20170928002205.17218-2-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20170928002205.17218-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4444125653494649260==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Long names now fail earlier and require a different test.
---
 unit/test-genl.c | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/unit/test-genl.c b/unit/test-genl.c
index db6d917..a381e25 100644
--- a/unit/test-genl.c
+++ b/unit/test-genl.c
@@ -92,7 +92,7 @@ static bool prep_family_vanished(struct l_genl *genl,
 	 * Use a bogus family name to trigger the vanished watch to
 	 * be called during the ELL event loop run.
 	 */
-	static const char BOGUS_GENL_NAME[] =3D "bogus_genl_family";
+	static const char BOGUS_GENL_NAME[] =3D "bogusgenlfamily";
 =

 	data->vanished_family =3D l_genl_family_new(genl, BOGUS_GENL_NAME);
 	return l_genl_family_set_watches(data->vanished_family,
@@ -100,6 +100,15 @@ static bool prep_family_vanished(struct l_genl *genl,
 						data, NULL);
 }
 =

+static bool name_too_long(struct l_genl *genl, struct test_data *data)
+{
+	static const char LONG_GENL_NAME[] =3D "long_genl_family_name";
+
+	assert(!l_genl_family_new(genl, LONG_GENL_NAME));
+
+	return true;
+}
+
 static bool check_test_data(struct test_data *data)
 {
     return data->group_id !=3D 0 && data->vanished_called;
@@ -154,6 +163,8 @@ int main(int argc, char *argv[])
 	assert(prep_family_appeared(genl, &data));
 	assert(prep_family_vanished(genl, &data));
 =

+	assert(name_too_long(genl, &data));
+
 	idle =3D l_idle_create(idle_callback, &data, NULL);
 =

 	l_main_run();
-- =

2.14.1


--===============4444125653494649260==--

