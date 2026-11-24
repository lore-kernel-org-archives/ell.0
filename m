Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=52.101.84.133
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795518571;
	b=eXqa5CEXahABla+x6CONk7FageubgxlOt0/W2Xhl34KNmtPBbs4ZL5tsvpCtj7Jm96Du
	 K6soP6WKKI1losz2ONCPgSV5YsTji4J49uG4BCo5cngjIH0DqGlyfQBXrL2CfH/lz2Z5n
	 ABtGn3b+0C3Kp410e+Nwo7SJMkxf6NkfxlgjA8dsxkUvMZXdbQOpoiMFicmOdWLv5o2qE
	 xGTwotnUjSf57llCEzbv2+/hzV1mEVqB43vFQmlfwgC/Ogl6g0BBKfLwyiv9Mw6SMy6JR
	 pC4TQ6KHPQWZlafVe8/hwaqtB2HKL5feYzLJ4tOxZstbIrMKxIyEGfspzwU1EItKC3g==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795518571;
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
	bh=EClAKRhBVrCmwpA8EQexo/HMXTnuaUL+hqJtkjqQbpM=;
	b=zPJZOdUUhO0QxE+1LZsUkVL9234tlrRIeWXPKCHgw3gWz0gqg9wn9QkhIKqyr+mpLu/M
	 I9LqytHUwQEx1qeast0Sil27tP2chpkyNl/2o6fYMdyVjstk4X0YhngNWPK2lcURznmVS
	 AhrnFbF5hrM9u43eqc9Q/Klw6i2aap+7/4i5CsRxQYxoZzSxvxUYCoAmWEV+2OhsffaQd
	 VqGaBEE1hsuKNxvrNIkdwu4x97lpWxBo2Wkr2Yaiebj7l1rhGTR05GYRBcMeZ/pKJ6OXq
	 ZRMpxbxNJh3kiNjSmTR4AYjvgEEuQ6WCXfxg3Xq8SqfB1ysTLwxTXLON7AT4eIm8utw==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=kuleuven.be;
	spf=pass smtp.mailfrom=kuleuven.be;
	dkim=pass header.d=kuleuven.be header.i=@kuleuven.be header.a=rsa-sha256 header.s=selector1 header.b="njNo/vwA";
	arc=pass header.oldest-pass=0 smtp.remote-ip=52.101.84.133
Received: from DB3PR0202CU003.outbound.protection.outlook.com (mail-northeuropeazon11020133.outbound.protection.outlook.com [52.101.84.133])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (secp384r1) server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1B2F1606A327
	for <ell@lists.linux.dev>; Tue, 24 Nov 2026 11:09:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 1B2F1606A327
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=kuleuven.be
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=kuleuven.be
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=kuleuven.be header.i=@kuleuven.be header.a=rsa-sha256 header.s=selector1 header.b=njNo/vwA
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=zHENoieq83MUc6RmFs0IugdfZMrESIi9ymvpnL6E1x2YeNrqCV2bb1Fp578kdPYwqQC02oUk0ZGkyfDwLi27ESAEDAmuqVROwJ/Ar7z2tIAyeY31BdifK9a3v8fm0rCp212/bL5KzXS1B7Gag5S1CmsE30m1yED6jgwVf/+Zr7eeBuEIhGnTog55wdTsneLkQI6eni2Upl+AMFT1tovgiLOEnR0bZyCUMHyN3CgmZVG/hZ5HxGYsIx77vvChq29TuBdvvTBAMFROYMdII1VksZPXBA0Celr/XO6sSQPWvUJdipeUAPjuxYwKDIFn1xGjdgtqQPyria8oYZ/U1RYN0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=EClAKRhBVrCmwpA8EQexo/HMXTnuaUL+hqJtkjqQbpM=;
 b=m4N3eJekL4l0GntqkOiF7yG/ZkC9SNUOffU4xfAPUC2X/AE7ikWyCk717UANBFlvS1vYTZd4OXrHLlRqydcv590knGzHEBa3Sz6MMA8Keb2L1eS0O+xOflgaNIFS6mEcNYTzgDBrcljANXlGS/0hWxWNd/I9xf1uCe9L93VMIx4wTdiEYAkcBjg7R6pZZlRRrXL4/1/HO6XX7nYRIQj++F+ugLzqua+ZxbUtTiBtO1ELT4orQOThBZ19oUCza/Wj87sQ8ak5JfsiwkUFomCEJ5rA+kYVrBAvCeK/VQfvSXKYf6nC9FuiAW62NUktS4wx+HCva7YYEgE4r+G8PvBGHw==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=kuleuven.be; dmarc=pass action=none header.from=kuleuven.be;
 dkim=pass header.d=kuleuven.be; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kuleuven.be;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=EClAKRhBVrCmwpA8EQexo/HMXTnuaUL+hqJtkjqQbpM=;
 b=njNo/vwAeoQDPG6Loip+hEvTn3qNPKjXvzis1tbiQNah1TxGATGnY/qP8uo21mSjP9wqCpMx3H8NkJUUMYP0CKLSJhxa4g9kWLFHAwaP4JJ62I9kj1q96JmnnIICPFejxAcmSyBAY2x1ZfzfBAnY4tiAPNru4hFErbQI2AnnNuM=
