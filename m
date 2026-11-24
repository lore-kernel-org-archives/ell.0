Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=52.101.84.133
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795518566;
	b=iuZzVeqiaPT1kMJN3brtImkVWlDAhd5+on8o+cO7LpAIUNbhOpyLs5OFsEWYVkhevDGl
	 guWJK80xyxVBxcYB4ZkehzI+k3OGtI44JeZwNtUZoq7aoOLcnluqRbOyMcvzJHr1LsGOv
	 c8+Mm9ctWbZuzt5TtnNZZZYqYqaKfSCMl6d9yXH+pFxEidJZ5Kdm4JPXscG4InFu1QWSc
	 YpRU9GERqIUTF9zdvjvdXPVHNrP+sMvknfF6p3CnWb8gcDSroJcRKddsDWhuwFFOm8yFa
	 vgZkFY2mVa/Ad35DFwuJ/h8/SkT/f6dNLoe3IXSFH8wPHSYzmnjE443q2firikjUbTA==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795518566;
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
	bh=0g6Fk+JP+hS9QniUIi/wTl8/F3wxwZAS3/TIW2msjpo=;
	b=Vv3Ofz6u3Zpdi8s6fDxvXrS8Lf/NURPAd2a7KWAmnu/vv1HUxtPO9MEZkH9hqTni/8M7
	 dfULy64SKaG8koO4PiAzDJGGqN3HPUiLB+fZKclPJ60TiNu3ZMzmiNKit3M33CqcHPBy+
	 A+d4rMsgbQO2HaDK0NzCGKMuwiYhQMIO47jsgp0TfhM8MAqMREshBdOuRd63BcHy5FfPZ
	 DwFJu0IEWcLMVueAplBQwkEEO9HJ3NP+fjg4qf6/9q0VP+IYeyigDNR+1th2aahcwkWK1
	 ajDt5OPGlokPuC5KcvNWGPJmHaNKcAH8dMkofX8JUBDACqPOanR7qInydLjQTFLNXdg==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=kuleuven.be;
	spf=pass smtp.mailfrom=kuleuven.be;
	dkim=pass header.d=kuleuven.be header.i=@kuleuven.be header.a=rsa-sha256 header.s=selector1 header.b=CwkKMXva;
	arc=pass header.oldest-pass=0 smtp.remote-ip=52.101.84.133
Received: from DB3PR0202CU003.outbound.protection.outlook.com (mail-northeuropeazon11020133.outbound.protection.outlook.com [52.101.84.133])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (secp384r1) server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E846C606A31E
	for <ell@lists.linux.dev>; Tue, 24 Nov 2026 11:09:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E846C606A31E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=kuleuven.be
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=kuleuven.be
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=kuleuven.be header.i=@kuleuven.be header.a=rsa-sha256 header.s=selector1 header.b=CwkKMXva
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=NSdyblFJwC/SrF4B5Td7ogLLVyE37Dh6c8RH33IYsHwDDRMgPal4sGwNmcVXPteGt6iysUIowI+iI/RPpOyHaCVA0OW3pg4Rh2W5K0N2XdhdioX3tL2DO6l/TLolxatIllQPOwrRi2F/ZA01Syb1cmiMguLZAlD+QRaC2kf54R0YymWJI2tLKMpf4/e0BODF8UoXDPxFu19N5NUr9hRq5PLyhH+yHDpM6306WGBgws2htb1xWQanUQ+A9VoRGcnjoUfEOKgGuuATi0udrSubiqRQoVeTzApbIzdbkPdkpq8vlC2BZdoTodTdprhwy58335XyS9ANFBZHhQKhMO/13Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=0g6Fk+JP+hS9QniUIi/wTl8/F3wxwZAS3/TIW2msjpo=;
 b=vZTnvcCzUVo5aC5t0qMxx6Z1UCUyS3ZJASCIKRC2XqS8rRjHhthPhzyEBF9USp5IqgW85yr7RaGU7oUhVwfM42ZUuojqQbew5QC4s2NArpcYGDR27yj+x/886fY5HPsEIDW1iNPPPf0QZqeRMJlkDrerTQfGF6vfPxRHuX17Z7crLudhfb/CoVmURyHlNiILMMotLfa+dMCXRqd5FWFvgIFZQnDMQl6ccgAnKGY65UwFD+ai/7pkuPgCB4xJGtVphHIYOfLo25DYOECkLhR2Mrz3VVLqyLT+vhRFyFTVl/mAscOBJfwnLmUPs3FdyNwiZwctD5PexJFQ81g8FNUv0Q==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=kuleuven.be; dmarc=pass action=none header.from=kuleuven.be;
 dkim=pass header.d=kuleuven.be; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kuleuven.be;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=0g6Fk+JP+hS9QniUIi/wTl8/F3wxwZAS3/TIW2msjpo=;
 b=CwkKMXvaDFpWgbYLnlN64NsntFjXEWGu/fIbktoLk335/lFesDmh043+8/GeuPwBE9nPccBcPs9a74TCRSaO07yUGescJ/lguXSelF+whlTVlV9669A/PaaU0Kya67HTXHqnXMuwFv1XPYEZG/KF/JZDs1L8GJAc5jnq0Yh4g8g=
