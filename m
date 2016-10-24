Content-Type: multipart/mixed; boundary="===============7834099743482844866=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 5/5] unit: Fix memory leak in trust chain test
Date: Mon, 24 Oct 2016 11:44:56 -0700
Message-ID: <20161024184456.25743-5-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20161024184456.25743-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7834099743482844866==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-key.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/unit/test-key.c b/unit/test-key.c
index 124e2ce..e4d0ba4 100644
--- a/unit/test-key.c
+++ b/unit/test-key.c
@@ -460,8 +460,10 @@ static void test_trust_chain(const void *data)
 	l_keyring_free(trust, true);
 	l_keyring_free(ring, true);
 	l_key_free(cakey, true);
+	l_key_free(intkey, true);
 	l_key_free(key, true);
 	l_free(cacert);
+	l_free(intcert);
 	l_free(cert);
 }
 =

-- =

2.10.1


--===============7834099743482844866==--

