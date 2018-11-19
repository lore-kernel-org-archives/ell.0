Content-Type: multipart/mixed; boundary="===============2913554572907398614=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/7] asn1: Add length check in asn1_parse_definite_length
Date: Mon, 19 Nov 2018 19:23:42 +0100
Message-ID: <20181119182348.4562-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2913554572907398614==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

I'm going to be using asn1_parse_definite_length outside of the local
functions so add the missing length validation.
---
 ell/asn1-private.h | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/ell/asn1-private.h b/ell/asn1-private.h
index 4ba17ac..0c5897a 100644
--- a/ell/asn1-private.h
+++ b/ell/asn1-private.h
@@ -46,8 +46,14 @@ static inline int asn1_parse_definite_length(const uint8=
_t **buf,
 	int n;
 	size_t result =3D 0;
 =

-	(*len)--;
+	/* Decrease the buffer length left */
+	if ((*len)-- < 1)
+		return -1;
 =

+	/*
+	 * If short form length, move the pointer to start of data and
+	 * return the data length.
+	 */
 	if (!(**buf & 0x80))
 		return *(*buf)++;
 =

-- =

2.19.1


--===============2913554572907398614==--

