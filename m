Content-Type: multipart/mixed; boundary="===============8910380120783896133=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 03/11] unit: Free all memory allocated during the DH test
Date: Mon, 06 Jun 2016 13:54:42 -0700
Message-ID: <20160606205450.23615-3-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20160606205450.23615-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8910380120783896133==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-key.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/unit/test-key.c b/unit/test-key.c
index d655fed..53232da 100644
--- a/unit/test-key.c
+++ b/unit/test-key.c
@@ -328,6 +328,7 @@ static void test_dh(const void *data)
 	testkey_free_contents(&pub1);
 	testkey_free_contents(&priv2);
 	testkey_free_contents(&pub2);
+	l_free(secret);
 	l_free(buffer);
 }
 =

-- =

2.8.3


--===============8910380120783896133==--

