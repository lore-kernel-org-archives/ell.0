Received: from mail-wr1-f42.google.com (mail-wr1-f42.google.com [209.85.221.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0FCE520F4
	for <ell@lists.linux.dev>; Mon, 31 Oct 2022 10:53:57 +0000 (UTC)
Received: by mail-wr1-f42.google.com with SMTP id l14so15417309wrw.2
        for <ell@lists.linux.dev>; Mon, 31 Oct 2022 03:53:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=ApYhUNEHaGl2Y5+EsjbwBXZ/7nePjQwUY1khxImAwIU=;
        b=43LVZgnWwXPXOnh3NE1lZnVR0qrmftu8iKPqHaJqlihuYbqCEGX3whHBph/BN6QjLw
         inOpIKPh7/iGGjW4w47S9EUMYDbh2af8jwfs3Xn8zhoygQgVqzUXg/1fmOHWmg7SANlR
         MjpNQJ8Ko2VV2waQXTBQSHNTY/RzShTQCFGR2VpL1XG2NVew8IYNlxVCSquybhX1mRtO
         Xx91iMOxN3wd0R6xdViFjd7oxfPI7zkzOmBx33qtXNLWuI+DoJeUXycKQgDdIBnCvqHa
         46/Jn7WYpddQkj57Z7/AtrHYqGfGqBCYEpOr6oCl6Waj7Hz/4cyQ6sp1z99ijugCUX3u
         Z5hw==
X-Gm-Message-State: ACrzQf0d8RAAlwSa1LGomD2UUopu/WcZ+dXbalmDj3ldkEZgSLHG4nfc
	KtuDOz9sbWbonx/FBkrG1TXvnp/osng=
X-Google-Smtp-Source: AMsMyM77rjgPGmebeY/2nC+rf5d1XtolgljmHZdyB+ylXmI/W2AsCJs6Agztk6tSUTmrXVE+tCdfZw==
X-Received: by 2002:a05:6000:79c:b0:236:6f2e:301e with SMTP id bu28-20020a056000079c00b002366f2e301emr7592079wrb.458.1667213635480;
        Mon, 31 Oct 2022 03:53:55 -0700 (PDT)
Received: from localhost.localdomain ([82.213.230.158])
        by smtp.gmail.com with ESMTPSA id ay19-20020a5d6f13000000b00236b2804d79sm6890737wrb.2.2022.10.31.03.53.54
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 31 Oct 2022 03:53:54 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 2/4] cert: Check validity dates in l_certchain_verify
Date: Mon, 31 Oct 2022 11:53:40 +0100
Message-Id: <20221031105342.2660357-2-andrew.zaborowski@intel.com>
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

Check the validity start and end dates of every certificate in the chain
being verified (must all be valid) and every trusted CA certificate
(ignore invalid ones, use the valid ones if any left).  The dates are
checked against current CLOCK_REALTIME value.  There may be use cases
for verifying a certificate chain without looking at the dates at all,
such as when the system clock hasn't been initialized in early boot and
that can be added if there's an actual user for that.  Until now we've
almost fully relied on the kernel to do all the verification and
consistency checks on the certificates and the kernel does not look at
validity dates.

Do these checks only in l_certchain_verify rather than directly in
l_cert_load_container_file() or l_pem_load_certificate_chain_from_data()
because 1. users may want to parse and display information about expired
certificates for a UI.  2. l_certchain_verify also returns a debug error
string which is going to be very helpful in diagnosing user issues from
logs, unlike the loader functions.  3. in some usages there may be a
longer periods of time between certchain loading, CA certificate loading
and/or verifying the chain against the CAs, and we mainly care about
them being valid at the time of the verification.
---
 ell/cert.c | 159 ++++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 126 insertions(+), 33 deletions(-)

diff --git a/ell/cert.c b/ell/cert.c
index ab469c2..2c80c84 100644
--- a/ell/cert.c
+++ b/ell/cert.c
@@ -35,6 +35,7 @@
 #include "cipher.h"
 #include "pem-private.h"
 #include "time.h"
+#include "time-private.h"
 #include "utf8.h"
 #include "cert.h"
 #include "cert-private.h"
@@ -562,24 +563,25 @@ LIB_EXPORT void l_certchain_walk_from_ca(struct l_certchain *chain,
 			break;
 }
 
-static struct l_keyring *cert_set_to_keyring(struct l_queue *certs, char *error)
+static struct l_keyring *cert_set_to_keyring(struct l_cert **certs, char *error)
 {
 	struct l_keyring *ring;
-	const struct l_queue_entry *entry;
 	int i = 1;
+	int count;
 
 	ring = l_keyring_new();
 	if (!ring)
 		return NULL;
 
-	for (entry = l_queue_get_entries(certs); entry; entry = entry->next) {
-		struct l_cert *cert = entry->data;
+	for (count = 0; certs[count]; count++);
+
+	for (; *certs; certs++) {
+		struct l_cert *cert = *certs;
 		struct l_key *key = l_cert_get_pubkey(cert);
 
 		if (!key) {
 			sprintf(error, "Can't get public key from certificate "
-				"%i / %i in certificate set", i,
-				l_queue_length(certs));
+				"%i / %i in certificate set", i, count);
 			goto cleanup;
 		}
 
@@ -587,7 +589,7 @@ static struct l_keyring *cert_set_to_keyring(struct l_queue *certs, char *error)
 			l_key_free(key);
 			sprintf(error, "Can't link the public key from "
 				"certificate %i / %i to target keyring",
-				i, l_queue_length(certs));
+				i, count);
 			goto cleanup;
 		}
 
@@ -602,12 +604,10 @@ cleanup:
 	return NULL;
 }
 
