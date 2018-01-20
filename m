Content-Type: multipart/mixed; boundary="===============4130789402166306702=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH] unit: Skip key crypto test if the kernel doesn't support it
Date: Fri, 19 Jan 2018 16:44:39 -0800
Message-ID: <20180120004439.11278-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4130789402166306702==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---

This is one approach to testing for key crypto functionality - I thought
I'd float it as a proposal for handling missing kernel features.

The l_key API fails cleanly when key crypto is not supported by the
kernel, but the unit test needs to differentiate between ELL bugs and
lack of kernel support.

If regular ELL programs need to query for kernel feature support, I
could add l_key_crypto_is_supported() instead.

Depending on how far back in kernel history we want to go, checks for DH
(kernel v4.7+) and keyring restriction (v4.12+) keyctls would be very
similar to this crypto check.


Mat



 unit/test-key.c | 20 +++++++++++++++++++-
 1 file changed, 19 insertions(+), 1 deletion(-)

diff --git a/unit/test-key.c b/unit/test-key.c
index f2526f5..81c9ee6 100644
--- a/unit/test-key.c
+++ b/unit/test-key.c
@@ -24,7 +24,11 @@
 #include <config.h>
 #endif
 =

+#define _GNU_SOURCE
 #include <assert.h>
+#include <unistd.h>
+#include <sys/syscall.h>
+#include <errno.h>
 =

 #include <ell/ell.h>
 =

@@ -497,6 +501,19 @@ static void test_trust_chain(const void *data)
 	l_free(cert);
 }
 =

+#ifndef KEYCTL_PKEY_QUERY
+#define KEYCTL_PKEY_QUERY	24
+#endif
+
+static bool kernel_has_key_crypto(void)
+{
+	long result =3D syscall(__NR_keyctl, KEYCTL_PKEY_QUERY, 0, 0, "", 0);
+
+	assert(result =3D=3D -1);
+
+	return (errno !=3D EOPNOTSUPP);
+}
+
 static void test_key_crypto(const void *data)
 {
 	uint8_t *cert;
@@ -626,7 +643,8 @@ int main(int argc, char *argv[])
 	l_test_add("trusted keyring", test_trusted_keyring, NULL);
 	l_test_add("trust chain", test_trust_chain, NULL);
 =

-	l_test_add("key crypto", test_key_crypto, NULL);
+	if (kernel_has_key_crypto())
+		l_test_add("key crypto", test_key_crypto, NULL);
 =

 	return l_test_run();
 }
-- =

2.16.0


--===============4130789402166306702==--

