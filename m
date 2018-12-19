Content-Type: multipart/mixed; boundary="===============4877644685888062607=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/9] unit: Call l_tls_start in tls tests
Date: Wed, 19 Dec 2018 01:57:53 +0100
Message-ID: <20181219005800.12013-2-andrew.zaborowski@intel.com>
In-Reply-To: <20181219005800.12013-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4877644685888062607==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-tls.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/unit/test-tls.c b/unit/test-tls.c
index 813487d..6731a0e 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -483,6 +483,9 @@ static void test_tls_test(const void *data)
 	assert(l_tls_set_cacert(s[0].tls, test->server_ca_cert_path));
 	assert(l_tls_set_cacert(s[1].tls, test->client_ca_cert_path));
 =

+	assert(l_tls_start(s[0].tls));
+	assert(l_tls_start(s[1].tls));
+
 	while (1) {
 		if (s[0].raw_buf_len) {
 			l_tls_handle_rx(s[1].tls, s[0].raw_buf,
-- =

2.19.1


--===============4877644685888062607==--

