Content-Type: multipart/mixed; boundary="===============7709379431085231528=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/9] unit: Call l_tls_start in tls tests
Date: Thu, 13 Dec 2018 20:57:39 +0100
Message-ID: <20181213195746.32144-2-andrew.zaborowski@intel.com>
In-Reply-To: <20181213195746.32144-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7709379431085231528==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-tls.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/unit/test-tls.c b/unit/test-tls.c
index 84dd950..04fd3ea 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -469,6 +469,9 @@ static void test_tls_test(const void *data)
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


--===============7709379431085231528==--

