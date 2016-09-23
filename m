Content-Type: multipart/mixed; boundary="===============4772941426185045084=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 3/9] key: Update restricted keyring syscall syntax
Date: Fri, 23 Sep 2016 16:02:16 -0700
Message-ID: <20160923230222.27401-3-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20160923230222.27401-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4772941426185045084==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/key.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/ell/key.c b/ell/key.c
index 83888c6..b529f8a 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -500,9 +500,7 @@ LIB_EXPORT struct l_keyring *l_keyring_new(enum l_keyri=
ng_type type,
 			return NULL;
 =

 		payload =3D l_strdup_printf(
-			"restrict_type=3Dasymmetric "
-			"restrict_by=3Dkeyring "
-			"restrict_key=3D%d",
+			"restrict=3Dasymmetric:key_or_keyring:%d",
 			trusted->serial);
 		payload_length =3D strlen(payload);
 	} else if (type !=3D L_KEYRING_SIMPLE) {
-- =

2.10.0


--===============4772941426185045084==--

