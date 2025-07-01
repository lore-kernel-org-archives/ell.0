Received: from relay6-d.mail.gandi.net (relay6-d.mail.gandi.net [217.70.183.198])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A3BAA264A73
	for <ell@lists.linux.dev>; Tue,  1 Jul 2025 13:20:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.183.198
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1751376028; cv=none; b=uRLBH7zqzafuAoetC0McSprwxemGxOdRxz/BhCPvbfB3UXbyNW7JrfT/qv9REd7BU1gkSlJ5syT4wu7g5+KbX+JktLFvTCSF/RYcAmiI/7DDiVkk7jrd1n2vThxewwET4+zv5WwMb+Fr6k3YyJFybeV74zpjIsABzZ7OelAqdCE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1751376028; c=relaxed/simple;
	bh=IilWCOgtGYfD5Zov1ZOjXmm0aOkmvWn9gO/4wDzqFf4=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=MrQfh1yXuQnVzWNFKYUMj8NcZw4sJAfiraUYEKiqePMuh1jwgSKzvz966Gzr61PGbar9Py+3cqBzncogi+POcbvvLktUup8qbReRaVXjamoVmrNnixsQ4vMEMVG80GtjJH29hl0dqkEMPIozzJElcQYdkww2UHKttbLPOzjym/I=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net; spf=pass smtp.mailfrom=hadess.net; arc=none smtp.client-ip=217.70.183.198
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hadess.net
Received: by mail.gandi.net (Postfix) with ESMTPSA id BCBCE44219;
	Tue,  1 Jul 2025 13:20:23 +0000 (UTC)
From: Bastien Nocera <hadess@hadess.net>
To: ell@lists.linux.dev
Cc: Bastien Nocera <hadess@hadess.net>
Subject: [PATCH] all: Fix typos
Date: Tue,  1 Jul 2025 15:20:07 +0200
Message-ID: <20250701132015.482623-1-hadess@hadess.net>
X-Mailer: git-send-email 2.50.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-GND-State: clean
X-GND-Score: 0
X-GND-Cause: gggruggvucftvghtrhhoucdtuddrgeeffedrtdefgddugeeigecutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfitefpfffkpdcuggftfghnshhusghstghrihgsvgenuceurghilhhouhhtmecufedtudenucenucfjughrpefhvfevufffkffoggfgsedtkeertdertddtnecuhfhrohhmpeeurghsthhivghnucfpohgtvghrrgcuoehhrgguvghssheshhgruggvshhsrdhnvghtqeenucggtffrrghtthgvrhhnpeffteektdejuddvhfdtfedtvdetgeeileethfetgfdtheekvefgueeifffhvefhfeenucfkphepvdgrtddumegvfeegmegvtgejfeemtghfvddtmeejudgurgemfegsugemvddtrgelmedufeefnecuvehluhhsthgvrhfuihiivgeptdenucfrrghrrghmpehinhgvthepvdgrtddumegvfeegmegvtgejfeemtghfvddtmeejudgurgemfegsugemvddtrgelmedufeefpdhhvghlohepohhlihhmphhitgdpmhgrihhlfhhrohhmpehhrgguvghssheshhgruggvshhsrdhnvghtpdhnsggprhgtphhtthhopedvpdhrtghpthhtohepvghllheslhhishhtshdrlhhinhhugidruggvvhdprhgtphhtthhopehhrgguvghssheshhgruggvshhsrdhnvght
X-GND-Sasl: hadess@hadess.net

---
 Makefile.am              | 2 +-
 ell/dbus.c               | 2 +-
 ell/strv.c               | 2 +-
 ell/util.h               | 2 +-
 tools/certchain-verify.c | 2 +-
 unit/test-dhcp.c         | 2 +-
 6 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/Makefile.am b/Makefile.am
