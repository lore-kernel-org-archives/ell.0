Content-Type: multipart/mixed; boundary="===============0380624121665799435=="
MIME-Version: 1.0
From: Rosen Penev <rosenp@gmail.com>
Subject: [PATCH 1/3] ell: cast printf call to double
Date: Tue, 21 Jul 2020 15:39:57 -0700
Message-ID: <20200721223959.87135-1-rosenp@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0380624121665799435==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

%f confusingly enough takes a bool, not a float.
---
 ell/settings.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/settings.c b/ell/settings.c
index 945dff7..dac45c9 100644
--- a/ell/settings.c
+++ b/ell/settings.c
@@ -1320,7 +1320,7 @@ LIB_EXPORT bool l_settings_set_float(struct l_setting=
s *settings,
 {
 	L_AUTO_FREE_VAR(char *, buf);
 =

-	buf =3D l_strdup_printf("%f", in);
+	buf =3D l_strdup_printf("%f", (double)in);
 =

 	return l_settings_set_value(settings, group_name, key, buf);
 }
-- =

2.26.2

--===============0380624121665799435==--

