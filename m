Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=52.101.84.133
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795518565;
	b=rG11c/Lu3IErh8AK9DrvfGECXskMWFtFDIinw2tY96MgNzVgJddkZXDvzwyMtgbVPkgW
	 kIDNzNTu+IfqXFlCCZZhcxUGxcBrMT4gus7fq87hJVwhXAv+SWYWScwAAtYsPRnD+RTvs
	 Zm0lyc86qemu5MvsSvyalhNa50cTn7+1Aj7XQZ0dumBFLDS/M0SXyiSMuV+oOOMG8Xrsq
	 B1Kq4cvSPjxWHh/3aDvvGeSR97rYUCKG2ho+nCil8xETXUlCvxbrxLMnt2z5sC7F//rus
	 KqLD/p5+xjhiJeGXY5nKiGBTaInolpIEzc94+3sq1LBW2nXHIB1Q2gQgWKKAtcWAD9A==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795518565;
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
	bh=hLLn8UjdYgCcrnVu5/l8hCnk/cZQIi2uPv2ff2yycn4=;
	b=GXRID/Lqmy2VA6CJdzE0RDV8MJX9IT+B1djxftqFe6jV0dxdIodheVBYHHPRXfGrahf4
	 kUGOi6dhsoTp626AVRrEGU7BUH2C1A1jzxlSKtsFOvScHJuTPQHmAuKwjwnyGXoVjIxJw
	 yzDNUVPixuVBAzQzi9Es4hTO9SWszrVv94NHdJynrz3EVZiaQMvVEFq66CQ2Z/0Lw7JlR
	 MmkQ4iA977W2xoXpThzsd3FN+Qhz5Ukci8Jz0kKgANmxt7LXJG8+K5iBC/HG8mnQR8sk6
	 7wIHwRmx+JSEQcL7Ve/jQ80fKpWyIXshsWVOtYtOQuiE589B/wRv4H0PiUsQoPLK9tA==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=kuleuven.be;
	spf=pass smtp.mailfrom=kuleuven.be;
	dkim=pass header.d=kuleuven.be header.i=@kuleuven.be header.a=rsa-sha256 header.s=selector1 header.b=Lf0VPPbC;
	arc=pass header.oldest-pass=0 smtp.remote-ip=52.101.84.133
Received: from DB3PR0202CU003.outbound.protection.outlook.com (mail-northeuropeazon11020133.outbound.protection.outlook.com [52.101.84.133])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (secp384r1) server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 279FA606A31E
	for <ell@lists.linux.dev>; Tue, 24 Nov 2026 11:09:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 279FA606A31E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=kuleuven.be
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=kuleuven.be
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=kuleuven.be header.i=@kuleuven.be header.a=rsa-sha256 header.s=selector1 header.b=Lf0VPPbC
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=epLXoLH5f7zDUconsZnd0fYai4fY/7bNuseMXdRoORyVsMpEXw2FXaqUpk3J8/4h7yGJ2JPpKQzdRDALpFSpz1LnF68jYbndzGOEsuNMHgjT9gXcUFgI/MwYtOgLGHeCTxL18V+8/HN3reNNhE2bN54/Q/XBCloRRBnMOELjnf3w1aljqz2sTFR5N1Y2CdhRFni1aMXYikhQP6v2uwaCiKkfZZEnCY9eG742K01tqBF2nvxotrSgLXhWGdN2sbXT+ykeozrdTkVNmTucl8mZWCtKVhnOAi+SM0L5WMCcrdHsi5MbtncIsy8gqFxBwTyAv1BXc4ue6HBaU2Bz17B7xA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=hLLn8UjdYgCcrnVu5/l8hCnk/cZQIi2uPv2ff2yycn4=;
 b=Q/9nOrDJUBYipen/tVeX5hWaQ2uWTB/XEbdv65ogyX7c96/TpAIZka9FEnqnep0eGl7QLA5yGfKdS6Yuf/lmjPK4L2F2cLEMIwg3D0qj1S3LqYV+Z3xAxuL28OFqJcYmRXZ2uKJ57TXGVvmmqUSUTbU7RdUc1KrD1X5tM192zXHLXe7bf5+w2ayhz2YWyC02yX6wHVm/XgxxNok885i4m7mcIN2qbhlOE2vQfbxXrnQgsNuormBMx8bJAmcrYwx/HLbaxkQXDEEQ59wRlq0USp5asLr0TIxgzAQHGlIWQicsNic+gE6To1HqaEA7eP6CIDW/GTOTPoHxxMXuTiz2IA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=kuleuven.be; dmarc=pass action=none header.from=kuleuven.be;
 dkim=pass header.d=kuleuven.be; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kuleuven.be;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=hLLn8UjdYgCcrnVu5/l8hCnk/cZQIi2uPv2ff2yycn4=;
 b=Lf0VPPbC6xy1uVnYozaN+isqIbP4z8Efd7Dn9EjYF/CcpbYLT2dlfCjDOUL7W7nstt7q61hgtGWHlwGt93c5dOlTing3kcncKe5laPvyKVGb4wUpZRtZ05rNI1AF19crWw8sFtsaHhsrSGmvluTS+22Mdig0Tijwn7P5w30C0ZM=