Authentication-Results: mx.microsoft.com 1; dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=kuleuven.be;
Received: from MI9PR08MB763857.eurprd08.prod.outlook.com
 (2603:10a6:290:c0::16) by DB9PR08MB7698.eurprd08.prod.outlook.com
 (2603:10a6:10:391::17) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.639.14; Tue, 24 Nov
 2026 11:09:21 +0000
Received: from MI9PR08MB763857.eurprd08.prod.outlook.com
 ([fe80::4f1d:a35e:c1b6:8b48]) by MI9PR08MB763857.eurprd08.prod.outlook.com
 ([fe80::4f1d:a35e:c1b6:8b48%7]) with mapi id 15.21.0639.012; Tue, 24 Nov 2026
 11:09:21 +0000
From: Mathy Vanhoef <Mathy.Vanhoef@kuleuven.be>
To: ell@lists.linux.dev
Cc: denkenz@gmail.com,
	marcel@holtmann.org,
	Mathy Vanhoef <Mathy.Vanhoef@kuleuven.be>
Subject: [PATCH 2/7] unit: Add tests for TLS server certificate pinning
Date: Tue, 24 Nov 2026 12:08:42 +0100
Message-ID: <20261124110847.1254540-3-Mathy.Vanhoef@kuleuven.be>
X-Mailer: git-send-email 2.56.1
In-Reply-To: <20261124110847.1254540-1-Mathy.Vanhoef@kuleuven.be>
References: <20261124110847.1254540-1-Mathy.Vanhoef@kuleuven.be>
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-ClientProxiedBy: AM5PR03CA0027.eurprd03.prod.outlook.com
 (2603:10a6:206:15::17) To MI9PR08MB763857.eurprd08.prod.outlook.com
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
X-MS-Office365-Filtering-Correlation-Id: 98cc991a-cc36-4985-10d6-08df4a1b63e0
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|376014|1800799024|10070799003|786006|366016|23010399003|10067099003|11063799006|56012099006|261102123227099003|261022105027099003|261028144727099003|261026121527099003|261021121427099003|261026140227099003|261009223027099003|22082099003|18002099003;
X-Microsoft-Antispam-Message-Info:
	Vsd8NAY3RF9w6iJJ1NbF6gxkp8LAAUum+g8SEv5eqRnRLWh9hrQF+d9iWm7PREJaIIUtpUgNSdCep88TOr66vDFXdxA0aAnQeqf8T0NsziEswf72zPvRies1JxycCrLuNGxAjl22P/T4YycUVCWJCRLpTgqshAyVv6ibEHhUFe8DwO5GVNK0J8g/1FF68Wp6VgPI4HPnMlCAy2iO4yjKT4plRanxDwKjrtu2FfV5vUtadqWu8keShCcbqbcNto0dVYdX0HiX6hWjcgO7EpQCZ0Zv8/8UQqlWCaIq6bkt7tIYEeusoW5ISk2F55rqvrSbz4GQCTKi/xk0MOYAllcrflseSr+l+sSOHm1n9GYbHYezcmBwhmxU8Ue9JRW+ImaupP0qY3l6BcLMQAV7hzYzu6rdIQHucbkKORdkYGn7AyMVtpnbKAF8oOFEVpw0YRD8hfsp0xB/y7aKmVCuppJGieXNipJNPkwb3cxsV/e0v2HN0Ac0Qxwv+RGWwtszVraI6jiuLxFA3zZaEYkdqyGJK+mwgIsTHzZrPzA8pOw9VR7739ferTWx+IJW4jP9wvpmFE5XBoIXU2fZqbllU8Jy1GVsJG6Zna/FLMF+E95PCCGCEofOuZSq+JFoPVRh2KHYwW0GVR+iDUV22/NE47LnneYg43rgwj2Qivmc5KV6JDY=
