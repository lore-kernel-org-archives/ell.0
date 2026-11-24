Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=52.101.84.133
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795518570;
	b=fwk3ld0XLhGuQv8mtaelyYpHIdrMhPlqjDNF8RNH5ll4fogkkx8zlRvbhzYJgQq5o+HT
	 dkPnT0uX4EbsBMMZBzKqbhdwTgdaP2OXOblLUVmDpHmEHUka43wg116VVi8POzdoWnrfo
	 gZoZo9mdnsmNS7gSIyD4uhLHBH70O9n/HBT/ouph6gK+3ynx6luQ+DDZeWNAR+I3Xk1ky
	 xI17Z88edeL4JiUla9U47lupft6Oeg0T5CJQPNMx72FfLttNrQn2OX94sVh7rE+TRKWN8
	 pM9hihlk2Ffd8n12xiDp2bpjpcyIJaHOyLgdVpYho90u3mPU8Z8a36SLe/LvNmL37sg==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795518570;
	h=DMARC-Filter:DKIM-Signature:Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:
	 Content-Transfer-Encoding:Content-Type:X-ClientProxiedBy:MIME-Version:
	 X-MS-PublicTrafficType:X-MS-TrafficTypeDiagnostic:
	 X-MS-Office365-Filtering-Correlation-Id:X-MS-Exchange-SenderADCheck:
	 X-MS-Exchange-AntiSpam-Relay:X-Microsoft-Antispam:
	 X-Microsoft-Antispam-Message-Info:X-Forefront-Antispam-Report:
	 X-MS-Exchange-AntiSpam-MessageData-ChunkCount:
	 X-MS-Exchange-AntiSpam-MessageData-0:X-OriginatorOrg:
	 X-MS-Exchange-CrossTenant-Network-Message-Id:
	 X-MS-Exchange-CrossTenant-AuthSource:X-MS-Exchange-CrossTenant-AuthAs:
	 X-MS-Exchange-CrossTenant-OriginalArrivalTime:
	 X-MS-Exchange-CrossTenant-FromEntityHeader:
	 X-MS-Exchange-CrossTenant-Id:X-MS-Exchange-CrossTenant-MailboxType:
	 X-MS-Exchange-CrossTenant-UserPrincipalName:
	 X-MS-Exchange-Transport-CrossTenantHeadersStamped;
	bh=6qwqZNrv2ZY8leJ36jxLt1aR7XIrZiJ/sRZDBmzrxhc=;
	b=5F9j+niZtlIVhdg8U7rQWS9UzSUeGnZ7Em1sevnTQJjIgKtjM7IdFQib0dv7Kv6IZuGz
	 ZaIv5As7fYX1u1KTk+ip01b2wefiutn1V1dNWI785/1rWmgyOz194KblYlW5SMJd8STGx
	 imPHsEo5UpO1GDWmvO/fPoyd+BzFm+PUWeLYqO58yeZkwdSd4LQJQHbF+xqlHNYABwmSN
	 YUJ6gcQsju02KwLUIxF/HBGQR5w/UXKrV5IE3/8ACi00A06odoSDo9CaZvw7fxPjVEosO
	 7grMHmHcsEYvIr2EmZKe695QbGK3Q9qsG7kWRhfxQcfnwVu/v22TkQ6DVpd6YxEmSyQ==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=kuleuven.be;
	spf=pass smtp.mailfrom=kuleuven.be;
	dkim=pass header.d=kuleuven.be header.i=@kuleuven.be header.a=rsa-sha256 header.s=selector1 header.b=Kj88ghxX;
	arc=pass header.oldest-pass=0 smtp.remote-ip=52.101.84.133
