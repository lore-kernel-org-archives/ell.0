Content-Type: multipart/mixed; boundary="===============5210480306580507484=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/2] dbus: Fix Dbus1 parsing of doubles
Date: Fri, 29 Apr 2016 05:31:55 +0200
Message-ID: <1461900728-20662-3-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1461900728-20662-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5210480306580507484==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Don't decode the 8-byte value as uint64_t and then cast to double
because that will produce a different number.  Gvariant already does
this right.
---
 ell/dbus-util.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/ell/dbus-util.c b/ell/dbus-util.c
index 6414216..1298228 100644
--- a/ell/dbus-util.c
+++ b/ell/dbus-util.c
@@ -675,17 +675,11 @@ bool _dbus1_iter_next_entry_basic(struct l_dbus_messa=
ge_iter *iter,
 		iter->pos =3D pos + 8;
 		break;
 	case 't':
-		if (pos + 8 > iter->len)
-			return false;
-		uint64_val =3D get_u64(iter->data + pos);
-		*(uint64_t *) out =3D uint64_val;
-		iter->pos =3D pos + 8;
-		break;
 	case 'd':
 		if (pos + 8 > iter->len)
 			return false;
 		uint64_val =3D get_u64(iter->data + pos);
-		*(double *) out =3D (double) uint64_val;
+		*(uint64_t *) out =3D uint64_val;
 		iter->pos =3D pos + 8;
 		break;
 	default:
-- =

2.5.0


--===============5210480306580507484==--

