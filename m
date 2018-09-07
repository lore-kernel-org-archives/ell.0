Content-Type: multipart/mixed; boundary="===============4893721569595446750=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 2/3] unit: Print message if test-hwdb does not find a database
Date: Fri, 07 Sep 2018 13:12:49 -0700
Message-ID: <20180907201250.17651-2-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20180907201250.17651-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4893721569595446750==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-hwdb.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/unit/test-hwdb.c b/unit/test-hwdb.c
index 073a1d0..3c4bdf6 100644
--- a/unit/test-hwdb.c
+++ b/unit/test-hwdb.c
@@ -69,8 +69,10 @@ int main(int argc, char *argv[])
 	struct l_hwdb *hwdb;
 =

 	hwdb =3D l_hwdb_new_default();
-	if (!hwdb)
+	if (!hwdb) {
+		printf("hwdb.bin not loaded\n");
 		return 0;
+	}
 =

 	l_hwdb_foreach(hwdb, print_entry, NULL);
 =

-- =

2.18.0


--===============4893721569595446750==--

