Content-Type: multipart/mixed; boundary="===============4673681521881962510=="
MIME-Version: 1.0
From: Martin =?unknown-8bit?q?Hundeb=C3=B8ll?= <martin@geanix.com>
Subject: [PATCH] key: export l_key_get_info
Date: Fri, 31 Aug 2018 11:40:51 +0200
Message-ID: <20180831094051.10364-1-martin@geanix.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4673681521881962510==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The function is listed in the header, so it should be exported from the
shared library too.
---
 ell/key.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/key.c b/ell/key.c
index 4093143..6b16e55 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -398,7 +398,7 @@ static const char *lookup_checksum(enum l_checksum_type=
 checksum)
 	return ret;
 }
 =

-bool l_key_get_info(struct l_key *key, enum l_key_cipher_type cipher,
+LIB_EXPORT bool l_key_get_info(struct l_key *key, enum l_key_cipher_type c=
ipher,
 			enum l_checksum_type checksum, size_t *bits,
 			bool *public)
 {
-- =

2.18.0


--===============4673681521881962510==--

