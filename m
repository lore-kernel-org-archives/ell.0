Content-Type: multipart/mixed; boundary="===============5285243375333417697=="
MIME-Version: 1.0
From: Tedd Ho-Jeong An <hj.tedd.an@gmail.com>
Subject: [PATCH] config: Stop config if it cannot find the required program
Date: Thu, 04 Feb 2021 00:21:45 -0500
Message-ID: <20210204052145.186165-1-hj.tedd.an@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5285243375333417697==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

From: Tedd Ho-Jeong An <tedd.an@intel.com>

This patch stops the config and displays an error message if the
config cannot find the required program like xxd or openssl when
the maintainer mode is enabled.
---
 configure.ac | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/configure.ac b/configure.ac
index 9924aac..a815f6f 100644
--- a/configure.ac
+++ b/configure.ac
@@ -126,7 +126,13 @@ AM_CONDITIONAL(GLIB, test "${enable_glib}" =3D "yes")
 =

 if (test "$USE_MAINTAINER_MODE" =3D "yes"); then
 	AC_CHECK_PROG(have_openssl, [openssl], [yes], [no])
+	if (test "${have_openssl}" !=3D "yes"); then
+		AC_MSG_ERROR(openssl is required)
+	fi
 	AC_CHECK_PROG(have_xxd, [xxd], [yes], [no])
+	if (test "${have_xxd}" !=3D "yes"); then
+		AC_MSG_ERROR(xxd is required)
+	fi
 fi
 =

 AM_CONDITIONAL(DBUS_TESTS, test "${little_endian}" =3D "yes")
-- =

2.29.2

--===============5285243375333417697==--

