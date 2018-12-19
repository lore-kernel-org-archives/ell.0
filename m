Content-Type: multipart/mixed; boundary="===============6339637496560898737=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/9] tls: Add TLS version number printf macros
Date: Wed, 19 Dec 2018 01:57:54 +0100
Message-ID: <20181219005800.12013-3-andrew.zaborowski@intel.com>
In-Reply-To: <20181219005800.12013-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6339637496560898737==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/tls-private.h |  3 +++
 ell/tls.c         | 17 +++++++++++------
 2 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/ell/tls-private.h b/ell/tls-private.h
index 16f142b..2e254b2 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -257,4 +257,7 @@ int tls_parse_certificate_list(const void *data, size_t=
 len,
 		tls_disconnect(tls, desc, local_desc);	\
 	} while (0)
 =

+#define TLS_VER_FMT		"1.%i"
+#define TLS_VER_ARGS(version)	(((version) & 0xff) - 1)
+
 const char *tls_handshake_state_to_str(enum tls_handshake_state state);
diff --git a/ell/tls.c b/ell/tls.c
index e913642..eb459ce 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -535,14 +535,17 @@ static bool tls_cipher_suite_is_compatible(struct l_t=
ls *tls,
 =

 	if (suite->encryption &&
 			suite->encryption->cipher_type =3D=3D TLS_CIPHER_AEAD) {
-		if (tls->negotiated_version &&
-				tls->negotiated_version < TLS_V12) {
+		uint16_t negotiated =3D tls->negotiated_version;
+
+		if (negotiated && negotiated < TLS_V12) {
 			if (error) {
 				*error =3D error_buf;
 				snprintf(error_buf, sizeof(error_buf),
 						"Cipher suite %s uses an AEAD "
-						"cipher but TLS < 1.2 was "
-						"negotiated", suite->name);
+						"cipher (TLS 1.2+) but "
+						TLS_VER_FMT " was negotiated",
+						suite->name,
+						TLS_VER_ARGS(negotiated));
 			}
 =

 			return false;
@@ -1587,7 +1590,8 @@ static void tls_handle_client_hello(struct l_tls *tls,
 			if (i !=3D HANDSHAKE_HASH_SHA1 && i !=3D HANDSHAKE_HASH_MD5)
 				tls_drop_handshake_hash(tls, i);
 =

-	TLS_DEBUG("Negotiated TLS 1.%i", (tls->negotiated_version & 0xff) - 1);
+	TLS_DEBUG("Negotiated TLS " TLS_VER_FMT,
+			TLS_VER_ARGS(tls->negotiated_version));
 =

 	/* Select a cipher suite according to client's preference list */
 	while (cipher_suites_size) {
@@ -1715,7 +1719,8 @@ static void tls_handle_server_hello(struct l_tls *tls,
 			if (i !=3D HANDSHAKE_HASH_SHA1 && i !=3D HANDSHAKE_HASH_MD5)
 				tls_drop_handshake_hash(tls, i);
 =

-	TLS_DEBUG("Negotiated TLS 1.%i", (tls->negotiated_version & 0xff) - 1);
+	TLS_DEBUG("Negotiated TLS " TLS_VER_FMT,
+			TLS_VER_ARGS(tls->negotiated_version));
 =

 	/* Set the new cipher suite and compression method structs */
 	tls->pending.cipher_suite =3D tls_find_cipher_suite(cipher_suite_id);
-- =

2.19.1


--===============6339637496560898737==--

