Content-Type: multipart/mixed; boundary="===============0621866861535768268=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 1/2] util: Fix skipped characters in strsplit functions
Date: Thu, 07 Jan 2016 16:26:50 -0800
Message-ID: <1452212811-7026-1-git-send-email-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0621866861535768268==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

l_strsplit and l_strsplit_sep were skipping an extra character after
each delimiter because len was incremented after being set to 0 but
before the next iteration of the loop began. This caused problems with
trailing and consecutive delimiters.
---
 ell/util.c | 20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

diff --git a/ell/util.c b/ell/util.c
index 5bd7b3b..f920895 100644
--- a/ell/util.c
+++ b/ell/util.c
@@ -293,9 +293,15 @@ LIB_EXPORT char **l_strsplit(const char *str, const ch=
ar sep)
 =

 	ret =3D l_new(char *, len + 1);
 =

-	for (i =3D 0, p =3D str, len =3D 0; p[len]; len++) {
-		if (p[len] !=3D sep)
+	i =3D 0;
+	p =3D str;
+	len =3D 0;
+
+	while (p[len]) {
+		if (p[len] !=3D sep) {
+			len +=3D 1;
 			continue;
+		}
 =

 		ret[i++] =3D l_strndup(p, len);
 		p +=3D len + 1;
@@ -347,9 +353,15 @@ LIB_EXPORT char **l_strsplit_set(const char *str, cons=
t char *separators)
 =

 	ret =3D l_new(char *, len + 1);
 =

-	for (i =3D 0, p =3D str, len =3D 0; p[len]; len++) {
-		if (sep_table[(unsigned char) p[len]] !=3D true)
+	i =3D 0;
+	p =3D str;
+	len =3D 0;
+
+	while (p[len]) {
+		if (sep_table[(unsigned char) p[len]] !=3D true) {
+			len +=3D 1;
 			continue;
+		}
 =

 		ret[i++] =3D l_strndup(p, len);
 		p +=3D len + 1;
-- =

2.7.0


--===============0621866861535768268==--