Authentication-Results: mx.microsoft.com 1; dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=kuleuven.be;
Received: from MI9PR08MB763857.eurprd08.prod.outlook.com
 (2603:10a6:290:c0::16) by DB9PR08MB7698.eurprd08.prod.outlook.com
 (2603:10a6:10:391::17) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.639.14; Tue, 24 Nov
 2026 11:09:28 +0000
Received: from MI9PR08MB763857.eurprd08.prod.outlook.com
 ([fe80::4f1d:a35e:c1b6:8b48]) by MI9PR08MB763857.eurprd08.prod.outlook.com
 ([fe80::4f1d:a35e:c1b6:8b48%7]) with mapi id 15.21.0639.012; Tue, 24 Nov 2026
 11:09:28 +0000
From: Mathy Vanhoef <Mathy.Vanhoef@kuleuven.be>
To: ell@lists.linux.dev
Cc: denkenz@gmail.com,
	marcel@holtmann.org,
	Mathy Vanhoef <Mathy.Vanhoef@kuleuven.be>
Subject: [PATCH 7/7] unit: Test the TLS peer certificate chain callback
Date: Tue, 24 Nov 2026 12:08:47 +0100
Message-ID: <20261124110847.1254540-8-Mathy.Vanhoef@kuleuven.be>
X-Mailer: git-send-email 2.56.1
In-Reply-To: <20261124110847.1254540-1-Mathy.Vanhoef@kuleuven.be>
References: <20261124110847.1254540-1-Mathy.Vanhoef@kuleuven.be>
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-ClientProxiedBy: AS4P191CA0050.EURP191.PROD.OUTLOOK.COM
 (2603:10a6:20b:657::26) To MI9PR08MB763857.eurprd08.prod.outlook.com
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
X-MS-Office365-Filtering-Correlation-Id: c30f3a00-dcaf-4e1b-eec0-08df4a1b67e0
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|376014|1800799024|10070799003|786006|366016|23010399003|10067099003|11063799006|56012099006|261102123227099003|261022105027099003|261028144727099003|261026121527099003|261021121427099003|261026140227099003|261009223027099003|22082099003|18002099003;
X-Microsoft-Antispam-Message-Info:
	YCsETyYHRpECnvaE6VYSWhkPJwxQgyh2HjeTRJrycxG3j1EK7Pfh/MI1YsCUCcvg6URfz5hvndVPOk3kVTo7eaft51YUp4/6I6T+xSqKwJkAC/SEbgMn+ydSKUh8wgaMwfXfCWjKj5s/Oo7x2xL/VdeuoJHTJhpV0hnk2vmKqDZPegKFjXYP7lvYAasDVThVWnF+CGAMpkBvUj7ZeCMjZaVVtmnqFwfrgcrZFlXaCkMSGYIr2piscErm/egoBa4mUC+rBHOd/k3/jiQbLifjsvhoUB8LC2kOBWZ4EhIT3C6cPhvBQZV6toP1tZzejw53wGhj/oKr5DHFCRUPyCrIrfmuAgVD/t08om+M2Ij9FgW3dWDYZ26m92woOdKYiteSG5ZACqTXWH+TZEHH2WYORL0F/YgzFDmPOnbS3gJc5ilpDd7nQRQfZjhi6PKuwNPoBoQ7ygkKUtnRgctTWCOqE4n8IjrozSXX5lfX0dkr3OrFhtMxCGsGQ2hDm45rFrf3vUQtNvv8Xt7ynx/Lt88GITnD1EJ872z/AS9u8yZvJV/Ih+IHglu3WJ5Hp/1sfrXT9YSLPj1dZ20f5MJivHYBoFi6Jg7sEAVPmUmdvn8FlTQO24uyj82bXs2z9d1+LLHqMHWxqYyNtCFXOwsVFPhTvhhgd6HObV2IGBXb6XYDGKM=
