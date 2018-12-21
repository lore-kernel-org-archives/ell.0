Content-Type: multipart/mixed; boundary="===============4733980804653174010=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 4/7] ecc: Relax length check in l_ecc_point_from_data
Date: Fri, 21 Dec 2018 23:03:23 +0100
Message-ID: <20181221220326.10112-4-andrew.zaborowski@intel.com>
In-Reply-To: <20181221220326.10112-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4733980804653174010==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

l_ecc_point_from_data handles four point formats and for the first three
the parser allows the len parameter to be longer than the ECC data while
for L_ECC_POINT_TYPE_FULL it checks that len is exactly the size of the
point data, relax this check to allow higher len values.
---
 ell/ecc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/ecc.c b/ell/ecc.c
index a59e8e4..6d9ab42 100644
--- a/ell/ecc.c
+++ b/ell/ecc.c
@@ -314,7 +314,7 @@ LIB_EXPORT struct l_ecc_point *l_ecc_point_from_data(
 =

 		break;
 	case L_ECC_POINT_TYPE_FULL:
-		if (len !=3D bytes * 2)
+		if (len < bytes * 2)
 			goto failed;
 =

 		_ecc_be2native(p->y, (void *) data + bytes, curve->ndigits);
-- =

2.19.1


--===============4733980804653174010==--

