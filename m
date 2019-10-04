Content-Type: multipart/mixed; boundary="===============8719895823640695810=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH] pem: ensure we dont side-effect type_label
Date: Fri, 04 Oct 2019 15:40:24 -0700
Message-ID: <20191004224024.3541-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8719895823640695810==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

In pem_load_buffer, l_base64_decode could fail. If it does we were
still keeping type_label set. Instead use a temporary variable to
hold the label, and only set if l_base64_decode succeeds. Otherwise
free the temp label and return NULL.
---
 ell/pem.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/ell/pem.c b/ell/pem.c
index 9da2071..c6481ef 100644
--- a/ell/pem.c
+++ b/ell/pem.c
@@ -198,13 +198,23 @@ static uint8_t *pem_load_buffer(const void *buf, size=
_t buf_len,
 {
 	size_t base64_len;
 	const char *base64;
+	char *label;
+	uint8_t *ret;
 =

-	base64 =3D pem_next(buf, buf_len, type_label, &base64_len,
+	base64 =3D pem_next(buf, buf_len, &label, &base64_len,
 				NULL, false);
 	if (!base64)
 		return NULL;
 =

-	return l_base64_decode(base64, base64_len, len);
+	ret =3D l_base64_decode(base64, base64_len, len);
+	if (ret) {
+		*type_label =3D label;
+		return ret;
+	}
+
+	l_free(label);
+
+	return NULL;
 }
 =

 LIB_EXPORT uint8_t *l_pem_load_buffer(const void *buf, size_t buf_len,
-- =

2.17.1

--===============8719895823640695810==--

