Content-Type: multipart/mixed; boundary="===============4922129515914860151=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 3/5] siphash: Fix fallthrough compiler warnings
Date: Tue, 11 Jul 2017 16:04:59 -0700
Message-ID: <20170711230501.5419-4-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20170711230501.5419-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4922129515914860151==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add "Fall through" comments to document that the lack of break
statements is deliberate in _siphash24(). The -Wimplicit-fallthrough
flag on newer compilers flags this as a warning, which stops
compilation.
---
 ell/siphash.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/ell/siphash.c b/ell/siphash.c
index c57f48f..c9ceac3 100644
--- a/ell/siphash.c
+++ b/ell/siphash.c
@@ -101,16 +101,22 @@ void _siphash24(uint8_t out[8], const uint8_t *in, si=
ze_t inlen,
 	switch (left) {
 	case 7:
 		b |=3D ((uint64_t) in[6]) << 48;
+		/* Fall through */
 	case 6:
 		b |=3D ((uint64_t) in[5]) << 40;
+		/* Fall through */
 	case 5:
 		b |=3D ((uint64_t) in[4]) << 32;
+		/* Fall through */
 	case 4:
 		b |=3D ((uint64_t) in[3]) << 24;
+		/* Fall through */
 	case 3:
 		b |=3D ((uint64_t) in[2]) << 16;
+		/* Fall through */
 	case 2:
 		b |=3D ((uint64_t) in[1]) << 8;
+		/* Fall through */
 	case 1:
 		b |=3D ((uint64_t) in[0]);
 		break;
-- =

2.13.2


--===============4922129515914860151==--