Authentication-Results: mx.microsoft.com 1; dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=kuleuven.be;
Received: from MI9PR08MB763857.eurprd08.prod.outlook.com
 (2603:10a6:290:c0::16) by DB9PR08MB7698.eurprd08.prod.outlook.com
 (2603:10a6:10:391::17) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.639.14; Tue, 24 Nov
 2026 11:09:19 +0000
Received: from MI9PR08MB763857.eurprd08.prod.outlook.com
 ([fe80::4f1d:a35e:c1b6:8b48]) by MI9PR08MB763857.eurprd08.prod.outlook.com
 ([fe80::4f1d:a35e:c1b6:8b48%7]) with mapi id 15.21.0639.012; Tue, 24 Nov 2026
 11:09:19 +0000
From: Mathy Vanhoef <Mathy.Vanhoef@kuleuven.be>
To: ell@lists.linux.dev
Cc: denkenz@gmail.com,
	marcel@holtmann.org,
	Mathy Vanhoef <Mathy.Vanhoef@kuleuven.be>
Subject: [PATCH 1/7] tls: Add support for server certificate pinning
Date: Tue, 24 Nov 2026 12:08:41 +0100
Message-ID: <20261124110847.1254540-2-Mathy.Vanhoef@kuleuven.be>
X-Mailer: git-send-email 2.56.1
In-Reply-To: <20261124110847.1254540-1-Mathy.Vanhoef@kuleuven.be>
References: <20261124110847.1254540-1-Mathy.Vanhoef@kuleuven.be>
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-ClientProxiedBy: AS9PR06CA0236.eurprd06.prod.outlook.com
 (2603:10a6:20b:45e::27) To MI9PR08MB763857.eurprd08.prod.outlook.com
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
X-MS-Office365-Filtering-Correlation-Id: 85273330-fdea-4b74-b137-08df4a1b630e
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|376014|1800799024|10070799003|786006|366016|23010399003|10067099003|11063799006|56012099006|261102123227099003|261026130827099003|261022105027099003|261022113327099003|261028144727099003|261026121527099003|261026135527099003|261022075727099003|261021135927099003|261021133027099003|261021130227099003|261021121427099003|261026140227099003|261102130727099003|261021123027099003|261022115727099003|261009223027099003|22082099003|6133799003|18002099003|3023799007;
X-Microsoft-Antispam-Message-Info:
	UTrexSs8XOhL7AvHli0TuXbTVzcGWB5tW3yewa7snx9Z4CKeDUuHvQoRwPAKGwdixLOo01gO8jRth8f7xnIfYr920rbqcVK1b4LhiQ/m/hXVga9DyG3oXUe5kdYVRPj7WBTI7oE+DTM8hlRLdAlo1VYPVSwjsRJtEnOTllspWq8H6U1sYPabEg4k48uXGLAjDMvXY55fcJm5no1eiN4O8TIDKsdJQc8vKEKCTlBSkvw20g9ak6fToh6kHG0UBc1yblW3QvATjmeU35CrRhBXA6FTmtymcKpV4ye9XeuERr/drPKoKX4XtJYljewrS9AVj+b4CFRaPZx+9zX7gOlYz1SszpBIk2ize+T1L7cmLUqPk8fWw6PldUrpIRGzwc1dGTG0NcC49vN5EfyoVE0fSVnJw7p3FBV87hYZIwjg3+4YcpHGTFkrOglUn6WIDQqjhQnuyIHfGDWVws0/wCk+d+1pKRpbYTzcgXn8/veOhb1ucEnXoMTn66TG6K1eE4JBo+4F9e0IVQhvkp0eCOjPC/FjFFsmtqOQ7hICnDgYAk2DdZDb4h3fibbYt8OEgUeKv2DpoHsXfB8YoQD39A1mkA9Z0t/L8JkkgEOO+gBxf2yYVhoa4Qp7/lEohyDYBXV34qFymJxnFahBbgzGTdhdDAogpuW1SBOl8ei11CXTfa0=
