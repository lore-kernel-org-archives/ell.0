Received: from mail-wm1-f51.google.com (mail-wm1-f51.google.com [209.85.128.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 82ABA20F2
	for <ell@lists.linux.dev>; Mon, 31 Oct 2022 10:53:59 +0000 (UTC)
Received: by mail-wm1-f51.google.com with SMTP id l16-20020a05600c4f1000b003c6c0d2a445so7749239wmq.4
        for <ell@lists.linux.dev>; Mon, 31 Oct 2022 03:53:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=l098gqDDpq8FmMdmc72F+5kq464PvPX49t7llvL/S4A=;
        b=vb9sw7uOqmaZvYJz/y0m31FWkvB+rJpACMJL2o0qaVxINK4CMQyystoDeaTUZwiVb+
         ghLX6C/6xFSqUhRvzztCyJljTMYDGCa1XYkUK1xLTdavK88YYFrwbzakH4O/GEP/7cqd
         1/D9IB83iJ3nzXkIFiEPZlqam4C65j16eC6RMA2J+eQjuDEThy1NnhmjIyh6TIfMY+wZ
         Sc6CGU0G33jbXr+9b2E2Wge7JxTsIVAXOLjGDEmuCoVHD839zqwARj5zJF6nbYLgF6AW
         Ot1/b0WUJThyp/MTP+VmJFBkQMHadNYKnH0LyJVBduFh7P5+EIae95AKpb8NprBwvlcs
         XU8A==
X-Gm-Message-State: ACrzQf3X/lp9qmB9gNfvH2qhAlRzkdDH5gidVEjdvq8JIBzVAJ9Tc0EK
	0gVESCinwRBxi1W1VWUgnxQSx6FgLJc=
X-Google-Smtp-Source: AMsMyM6ERheeBgIVU727jrnogmQBQMLShC5gvsMpNeFPJQmxhVhJ62jATfYmTNf95oVuxwB7vy37eA==
X-Received: by 2002:a1c:acc5:0:b0:3c6:eebf:feee with SMTP id v188-20020a1cacc5000000b003c6eebffeeemr7691656wme.122.1667213637055;
        Mon, 31 Oct 2022 03:53:57 -0700 (PDT)
Received: from localhost.localdomain ([82.213.230.158])
        by smtp.gmail.com with ESMTPSA id ay19-20020a5d6f13000000b00236b2804d79sm6890737wrb.2.2022.10.31.03.53.55
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 31 Oct 2022 03:53:55 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 3/4] build: Generate an expired test certificate
Date: Mon, 31 Oct 2022 11:53:41 +0100
Message-Id: <20221031105342.2660357-3-andrew.zaborowski@intel.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20221031105342.2660357-1-andrew.zaborowski@intel.com>
References: <20221031105342.2660357-1-andrew.zaborowski@intel.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

---
 .gitignore  |  2 ++
 Makefile.am | 29 +++++++++++++++++++++++++++--
 2 files changed, 29 insertions(+), 2 deletions(-)

diff --git a/.gitignore b/.gitignore
index 76f10ae..1540012 100644
--- a/.gitignore
+++ b/.gitignore
@@ -67,6 +67,8 @@ unit/cert-*.csr
 unit/cert-*.srl
 unit/cert-*.crt
 unit/cert-*.p12
+unit/cert-ca.cnf
+unit/cert-ca-index*
 unit/ec-cert-*.pem
 unit/ec-cert-*.csr
 unit/key-*.dat
diff --git a/Makefile.am b/Makefile.am
index 596771a..7daebde 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -242,7 +242,8 @@ cert_files = unit/cert-chain.pem \
 			unit/cert-entity-pkcs12-rc4-sha384.p12 \
 			unit/cert-entity-pkcs12-pkcs5-sha512.p12 \
 			unit/cert-entity-combined.pem \
-			unit/cert-no-keyid.pem
+			unit/cert-no-keyid.pem \
+			unit/cert-expired.pem
 
 cert_checks = unit/cert-intca \
 			unit/cert-entity-int \
@@ -617,6 +618,29 @@ unit/cert-no-keyid.pem: unit/cert-no-keyid.csr unit/cert-ca2.pem unit/gencerts.c
 unit/cert-no-keyid: unit/cert-no-keyid.pem unit/cert-ca2.pem
 	$(AM_V_GEN)openssl verify -CAfile $(builddir)/unit/cert-ca2.pem $<
 
+unit/cert-expired.csr: unit/cert-client-key-pkcs1.pem unit/gencerts.cnf
+	$(AM_V_GEN)openssl req -new -extensions cert_ext \
+			-config $(srcdir)/unit/gencerts.cnf \
+			-subj '/O=Bar Example Organization/CN=Bar Example Organization/emailAddress=bar@mail.example' \
+			-key $< -out $@
+
+unit/cert-ca.cnf:
+	$(AM_V_GEN)echo -e '[example]\ndatabase = unit/cert-ca-index.txt\npolicy = dummy\nserial = dummy\n[dummy]' > $@
+
+unit/cert-expired.pem: unit/cert-expired.csr unit/cert-ca.pem unit/gencerts.cnf unit/cert-ca.cnf
+	$(AM_V_at)> unit/cert-ca-index.txt
+	$(AM_V_at)$(MKDIR_P) unit/cert-ca-tmp
+	$(AM_V_GEN)openssl ca -batch \
+			-config $(builddir)/unit/cert-ca.cnf -name example \
+			-cert $(builddir)/unit/cert-ca.pem \
+			-keyfile $(builddir)/unit/cert-ca-key.pem \
+			-outdir $(builddir)/unit/cert-ca-tmp \
+			-rand_serial -extensions cert_ext \
+			-extfile $(srcdir)/unit/gencerts.cnf -md sha256 \
+			-startdate 000101120000Z -enddate 010101120000Z \
+			-preserveDN -notext -in $< -out $@ 2> /dev/null
+	$(AM_V_at)rm -r unit/cert-ca-tmp unit/cert-ca-index.txt
+
 unit/cert-entity-pkcs12-nomac.p12: unit/cert-entity-int-key.pem unit/cert-entity-int.pem
 	$(AM_V_GEN)openssl pkcs12 -inkey $< -in $(builddir)/unit/cert-entity-int.pem -out $@ -export -passout pass:abc -nomac # defaut ciphers
 
@@ -660,7 +684,8 @@ endif
 
 clean-local:
 	-rm -f unit/ec-cert*.pem unit/ec-cert-*.csr \
-		unit/cert-*.pem unit/cert-*.csr unit/cert-*.srl unit/key-*.dat
+		unit/cert-*.pem unit/cert-*.csr unit/cert-*.srl unit/key-*.dat \
+		unit/cert-ca-index* unit/cert-ca.cnf
 
 maintainer-clean-local:
 	-rm -rf build-aux
-- 
2.34.1

