Content-Type: multipart/mixed; boundary="===============7608159399652411182=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] pem: Write encrypted flag in load_container with .crt format
Date: Thu, 11 Mar 2021 00:22:57 +0100
Message-ID: <20210310232257.955127-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7608159399652411182==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Make sure a value is written to *out_encrypted whenever
l_cert_load_container_file() returns success.  Specifically we were
forgetting to do this with raw DER-encoded certificates.  Fixes the
following valgrind warning (sometimes test failure) in test-pem:

=3D=3D1142=3D=3D Conditional jump or move depends on uninitialised value(s)
=3D=3D1142=3D=3D    at 0x10B427: test_load_file (test-pem.c:369)
=3D=3D1142=3D=3D    by 0x10CF53: l_test_run (test.c:83)
=3D=3D1142=3D=3D    by 0x10BC19: main (test-pem.c:523)
=3D=3D1142=3D=3D
test-pem: unit/test-pem.c:369: test_load_file: Assertion `encrypted =3D=3D =
params->expect_encrypted' failed.
---
 ell/cert.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/ell/cert.c b/ell/cert.c
index 8463a1d..c489f60 100644
--- a/ell/cert.c
+++ b/ell/cert.c
@@ -1413,6 +1413,9 @@ static int cert_try_load_der_format(const uint8_t *co=
ntent, size_t content_len,
 			if (out_privkey)
 				*out_privkey =3D NULL;
 =

+			if (out_encrypted)
+				*out_encrypted =3D false;
+
 			return 0;
 		}
 =

-- =

2.27.0

--===============7608159399652411182==--

