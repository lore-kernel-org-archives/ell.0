Content-Type: multipart/mixed; boundary="===============0285192335758691770=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/3] pem: Fix a bad l_free
Date: Thu, 10 Jan 2019 23:25:35 +0100
Message-ID: <20190110222537.14492-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0285192335758691770==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On error pem_load_buffer will not set @label so it may end up being
uninitialized when we l_free it.  pem_load_buffer may also fail under
normal circumstances at the end of file, make sure we only l_free(label)
if the call succeeded.
---
 ell/pem.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/ell/pem.c b/ell/pem.c
index fa08962..4a91bb3 100644
--- a/ell/pem.c
+++ b/ell/pem.c
@@ -284,8 +284,9 @@ LIB_EXPORT struct l_queue *l_pem_load_certificate_list(=
const char *filename)
 		der =3D pem_load_buffer(ptr, end - ptr, 0, &label, &der_len, &ptr);
 =

 		if (!der || strcmp(label, "CERTIFICATE")) {
+			if (der)
+				l_free(label);
 			l_free(der);
-			l_free(label);
 =

 			if (!ptr)	/* EOF */
 				break;
-- =

2.19.1


--===============0285192335758691770==--

