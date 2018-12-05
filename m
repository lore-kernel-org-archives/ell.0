Content-Type: multipart/mixed; boundary="===============4386482849419883892=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH v2 5/5] gitignore: added ecc/ecdh unit tests
Date: Wed, 05 Dec 2018 09:38:05 -0800
Message-ID: <20181205173805.7141-5-james.prestwood@linux.intel.com>
In-Reply-To: <20181205173805.7141-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4386482849419883892==
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


--===============4386482849419883892==--

