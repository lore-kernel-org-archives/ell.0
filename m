Received: from mail.holtmann.org (coyote.holtmann.net [212.227.132.17])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 00A188F6B
	for <ell@lists.linux.dev>; Tue,  3 Jan 2023 22:02:56 +0000 (UTC)
Received: from fedora.. (p4ff9ff43.dip0.t-ipconnect.de [79.249.255.67])
	by mail.holtmann.org (Postfix) with ESMTPSA id 45A3FCECF2;
	Tue,  3 Jan 2023 23:02:53 +0100 (CET)
From: Marcel Holtmann <marcel@holtmann.org>
To: ell@lists.linux.dev
Cc: andrew.zaborowski@intel.com
Subject: [PATCH 1/3] tls: Make mask parameter in l_tls_set_domain_mask() const
Date: Tue,  3 Jan 2023 23:02:48 +0100
Message-Id: <20230103220250.717876-1-marcel@holtmann.org>
X-Mailer: git-send-email 2.39.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

While using l_strv_copy and const char ** is a problem, it is a problem
of the C language and should not affect public API. The public API
should make it clear that a string array is not going to be modified by
that function by making it const. Also allowing to feed a const string
array to that function is useful. The required casting is pushed into
the implementation.

In addition check if the struct l_tls object is valid.
---
 ell/tls.c       |  8 +++++---
 ell/tls.h       |  2 +-
 unit/test-tls.c | 32 ++++++++++++++++++--------------
 3 files changed, 24 insertions(+), 18 deletions(-)