X-Forefront-Antispam-Report:
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:MI9PR08MB763857.eurprd08.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(376014)(1800799024)(10070799003)(786006)(366016)(23010399003)(10067099003)(11063799006)(56012099006)(261102123227099003)(261022105027099003)(261028144727099003)(261026121527099003)(261021121427099003)(261026140227099003)(261009223027099003)(22082099003)(18002099003);DIR:OUT;SFP:1102;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?us-ascii?Q?SMBqUBSd1/FV8pzA+crdHwtbIpvuWQcdQvm+7M+0P24f1efGsjjoo2Od2371?=
 =?us-ascii?Q?sB/Iicn/hOqeuQQWo/nj19ky5PEQYcnXhbObhe2He2rbSsSQ851s75Fi9dA0?=
 =?us-ascii?Q?ci9QUzflOGTziFREpUr4jIc7HyHW5kZ2sfFLFYmc/13u7CtXlgefU23JJrB0?=
 =?us-ascii?Q?LwZBiE5GIspNemoBw6QKMJ7a8PpiZ5q5pE5Nux8VBLpe8+fViVjlA5dix1f4?=
 =?us-ascii?Q?oizLRBOHPaxTRY17Pp3cF6MTulhkLfjaD9ccXhCBABbF04dBS9SZ/EUFRO0D?=
 =?us-ascii?Q?8mCK2MnKtmR+r3QlXz2TNYhZEL3iSAolyVuQwQqoF8FweNRWg2hBvIbAKRqn?=
 =?us-ascii?Q?eyU0S7CRxT2kUa8ye0aHXwyO9O8CECU8BJuYmR7UjuqMgmnIvzsPhELdBn38?=
 =?us-ascii?Q?aaLhn6Egu0RrM0tKgaPhH6Nq+HCt54maBiV/BtI3RisHOXMd/4UhocYAmFQC?=
 =?us-ascii?Q?wzmDU6yAT5YxrQKnZN1lSxUXTpbIZbtq3SmS+qezXf1bBPbYZO5PkYW48GL/?=
 =?us-ascii?Q?N1tDplKXoXbJJFj174m7k71EdZ0QHe+3yUqFXgU2k+ynjCyvbSPLBHJPO+B+?=
 =?us-ascii?Q?RKBNr0MJL+J1r+m3QH4DZ1CEeanX7BUXMSsEQiPznozW0nSRMSdSRiPK+wo5?=
 =?us-ascii?Q?IJJTTyi4RnvBG00l4vohmruEKS6YoTPJcQVJCZrPuNfg4NexOovtOE/3IAHZ?=
 =?us-ascii?Q?xYlkdM8Peo7fBVQ2jJZZc63aaCtvNAwUxiHys2pqdAAe5DGO3xi2QmVcEZXt?=
 =?us-ascii?Q?VyK7KMxMOxeV8+IbD8vMISfMYqLhgbNy0c9yS3oGU1cfPcJiPlRZ5v7HQABb?=
 =?us-ascii?Q?+bFzi9DDtFIBbSNq9HjIHdjCMHkackjKbmjMSCw9hgjMrDeI/uD2yR/vqpRp?=
 =?us-ascii?Q?Tg3cKaCciaQQ110ZhEBSjEZJi+tWP1DQeGpHzJBHLKPxf2+aPgxO8V+aVGuC?=
 =?us-ascii?Q?EsBPN5b/pivsoNthqco1T//q2bGIvUqUnOplHSTU+GRtiOOiiYc4GEHCEG9V?=
 =?us-ascii?Q?4iTCMBQuDE1WEt1qcw1V0DotM5IyO+LWmZuM6Xti+t9flBzf8BKshhNDFwkq?=
 =?us-ascii?Q?4DdEY0bexQcjnyhH9BvIgJRbEdWUrEVJozMA7BLk5WHzq9FEiTy5DmzSVecq?=
 =?us-ascii?Q?XxJTSl2EprEpY3VYuTIA6MlCw6uCg6eUXlZ6cex55D/fbDOUnyQfaegRs9bI?=
 =?us-ascii?Q?74WURMIQe2W59Y0mx3/bAQYIapnaLUEV+IhwaLyjS2Vn7p19eboX8tEG/Km8?=
 =?us-ascii?Q?2HpObEZTQKeRl+QDaviKeWVGgyydYcrR9ZOTPv5HEpYSKy+eF8n2nYsDooY6?=
 =?us-ascii?Q?RYh3HodBF1P/Wba4ToI3gkGlXgOJiHDQ4FMixh/oqW+Wy2KmKV+Spi7vtNLy?=
 =?us-ascii?Q?R0UekBHvCHOSCO1nUAjPv0XSlL97NWl1Oc0h4PFCla0S3xmgD4Pse8v1POhI?=
 =?us-ascii?Q?iOZvWaMX/9dmEZUVCevsnnWCEmlmPFAfPWHaiGbbnPeUsTXCCcpxSiQESFgX?=
 =?us-ascii?Q?Ok4qaKyellnZi/BXwQiRxAm/wbWxrlpfKhjfOIX5w0o9F5lygA3uGsulRRGo?=
 =?us-ascii?Q?2C1ueL9KDWE+593C+dsuSXvMgltNsQLG+VIcTU/l4HfaEl0GeylJw2QCvBqS?=
 =?us-ascii?Q?j9UzYjWPh8macEroK5J9AtIXFPLhcg4krPTZxEOh6xE2G+Kg29RAzggANBZY?=
 =?us-ascii?Q?Jg9uejtB4+TfgCkulRf1aBihxwCiz7ir2kvS/0KM8DTLEeJEh5ypDITTOKmR?=
 =?us-ascii?Q?lxnNBSRB+wCuV9zNgwQZUm0luYAygzrEYtnnpn89jPVGsLBvQ4TO?=
