Content-Type: multipart/mixed; boundary="===============4489568451385138563=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/5] gvariant: _gvariant_num_children error check
Date: Sat, 23 Apr 2016 03:10:03 +0200
Message-ID: <1461373807-19793-2-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1461373807-19793-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4489568451385138563==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/gvariant-util.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/ell/gvariant-util.c b/ell/gvariant-util.c
index 88bb74e..17606f8 100644
--- a/ell/gvariant-util.c
+++ b/ell/gvariant-util.c
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


--===============4489568451385138563==--