diff --git a/ell/tls.c b/ell/tls.c
index 207f6c3ae40f..330ad4841e25 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -3786,11 +3786,13 @@ LIB_EXPORT void l_tls_set_version_range(struct l_tls *tls,
  * beginning of the mask matches one or more consecutive labels from
  * the beginning of the domain string.
  */
-LIB_EXPORT void l_tls_set_domain_mask(struct l_tls *tls, char **mask)
+LIB_EXPORT void l_tls_set_domain_mask(struct l_tls *tls, const char **mask)
 {
-	l_strv_free(tls->subject_mask);
+	if (!tls)
+		return;
 
-	tls->subject_mask = l_strv_copy(mask);
+	l_strv_free(tls->subject_mask);
+	tls->subject_mask = l_strv_copy((char **) mask);
 }
 
 /**
diff --git a/ell/tls.h b/ell/tls.h
index 6964380ab84f..cca8792a3262 100644
--- a/ell/tls.h
+++ b/ell/tls.h
@@ -127,7 +127,7 @@ void l_tls_set_version_range(struct l_tls *tls,
 				enum l_tls_version min_version,
 				enum l_tls_version max_version);
 
-void l_tls_set_domain_mask(struct l_tls *tls, char **mask);
+void l_tls_set_domain_mask(struct l_tls *tls, const char **mask);
 
 void l_tls_set_session_cache(struct l_tls *tls, struct l_settings *settings,
 				const char *group_prefix, uint64_t lifetime,
diff --git a/unit/test-tls.c b/unit/test-tls.c
index e0898593536d..b981f577d5eb 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -374,7 +374,7 @@ struct tls_conn_test {
 	const char *client_ca_cert_path;
 	const char *client_expect_identity;
 	const char **client_cipher_suites;
-	char **client_domain_mask;
+	const char **client_domain_mask;
 	bool expect_alert;
 	bool expect_client_start_fail;
 	enum l_tls_alert_desc alert_desc;
@@ -736,7 +736,9 @@ static const struct tls_conn_test tls_conn_test_domain_match1 = {
 	.client_ca_cert_path = CERTDIR "cert-ca.pem",
 	.client_expect_identity = "/O=Bar Example Organization"
 		"/CN=Bar Example Organization/emailAddress=bar@mail.example",
-	.client_domain_mask = (char *[]) { "Bar Example Organization", NULL },
+	.client_domain_mask = (const char *[]) {
+		"Bar Example Organization", NULL
+	},
 };
 
 static const struct tls_conn_test tls_conn_test_domain_match2 = {
@@ -750,7 +752,7 @@ static const struct tls_conn_test tls_conn_test_domain_match2 = {
 	.client_ca_cert_path = CERTDIR "cert-ca.pem",
 	.client_expect_identity = "/O=Bar Example Organization"
 		"/CN=Bar Example Organization/emailAddress=bar@mail.example",
-	.client_domain_mask = (char *[]) {
+	.client_domain_mask = (const char *[]) {
 		"Bar Example Organization", "Foo Example Organization", NULL
 	},
 };
@@ -766,7 +768,7 @@ static const struct tls_conn_test tls_conn_test_domain_match3 = {
 	.client_ca_cert_path = CERTDIR "cert-ca.pem",
 	.client_expect_identity = "/O=Bar Example Organization"
 		"/CN=Bar Example Organization/emailAddress=bar@mail.example",
-	.client_domain_mask = (char *[]) {
+	.client_domain_mask = (const char *[]) {
 		"Foo Example Organization", "Bar Example Organization", NULL
 	},
 };
@@ -782,7 +784,7 @@ static const struct tls_conn_test tls_conn_test_domain_match4 = {
 	.client_ca_cert_path = CERTDIR "cert-ca.pem",
 	.client_expect_identity = "/O=Bar Example Organization"
 		"/CN=Bar Example Organization/emailAddress=bar@mail.example",
-	.client_domain_mask = (char *[]) { "*", NULL },
+	.client_domain_mask = (const char *[]) { "*", NULL },
 };
 
 static const struct tls_conn_test tls_conn_test_domain_match5 = {
@@ -796,7 +798,7 @@ static const struct tls_conn_test tls_conn_test_domain_match5 = {
 	.client_ca_cert_path = CERTDIR "cert-ca.pem",
 	.client_expect_identity = "/O=Foo Example Organization"
 		"/CN=Foo Example Organization/emailAddress=foo@mail.example",
-	.client_domain_mask = (char *[]) { "foo.int.com", NULL },
+	.client_domain_mask = (const char *[]) { "foo.int.com", NULL },
 };
 
 static const struct tls_conn_test tls_conn_test_domain_match6 = {
@@ -810,7 +812,7 @@ static const struct tls_conn_test tls_conn_test_domain_match6 = {
 	.client_ca_cert_path = CERTDIR "cert-ca.pem",
 	.client_expect_identity = "/O=Foo Example Organization"
 		"/CN=Foo Example Organization/emailAddress=foo@mail.example",
-	.client_domain_mask = (char *[]) { "*.*", NULL },
+	.client_domain_mask = (const char *[]) { "*.*", NULL },
 };
 
 static const struct tls_conn_test tls_conn_test_domain_match7 = {
@@ -824,7 +826,7 @@ static const struct tls_conn_test tls_conn_test_domain_match7 = {
 	.client_ca_cert_path = CERTDIR "cert-ca.pem",
 	.client_expect_identity = "/O=Foo Example Organization"
 		"/CN=Foo Example Organization/emailAddress=foo@mail.example",
-	.client_domain_mask = (char *[]) { "*.*.*", NULL },
+	.client_domain_mask = (const char *[]) { "*.*.*", NULL },
 };
 
 static const struct tls_conn_test tls_conn_test_domain_mismatch1 = {
@@ -838,7 +840,7 @@ static const struct tls_conn_test tls_conn_test_domain_mismatch1 = {
 	.client_ca_cert_path = CERTDIR "cert-ca.pem",
 	.client_expect_identity = "/O=Bar Example Organization"
 		"/CN=Bar Example Organization/emailAddress=bar@mail.example",
-	.client_domain_mask = (char *[]) { "", NULL },
+	.client_domain_mask = (const char *[]) { "", NULL },
 	.expect_alert = true,
 	.alert_desc = TLS_ALERT_BAD_CERT,
 };
@@ -854,7 +856,9 @@ static const struct tls_conn_test tls_conn_test_domain_mismatch2 = {
 	.client_ca_cert_path = CERTDIR "cert-ca.pem",
 	.client_expect_identity = "/O=Bar Example Organization"
 		"/CN=Bar Example Organization/emailAddress=bar@mail.example",
-	.client_domain_mask = (char *[]) { "Foo Example Organization", NULL },
+	.client_domain_mask = (const char *[]) {
+		"Foo Example Organization", NULL
+	},
 	.expect_alert = true,
 	.alert_desc = TLS_ALERT_BAD_CERT,
 };
@@ -870,7 +874,7 @@ static const struct tls_conn_test tls_conn_test_domain_mismatch3 = {
 	.client_ca_cert_path = CERTDIR "cert-ca.pem",
 	.client_expect_identity = "/O=Bar Example Organization"
 		"/CN=Bar Example Organization/emailAddress=bar@mail.example",
-	.client_domain_mask = (char *[]) {
+	.client_domain_mask = (const char *[]) {
 		"Bar Example Organization.com", NULL
 	},
 	.expect_alert = true,
@@ -888,7 +892,7 @@ static const struct tls_conn_test tls_conn_test_domain_mismatch4 = {
 	.client_ca_cert_path = CERTDIR "cert-ca.pem",
 	.client_expect_identity = "/O=Bar Example Organization"
 		"/CN=Bar Example Organization/emailAddress=bar@mail.example",
-	.client_domain_mask = (char *[]) {
+	.client_domain_mask = (const char *[]) {
 		"Bar Example Organization.*", NULL
 	},
 	.expect_alert = true,
@@ -906,7 +910,7 @@ static const struct tls_conn_test tls_conn_test_domain_mismatch5 = {
 	.client_ca_cert_path = CERTDIR "cert-ca.pem",
 	.client_expect_identity = "/O=Bar Example Organization"
 		"/CN=Bar Example Organization/emailAddress=bar@mail.example",
-	.client_domain_mask = (char *[]) {
+	.client_domain_mask = (const char *[]) {
 		"*.Bar Example Organization", NULL
 	},
 	.expect_alert = true,
@@ -924,7 +928,7 @@ static const struct tls_conn_test tls_conn_test_domain_mismatch6 = {
 	.client_ca_cert_path = CERTDIR "cert-ca.pem",
 	.client_expect_identity = "/O=Foo Example Organization"
 		"/CN=Foo Example Organization/emailAddress=foo@mail.example",
-	.client_domain_mask = (char *[]) {
+	.client_domain_mask = (const char *[]) {
 		"foo.*", NULL
 	},
 	.expect_alert = true,
-- 
2.39.0

