Received: from mail-wr1-f50.google.com (mail-wr1-f50.google.com [209.85.221.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E5F90138F
	for <ell@lists.linux.dev>; Wed, 26 Oct 2022 13:16:12 +0000 (UTC)
Received: by mail-wr1-f50.google.com with SMTP id h9so15176656wrt.0
        for <ell@lists.linux.dev>; Wed, 26 Oct 2022 06:16:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=eyEkCNuSlqIVDW8pW4hy04GzTqYKFDuK7d7Ve8z1OCc=;
        b=0mwlrqYn4k4WTETvGEM5Hdd2SVwQiOvaOMukr/OW53k6sL6Xia3uTo04y3depjaT/6
         JDnAAWjIcBx/ayzMOIhiJGKjKs/dSM/bmerEi9nx2mW9bEOUZS1k7TRCPReOxj51IxGi
         qNm0rMMb4/LoLTmCKMR/xp3Egx2DFJiZj2au1RGCsRjrjB3TAa/Dr3oOZBQAl6mJakq1
         BlsWrMbWWa8tqOwDMWAg6KQENwbihm/4agImQJDGxfl6dJa1A+plrfN+7+6PVBB8aCzO
         y3DgovVUDRq763Khr6FORBtUu/pUxA4E699bZcHonoXRm8f+EWwfpmpIQleRoW7sqnvR
         JHRg==
X-Gm-Message-State: ACrzQf0tOflkEHDGopSTtv6AEFAOcTFyu7CmnBTq+QSzAN8mXYzVNRED
	pbZzw310eETfjtVyc7N7MOCI+GZiVwA=
X-Google-Smtp-Source: AMsMyM78/l6XmjyUzFsBbLCGWNpuRgs+jsSHxk5WiMNg5CoSepn7YdfXhyLlIKD0hu8SxW0WjAoo0A==
X-Received: by 2002:a5d:4f12:0:b0:22e:3920:a09c with SMTP id c18-20020a5d4f12000000b0022e3920a09cmr28124523wru.95.1666790170411;
        Wed, 26 Oct 2022 06:16:10 -0700 (PDT)
Received: from localhost.localdomain ([82.213.230.158])
        by smtp.gmail.com with ESMTPSA id x23-20020a05600c21d700b003a83ca67f73sm1934771wmj.3.2022.10.26.06.16.08
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 26 Oct 2022 06:16:09 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 2/6] cert: Add l_cert_get_valid_times
Date: Wed, 26 Oct 2022 15:15:54 +0200
Message-Id: <20221026131558.2393488-2-andrew.zaborowski@intel.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20221026131558.2393488-1-andrew.zaborowski@intel.com>
References: <20221026131558.2393488-1-andrew.zaborowski@intel.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Add utility to extract the Not Before and Not After timestamps from
certificates.
---
 ell/asn1-private.h |   2 +
 ell/cert.c         | 185 +++++++++++++++++++++++++++++++++++++++++++++
 ell/cert.h         |   2 +
 ell/ell.sym        |   1 +
 4 files changed, 190 insertions(+)

diff --git a/ell/asn1-private.h b/ell/asn1-private.h
index d794515..36d8de3 100644
--- a/ell/asn1-private.h
+++ b/ell/asn1-private.h
@@ -34,6 +34,8 @@
 #define ASN1_ID_UTF8STRING	ASN1_ID(ASN1_CLASS_UNIVERSAL, 0, 0x0c)
 #define ASN1_ID_PRINTABLESTRING	ASN1_ID(ASN1_CLASS_UNIVERSAL, 0, 0x13)
 #define ASN1_ID_IA5STRING	ASN1_ID(ASN1_CLASS_UNIVERSAL, 0, 0x16)
+#define ASN1_ID_UTCTIME		ASN1_ID(ASN1_CLASS_UNIVERSAL, 0, 0x17)
+#define ASN1_ID_GENERALIZEDTIME	ASN1_ID(ASN1_CLASS_UNIVERSAL, 0, 0x18)
 
 struct asn1_oid {
 	uint8_t asn1_len;
diff --git a/ell/cert.c b/ell/cert.c
index a158142..b4f5df7 100644
--- a/ell/cert.c
+++ b/ell/cert.c
@@ -25,6 +25,7 @@
 #include <string.h>
 #include <stdio.h>
 #include <errno.h>
+#include <time.h>
 
 #include "private.h"
 #include "useful.h"
@@ -33,6 +34,8 @@
 #include "asn1-private.h"
 #include "cipher.h"
 #include "pem-private.h"
+#include "time.h"
+#include "utf8.h"
 #include "cert.h"
 #include "cert-private.h"
 #include "tls.h"
@@ -186,6 +189,188 @@ LIB_EXPORT const uint8_t *l_cert_get_dn(struct l_cert *cert, size_t *out_len)
 						-1);
 }
 
