Content-Type: multipart/mixed; boundary="===============0373018160643860995=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 09/12] tls: Make tls_prf_get_bytes static
Date: Wed, 14 Nov 2018 14:18:59 +0100
Message-ID: <20181114131902.1695-9-andrew.zaborowski@intel.com>
In-Reply-To: <20181114131902.1695-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0373018160643860995==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

tls_prf_get_bytes is not used outside tls.c and everyone can use
l_tls_prf_get_bytes()
---
 ell/tls-private.h | 7 -------
 ell/tls.c         | 2 +-
 2 files changed, 1 insertion(+), 8 deletions(-)

diff --git a/ell/tls-private.h b/ell/tls-private.h
index 5b76e73..0d8592a 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -265,13 +265,6 @@ void tls_cert_free_certchain(struct tls_cert *cert);
 =

 enum tls_cert_key_type tls_cert_get_pubkey_type(struct tls_cert *cert);
 =

-void tls_prf_get_bytes(struct l_tls *tls,
-				enum l_checksum_type type, size_t hash_len,
-				const void *secret, size_t secret_len,
-				const char *label,
-				const void *seed, size_t seed_len,
-				uint8_t *buf, size_t len);
-
 #define TLS_DEBUG(fmt, args...)	\
 	l_util_debug(tls->debug_handler, tls->debug_data, "%s:%i " fmt,	\
 			__func__, __LINE__, ## args)
diff --git a/ell/tls.c b/ell/tls.c
index 0645897..534d22c 100644
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


--===============0373018160643860995==--

