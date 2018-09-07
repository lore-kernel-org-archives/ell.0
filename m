Content-Type: multipart/mixed; boundary="===============6340901098429683542=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 3/3] unit: Report hwdb summary stats rather than dump the
 whole db
Date: Fri, 07 Sep 2018 13:12:50 -0700
Message-ID: <20180907201250.17651-3-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20180907201250.17651-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6340901098429683542==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-hwdb.c | 28 ++++++++++++++++++++--------
 1 file changed, 20 insertions(+), 8 deletions(-)

diff --git a/unit/test-hwdb.c b/unit/test-hwdb.c
index 3c4bdf6..d0efc8d 100644
--- a/unit/test-hwdb.c
+++ b/unit/test-hwdb.c
@@ -24,10 +24,16 @@
 #include <config.h>
 #endif
 =

+#include <assert.h>
 #include <stdio.h>
 =

 #include <ell/ell.h>
 =

+struct hwdb_stats {
+	int aliases;
+	int entries;
+};
+
 static void print_modalias(struct l_hwdb *hwdb, const char *format, ...)
 {
 	struct l_hwdb_entry *entries, *entry;
@@ -51,22 +57,26 @@ static void print_modalias(struct l_hwdb *hwdb, const c=
har *format, ...)
 	printf("\n");
 }
 =

-static void print_entry(const char *modalias,
-				struct l_hwdb_entry *entries, void *user_data)
+static void check_entry(const char *modalias, struct l_hwdb_entry *entries,
+			void *user_data)
 {
 	struct l_hwdb_entry *entry;
+	struct hwdb_stats *stats =3D user_data;
 =

-	printf("%s\n", modalias);
-
-	for (entry =3D entries; entry; entry =3D entry->next)
-		printf(" %s=3D%s\n", entry->key, entry->value);
+	assert(modalias);
+	stats->aliases++;
 =

-	printf("\n");
+	for (entry =3D entries; entry; entry =3D entry->next) {
+		assert(entry->key);
+		assert(entry->value);
+		stats->entries++;
+	}
 }
 =

 int main(int argc, char *argv[])
 {
 	struct l_hwdb *hwdb;
+	struct hwdb_stats stats =3D { 0 };
 =

 	hwdb =3D l_hwdb_new_default();
 	if (!hwdb) {
@@ -74,7 +84,9 @@ int main(int argc, char *argv[])
 		return 0;
 	}
 =

-	l_hwdb_foreach(hwdb, print_entry, NULL);
+	l_hwdb_foreach(hwdb, check_entry, &stats);
+	printf("Found %d aliases with %d total entries\n\n",
+	       stats.aliases, stats.entries);
 =

 	/* Bluetooth Interest Group Inc. */
 	print_modalias(hwdb, "OUI:000F79");
-- =

2.18.0


--===============6340901098429683542==--

