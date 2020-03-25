Content-Type: multipart/mixed; boundary="===============5818246878277021614=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] settings: Parse non-base-10 integer settings
Date: Wed, 25 Mar 2020 21:18:05 +0100
Message-ID: <20200325201805.4801-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5818246878277021614==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Change the stro{,u}{l,ll} base parameter to 0 to not disallow hex or
octal numbers, useful for bitmasks.
---
 ell/settings.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/ell/settings.c b/ell/settings.c
index c5e1184..f4326d6 100644
--- a/ell/settings.c
+++ b/ell/settings.c
@@ -998,7 +998,7 @@ LIB_EXPORT bool l_settings_get_int(const struct l_setti=
ngs *settings,
 =

 	errno =3D 0;
 =

-	t =3D r =3D strtol(value, &endp, 10);
+	t =3D r =3D strtol(value, &endp, 0);
 	if (*endp !=3D '\0')
 		goto error;
 =

@@ -1045,7 +1045,7 @@ LIB_EXPORT bool l_settings_get_uint(const struct l_se=
ttings *settings,
 =

 	errno =3D 0;
 =

-	t =3D r =3D strtoul(value, &endp, 10);
+	t =3D r =3D strtoul(value, &endp, 0);
 	if (*endp !=3D '\0')
 		goto error;
 =

@@ -1091,7 +1091,7 @@ LIB_EXPORT bool l_settings_get_int64(const struct l_s=
ettings *settings,
 =

 	errno =3D 0;
 =

-	r =3D strtoll(value, &endp, 10);
+	r =3D strtoll(value, &endp, 0);
 	if (*endp !=3D '\0')
 		goto error;
 =

@@ -1137,7 +1137,7 @@ LIB_EXPORT bool l_settings_get_uint64(const struct l_=
settings *settings,
 =

 	errno =3D 0;
 =

-	r =3D strtoull(value, &endp, 10);
+	r =3D strtoull(value, &endp, 0);
 	if (*endp !=3D '\0')
 		goto error;
 =

-- =

2.20.1

--===============5818246878277021614==--

