Content-Type: multipart/mixed; boundary="===============9107555587830611161=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH] unit: Make gencerts.sh work on more distros
Date: Wed, 16 Aug 2017 15:51:04 -0700
Message-ID: <20170816225104.28209-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9107555587830611161==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

/bin/sh is more universally available than /usr/bin/sh
---
 unit/gencerts.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/unit/gencerts.sh b/unit/gencerts.sh
index 790c715..b0249fb 100755
--- a/unit/gencerts.sh
+++ b/unit/gencerts.sh
@@ -1,4 +1,4 @@
-#!/usr/bin/sh
+#!/bin/sh
 =

 echo "*** CA Certificate ***"
 openssl genrsa -out cert-ca-key.pem 2048
-- =

2.14.1


--===============9107555587830611161==--

