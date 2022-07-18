Received: from mail-oa1-f52.google.com (mail-oa1-f52.google.com [209.85.160.52])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8E4B333DE
	for <ell@lists.linux.dev>; Mon, 18 Jul 2022 18:07:11 +0000 (UTC)
Received: by mail-oa1-f52.google.com with SMTP id 586e51a60fabf-10bf634bc50so25866196fac.3
        for <ell@lists.linux.dev>; Mon, 18 Jul 2022 11:07:11 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=eJv6T4eZlPUQrv96VWRsGjDiVJ2iugN0FZGR84yt/kA=;
        b=DQtZnL2kWdcShFuehGPgKzpj6YJ1FAvClhkknLcl4DaK0NStuBq8xYfA8hw7yMFsrH
         QDvH+06feTP2Vpqrpx3kZoIiqVIx3qNPxyD19vSb8tOo+udH0CO7RohZeH6Ynrp+dFoH
         oJx8x9RbncYgQSMgllBcwY036hSozfJ285dXoKW7QX6cnZ62OkcCouVVNpE1YWyZctzW
         4sasKCWR2WXsmaUPYHVY2DgF4I9vQxLRIUFXEccFR84kc1q5vVI7g8/oDzDLRW7+T8uz
         V3TMNjGkV+wVEUPV+/anqYq6oMh6xC9eTS4KAakjCWtOjo5taaVGpZycidq68XSzOEcu
         g6WQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=eJv6T4eZlPUQrv96VWRsGjDiVJ2iugN0FZGR84yt/kA=;
        b=iP0pYFUwRGoIcngvGVdLLdFk1AUfPQLo+wwEWHvcMAQnn9/MhHZhtP8rb6A6AcJ2Yt
         gl91RNAM0Kj03WJW5+LYkPJyrExlNT09c9tbclUj8ndsfnGkY78Z+PUB6V8Seydy3RfI
         i9ENaAi1kHytRSlv/XLemzGpuyVOKUv7zdGR5Ec7wGiB1c0dLSd0+DZUJhaEUYicuXvi
         2FMZAn0g8UvtyZtbPG+BVuTmedEhR8Vwy4dW2wnm3jxHJGmsul097tnPz/bEbAvo9jHW
         72XzWoOOd7oZNbpHImELoDLt1a4wHDJtWCC8v0G8rEBwisSeYnf0pRGDHaAyiaAbuhw5
         U6KA==
X-Gm-Message-State: AJIora9eIxdmdcmIccde7emV5Z1EHMsD8a18+dv3DT+hNLv2YzlQQ9Yk
	JCtqw7Sk4v2VFBrg2nrAssaCWXZpZyA=
X-Google-Smtp-Source: AGRyM1tyMt4x2ohBVVJDwldBtnrfC4QsD7UzXNn+ArCisOAkAAsMf8sFrLXKuCgCAxDU+Sfh9mw08w==
X-Received: by 2002:a05:6870:829e:b0:10c:240b:cbb9 with SMTP id q30-20020a056870829e00b0010c240bcbb9mr15044385oae.115.1658167630415;
        Mon, 18 Jul 2022 11:07:10 -0700 (PDT)
Received: from localhost.localdomain (216.106.68.145.reverse.socket.net. [216.106.68.145])
        by smtp.gmail.com with ESMTPSA id n23-20020a056870559700b0010c727a3c79sm6808467oao.26.2022.07.18.11.07.09
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 18 Jul 2022 11:07:10 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH v2 02/10] unit: Add basic EC-DSA verification test
Date: Mon, 18 Jul 2022 13:00:37 -0500
Message-Id: <20220718180045.5845-2-denkenz@gmail.com>
X-Mailer: git-send-email 2.35.1
In-Reply-To: <20220718180045.5845-1-denkenz@gmail.com>
References: <20220718180045.5845-1-denkenz@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

---
 .gitignore      |  2 ++
 Makefile.am     | 39 ++++++++++++++++++++++++++++++++++++++-
 unit/test-tls.c | 22 +++++++++++++++++++++-
 3 files changed, 61 insertions(+), 2 deletions(-)