X-OriginatorOrg: kuleuven.be
X-MS-Exchange-CrossTenant-Network-Message-Id: 98cc991a-cc36-4985-10d6-08df4a1b63e0
X-MS-Exchange-CrossTenant-AuthSource: MI9PR08MB763857.eurprd08.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 24 Nov 2026 11:09:21.1056
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 3973589b-9e40-4eb5-800e-b0b6383d1621
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: 3TCwo0hXpIccU8H0peYJ7AC2EOOZ546TsTdSCSNZq4yhw+C0T1aLz3c7MlE5OryNiE0wrHdy/UgUMPZWSxe8SZCxlGBer8hiURO8pJGRZzg=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DB9PR08MB7698

Test a pinned server certificate that matches and one that does not,
both with and without a CA certificate, and an expired pinned
certificate.

Co-authored-by: Rathan Appana <rathan.appana@kuleuven.be>
---
 unit/test-tls.c | 78 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 78 insertions(+)

diff --git a/unit/test-tls.c b/unit/test-tls.c
index 1f7961d..669e5e5 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -360,6 +360,7 @@ struct tls_conn_test {
 	const char *client_expect_identity;
 	const char **client_cipher_suites;
 	char **client_domain_mask;
+	const char *client_pinned_cert_path;
 	bool expect_alert;
 	bool expect_client_start_fail;
 	enum l_tls_alert_desc alert_desc;
@@ -660,6 +661,25 @@ static void test_tls_with_ver(const struct tls_conn_test *test,
 	if (test->client_domain_mask)
 		l_tls_set_domain_mask(s[1].tls, test->client_domain_mask);
 
+	if (test->client_pinned_cert_path) {
+		struct l_cert *cert =
+			load_cert_file(test->client_pinned_cert_path);
+		struct l_checksum *sha256 = l_checksum_new(L_CHECKSUM_SHA256);
+		const uint8_t *der;
+		size_t der_len;
+		uint8_t hash[32];
+
+		assert(cert && sha256);
+		der = l_cert_get_der_data(cert, &der_len);
+		assert(l_checksum_update(sha256, der, der_len));
+		assert(l_checksum_get_digest(sha256, hash, 32) == 32);
+		l_checksum_free(sha256);
+		l_cert_free(cert);
+
+		assert(!l_tls_set_server_cert_hash(s[0].tls, hash));
+		assert(l_tls_set_server_cert_hash(s[1].tls, hash));
+	}
+
 	assert(l_tls_start(s[0].tls));
 	assert(!!l_tls_start(s[1].tls) == !test->expect_client_start_fail);
 
@@ -722,6 +742,48 @@ static void test_tls_version_mismatch_test(const void *data)
 				L_TLS_V10, L_TLS_V11);
 }
 
