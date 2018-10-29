Content-Type: multipart/mixed; boundary="===============0590477632893007513=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 4/5] ell: Make tls-private.h header self-contained.
Date: Mon, 29 Oct 2018 13:07:14 -0700
Message-ID: <20181029200715.28427-5-ossama.othman@intel.com>
In-Reply-To: <20181029200715.28427-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0590477632893007513==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add a missing struct iovec forward declaration, and include the
appropriate headers in tls-private.h to make it self-contained.  This
simplifies its use so that files that include it need not be forced to
include other headers it requires.
---
 ell/cipher.h      | 1 +
 ell/tls-private.h | 4 ++++
 2 files changed, 5 insertions(+)

diff --git a/ell/cipher.h b/ell/cipher.h
index d787f33..6b43458 100644
--- a/ell/cipher.h
+++ b/ell/cipher.h
@@ -27,6 +27,7 @@
 extern "C" {
 #endif
 =

+struct iovec;
 struct l_cipher;
 =

 enum l_cipher_type {
diff --git a/ell/tls-private.h b/ell/tls-private.h
index 8cf5be9..0da7d21 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -20,6 +20,10 @@
  *
  */
 =

+#include <ell/checksum.h>
+#include <ell/cipher.h>
+#include <ell/tls.h>
+
 /* Only TLS 1.2 supported */
 #define TLS_V12		((3 << 8) | 3)
 #define TLS_V11		((3 << 8) | 2)
-- =

2.17.1


--===============0590477632893007513==--

