Content-Type: multipart/mixed; boundary="===============6939854876171826023=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 7/8] tls: Make tls_prf_get_bytes static
Date: Sat, 17 Nov 2018 14:38:10 +0100
Message-ID: <20181117133811.5470-7-andrew.zaborowski@intel.com>
In-Reply-To: <20181117133811.5470-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6939854876171826023==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

tls_prf_get_bytes is not used outside tls.c and everyone can use
l_tls_prf_get_bytes()
---
 ell/tls-private.h | 6 ------
 ell/tls.c         | 2 +-
 2 files changed, 1 insertion(+), 7 deletions(-)

diff --git a/ell/tls-private.h b/ell/tls-private.h
index 8cd3423..0d8592a 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -265,12 +265,6 @@ void tls_cert_free_certchain(struct tls_cert *cert);
 =

 enum tls_cert_key_type tls_cert_get_pubkey_type(struct tls_cert *cert);
 =

-void tls_prf_get_bytes(struct l_tls *tls,
-				const void *secret, size_t secret_len,
-				const char *label,
-				const void *seed, size_t seed_len,
-				uint8_t *buf, size_t len);
-
 #define TLS_DEBUG(fmt, args...)	\
 	l_util_debug(tls->debug_handler, tls->debug_data, "%s:%i " fmt,	\
 			__func__, __LINE__, ## args)
diff --git a/ell/tls.c b/ell/tls.c
index baa4583..6f80705 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -113,7 +113,7 @@ void tls12_prf(enum l_checksum_type type, size_t hash_l=
en,
 	l_checksum_free(hmac);
 }
 =

-void tls_prf_get_bytes(struct l_tls *tls,
+static void tls_prf_get_bytes(struct l_tls *tls,
 				const void *secret, size_t secret_len,
 				const char *label,
 				const void *seed, size_t seed_len,
-- =

2.19.1


--===============6939854876171826023==--