diff --git a/.gitignore b/.gitignore
index 346243a8f9c7..76f10aecfdd3 100644
--- a/.gitignore
+++ b/.gitignore
@@ -67,6 +67,8 @@ unit/cert-*.csr
 unit/cert-*.srl
 unit/cert-*.crt
 unit/cert-*.p12
+unit/ec-cert-*.pem
+unit/ec-cert-*.csr
 unit/key-*.dat
 unit/key-*.h
 unit/*.log
diff --git a/Makefile.am b/Makefile.am
index 2bf728bbde7a..e5d7143af236 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -219,6 +219,7 @@ cert_tests = unit/test-pem \
 cert_files = unit/cert-chain.pem \
 			unit/cert-entity-int.pem \
 			unit/cert-server.pem \
+			unit/ec-cert-server.pem \
 			unit/cert-server-key-pkcs8.pem \
 			unit/cert-client.pem \
 			unit/cert-client.crt \
@@ -246,6 +247,7 @@ cert_files = unit/cert-chain.pem \
 cert_checks = unit/cert-intca \
 			unit/cert-entity-int \
 			unit/cert-server \
+			unit/ec-cert-server \
 			unit/cert-client \
 			unit/cert-no-keyid
 
@@ -417,15 +419,30 @@ false_redirect_openssl = 2>/dev/null
 unit/cert-ca-key.pem:
 	$(AM_V_GEN)openssl genrsa -out $@ 2048 $($(AM_V_P)_redirect_openssl)
 
+unit/ec-cert-ca-key.pem:
+	$(AM_V_GEN)openssl ecparam -out $@ -name secp384r1 \
+				-genkey $($(AM_V_P)_redirect_openssl)
+
+
 unit/cert-ca.pem: unit/cert-ca-key.pem unit/gencerts.cnf
 	$(AM_V_GEN)openssl req -x509 -new -nodes -extensions ca_ext \
 			-config $(srcdir)/unit/gencerts.cnf \
 			-subj '/O=International Union of Example Organizations/CN=Certificate issuer guy/emailAddress=ca@mail.example' \
 			-key $< -sha256 -days 10000 -out $@
 
+unit/ec-cert-ca.pem: unit/ec-cert-ca-key.pem unit/gencerts.cnf
+	$(AM_V_GEN)openssl req -x509 -new -nodes -extensions ca_ext \
+			-config $(srcdir)/unit/gencerts.cnf \
+			-subj '/O=International Union of Example Organizations/CN=Certificate issuer guy/emailAddress=ca@mail.example' \
+			-key $< -sha256 -days 10000 -out $@
+
 unit/cert-server-key.pem:
 	$(AM_V_GEN)openssl genrsa -out $@ $($(AM_V_P)_redirect_openssl)
 
+unit/ec-cert-server-key.pem:
+	$(AM_V_GEN)openssl ecparam -out $@ -name secp384r1 \
+				-genkey $($(AM_V_P)_redirect_openssl)
+
 unit/cert-server-key-pkcs8.pem: unit/cert-server-key.pem
 	$(AM_V_GEN)openssl pkcs8 -topk8 -nocrypt -in $< -out $@
 
@@ -435,6 +452,12 @@ unit/cert-server.csr: unit/cert-server-key.pem unit/gencerts.cnf
 			-subj '/O=Foo Example Organization/CN=Foo Example Organization/emailAddress=foo@mail.example' \
 			-key $< -out $@
 
+unit/ec-cert-server.csr: unit/ec-cert-server-key.pem unit/gencerts.cnf
+	$(AM_V_GEN)openssl req -new -extensions cert_ext \
+			-config $(srcdir)/unit/gencerts.cnf \
+			-subj '/O=Foo Example Organization/CN=Foo Example Organization/emailAddress=foo@mail.example' \
+			-key $< -out $@
+
 unit/cert-server.pem: unit/cert-server.csr unit/cert-ca.pem unit/gencerts.cnf
 	$(AM_V_GEN)openssl x509 -req -extensions server_ext \
 			-extfile $(srcdir)/unit/gencerts.cnf \
@@ -443,9 +466,22 @@ unit/cert-server.pem: unit/cert-server.csr unit/cert-ca.pem unit/gencerts.cnf
 			-CAserial $(builddir)/unit/cert-ca.srl \
 			-CAcreateserial -sha256 -days 10000 -out $@ $($(AM_V_P)_redirect_openssl)
 
+unit/ec-cert-server.pem: unit/ec-cert-server.csr unit/ec-cert-ca.pem \
+				unit/gencerts.cnf
+	$(AM_V_GEN)openssl x509 -req -extensions server_ext \
+			-extfile $(srcdir)/unit/gencerts.cnf \
+			-in $< -CA $(builddir)/unit/ec-cert-ca.pem \
+			-CAkey $(builddir)/unit/ec-cert-ca-key.pem \
+			-CAserial $(builddir)/unit/cert-ca.srl \
+			-CAcreateserial -sha256 -days 10000 \
+			-out $@ $($(AM_V_P)_redirect_openssl)
+
 unit/cert-server: unit/cert-server.pem unit/cert-ca.pem
 	$(AM_V_GEN)openssl verify -CAfile $(builddir)/unit/cert-ca.pem $<
 
+unit/ec-cert-server: unit/ce-cert-server.pem unit/ce-cert-ca.pem
+	$(AM_V_GEN)openssl verify -CAfile $(builddir)/unit/ce-cert-ca.pem $<
+
 unit/cert-client-key-pkcs1.pem:
 	$(AM_V_GEN)openssl genrsa -out $@ $($(AM_V_P)_redirect_openssl)
 
@@ -623,7 +659,8 @@ check-local: $(cert_checks)
 endif
 
 clean-local:
-	-rm -f unit/cert-*.pem unit/cert-*.csr unit/cert-*.srl unit/key-*.dat
+	-rm -f unit/ec-cert*.pem unit/ec-cert-*.csr \
+		unit/cert-*.pem unit/cert-*.csr unit/cert-*.srl unit/key-*.dat
 
 maintainer-clean-local:
 	-rm -rf build-aux
diff --git a/unit/test-tls.c b/unit/test-tls.c
index 7937962cf8a0..aee5b2e36b78 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -325,6 +325,24 @@ static void test_certificates(const void *data)
 	l_queue_destroy(twocas, (l_queue_destroy_func_t) l_cert_free);
 }
 
+static void test_ec_certificates(const void *data)
+{
+	struct l_queue *cacert;
+	struct l_certchain *chain;
+
+	cacert = l_pem_load_certificate_list(CERTDIR "ec-cert-ca.pem");
+	assert(cacert && !l_queue_isempty(cacert));
+
+	chain = l_pem_load_certificate_chain(CERTDIR "ec-cert-server.pem");
+	assert(chain);
+
+	assert(l_certchain_verify(chain, cacert, NULL));
+	assert(l_certchain_verify(chain, NULL, NULL));
+
+	l_certchain_free(chain);
+	l_queue_destroy(cacert, (l_queue_destroy_func_t) l_cert_free);
+}
+
 struct tls_conn_test {
 	const char *server_cert_path;
 	const char *server_key_path;
@@ -948,8 +966,10 @@ int main(int argc, char *argv[])
 	l_test_add("TLS 1.2 PRF with SHA512", test_tls12_prf,
 			&tls12_prf_sha512_0);
 
-	if (l_key_is_supported(L_KEY_FEATURE_RESTRICT))
+	if (l_key_is_supported(L_KEY_FEATURE_RESTRICT)) {
 		l_test_add("Certificate chains", test_certificates, NULL);
+		l_test_add("ECDSA Certificates", test_ec_certificates, NULL);
+	}
 
 	if (!l_getrandom_is_supported()) {
 		printf("getrandom missing, skipping TLS connection tests...\n");
-- 
2.35.1

