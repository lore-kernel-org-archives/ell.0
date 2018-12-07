Content-Type: multipart/mixed; boundary="===============3118663862276197073=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH v3 5/5] gitignore: added ecc/ecdh unit tests
Date: Fri, 07 Dec 2018 09:11:31 -0800
Message-ID: <20181207171131.5741-5-james.prestwood@linux.intel.com>
In-Reply-To: <20181207171131.5741-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3118663862276197073==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 .gitignore | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/.gitignore b/.gitignore
index 16725f5..75ab7b2 100644
--- a/.gitignore
+++ b/.gitignore
@@ -56,6 +56,8 @@ unit/test-key
 unit/test-pbkdf2
 unit/test-dhcp
 unit/test-dir-watch
+unit/test-ecc
+unit/test-ecdh
 unit/cert-*.pem
 unit/cert-*.csr
 unit/cert-*.srl
-- =

2.17.1


--===============3118663862276197073==--

