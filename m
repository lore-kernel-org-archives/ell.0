Content-Type: multipart/mixed; boundary="===============4053158485084326154=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH v10 1/4] pem: make endp setting smarter
Date: Fri, 04 Oct 2019 12:51:08 -0700
Message-ID: <20191004195111.8751-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4053158485084326154==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Always doing eol + 1 could result in endp pointing past the bounds
of the PEM if the PEM does not have a final newline. Now we check
that we aren't going past the bounds of the buffer before setting
endp, and if we are just set endp to eol.
---
 ell/pem.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/ell/pem.c b/ell/pem.c
index d8f57ed..9da2071 100644
--- a/ell/pem.c
+++ b/ell/pem.c
@@ -164,8 +164,12 @@ const char *pem_next(const void *buf, size_t buf_len, =
char **type_label,
 			if (base64_len)
 				*base64_len =3D buf_ptr - base64_data;
 =

-			if (endp)
-				*endp =3D eol + 1;
+			if (endp) {
+				if (eol =3D=3D buf + buf_len)
+					*endp =3D eol;
+				else
+					*endp =3D eol + 1;
+			}
 =

 			return base64_data;
 		}
-- =

2.17.1

--===============4053158485084326154==--