X-Forefront-Antispam-Report:
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:MI9PR08MB763857.eurprd08.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(376014)(1800799024)(10070799003)(786006)(366016)(23010399003)(10067099003)(11063799006)(56012099006)(261102123227099003)(261026130827099003)(261022105027099003)(261022113327099003)(261028144727099003)(261026121527099003)(261026135527099003)(261022075727099003)(261021135927099003)(261021133027099003)(261021130227099003)(261021121427099003)(261026140227099003)(261102130727099003)(261021123027099003)(261022115727099003)(261009223027099003)(22082099003)(6133799003)(18002099003)(3023799007);DIR:OUT;SFP:1102;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?us-ascii?Q?eFh9mTDJck8dKLPs4839yCKitwIQ8oiYyA1l5kbDqQfcHS1ncgxl3/i35efD?=
 =?us-ascii?Q?/57cchJ8oODXV8PbkYZaRN7Xs4qxtAJ7NtLjTcL1yIeFuFRP2wQvI6lxLUSV?=
 =?us-ascii?Q?+I2i3i9iszmIs5C0//VPo8XmQ0WJNLg8yG/Bl6hJDuZPptlaKc8fVYeBuEZi?=
 =?us-ascii?Q?8jUWzKGl9hLusGeZTaslsQ/WNA2YxzMvAiesnonSvEcdDurwV8B1EkQNLTnZ?=
 =?us-ascii?Q?xAGF2TFYtV4ymiv1KPEsbw7TKnBkvogufe+96oICh6G43QVt4JXiK4V724RI?=
 =?us-ascii?Q?cjtPN1ULUjSptpLtZyKBq/kXPejyoqkgqbC47zmKT2mRgNPKoHvsLhzH9HvC?=
 =?us-ascii?Q?0Vxgo0CXzDkrkKPVXTrRpGwqq7wosstkwQqpUI7Zxq2VW8J1fUdGmkBPphxe?=
 =?us-ascii?Q?fn81D44/QAAx8cwnZpFhCes7chK6mjgtcICpLnFsodn2xj7MFgSZZQxJhHa5?=
 =?us-ascii?Q?1wjzWBjXUNrxv7Qs3y+vCmK8AA+MVYfc0fSd8WLNWxyydLKiFNsULNPqudRV?=
 =?us-ascii?Q?Ppwmz0KYpHTvZQdDihk4UbrNLgZuk0fvT+c7I7Uy5xN2YbNGRipZn3R6fTTx?=
 =?us-ascii?Q?W9plm8qKhwwwskzhce2wBNVAkXj4bqMiEEaHpwZkn5X2dnFqexn59WhhA6Uu?=
 =?us-ascii?Q?8Evd3dlNT+6H08y5g2z/d51evua89Sd2rawyEqAiha9cWTpNPmTaEWQWQx0H?=
 =?us-ascii?Q?dWwOpgFtoQfkVU9Ra9+NBboSvFo81JM5Lbqx81WUUD4bQaHssz9gWcJ9UZV5?=
 =?us-ascii?Q?HM2JLO5L8MynLGnXXfxTgCMRfeZ5m5USb9msywNFpQaaJgU4WIk9jtTRzB1x?=
 =?us-ascii?Q?nXtDjSzDWenls21LlCahN1ZspvT/hXjogicD4duxH30dP3a5S+pc/3tZ61wg?=
 =?us-ascii?Q?pziz8IeZtSsM1ORFi/LDcwCdnkR69TjB3eDczUeTrspxQqLUa06EDiaSj2HL?=
 =?us-ascii?Q?Zne2VnNQVCQhP+5AEMKYWiCNxRCWHSaqlk5he1g+QDd0uXJRR3eEFzfsEohw?=
 =?us-ascii?Q?nFX/hXOnMH/LDYjRB2DqwK7iqjVi5DbtRVhKrr094c8ps0RXYFQ4wl7VwYJM?=
 =?us-ascii?Q?rXTPMK1EVsQ6DkeOoOS+eLIR1FdccI5Vp3w9sMmprbWcliF6VBEQpei3nz/7?=
 =?us-ascii?Q?I+1Tm2rK8ly2IkZOy2VXk92M3h2PHpn98pgc4zkWAvBhxVt959fJiemZlQ3S?=
 =?us-ascii?Q?g59FyeD0YqN/1iYpLp6UFX2br+ti5ApD/20Ca4xKz4t79mCJMYXZwmF59xFS?=
 =?us-ascii?Q?aNLKOdQd1iI19esOEOVjTYo1TadLbxg/BDZawWdM7PSUMwcl9RM/3SxU0W2c?=
 =?us-ascii?Q?7Skz+M0RXccCV0PE0me1IU6Zyk+jT3QAgv7O2JHAlvUtPOfecD9DXYTL7DW7?=
 =?us-ascii?Q?Bi/xThERpJkZCkHHeeIQ1ET0+Rx9mqxfyqLlHhDiWsDTbJJWc464ssOcg828?=
 =?us-ascii?Q?QvUwKHp4Qhi3wQxeNmYBU6Tz3A1q+f8OeCdk2m6O1HeeN/CdnoVcqA40fonT?=
 =?us-ascii?Q?ZDzzocSbh20Ry1unooxVAkZLuc9BuCYbpLBME95CgrnFetdmGxgV+Pjz04wk?=
 =?us-ascii?Q?HSNE4Qdse6M7ElRUCmiZeQ6hjGnfGmSX+Js/hcpGDO9BTr9OCuZB82TWhF1V?=
 =?us-ascii?Q?0JmsFlVkHYQ4PsXkKK6kZ6XrkFt8QQrJGItImNXnpgbNbrGo0md2EPv+rzp7?=
 =?us-ascii?Q?P10rN7KQre1bgite3aqfs5OW/aJCDw95jCGdso0YSt15HxKNwT71V1AESfqf?=
 =?us-ascii?Q?lNgttIHIwgYMFbtdhihI5ULnjVtnnZ9SL20vgg//Ldi/3Aw8IhfY?=