Received: from DB3PR0202CU003.outbound.protection.outlook.com (mail-northeuropeazon11020133.outbound.protection.outlook.com [52.101.84.133])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (secp384r1) server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 87351606A327
	for <ell@lists.linux.dev>; Tue, 24 Nov 2026 11:09:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 87351606A327
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=kuleuven.be
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=kuleuven.be
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=kuleuven.be header.i=@kuleuven.be header.a=rsa-sha256 header.s=selector1 header.b=Kj88ghxX
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=S+PR4fRtSZMSHHRQPkVAE3GNfsji7THl7CCQ+XChOxsKT77bnCL6T0vjrn4dSPc2+BGHaOVv7skarADj/YYALjPUTB1kCeSdarxeD6K0hdnI8Cwnypvzmf51L4SP73Xsquqs5NICK01HEp2cjoCgtwJkmVaXuPsGQWPRA8KeDGkIM4+u6SG0+SIz5VrDBZ+eFDq7ptnPp5wxe+16hY29rqWzisn4yAkAcHU8P79QLjFtkUHo8G4lNfLKmo6GXduf5Z7Rea/rpikhST06ERe7WJB7mOU9aW7tNph905O2Fyk+0b2xCVEAOEBpWIalPUGgMk5KpPZdB+FZV/peal3pUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=6qwqZNrv2ZY8leJ36jxLt1aR7XIrZiJ/sRZDBmzrxhc=;
 b=hCUdHxdVq3TveLwNI47MaeKW3VMjdOa0YEOM/Gwl7ejCkrJlAn7lzzDC2XjwVopLkmWNRAwzMltnY6U8x6xr3qWa22t4NNIRn+6AOMUi9dW4/oYUDVtWtP/dawA5FXyDJ1NjZ4u8zWZMta+CCUp+qsGJXleCcfjWlU/yrzf/BEqlNMT0100x5kDWkB0gAZPRte+Pf0gfvXRZnLKL+dLCtxiNfm/2VzlL64Rz3t0/0AHRZ42D/dO/YWFc9sVRolj/8yDtFTWi1R3p9dANu15nOO7okveHquKNYY0n+sr+L9LwDiq2g8l6sIkgqbNPGugTW7hFiVWXMn0Kjx2zcrMpJw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=kuleuven.be; dmarc=pass action=none header.from=kuleuven.be;
 dkim=pass header.d=kuleuven.be; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kuleuven.be;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=6qwqZNrv2ZY8leJ36jxLt1aR7XIrZiJ/sRZDBmzrxhc=;
 b=Kj88ghxXnGKTVQGMjL9xnTAPWV8L1V0F8/T0b0yQuBcg8rJf8kxSICppad7vLJ6wjM9/Sy/Ken/Q+qBmoDYefD2T9sctfMZm2FMpJCiyhERL1LGQnejAayJwrvjV8rMV177cfXI6uv2Mv6wpbaAksTx0qi4NhSrKWCU9Q4m6c60=
Authentication-Results: mx.microsoft.com 1; dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=kuleuven.be;
Received: from MI9PR08MB763857.eurprd08.prod.outlook.com
 (2603:10a6:290:c0::16) by DB9PR08MB7698.eurprd08.prod.outlook.com
 (2603:10a6:10:391::17) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.639.14; Tue, 24 Nov
 2026 11:09:23 +0000
Received: from MI9PR08MB763857.eurprd08.prod.outlook.com
 ([fe80::4f1d:a35e:c1b6:8b48]) by MI9PR08MB763857.eurprd08.prod.outlook.com
 ([fe80::4f1d:a35e:c1b6:8b48%7]) with mapi id 15.21.0639.012; Tue, 24 Nov 2026
 11:09:23 +0000
From: Mathy Vanhoef <Mathy.Vanhoef@kuleuven.be>
To: ell@lists.linux.dev
Cc: denkenz@gmail.com,
	marcel@holtmann.org,
	Mathy Vanhoef <Mathy.Vanhoef@kuleuven.be>
Subject: [PATCH 4/7] cert: Add l_cert_get_altnames
Date: Tue, 24 Nov 2026 12:08:44 +0100
Message-ID: <20261124110847.1254540-5-Mathy.Vanhoef@kuleuven.be>
X-Mailer: git-send-email 2.56.1
In-Reply-To: <20261124110847.1254540-1-Mathy.Vanhoef@kuleuven.be>
References: <20261124110847.1254540-1-Mathy.Vanhoef@kuleuven.be>
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-ClientProxiedBy: AS8PR07CA0023.eurprd07.prod.outlook.com
 (2603:10a6:20b:451::23) To MI9PR08MB763857.eurprd08.prod.outlook.com
 (2603:10a6:290:c0::16)
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Post: <mailto:ell@lists.linux.dev>
List-Help: <mailto:ell+help@lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
List-Owner: <mailto:ell+owner@lists.linux.dev>
Precedence: list
MIME-Version: 1.0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: MI9PR08MB763857:EE_|DB9PR08MB7698:EE_
X-MS-Office365-Filtering-Correlation-Id: 375b1924-fba4-4784-e00e-08df4a1b655e
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|376014|1800799024|10070799003|786006|366016|23010399003|10067099003|11063799006|56012099006|261102123227099003|261022105027099003|261028144727099003|261026121527099003|261021121427099003|261026140227099003|261102130727099003|261021123027099003|261009223027099003|22082099003|18002099003;
X-Microsoft-Antispam-Message-Info:
	PG5Bz3Q1f+ul2dE3j0Pg3PXJk56972/ZSzk3lVe/eucpFLg6WbBG4T1JgHWn25BVywO+Ft0R6oFSOGNe/Uv3gc3JVzthj/jj3znON1SdgDzU+5JBe2bLWGv6x7RL0ldRHaFokyEKZqP+qou/VQLiRWAYkxyvY9OTVPoSW+MWtJgP3Zduafma8TffrWjyLQRKXdEhbLCyUhAMOoUfH6RWmqh4h6AC39xi8t32iNsLkDuJCAxVF0gBu4U6gdokwZqnIip/GvxdRhfnjA9IOIHSBSF87yVcF6gqki2zzHZ20UoxSu6CdOwZlQkPkhmfeF0efxD+j5SFCQR509tVWA+5co4R4U+PJfyS3ZApscsCANutMawd0dFfsASH31DUxPBeqiJlyycYYf+siJL80z0cqGeplxNB2WK0qWo7tWhOrzU7Ii7hAlov7UtBzNd6WqhC/fD0BX2iZ0nw6B9YtrKDofzVtGa6R3qW6qQawEzB/4hq5AamhQp+nIQKHTTHT+kDTjBuPe5P+Y7hrwbWWS5c4xgt92zkWXW+wAk8FlMKTiVLZjTPYKkfB5QWkZEHFOqSaj2lT5r5BUyMZG2TaW2j3zv/t9MCQ3Op+i5POYo4bjuROSdlUgKm3FJlPRJ49qfpj/HfGAO8ljU9Vwd4VgA3enaCE5LtZ3QInaZVklakYdE=
