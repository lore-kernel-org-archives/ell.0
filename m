Content-Type: multipart/mixed; boundary="===============6472502364104404399=="
MIME-Version: 1.0
From: James Prestwood <prestwoj at gmail.com>
To: ell at lists.01.org
Subject: [PATCH] utf8: fixed bit shift larger than type size
Date: Wed, 23 Feb 2022 15:30:20 -0800
Message-ID: <20220223233020.2723150-1-prestwoj@gmail.com>

--===============6472502364104404399==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The C standard requires the bit shift result value width to be greater
than or equal to the number of bits being shifted, otherwise the behavior
is undefined. In this case str[0] was being cast to an unsigned char
(1 byte) but being shifted 24 bits. This resulted, on some compilers,
with a runtime error:

runtime error: left shift of 255 by 24 places cannot be represented in type=
 'int'

Casting str[0] to an unsigned int satisfies the width requirements
for this bit shift.
---
 ell/utf8.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/utf8.c b/ell/utf8.c
index 84ab774..ceda1de 100644
--- a/ell/utf8.c
+++ b/ell/utf8.c
@@ -98,7 +98,7 @@ LIB_EXPORT int l_utf8_get_codepoint(const char *str, size=
_t len, wchar_t *cp)
 		return 1;
 	}
 =

-	expect_bytes =3D __builtin_clz(~((unsigned char)str[0] << 24));
+	expect_bytes =3D __builtin_clz(~((unsigned int)str[0] << 24));
 =

 	if (expect_bytes < 2 || expect_bytes > 4)
 		goto error;
-- =

2.34.1

--===============6472502364104404399==--

