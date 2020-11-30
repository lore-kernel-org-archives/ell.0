Content-Type: multipart/mixed; boundary="===============4815469108424749843=="
MIME-Version: 1.0
From: =?unknown-8bit?q?=C3=89rico?= Nogueira <ericonr@disroot.org>
Subject: [BUG] ELL doesn't have a fallback for rawmemchr
Date: Mon, 30 Nov 2020 13:49:47 -0300
Message-ID: <C7GR3VAGOXZZ.37PH59CQ2TJO2@mussels>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4815469108424749843==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi!

Building ELL 0.35 on a musl system fails, due to ell/pem.c using
rawmemchr(), which is a glibc extension. Building IWD with internal
ELL fails for the same reason.

I see that IWD itself has src/missing.h with a fallback, but ELL lacks
that.

We are using the following patch to fix the build:

diff --git a/ell/pem.c b/ell/pem.c
index 790f2c2..237ae02 100644
--- a/ell/pem.c
+++ b/ell/pem.c
@@ -224,7 +224,7 @@ static uint8_t *pem_load_buffer(const void *buf, size_t=
=3D
 buf_len,
=3D20
 		/* Check that each header line has a key and a colon */
 		while (start < end) {
-			const char *lf =3D3D rawmemchr(start, '\n');
+			const char *lf =3D3D memchr(start, '\n', end - start);
 			const char *colon =3D3D memchr(start, ':', lf - start);
=3D20
 			if (!colon)

--

If ELL is willing to include a src/missing.h of their own, that would
solve the issue, but avoiding rawmemchr() completely is also a
possibility.

Thanks,
=C3=89rico
--===============4815469108424749843==--