-static bool cert_is_in_set(struct l_cert *cert, struct l_queue *set)
+static bool cert_is_in_set(struct l_cert *cert, struct l_cert **set)
 {
-	const struct l_queue_entry *entry;
-
-	for (entry = l_queue_get_entries(set); entry; entry = entry->next) {
-		struct l_cert *cert2 = entry->data;
+	for (; *set; set++) {
+		struct l_cert *cert2 = *set;
 
 		if (cert == cert2)
 			return true;
@@ -621,6 +621,35 @@ static bool cert_is_in_set(struct l_cert *cert, struct l_queue *set)
 	return false;
 }
 
+static struct l_cert **cert_set_filter_by_validity(struct l_queue *set,
+							uint64_t now,
+							int *out_total,
+							int *out_valid)
+{
+	const struct l_queue_entry *entry;
+	_auto_(l_free) struct l_cert **valid;
+
+	*out_total = l_queue_length(set);
+	*out_valid = 0;
+	valid = l_new(struct l_cert *, *out_total + 1);
+
+	for (entry = l_queue_get_entries(set); entry; entry = entry->next) {
+		struct l_cert *cert = entry->data;
+		uint64_t not_before;
+		uint64_t not_after;
+
+		if (!l_cert_get_valid_times(cert, &not_before, &not_after))
+			return NULL;
+
+		if (now < not_before || (not_after && now > not_after))
+			continue;
+
+		valid[(*out_valid)++] = cert;
+	}
+
+	return l_steal_ptr(valid);
+}
+
 static struct l_key *cert_try_link(struct l_cert *cert, struct l_keyring *ring)
 {
 	struct l_key *key;
@@ -655,22 +684,81 @@ LIB_EXPORT bool l_certchain_verify(struct l_certchain *chain,
 	struct l_key *prev_key = NULL;
 	int verified = 0;
 	int ca_match = 0;
-	int i = 0;
+	int i;
 	static char error_buf[200];
+	int total = 0;
+	uint64_t now;
+	_auto_(l_free) struct l_cert **ca_certs_valid = NULL;
+	int ca_certs_total_count = 0;
+	int ca_certs_valid_count = 0;
 
 	if (unlikely(!chain || !chain->leaf))
 		RETURN_ERROR("Chain empty");
 
+	for (cert = chain->ca; cert; cert = cert->issued, total++);
+
+	now = time_realtime_now();
+
+	for (cert = chain->ca, i = 0; cert; cert = cert->issued, i++) {
+		uint64_t not_before;
+		uint64_t not_after;
+		char time_str[100];
+
+		if (unlikely(!l_cert_get_valid_times(cert, &not_before,
+							&not_after)))
+			RETURN_ERROR("Can't parse validity in certificate "
+					"%i / %i", i + 1, total);
+
+		if (unlikely(now < not_before)) {
+			time_t t = not_before / L_USEC_PER_SEC;
+			struct tm *tm = gmtime(&t);
+
+			if (!tm || !strftime(time_str, sizeof(time_str),
+						"%a %F %T UTC", tm))
+				strcpy(time_str, "<error>");
+
+			RETURN_ERROR("Certificate %i / %i not valid before %s",
+					i + 1, total, time_str);
+		}
+
+		if (unlikely(not_after && now > not_after)) {
+			time_t t = not_after / L_USEC_PER_SEC;
+			struct tm *tm = gmtime(&t);
+
+			if (!tm || !strftime(time_str, sizeof(time_str),
+						"%a %F %T UTC", tm))
+				strcpy(time_str, "<error>");
+
+			RETURN_ERROR("Certificate %i / %i expired on %s",
+					i + 1, total, time_str);
+		}
+	}
+
+	if (ca_certs) {
+		if (unlikely(l_queue_isempty(ca_certs)))
+			RETURN_ERROR("No trusted CA certificates");
+
+		ca_certs_valid = cert_set_filter_by_validity(ca_certs, now,
+							&ca_certs_total_count,
+							&ca_certs_valid_count);
+		if (unlikely(!ca_certs_valid))
+			RETURN_ERROR("Can't parse validity in CA cert(s)");
+
+		if (unlikely(!ca_certs_valid_count))
+			RETURN_ERROR("All trusted CA certs are expired or "
+					"not-yet-valid");
+
+		for (cert = chain->ca, i = 0; cert; cert = cert->issued, i++)
+			if (cert_is_in_set(cert, ca_certs_valid)) {
+				ca_match = i + 1;
+				break;
+			}
+	}
+
 	verify_ring = l_keyring_new();
 	if (!verify_ring)
 		RETURN_ERROR("Can't create verify keyring");
 
-	for (cert = chain->ca; cert; cert = cert->issued, i++)
-		if (cert_is_in_set(cert, ca_certs)) {
-			ca_match = i + 1;
-			break;
-		}
-
 	cert = chain->ca;
 
 	/*
@@ -690,7 +778,7 @@ LIB_EXPORT bool l_certchain_verify(struct l_certchain *chain,
 	 * all of the trusted certificates into the kernel, link them
 	 * to @ca_ring or link @ca_ring to @verify_ring, instead we
 	 * load the first certificate into @verify_ring before we set
-	 * the restric mode on it, same as when no trusted CAs are
+	 * the restrict mode on it, same as when no trusted CAs are
 	 * provided.
 	 *
 	 * Note this happens to work around a kernel issue preventing
@@ -701,7 +789,7 @@ LIB_EXPORT bool l_certchain_verify(struct l_certchain *chain,
 	 * the chain.
 	 */
 	if (ca_certs && !ca_match) {
-		ca_ring = cert_set_to_keyring(ca_certs, error_buf);
+		ca_ring = cert_set_to_keyring(ca_certs_valid, error_buf);
 		if (!ca_ring) {
 			if (error)
 				*error = error_buf;
@@ -754,23 +842,28 @@ LIB_EXPORT bool l_certchain_verify(struct l_certchain *chain,
 	}
 
 	if (!prev_key) {
-		int total = 0;
-		char str[100];
-
-		for (cert = chain->ca; cert; cert = cert->issued, total++);
+		char str1[100];
+		char str2[100] = "";
 
 		if (ca_match)
-			snprintf(str, sizeof(str), "%i / %i matched a trusted "
-					"certificate, root not verified",
+			snprintf(str1, sizeof(str1), "%i / %i matched a trusted"
+					" certificate, root not verified",
 					ca_match, total);
 		else
-			snprintf(str, sizeof(str), "root %sverified against "
+			snprintf(str1, sizeof(str1), "root %sverified against "
 					"trusted CA(s)",
-					ca_certs && !ca_match && verified ? "" :
-					"not ");
-
-		RETURN_ERROR("Linking certificate %i / %i failed, %s",
-				verified + 1, total, str);
+					ca_certs && verified ? "" : "not ");
+
+		if (ca_certs && !ca_match && !verified &&
+				ca_certs_valid_count < ca_certs_total_count)
+			snprintf(str2, sizeof(str2), ", %i out of %i trused "
+					"CA(s) were expired or not-yet-valid",
+					ca_certs_total_count -
+					ca_certs_valid_count,
+					ca_certs_total_count);
+
+		RETURN_ERROR("Linking certificate %i / %i failed, %s%s",
+				verified + 1, total, str1, str2);
 	}
 
 	l_key_free(prev_key);
-- 
2.34.1

