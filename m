Content-Type: multipart/mixed; boundary="===============8501822479693430632=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH v8 1/4] pem: remove endp increment past eol
Date: Fri, 04 Oct 2019 11:53:04 -0700
Message-ID: <20191004185307.22707-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8501822479693430632==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Doing this could result in endp pointing past the bounds of the PEM
if the PEM does not have a final newline. In terms of calculating
the PEM length based off endp, we do want to take the byte into
account, but potentially returning an invalid pointer on 'success'
is not a great way to do this. It is now left up to the caller to
bounds check and increment endp themselves for calculating the
length or finding the next PEM.

The existing PEM parsers will also handle this newline if endp is
used directly (without incrementing) when parsing the next PEM in
a list, so removing the + 1 has no effect on other code in pem.c.
---
 ell/pem.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/pem.c b/ell/pem.c
index d8f57ed..3fa91cd 100644
--- a/ell/pem.c
+++ b/ell/pem.c
@@ -165,7 +165,7 @@ const char *pem_next(const void *buf, size_t buf_len, c=
har **type_label,
 				*base64_len =3D buf_ptr - base64_data;
 =

 			if (endp)
-				*endp =3D eol + 1;
+				*endp =3D eol;
 =

 			return base64_data;
 		}
-- =

2.17.1

--===============8501822479693430632==--