index 84d008febe0c..860d59184c7e 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -666,7 +666,7 @@ unit/cert-expired.pem: unit/cert-expired.csr unit/cert-ca.pem unit/gencerts.cnf
 	$(AM_V_at)rm -r unit/cert-ca-tmp unit/cert-ca-index.txt
 
 unit/cert-entity-pkcs12-nomac.p12: unit/cert-entity-int-key.pem unit/cert-entity-int.pem
-	$(AM_V_GEN)openssl pkcs12 -inkey $< -in $(builddir)/unit/cert-entity-int.pem -out $@ -export -passout pass:abc -nomac # defaut ciphers
+	$(AM_V_GEN)openssl pkcs12 -inkey $< -in $(builddir)/unit/cert-entity-int.pem -out $@ -export -passout pass:abc -nomac # default ciphers
 
 unit/cert-entity-pkcs12-rc2-sha1.p12: unit/cert-entity-int-key.pem unit/cert-entity-int.pem unit/cert-chain.pem
 	$(AM_V_GEN)openssl pkcs12 -inkey $< -in $(builddir)/unit/cert-entity-int.pem -certfile $(builddir)/unit/cert-chain.pem -out $@ -export -passout pass:abc -certpbe PBE-SHA1-RC2-40 -keypbe PBE-SHA1-RC2-128 -macalg sha1 $(openssl_legacy)
diff --git a/ell/dbus.c b/ell/dbus.c
index 7fa5c18d6b92..bcd9869da15d 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -181,7 +181,7 @@ done:
 	if (l_queue_isempty(dbus->message_queue))
 		return false;
 
-	/* Only continue sending messges if the connection is ready */
+	/* Only continue sending messages if the connection is ready */
 	return dbus->is_ready;
 }
 
diff --git a/ell/strv.c b/ell/strv.c
index b7bf23c92292..e22fc1fea029 100644
--- a/ell/strv.c
+++ b/ell/strv.c
@@ -261,7 +261,7 @@ LIB_EXPORT bool l_strv_contains(char **str_array, const char *item)
 /**
  * l_strv_append:
  * @str_array: a %NULL terminated array of strings or %NULL
- * @str: A string to be appened at the end of @str_array
+ * @str: A string to be appended at the end of @str_array
  *
  * Returns: New %NULL terminated array of strings with @str added
  */
diff --git a/ell/util.h b/ell/util.h
index da0741d2cbba..e44ec69f8d97 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -44,7 +44,7 @@ _Pragma("GCC diagnostic pop")						\
 	})
 
 /*
- * If ELL headers and iterfaces end up getting compiled in a C++
+ * If ELL headers and interfaces end up getting compiled in a C++
  * environment, even though ELL itself is a C source based and is
  * compiled as such, certain assignments may be flagged by the C++
  * compiler as errors or warnings. The following portable casts should
diff --git a/tools/certchain-verify.c b/tools/certchain-verify.c
index e8ff346dce54..c3a38263b612 100644
--- a/tools/certchain-verify.c
+++ b/tools/certchain-verify.c
@@ -48,7 +48,7 @@ int main(int argc, char *argv[])
 
 	ca_certs = l_pem_load_certificate_list(argv[1]);
 	if (!ca_certs) {
-		fprintf(stderr, "Unable to load CA certifiates\n");
+		fprintf(stderr, "Unable to load CA certificates\n");
 		goto free_certchain;
 	}
 
diff --git a/unit/test-dhcp.c b/unit/test-dhcp.c
index b1e3cb0c33aa..34faae4b09a7 100644
--- a/unit/test-dhcp.c
+++ b/unit/test-dhcp.c
@@ -655,7 +655,7 @@ static int fake_transport_send(struct dhcp_transport *transport,
 	return len;
 }
 
-static int fake_transport_l2_send(struct dhcp_transport *transprot,
+static int fake_transport_l2_send(struct dhcp_transport *transport,
 					uint32_t saddr, uint16_t sport,
 					uint32_t daddr, uint16_t dport,
 					const uint8_t *dest_mac,
-- 
2.50.0

