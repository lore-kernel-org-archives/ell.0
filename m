Content-Type: multipart/mixed; boundary="===============0274378261753853959=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH v2 1/3] unit: Fix memory leak in trust chain test
Date: Mon, 24 Oct 2016 14:36:31 -0700
Message-ID: <20161024213633.10668-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0274378261753853959==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-key.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/unit/test-key.c b/unit/test-key.c
index 1195da4..455ebb4 100644
--- a/unit/test-key.c
+++ b/unit/test-key.c
@@ -460,8 +460,10 @@ static void test_trust_chain(const void *data)
 	l_keyring_free(trust);
 	l_keyring_free(ring);
 	l_key_free(cakey);
+	l_key_free(intkey);
 	l_key_free(key);
 	l_free(cacert);
+	l_free(intcert);
 	l_free(cert);
 }
 =

-- =

2.10.1


--===============0274378261753853959==--