X-Forefront-Antispam-Report:
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:MI9PR08MB763857.eurprd08.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(376014)(1800799024)(10070799003)(786006)(366016)(23010399003)(10067099003)(11063799006)(56012099006)(261102123227099003)(261022105027099003)(261028144727099003)(261026121527099003)(261021121427099003)(261026140227099003)(261102130727099003)(261021123027099003)(261009223027099003)(22082099003)(18002099003);DIR:OUT;SFP:1102;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?us-ascii?Q?z9wmuUDu8tRLgmYE84T7Mf1ieFWkpQ/xXrLO48hNawj8I6IDd+zclEMXZM+h?=
 =?us-ascii?Q?ZfH3hUUDmuWOxyDiYXWImgZs1rD2fHhnqKVgc1DGGu4la3Ie9r4DO56A9wWV?=
 =?us-ascii?Q?bYNhoaDIrw6yb5xld0llMz8isDEawIer6TSEQClc/KsNM1+Oauwuj8ow2uoJ?=
 =?us-ascii?Q?pfTShSx30h2TsoOzIpUknigCYtGlPoNJL5kVzKWxwashbUWdiWvGlXMvJswk?=
 =?us-ascii?Q?ASTeTbnbN3oQQrELwN24fSukkyVxkUcRWtaRtRumlKE9QyoaRtDfceSjdeHg?=
 =?us-ascii?Q?Zqw7B0zlKzh4LpoTCeV7ZKOd7pt8FwH20gtgOb0pnydpJ7S/peWvjNtNRQug?=
 =?us-ascii?Q?YV89oSwZoCulZJmKbySMNHFnPV1NHPNQ7ywuXJMb+b+g9rMtGslp1y3SG1Oj?=
 =?us-ascii?Q?wL6cg7lGfDCDuvEr2WDssyX7VlTCJGoZnTcDeto6j4ihx9DdO5QL1O5lPMDk?=
 =?us-ascii?Q?8b8/VctvsCVJq19C8P/BE+PUWpiga3WWqS7VBqjcLEYex1dylhjmzg5vHyZy?=
 =?us-ascii?Q?+vK12ZIwqkb2VsVOPq5C3ZHMFBsO2WpxeJYiF/bJ4fRRuTDaxr+ggTeSfmpr?=
 =?us-ascii?Q?tKFvnDsnRm37ktRe2swTD1syEjTOzgE5DtP/fczPSZlB7s3roTv+Z/yGjP8P?=
 =?us-ascii?Q?1INLKu6/KyxOGH874cBf9Uv3iMVfEaLSswLo8L7YknDMG9NuoG4aOwCECLZ5?=
 =?us-ascii?Q?oBJInTasdnrp0MCDFnWNo+6O/9rJ/y7PG5ciYjCq73v7R9xGVT5ZWuxdckho?=
 =?us-ascii?Q?laYsS3RyiaJsRUhF/QMLRiM5p+/QNjhs1WL8WF0MlEBL7y0SxS/o1FZ6d8oF?=
 =?us-ascii?Q?b3qNM/TgQplS2nSYDiYS/r9MnjEgOl/X4cQ4zjMSKhk0ZHLKvHB308IAXj2Y?=
 =?us-ascii?Q?0fM6ilm0adLJfup6FXAoZa96cr/x6tZiW/uLGwgpUEZzkVhO7rOldkBfZL8s?=
 =?us-ascii?Q?1xj0v9RqEMUva4uG5Obfs9N+ghO6zk7b7mRgl1vUpSzfDV/2wiMwOIq4PPMB?=
 =?us-ascii?Q?nS+VWrKsuSIZ4oES1srABQHzIYKWKpmmaA93dvgXTcEOA2iEVL7XaalTsWve?=
 =?us-ascii?Q?b0tgYMTGPhP+QF3iFGkT52GwA1UqiRrnkWx8T17SCfkxrHlYYyBLlj7g9F2r?=
 =?us-ascii?Q?I7gvfOEePIChI/H+/Gzrw5rNMbv4JZqo+skQgTHsYAOQ2qWncH7VFfowC0rj?=
 =?us-ascii?Q?sDSNHbNrvYJ4pGBAZPCpoagcpGMEprNaSXya9Ynt2Tb+uTchcPN1ta31/QKn?=
 =?us-ascii?Q?93IVAODpbA2k8k7lunskBTu3489A01/A/B9TKrp9AEWpalkEkx7sOB3QWlfX?=
 =?us-ascii?Q?SODZQr7HZP4/JsXiFULJlAj/8pS0jOer6cvLdUIaY1A5+yeFvuRs6+4xcJSs?=
 =?us-ascii?Q?2aLXtNfI2Sv2O0ugFR6iRz+XkABI2eQWsKD8Qc4ivNw0KSun8JFxsdX5nTvt?=
 =?us-ascii?Q?lZQOqSfdGccso+T3uL0QnP3F5XB5RzVzpyxUPOIFD1EDEt65D5e+wEUp7N+M?=
 =?us-ascii?Q?LA0F113imhoeLPW482rRnskEajsBejSwvM888stPKLmzEJ81QxZCmis1fz+l?=
 =?us-ascii?Q?tyS1+gUOv5EOsBpqfXZXZxG+Qh+FqyTJzn6Yfj1SxKSrazB5OJeqUbMjet6U?=
 =?us-ascii?Q?ZTW6S323GX92XXq1VCcxTHvcui4L6dQejdX2w0nGGCo3/lJo/Cujn5tODkqT?=
 =?us-ascii?Q?gWjzqfDw/1jWyGSPUp+yF8aqSgdl5zQ3hD78fYwFTasWg+s/L1rEg5yTKGRO?=
 =?us-ascii?Q?RFRZjLmoiIyGoaT9l9X0j+dUUkG+rNbfo+FT8vpe8VyOo7Sbj0H6?=
