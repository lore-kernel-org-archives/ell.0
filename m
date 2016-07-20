Content-Type: multipart/mixed; boundary="===============4965973362419183187=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 1/4] key: Update restrict method name
Date: Wed, 20 Jul 2016 15:19:25 -0700
Message-ID: <20160720221928.24488-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4965973362419183187==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Kernel now uses "restrict_by=3Dkeyring" instead of
"restrict_by=3Dsignature_keyring".
---
 ell/key.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/key.c b/ell/key.c
index e6ae92a..6117e31 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -243,7 +243,7 @@ LIB_EXPORT struct l_keyring *l_keyring_new(enum l_keyri=
ng_type type,
 =

 		payload =3D l_strdup_printf(
 			"restrict_type=3Dasymmetric "
-			"restrict_by=3Dsignature_keyring "
+			"restrict_by=3Dkeyring "
 			"restrict_key=3D%d",
 			trusted->serial);
 		payload_length =3D strlen(payload);
-- =

2.9.2


--===============4965973362419183187==--

