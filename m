Content-Type: multipart/mixed; boundary="===============5558291820084611598=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/7] settings: Fix a format string
Date: Thu, 01 Nov 2018 03:12:14 +0100
Message-ID: <20181101021220.19073-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5558291820084611598==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The %d conersion specifier is for integers.
---
 ell/settings.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/settings.c b/ell/settings.c
index c6cb0ff..e3e8303 100644
--- a/ell/settings.c
+++ b/ell/settings.c
@@ -1068,7 +1068,7 @@ LIB_EXPORT bool l_settings_set_double(struct l_settin=
gs *settings,
 {
 	L_AUTO_FREE_VAR(char *, buf);
 =

-	buf =3D l_strdup_printf("%d", in);
+	buf =3D l_strdup_printf("%f", in);
 =

 	return l_settings_set_value(settings, group_name, key, buf);
 }
-- =

2.19.1


--===============5558291820084611598==--