X-OriginatorOrg: kuleuven.be
X-MS-Exchange-CrossTenant-Network-Message-Id: 85273330-fdea-4b74-b137-08df4a1b630e
X-MS-Exchange-CrossTenant-AuthSource: MI9PR08MB763857.eurprd08.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 24 Nov 2026 11:09:19.7348
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 3973589b-9e40-4eb5-800e-b0b6383d1621
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: SlSbHpC/T3JKbgdJgLppT5ipPE5txSWSwdsqvLz5AkFqYIiu+OYgbg3/khbKP9yvl0qJUgpPV4+BSSdnKoMo4nFVXf0qFuJwSHx/J68czDg=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DB9PR08MB7698

Add l_tls_set_server_cert_hash() to pin the server's end-entity
certificate by the SHA256 hash of its DER encoding.  The handshake then
fails unless the server's certificate matches the hash.  A matching
certificate authenticates the server even when no CA certificates were
set, in which case its issuer chain is not checked, but its validity
period is still enforced.

This allows a client to trust a server certificate that it has seen
before, for example on first use, without trusting the CA that issued
it.

Co-authored-by: Rathan Appana <rathan.appana@kuleuven.be>
---
 ell/ell.sym       |  1 +
 ell/tls-private.h |  2 ++
 ell/tls.c         | 84 +++++++++++++++++++++++++++++++++++++++++++++--
 ell/tls.h         |  2 ++
 4 files changed, 86 insertions(+), 3 deletions(-)

