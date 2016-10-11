Content-Type: multipart/mixed; boundary="===============5342201556181222891=="
MIME-Version: 1.0
From: Thomas Hindoe Paaboel Andersen <phomes@gmail.com>
Subject: [PATCH] key: return proper value and avoid leak
Date: Tue, 11 Oct 2016 23:38:04 +0200
Message-ID: <20161011213804.25873-1-phomes@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5342201556181222891==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The return value was incorrect for bool. The code should also go to
'done' to free sig_hash.
---
 ell/key.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/ell/key.c b/ell/key.c
index ad88d81..a71bdc8 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -603,8 +603,10 @@ LIB_EXPORT bool l_key_verify(struct l_key *key,
 	uint8_t *sig_hash =3D l_malloc(len_sig);
 =

 	/* Other checksum types are not yet supported */
-	if (checksum !=3D L_CHECKSUM_NONE)
-		return -EINVAL;
+	if (checksum !=3D L_CHECKSUM_NONE) {
+		success =3D false;
+		goto done;
+	}
 =

 	/* The keyctl verify implementation compares the verify results
 	 * before we get a chance to unpad it. Instead, use the *encrypt*
-- =

2.9.3


--===============5342201556181222891==--

