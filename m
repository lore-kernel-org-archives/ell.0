Content-Type: multipart/mixed; boundary="===============1241540763067560109=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 8/9] fixme: add mte to the set ci su patch
Date: Wed, 19 Dec 2018 01:57:59 +0100
Message-ID: <20181219005800.12013-8-andrew.zaborowski@intel.com>
In-Reply-To: <20181219005800.12013-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1241540763067560109==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/tls.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/ell/tls.c b/ell/tls.c
index 904784e..42db275 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -1625,7 +1625,7 @@ static void tls_handle_client_hello(struct l_tls *tls,
 	TLS_DEBUG("Negotiated TLS " TLS_VER_FMT,
 			TLS_VER_ARGS(tls->negotiated_version));
 =

-	if (tls->cipher_suite_pref_list) {
+	if (!tls->cipher_suite_pref_list) {
 		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
 				"No usable cipher suites");
 		return;
@@ -2846,10 +2846,10 @@ LIB_EXPORT void l_tls_set_version_range(struct l_tl=
s *tls,
 =

 bool tls_set_cipher_suites(struct l_tls *tls, const char **suite_list)
 {
-	unsigned int len;
 	struct tls_cipher_suite **suite;
 =

-	l_free(tls->cipher_suite_pref_list);
+	if (tls->cipher_suite_pref_list !=3D tls_cipher_suite_pref)
+		l_free(tls->cipher_suite_pref_list);
 =

 	if (!suite_list) {
 		/* Use our default cipher suite preference list */
@@ -2857,19 +2857,19 @@ bool tls_set_cipher_suites(struct l_tls *tls, const=
 char **suite_list)
 		return true;
 	}
 =

-	len =3D l_strv_length((char **) suite_list);
-	tls->cipher_suite_pref_list =3D l_new(struct tls_cipher_suite *, len + 1);
+	tls->cipher_suite_pref_list =3D l_new(struct tls_cipher_suite *,
+				l_strv_length((char **) suite_list) + 1);
 	suite =3D tls->cipher_suite_pref_list;
 =

 	for (; *suite_list; suite_list++) {
 		unsigned int i;
 =

-		for (i =3D 0; i < len; i++)
+		for (i =3D 0; i < L_ARRAY_SIZE(tls_cipher_suite_pref); i++)
 			if (!strcmp(tls_cipher_suite_pref[i]->name,
 						*suite_list))
 				break;
 =

-		if (i < len)
+		if (i < L_ARRAY_SIZE(tls_cipher_suite_pref))
 			*suite++ =3D tls_cipher_suite_pref[i];
 		else
 			TLS_DEBUG("Cipher suite %s is not supported",
-- =

2.19.1


--===============1241540763067560109==--