X-Forefront-Antispam-Report:
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:MI9PR08MB763857.eurprd08.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(376014)(1800799024)(10070799003)(786006)(366016)(23010399003)(10067099003)(11063799006)(56012099006)(261102123227099003)(261022105027099003)(261028144727099003)(261026121527099003)(261021121427099003)(261026140227099003)(261009223027099003)(22082099003)(18002099003);DIR:OUT;SFP:1102;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?us-ascii?Q?ZOOe2SH71o+U0FSDd0H5jxFbP5QeFYLXHARaAli1jT0S/xdwq/q0DPLDCX3i?=
 =?us-ascii?Q?GTwNb+vb19wtNHiROe/tpWIqTh5SxRMBdrXQRSa/lIwjBLEXPJMiUuod/t99?=
 =?us-ascii?Q?YO22o0TtI+gdrTCsk6cWReLQDqlt/zD8oswHD357wmdwyT+63IFdoCpUR/3+?=
 =?us-ascii?Q?auHgslulJQ9E8c6axLtyQjxiYdeYjqpEcgglRHaAsxrn8nXIgG0yOs3GyEoT?=
 =?us-ascii?Q?bHlDqENkF+yZCV5kAv1G0/BI8DgziVOuyizEHmRDeg4O5EK/XJvHCdfYrQa3?=
 =?us-ascii?Q?xDuSKjvbgUWKHWs10jmSU+WU0JvxvvZX8d6f6m3iXeZZ2gV8VGlYbcy9yn4K?=
 =?us-ascii?Q?HHcBTaeHXen3cQrbrUEed67rtXpMwbVPwnm5IRgsug0u8ZirV8Sl4JAYLEo6?=
 =?us-ascii?Q?TTgb+zs5a4Ik41lRAmuRSEgGeuNzHuINDPntFlJrVb4uUoo2Y5XDTLgoidP0?=
 =?us-ascii?Q?zpZ2sJCVOyhoCZsm2wg0M/tsIKOFhmQzVqP5TCOhqfvmfUgXxeS1716APO95?=
 =?us-ascii?Q?wnd3htY+DU5itkz4ZEmKpqSH2/IEZQVXuVgsNHQCyqEE4D+z9L+w0G5zGsFg?=
 =?us-ascii?Q?Pv4WRHrIl6Unobc9xyj+tm3236RBACbzc+pU6GmXIg+3IxWlQYfidPjFKVsT?=
 =?us-ascii?Q?y0rKEySECkYFqEyzz085SxfaEBiOktmb7MwK1d90pRvZNuECc+IBbYbynNuX?=
 =?us-ascii?Q?vY/+FZOoZ0msUWHAoP28pI6wf3yYjm6nkEtgEaLqr0m2tGee6euXjm+DLWvK?=
 =?us-ascii?Q?rsSxkHHqkIyXqkjTqGriIivw0oiIY5PI+ei207AJI3Szn4DDKNcUGrVI8/9W?=
 =?us-ascii?Q?GTFN3/lMfWDgKsZKf4kQsWiDxPwaLDofF1ruljwbNGM5H8vPz9vBrx/Y8y7U?=
 =?us-ascii?Q?ZdMhNs2nx0SgYL/eEkiD+RdtuyNN2nHHzc94Jqy8MzhsxiIEhtwmlgLU7KgI?=
 =?us-ascii?Q?xb2OPAeBSvdkAua4YXXPBN6RXUBJQpce4cLB3ExZh6l6HeNqqMNwB0MlrUSu?=
 =?us-ascii?Q?WczokiqKPAc0R2V2VZAgqU4POTOJc7B0U5x/q8u/b5b7ZX/XqjDd8CKnE+C6?=
 =?us-ascii?Q?zBICiAPhN8+2GQITyY8BFeNTaXnysImtSYVJgS990pr5/cmmJJhwgg8JlhrB?=
 =?us-ascii?Q?+9bOwnouZsP0asAyyGbPzrNlbBznXNNn0/x5sZTShbuUaoT0xPIKCflqIWiB?=
 =?us-ascii?Q?pdQn2b4y3G462YXn9nN2REGquFk/xtsUbVW1v3stOXTbVUc0SUC68tuNXUUb?=
 =?us-ascii?Q?DDlY5tuJGf7Q1P00z4wnchUXqBipIbfNXxPqKEaBnFBQl6wCm0Ux0tfU5e3K?=
 =?us-ascii?Q?JL7pGKnTGpQ/JNmlP+y6rQ+hRVt2XKV6prIIg8tnfan3vYQViQOBEz/0Zb77?=
 =?us-ascii?Q?R9DSyPoqhPsNCAT7MQMTBDIl6vBCAf/1cmXVsFF+6U4aQSIuXIzdmvsvUCeC?=
 =?us-ascii?Q?1CtCLlnrBigBlqwQdNcItLqAuitLDOvGsOI5jxQ+P9hFEiGu7BY1Oy0vRoHY?=
 =?us-ascii?Q?G68ExJqo7U8W71dxydPu2e8rltNe4TWPZlNFIIriI8vUCxxkth3T+u9GC3jB?=
 =?us-ascii?Q?8j9OPPPqhW1gV+hUUUtnfx2EFeYeZbXzPydMPWya0vXPNrz4uxzQWePBwjjR?=
 =?us-ascii?Q?u9GTksc1vJ2c64cWdJc2pddCGOoqAkCbmOqOwnPdkl4wd0M5uCQitLnqT0Kq?=
 =?us-ascii?Q?3Ve9FlsAGqOhZvYV5OLw43bMvxF1i1B5jlbC7ZBlC85fe2VCOLq0VHCBfVTa?=
 =?us-ascii?Q?KiKL5kUuaijgjO6RGyM1heWrA+4zHmzoSaqL9JOIgwuul3QE1EBk?=