+static const struct tls_conn_test tls_conn_test_pin_match = {
+	.server_cert_path = CERTDIR "cert-server.pem",
+	.server_key_path = CERTDIR "cert-server-key-pkcs8.pem",
+	.client_expect_identity = "/O=Foo Example Organization"
+		"/CN=Foo Example Organization/emailAddress=foo@mail.example",
+	.client_pinned_cert_path = CERTDIR "cert-server.pem",
+};
+
+static const struct tls_conn_test tls_conn_test_pin_mismatch = {
+	.server_cert_path = CERTDIR "cert-server.pem",
+	.server_key_path = CERTDIR "cert-server-key-pkcs8.pem",
+	.client_pinned_cert_path = CERTDIR "cert-client.pem",
+	.expect_alert = true,
+	.alert_desc = TLS_ALERT_BAD_CERT,
+};
+
+static const struct tls_conn_test tls_conn_test_pin_match_ca_match = {
+	.server_cert_path = CERTDIR "cert-server.pem",
+	.server_key_path = CERTDIR "cert-server-key-pkcs8.pem",
+	.client_ca_cert_path = CERTDIR "cert-ca.pem",
+	.client_expect_identity = "/O=Foo Example Organization"
+		"/CN=Foo Example Organization/emailAddress=foo@mail.example",
+	.client_pinned_cert_path = CERTDIR "cert-server.pem",
+};
+
+static const struct tls_conn_test tls_conn_test_pin_match_ca_mismatch = {
+	.server_cert_path = CERTDIR "cert-server.pem",
+	.server_key_path = CERTDIR "cert-server-key-pkcs8.pem",
+	.client_ca_cert_path = CERTDIR "cert-intca.pem",
+	.client_pinned_cert_path = CERTDIR "cert-server.pem",
+	.expect_alert = true,
+	.alert_desc = TLS_ALERT_BAD_CERT,
+};
+
+static const struct tls_conn_test tls_conn_test_pin_expired = {
+	.server_cert_path = CERTDIR "cert-expired.pem",
+	.server_key_path = CERTDIR "cert-client-key-pkcs8.pem",
+	.client_pinned_cert_path = CERTDIR "cert-expired.pem",
+	.expect_alert = true,
+	.alert_desc = TLS_ALERT_CERT_EXPIRED,
+};
+
 static const struct tls_conn_test tls_conn_test_domain_match1 = {
 	.server_cert_path = CERTDIR "cert-client.pem",
 	.server_key_path = CERTDIR "cert-client-key-pkcs8.pem",
@@ -1021,6 +1083,22 @@ int main(int argc, char *argv[])
 			test_tls_version_mismatch_test,
 			L_TEST_FLAG_ALLOW_FAILURE);
 
+	l_test_add_data_func("TLS connection pinned cert match",
+			&tls_conn_test_pin_match, test_tls_test,
+			L_TEST_FLAG_ALLOW_FAILURE);
+	l_test_add_data_func("TLS connection pinned cert mismatch",
+			&tls_conn_test_pin_mismatch, test_tls_test,
+			L_TEST_FLAG_ALLOW_FAILURE);
+	l_test_add_data_func("TLS connection pinned cert match CA match",
+			&tls_conn_test_pin_match_ca_match, test_tls_test,
+			L_TEST_FLAG_ALLOW_FAILURE);
+	l_test_add_data_func("TLS connection pinned cert match CA mismatch",
+			&tls_conn_test_pin_match_ca_mismatch, test_tls_test,
+			L_TEST_FLAG_ALLOW_FAILURE);
+	l_test_add_data_func("TLS connection pinned cert expired",
+			&tls_conn_test_pin_expired, test_tls_test,
+			L_TEST_FLAG_ALLOW_FAILURE);
+
 	l_test_add_data_func("TLS connection domain match 1",
 			&tls_conn_test_domain_match1, test_tls_test,
 			L_TEST_FLAG_ALLOW_FAILURE);
-- 
2.53.0

