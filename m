Content-Type: multipart/mixed; boundary="===============8445709464589472234=="
MIME-Version: 1.0
From: Michael Tretter <michael.tretter@posteo.net>
Subject: [PATCH 2/2] utf8: Fix expected bytes in l_utf8_get_codepoint
Date: Thu, 21 Mar 2019 00:31:45 +0100
Message-ID: <20190320233145.8063-2-michael.tretter@posteo.net>
In-Reply-To: <20190320233145.8063-1-michael.tretter@posteo.net>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8445709464589472234==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

UTF-8 requires the form 10xxxxxx for the second, third and forth bytes
of a well-formed byte sequences. Therefore, comparing with 0 is not
sufficient to exclude ill-formed byte sequences, but the first two bit
must follow the specified form.

Without this check, iwd crashes if it encounters Latin-1 Supplement
encoded SSIDs during scanning, because they are erroneously accepted as
valid UTF-8.
---
 ell/utf8.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/utf8.c b/ell/utf8.c
index e9998f7..f8750d8 100644
--- a/ell/utf8.c
+++ b/ell/utf8.c
@@ -109,7 +109,7 @@ LIB_EXPORT int l_utf8_get_codepoint(const char *str, si=
ze_t len, wchar_t *cp)
 	val =3D str[0] & (0xff >> (expect_bytes + 1));
 =

 	for (i =3D 1; i < expect_bytes; i++) {
-		if ((str[i] & 0xc0) =3D=3D 0)
+		if ((str[i] & 0xc0) !=3D 0x80)
 			goto error;
 =

 		val <<=3D 6;
-- =

2.21.0


--===============8445709464589472234==--

