Received: from mail-oa1-f41.google.com (mail-oa1-f41.google.com [209.85.160.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 54BF6323C
	for <ell@lists.linux.dev>; Mon, 18 Jul 2022 16:08:36 +0000 (UTC)
Received: by mail-oa1-f41.google.com with SMTP id 586e51a60fabf-10d4691a687so9637993fac.10
        for <ell@lists.linux.dev>; Mon, 18 Jul 2022 09:08:36 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=eJv6T4eZlPUQrv96VWRsGjDiVJ2iugN0FZGR84yt/kA=;
        b=mm0LhdkCqaiJ3/XUmYhOU8g40KHWNuTFANUogPFfPPjTZENRsori8EWaG3dgqYcTZM
         gVgOWtthBKt9t/2GyPixA6hPk7qsDjacEFsgHEczEj/PhfGCDE4tmeRF/pi+Yyl0BnRL
         MJPRebSrbrOr/20u/PeTdwT9jSBbG7TZm/QkHgecdjGQoznxb7Yn2EgpC5wahOD6YRWE
         QD0W1l7yvgjB8cpwQcjInWN9sEliRIm2Uhg0JaaOxYFSYeWAg3NLmhebXWIKC7QYSJBt
         VAbmCRiQc7obhGrviVC7DoStacYXsa5DSHm5jnGO69+jzbeZTjpEraTBVt9YPsR/iQOJ
         wAng==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=eJv6T4eZlPUQrv96VWRsGjDiVJ2iugN0FZGR84yt/kA=;
        b=dzFprZ8T1n/jP8v2ukiqLHmF8bliHjngERQ7InfUMHwB5lhzPsVqxyVXIv4kAqJU59
         szSl0TIJs6Ba/6bar8gt9Ygmuj2yU8veC3hB/Pt5BMSERlUnX9jsOMvylVtpFDHqZcLy
         IQykKnegPPIDb2hHb5TqRkRbv82WTFVOCpqUKhuYYADeX9GXIuUiEXZB9LA0eFSV5o4C
         fTy/67ehy9H4QVXEiSe96ic0EeOIgli79O5FVYos3F9uVd5j6ymMF6WgJCzQsqwIwncI
         GmVnZvjmfuDK33S2Ivm7HFoemsjfjGm4S2lL7VmY/xatureWH1urLP5/fyqXbkJNPMZK
         AwgA==
X-Gm-Message-State: AJIora8rbjSqI6uYz47oCI71afwV2Rll4HECk/57opF5JINjVfNof3d2
	fQbn4EHXIzeymvDXXD/tV06243J6Rd8=
X-Google-Smtp-Source: AGRyM1s1Axn8+rAg4B60k3GMCRAATLTLpJwIGJ/39+O0nEFMYXsZTMiIzt5XgqfkoSyd7fsJDs4mnQ==
X-Received: by 2002:a05:6870:3411:b0:10c:fdf5:967a with SMTP id g17-20020a056870341100b0010cfdf5967amr11553496oah.47.1658160515234;
        Mon, 18 Jul 2022 09:08:35 -0700 (PDT)
Received: from localhost.localdomain (216.106.68.145.reverse.socket.net. [216.106.68.145])
        by smtp.gmail.com with ESMTPSA id t19-20020a9d5913000000b0061cae832e5dsm297941oth.3.2022.07.18.09.08.34
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 18 Jul 2022 09:08:34 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 2/9] unit: Add basic EC-DSA verification test
Date: Mon, 18 Jul 2022 11:02:15 -0500
Message-Id: <20220718160222.10634-2-denkenz@gmail.com>
X-Mailer: git-send-email 2.35.1
In-Reply-To: <20220718160222.10634-1-denkenz@gmail.com>
References: <20220718160222.10634-1-denkenz@gmail.com>
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