X-OriginatorOrg: kuleuven.be
X-MS-Exchange-CrossTenant-Network-Message-Id: 375b1924-fba4-4784-e00e-08df4a1b655e
X-MS-Exchange-CrossTenant-AuthSource: MI9PR08MB763857.eurprd08.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 24 Nov 2026 11:09:23.6136
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 3973589b-9e40-4eb5-800e-b0b6383d1621
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: kirUG7egAQ85zopnVXPhLzvHwjY1YssLsbteWJ2FwjIRTB1i+i2cQttO7IcAcIl5U61ZWq51rSZ2YDtyrkJbEGPmEB91wtCcwccPIxYUV4I=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DB9PR08MB7698

Add a function that returns the email address, DNS name and URI entries
of a certificate's SubjectAltName extension as strings prefixed with
"EMAIL:", "DNS:" and "URI:", in the order in which they appear in the
certificate.  This is the same form in which wpa_supplicant reports
them, so that network managers can handle the certificates reported by
both in the same way.

Co-authored-by: Rathan Appana <rathan.appana@kuleuven.be>
---
 ell/cert-private.h |  2 ++
 ell/cert.c         | 71 ++++++++++++++++++++++++++++++++++++++++++++++
 ell/cert.h         |  1 +
 ell/ell.sym        |  1 +
 ell/tls.c          |  2 --
 5 files changed, 75 insertions(+), 2 deletions(-)

diff --git a/ell/cert-private.h b/ell/cert-private.h
index c1b2e01..4b014a1 100644
--- a/ell/cert-private.h
+++ b/ell/cert-private.h
@@ -7,6 +7,8 @@
 
 struct asn1_oid;
 
+extern const struct asn1_oid subject_alt_name_oid;
+
 struct l_certchain *certchain_new_from_leaf(struct l_cert *leaf);
 void certchain_link_issuer(struct l_certchain *chain, struct l_cert *ca);
 