diff --git a/ell/ell.sym b/ell/ell.sym
index 5cfb80d..f428289 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -551,6 +551,7 @@ global:
 	l_tls_set_auth_data;
 	l_tls_set_version_range;
 	l_tls_set_domain_mask;
+	l_tls_set_server_cert_hash;
 	l_tls_set_session_cache;
 	l_tls_get_session_resumed;
 	l_tls_alert_to_str;
diff --git a/ell/tls-private.h b/ell/tls-private.h
index c493f7f..7581567 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -200,6 +200,8 @@ struct l_tls {
 	struct l_key *priv_key;
 	size_t priv_key_size;
 	char **subject_mask;
+	uint8_t server_cert_hash[32];
+	bool server_cert_pinned;
 
 	struct tls_cipher_suite **cipher_suite_pref_list;
 
diff --git a/ell/tls.c b/ell/tls.c
index 5246650..a5bfbae 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -2500,6 +2500,21 @@ decode_error:
 			"ServerHello decode error");
 }
 
+static bool tls_cert_sha256(const uint8_t *der, size_t der_len,
+				uint8_t *out)
+{
+	struct l_checksum *sha256 = l_checksum_new(L_CHECKSUM_SHA256);
+	bool r;
+
+	if (!sha256)
+		return false;
+
+	r = l_checksum_update(sha256, der, der_len) &&
+		l_checksum_get_digest(sha256, out, 32) == 32;
+	l_checksum_free(sha256);
+	return r;
+}
+
 static void tls_handle_certificate(struct l_tls *tls,
 					const uint8_t *buf, size_t len)
 {
@@ -2563,6 +2578,40 @@ static void tls_handle_certificate(struct l_tls *tls,
 					tls->cert_dump_path);
 	}
 
+	leaf = l_certchain_get_leaf(certchain);
+
+	if (!tls->server && tls->server_cert_pinned) {
+		uint8_t hash[32];
+		uint64_t not_before;
+		uint64_t not_after;
+		uint64_t now = time_realtime_now();
+
+		der = l_cert_get_der_data(leaf, &der_len);
+
+		if (!tls_cert_sha256(der, der_len, hash) ||
+				memcmp(hash, tls->server_cert_hash, 32)) {
+			TLS_DISCONNECT(TLS_ALERT_BAD_CERT, 0,
+					"Server certificate doesn't match the "
+					"pinned SHA256 hash");
+			return;
+		}
+
+		/*
+		 * Accept the pinned certificate regardless of who issued it
+		 * but still enforce its validity period.
+		 */
+		if (!l_cert_get_valid_times(leaf, &not_before, &not_after) ||
+				now < not_before ||
+				(not_after && now > not_after)) {
+			TLS_DISCONNECT(TLS_ALERT_CERT_EXPIRED, 0,
+					"Pinned server certificate is outside "
+					"of its validity period");
+			return;
+		}
+
+		TLS_DEBUG("Server certificate matches the pinned SHA256 hash");
+	}
+
 	/*
 	 * Validate the certificate chain's consistency and validate it
 	 * against our CAs if we have any.
@@ -2603,7 +2652,6 @@ static void tls_handle_certificate(struct l_tls *tls,
 	 * restrictions) MUST be compatible with the selected key exchange
 	 * algorithm."
 	 */
