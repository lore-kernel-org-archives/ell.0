Content-Type: multipart/mixed; boundary="===============8081701721640236731=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH v2 10/11] gvariant: Fix empty structure/array parsing and
 error check
Date: Tue, 12 Apr 2016 03:56:14 +0200
Message-ID: <1460426175-25501-10-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1460426175-25501-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8081701721640236731==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Allow empty signatures in _gvariant_num_children and check the return
value for errors or we might crash.
---
 ell/gvariant-util.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/ell/gvariant-util.c b/ell/gvariant-util.c
index fa1ca45..07b4874 100644
--- a/ell/gvariant-util.c
+++ b/ell/gvariant-util.c
@@ -201,14 +201,14 @@ int _gvariant_num_children(const char *sig)
 	if (strlen(sig) > 255)
 		return false;
 =

-	do {
+	while (*s) {
 		s =3D validate_next_type(s, &a);
 =

 		if (!s)
 			return -1;
 =

 		num_children +=3D 1;
-	} while (*s);
+	}
 =

 	return num_children;
 }
@@ -374,7 +374,7 @@ static bool gvariant_iter_init_internal(struct l_dbus_m=
essage_iter *iter,
 		unsigned int alignment : 4;
 		size_t end;		/* Index past the end of the type */
 	} *children;
-	uint8_t n_children;
+	int n_children;
 =

 	if (sig_end) {
 		size_t len =3D sig_end - sig_start;
@@ -392,6 +392,9 @@ static bool gvariant_iter_init_internal(struct l_dbus_m=
essage_iter *iter,
 	iter->pos =3D 0;
 =

 	n_children =3D _gvariant_num_children(subsig);
+	if (n_children < 0)
+		return false;
+
 	children =3D l_new(struct gvariant_type_info, n_children);
 =

 	for (p =3D sig_start, i =3D 0; i < n_children; i++) {
-- =

2.5.0


--===============8081701721640236731==--