+static uint64_t cert_parse_asn1_time(const uint8_t *data, size_t len,
+					uint8_t tag)
+{
+	struct tm tm = {};
+	int tz_hours;
+	int tz_mins;
+	int century;
+	int msecs = 0;
+	time_t tt;
+	unsigned int i;
+
+	for (i = 0; i < len && i < 15; i++)
+		if (unlikely(!l_ascii_isdigit(data[i])))
+			break;
+
+	if (tag == ASN1_ID_UTCTIME) {
+		if (unlikely(!L_IN_SET(i, 10, 12)))
+			return L_TIME_INVALID;
+
+		century = 19;
+	} else if (tag == ASN1_ID_GENERALIZEDTIME) {
+		if (unlikely(!L_IN_SET(i, 10, 12, 14)))
+			return L_TIME_INVALID;
+
+		century = (data[0] - '0') * 10 + (data[1] - '0');
+		if (century < 19)
+				return L_TIME_INVALID;
+
+		if (len >= i + 4 && data[i] == '.') {
+			if (unlikely(!l_ascii_isdigit(data[i + 1]) ||
+						!l_ascii_isdigit(data[i + 2]) ||
+						!l_ascii_isdigit(data[i + 3])))
+				return L_TIME_INVALID;
+
+			i++;
+			msecs += (data[i++] - '0') * 100;
+			msecs += (data[i++] - '0') * 10;
+			msecs += (data[i++] - '0');
+		}
+
+		data += 2;
+		len -= 2;
+		i -= 2;
+	} else
+		return L_TIME_INVALID;
+
+	if (unlikely((len != i + 1 || data[i] != 'Z') &&
+			(len != i + 5 || data[i] != '+' || data[i] != '-')))
+		return L_TIME_INVALID;
+
+	tm.tm_year = (data[0] - '0') * 10 + (data[1] - '0');
+	tm.tm_mon = (data[2] - '0') * 10 + (data[3] - '0');
+	tm.tm_mday = (data[4] - '0') * 10 + (data[5] - '0');
+	tm.tm_hour = (data[6] - '0') * 10 + (data[7] - '0');
+
+	if (unlikely(tm.tm_mon < 1 || tm.tm_mon > 12 ||
+				tm.tm_mday < 1 || tm.tm_mday > 31 ||
+				tm.tm_hour > 23))
+		return L_TIME_INVALID;
+
+	if (i >= 10) {
+		tm.tm_min = (data[8] - '0') * 10 + (data[9] - '0');
+		if (unlikely(tm.tm_min > 59))
+			return L_TIME_INVALID;
+	}
+
+	if (i >= 12) {
+		tm.tm_sec = (data[10] - '0') * 10 + (data[11] - '0');
+		if (unlikely(tm.tm_sec > 59))
+			return L_TIME_INVALID;
+	}
+
+	/* RFC5280 Section 4.1.2.5.1 */
+	if (tag == ASN1_ID_UTCTIME && tm.tm_year < 50)
+		century = 20;
+
+	tm.tm_year += (century - 19) * 100;
+
+	/* Month number is 1-based in UTCTime and 0-based in struct tm */
+	tm.tm_mon -= 1;
+
+	tt = timegm(&tm);
+	if (unlikely(tt == (time_t) -1))
+		return L_TIME_INVALID;
+
+	if (len == i + 5) {
+		data += i;
+
+		for (i = 1; i < 5; i++)
+			if (unlikely(!l_ascii_isdigit(data[i])))
+				return L_TIME_INVALID;
+
+		tz_hours = (data[1] - '0') * 10 + (data[2] - '0');
+		tz_mins = (data[3] - '0') * 10 + (data[4] - '0');
+
+		if (unlikely(tz_hours > 14 || tz_mins > 59))
+			return L_TIME_INVALID;
+
+		/* The sign converts UTC to local so invert it */
+		if (data[0] == '+')
+			tt -= tz_hours * 3600 + tz_mins * 60;
+		else
+			tt += tz_hours * 3600 + tz_mins * 60;
+	}
+
+	return (uint64_t) tt * L_USEC_PER_SEC + msecs * L_USEC_PER_MSEC;
+}
+
+LIB_EXPORT bool l_cert_get_valid_times(struct l_cert *cert,
+					uint64_t *out_not_before_time,
+					uint64_t *out_not_after_time)
+{
+	const uint8_t *validity;
+	const uint8_t *not_before;
+	const uint8_t *not_after;
+	size_t seq_size;
+	size_t not_before_size;
+	size_t not_after_size;
+	uint8_t not_before_tag;
+	uint8_t not_after_tag;
+	uint64_t not_before_time = 0;
+	uint64_t not_after_time = 0;
+
+	if (unlikely(!cert))
+		return false;
+
+	validity = asn1_der_find_elem_by_path(cert->asn1, cert->asn1_len,
+						ASN1_ID_SEQUENCE, &seq_size,
+						X509_CERTIFICATE_POS,
+						X509_TBSCERTIFICATE_POS,
+						X509_TBSCERT_VALIDITY_POS,
+						-1);
+	if (unlikely(!validity))
+		return false;
+
+	not_before = asn1_der_find_elem(validity, seq_size, 0, &not_before_tag,
+					&not_before_size);
+	if (!not_before)
+		return false;
+
+	seq_size -= not_before_size + (not_before - validity);
+	validity = not_before + not_before_size;
+	not_after = asn1_der_find_elem(validity, seq_size, 0, &not_after_tag,
+					&not_after_size);
+	if (!not_after)
+		return false;
+
+	if (out_not_before_time) {
+		not_before_time = cert_parse_asn1_time(not_before,
+							not_before_size,
+							not_before_tag);
+		if (not_before_time == L_TIME_INVALID)
+			return false;
+	}
+
+	if (out_not_after_time) {
+		/*
+		 * RFC5280 Section 4.1.2.5: "To indicate that a certificate
+		 * has no well-defined expiration date, the notAfter SHOULD
+		 * be assigned the GeneralizedTime value of 99991231235959Z."
+		 */
+		if (not_after_size == 15 &&
+				!memcmp(not_after, "99991231235959Z", 15))
+			not_after_time = 0;
+		else {
+			not_after_time = cert_parse_asn1_time(not_after,
+								not_after_size,
+								not_after_tag);
+			if (not_after_time == L_TIME_INVALID)
+				return false;
+		}
+	}
+
+	if (out_not_before_time)
+		*out_not_before_time = not_before_time;
+
+	if (out_not_after_time)
+		*out_not_after_time = not_after_time;
+
+	return true;
+}
+
 const uint8_t *cert_get_extension(struct l_cert *cert,
 					const struct asn1_oid *ext_id,
 					bool *out_critical, size_t *out_len)
diff --git a/ell/cert.h b/ell/cert.h
index f637588..db116e0 100644
--- a/ell/cert.h
+++ b/ell/cert.h
@@ -48,6 +48,8 @@ DEFINE_CLEANUP_FUNC(l_cert_free);
 
 const uint8_t *l_cert_get_der_data(struct l_cert *cert, size_t *out_len);
 const uint8_t *l_cert_get_dn(struct l_cert *cert, size_t *out_len);
+bool l_cert_get_valid_times(struct l_cert *cert, uint64_t *out_not_before_time,
+				uint64_t *out_not_after_time);
 enum l_cert_key_type l_cert_get_pubkey_type(struct l_cert *cert);
 struct l_key *l_cert_get_pubkey(struct l_cert *cert);
 
diff --git a/ell/ell.sym b/ell/ell.sym
index 6df9024..5fe8d6e 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -553,6 +553,7 @@ global:
 	l_cert_free;
 	l_cert_get_der_data;
 	l_cert_get_dn;
+	l_cert_get_valid_times;
 	l_cert_get_pubkey_type;
 	l_cert_get_pubkey;
 	l_certchain_free;
-- 
2.34.1