-	leaf = l_certchain_get_leaf(certchain);
 	if (!tls->pending.cipher_suite->signature->
 			validate_cert_key_type(leaf)) {
 		TLS_DISCONNECT(TLS_ALERT_UNSUPPORTED_CERT, 0,
@@ -3292,7 +3340,8 @@ static void tls_handle_handshake(struct l_tls *tls, int type,
 		 *  - tls->ca_certs is non-NULL so tls_handle_certificate
 		 *    (always called on the client) must have veritifed the
 		 *    server's certificate chain to be valid and additionally
-		 *    trusted by our CA.
+		 *    trusted by our CA, or tls->server_cert_pinned is set and
+		 *    the end-entity certificate matched the pinned hash.
 		 *
 		 *  - the peer owns the end-entity certificate because:
 		 *    either:
@@ -3318,7 +3367,8 @@ static void tls_handle_handshake(struct l_tls *tls, int type,
 		 * message confirms their identity hasn't changed.
 		 */
 		if (tls->cipher_suite[0]->signature &&
-				((!tls->server && !resuming && tls->ca_certs) ||
+				((!tls->server && !resuming &&
+				  (tls->ca_certs || tls->server_cert_pinned)) ||
 				 (resuming && tls->session_peer_identity)))
 			tls->peer_authenticated = true;
 
@@ -3776,6 +3826,34 @@ LIB_EXPORT void l_tls_set_domain_mask(struct l_tls *tls, char **mask)
 	tls->subject_mask = l_strv_copy(mask);
 }
 
+/**
+ * l_tls_set_server_cert_hash:
+ * @tls: TLS client object being configured
+ * @sha256: 32-byte SHA256 hash of the server's DER-encoded end-entity
+ *   certificate, or NULL to clear
+ *
+ * Pin the server's end-entity certificate.  When set, the handshake fails
+ * unless the server's certificate hashes to @sha256.  A matching
+ * certificate authenticates the server even if no CA certificates were set
+ * with l_tls_set_cacert, in which case the issuer chain is not checked.
+ * The certificate's validity period is still enforced.
+ *
+ * Returns: true on success, false on invalid @tls or if @tls is a server.
+ */
+LIB_EXPORT bool l_tls_set_server_cert_hash(struct l_tls *tls,
+						const uint8_t *sha256)
+{
+	if (unlikely(!tls || tls->server))
+		return false;
+
+	tls->server_cert_pinned = sha256 != NULL;
+
+	if (sha256)
+		memcpy(tls->server_cert_hash, sha256, 32);
+
+	return true;
+}
+
 /**
  * l_tls_set_session_cache:
  * @tls: TLS object being configured
diff --git a/ell/tls.h b/ell/tls.h
index f283316..d59b5e0 100644
--- a/ell/tls.h
+++ b/ell/tls.h
@@ -116,6 +116,8 @@ void l_tls_set_version_range(struct l_tls *tls,
 
 void l_tls_set_domain_mask(struct l_tls *tls, char **mask);
 
+bool l_tls_set_server_cert_hash(struct l_tls *tls, const uint8_t *sha256);
+
 void l_tls_set_session_cache(struct l_tls *tls, struct l_settings *settings,
 				const char *group_prefix, uint64_t lifetime,
 				unsigned int max_sessions,
-- 
2.53.0