diff --git a/ell/cert.c b/ell/cert.c
index 0ffb5c3..b0312dd 100644
--- a/ell/cert.c
+++ b/ell/cert.c
@@ -25,6 +25,7 @@
 #include "time.h"
 #include "time-private.h"
 #include "utf8.h"
+#include "strv.h"
 #include "string.h"
 #include "cert.h"
 #include "cert-private.h"
@@ -296,6 +297,76 @@ error:
 	return NULL;
 }
 
+const struct asn1_oid subject_alt_name_oid = { 3, { 0x55, 0x1d, 0x11 } };
+
+/**
+ * l_cert_get_altnames:
+ * @cert: certificate
+ *
+ * Returns: the certificate's SubjectAltName email address, DNS name and
+ * URI entries, in the order in which they appear in the certificate, as a
+ * newly allocated NULL-terminated string array.  The entries are prefixed
+ * with "EMAIL:", "DNS:" and "URI:" respectively.  Returns NULL if there
+ * are no such entries.  Free with l_strv_free.
+ */
+LIB_EXPORT char **l_cert_get_altnames(struct l_cert *cert)
+{
+	const uint8_t *san, *end;
+	size_t san_len;
+	uint8_t tag;
+	char **names = NULL;
+
+	if (unlikely(!cert))
+		return NULL;
+
+	san = cert_get_extension(cert, &subject_alt_name_oid, NULL, &san_len);
+	if (!san)
+		return NULL;
+
+	san = asn1_der_find_elem(san, san_len, 0, &tag, &san_len);
+	if (!san || tag != ASN1_ID_SEQUENCE)
+		return NULL;
+
+	end = san + san_len;
+
+	while (end - san >= 2) {
+		const uint8_t *value = san + 1;
+		size_t len = end - value;
+		const char *prefix;
+		int value_len;
+
+		tag = *san;
+
+		value_len = asn1_parse_definite_length(&value, &len);
+		if (value_len < 0 || (size_t) value_len > len)
+			break;
+
+		/* rfc822Name, dNSName and URI are all implicitly IA5STRING */
+		switch (tag) {
+		case ASN1_ID(ASN1_CLASS_CONTEXT, 0, 1):
+			prefix = "EMAIL:";
+			break;
+		case ASN1_ID(ASN1_CLASS_CONTEXT, 0, 2):
+			prefix = "DNS:";
+			break;
+		case ASN1_ID(ASN1_CLASS_CONTEXT, 0, 6):
+			prefix = "URI:";
+			break;
+		default:
+			prefix = NULL;
+			break;
+		}
+
+		if (prefix)
+			names = l_strv_append_printf(names, "%s%.*s", prefix,
+						value_len, (const char *) value);
+
+		san = value + value_len;
+	}
+
+	return names;
+}
+
 static uint64_t cert_parse_asn1_time(const uint8_t *data, size_t len,
 					uint8_t tag)
 {
diff --git a/ell/cert.h b/ell/cert.h
index ce6efea..7aadeb9 100644
--- a/ell/cert.h
+++ b/ell/cert.h
@@ -34,6 +34,7 @@ DEFINE_CLEANUP_FUNC(l_cert_free);
 const uint8_t *l_cert_get_der_data(struct l_cert *cert, size_t *out_len);
 const uint8_t *l_cert_get_dn(struct l_cert *cert, size_t *out_len);
 char *l_cert_get_subject_str(struct l_cert *cert);
+char **l_cert_get_altnames(struct l_cert *cert);
 bool l_cert_get_valid_times(struct l_cert *cert, uint64_t *out_not_before_time,
 				uint64_t *out_not_after_time);
 enum l_cert_key_type l_cert_get_pubkey_type(struct l_cert *cert);
diff --git a/ell/ell.sym b/ell/ell.sym
index fa9788b..ee876ac 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -590,6 +590,7 @@ global:
 	l_cert_get_der_data;
 	l_cert_get_dn;
 	l_cert_get_subject_str;
+	l_cert_get_altnames;
 	l_cert_get_valid_times;
 	l_cert_get_pubkey_type;
 	l_cert_get_pubkey;
diff --git a/ell/tls.c b/ell/tls.c
index 78c15cb..ccdc4cb 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -693,8 +693,6 @@ ok_next:
 	}
 }
 
-static const struct asn1_oid subject_alt_name_oid =
-	{ 3, { 0x55, 0x1d, 0x11 } };
 static const struct asn1_oid dn_common_name_oid =
 	{ 3, { 0x55, 0x04, 0x03 } };
 
-- 
2.53.0

