Content-Type: multipart/mixed; boundary="===============1036528108356252030=="
MIME-Version: 1.0
From: Will Dietz <w@wdtz.org>
Subject: [PATCH] ell/tls: fix crash, don't index through adj. stack objs
Date: Mon, 28 Oct 2019 14:41:12 -0500
Message-ID: <20191028194112.11921-1-w@wdtz.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1036528108356252030==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Building with clang may make this more likely to crash,
problem is encountered on ell/tls.c:114 (before).

Also, use memmove as src/dst may overlap.
---
 ell/tls.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/ell/tls.c b/ell/tls.c
index 0e06c27..50df446 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -92,7 +92,8 @@ bool tls12_prf(enum l_checksum_type type,
 {
 	struct l_checksum *hmac =3D l_checksum_new_hmac(type, secret, secret_len);
 	size_t a_len, chunk_len, prfseed_len =3D strlen(label) + seed_len;
-	uint8_t a[128], prfseed[prfseed_len];
+	uint8_t a[128 + prfseed_len];
+	uint8_t *prfseed =3D &a[128];
 =

 	if (!hmac)
 		return false;
@@ -108,10 +109,10 @@ bool tls12_prf(enum l_checksum_type type,
 		/* Generate A(i) */
 		l_checksum_reset(hmac);
 		l_checksum_update(hmac, a, a_len);
-		a_len =3D l_checksum_get_digest(hmac, a, sizeof(a));
+		a_len =3D l_checksum_get_digest(hmac, a, 128);
 =

 		/* Append seed & generate output */
-		memcpy(a + a_len, prfseed, prfseed_len);
+		memmove(a + a_len, prfseed, prfseed_len);
 		l_checksum_reset(hmac);
 		l_checksum_update(hmac, a, a_len + prfseed_len);
 =

-- =

2.24.0-rc1

--===============1036528108356252030==--