X-OriginatorOrg: kuleuven.be
X-MS-Exchange-CrossTenant-Network-Message-Id: c30f3a00-dcaf-4e1b-eec0-08df4a1b67e0
X-MS-Exchange-CrossTenant-AuthSource: MI9PR08MB763857.eurprd08.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 24 Nov 2026 11:09:27.8321
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 3973589b-9e40-4eb5-800e-b0b6383d1621
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: U1CVXJLRftmrdi3Xi+Glchbac42xzOzERLBRPLuWasx2tpyLWOk1BloxK90BmJHL7qlWoSFRKFp6usKfleBJ0MnGjIdHmvxCbrD4e2UsbXM=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DB9PR08MB7698

Check that the peer certificate chain callback is called both when the
handshake succeeds and when it then fails because the server certificate
does not match the pinned one.

Co-authored-by: Rathan Appana <rathan.appana@kuleuven.be>
---
 unit/test-tls.c | 27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

diff --git a/unit/test-tls.c b/unit/test-tls.c
index e6b083c..fc4745e 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -358,6 +358,7 @@ struct tls_conn_test {
 	const char *client_key_passphrase;
 	const char *client_ca_cert_path;
 	const char *client_expect_identity;
+	const char *client_expect_certchain_subject;
 	const char **client_cipher_suites;
 	char **client_domain_mask;
 	const char *client_pinned_cert_path;
@@ -492,8 +493,22 @@ struct tls_test_state {
 
 	bool expect_alert;
 	enum l_tls_alert_desc alert_desc;
+
+	const char *expect_certchain_subject;
+	bool certchain_seen;
 };
 
+static void tls_test_peer_certchain(struct l_certchain *chain,
+					void *user_data)
+{
+	struct tls_test_state *s = user_data;
+	char *subject = l_cert_get_subject_str(l_certchain_get_leaf(chain));
+
+	assert(!strcmp(subject, s->expect_certchain_subject));
+	l_free(subject);
+	s->certchain_seen = true;
+}
+
 static void tls_test_new_data(const uint8_t *data, size_t len, void *user_data)
 {
 	struct tls_test_state *s = user_data;
@@ -614,6 +629,8 @@ static void test_tls_with_ver(const struct tls_conn_test *test,
 			.expect_peer = test->client_expect_identity,
 			.expect_alert = test->expect_alert,
 			.alert_desc = test->alert_desc,
+			.expect_certchain_subject =
+				test->client_expect_certchain_subject,
 		},
 	};
 
@@ -700,6 +717,11 @@ static void test_tls_with_ver(const struct tls_conn_test *test,
 	if (test->client_domain_mask)
 		l_tls_set_domain_mask(s[1].tls, test->client_domain_mask);
 
+	if (test->client_expect_certchain_subject)
+		assert(l_tls_set_peer_certchain_cb(s[1].tls,
+						tls_test_peer_certchain,
+						&s[1]));
+
 	if (test->client_pinned_cert_path) {
 		struct l_cert *cert =
 			load_cert_file(test->client_pinned_cert_path);
@@ -739,6 +761,7 @@ static void test_tls_with_ver(const struct tls_conn_test *test,
 	}
 
 	assert(s[0].success && s[1].success);
+	assert(s[1].certchain_seen == !!test->client_expect_certchain_subject);
 
 done:
 	l_tls_free(s[0].tls);
@@ -787,11 +810,15 @@ static const struct tls_conn_test tls_conn_test_pin_match = {
 	.client_expect_identity = "/O=Foo Example Organization"
 		"/CN=Foo Example Organization/emailAddress=foo@mail.example",
 	.client_pinned_cert_path = CERTDIR "cert-server.pem",
+	.client_expect_certchain_subject = "/O=Foo Example Organization"
+		"/CN=Foo Example Organization/emailAddress=foo@mail.example",
 };
 
 static const struct tls_conn_test tls_conn_test_pin_mismatch = {
 	.server_cert_path = CERTDIR "cert-server.pem",
 	.server_key_path = CERTDIR "cert-server-key-pkcs8.pem",
+	.client_expect_certchain_subject = "/O=Foo Example Organization"
+		"/CN=Foo Example Organization/emailAddress=foo@mail.example",
 	.client_pinned_cert_path = CERTDIR "cert-client.pem",
 	.expect_alert = true,
 	.alert_desc = TLS_ALERT_BAD_CERT,
-- 
2.53.0

