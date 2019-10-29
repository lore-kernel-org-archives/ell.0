Content-Type: multipart/mixed; boundary="===============6836056443553809961=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/5] tls: Fix tls12_prf buffer size
Date: Tue, 29 Oct 2019 01:24:39 +0100
Message-ID: <20191029002443.23574-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6836056443553809961==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Enlarge the A(i) buffer to be able to hold the biggest possible hash
result (64) + the label + the biggest possible seed (64).  As reported
by Will Dietz the buffer size issue could cause crashes with the bigger
hashes when built under clang.

Reported-by: Will Dietz <w@wdtz.org>
---
 ell/tls.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/tls.c b/ell/tls.c
index 0e06c27..5efd928 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -92,7 +92,7 @@ bool tls12_prf(enum l_checksum_type type,
 {
 	struct l_checksum *hmac =3D l_checksum_new_hmac(type, secret, secret_len);
 	size_t a_len, chunk_len, prfseed_len =3D strlen(label) + seed_len;
-	uint8_t a[128], prfseed[prfseed_len];
+	uint8_t a[64 + prfseed_len], prfseed[prfseed_len];
 =

 	if (!hmac)
 		return false;
-- =

2.20.1

--===============6836056443553809961==--

