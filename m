Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=52.101.84.133
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795518570;
	b=RrrLW9J0pcFSmLTg3I3Uy5I66/F86MV7H4Br4mO9L4TqHHFSACk9dXZOZNTUCi7R1FFl
	 vU6BoKbuyAHW/cB0U2vtqhxeeoF5un7QJ7QLR8n5VibXbqmQ6LGrmUBedMSU1R0NJGuDS
	 1usNXgnET4zK/Q/ef46+lYyAUsX8zMNjxpJ8uh/pLFBVPzNu3IajSAPR5LK4EJesgOQTE
	 WcMKuxmQ5X0h0h/b+terRCsrBX+8wISO0Ai3bBnOOEpbTu3s4f4VHiaw1YesNTHzqFGYB
	 Q53VmSSd0T1wD6AJt1SwKpAJ/Qr0bxaoDZuBZWXBykIyRpm0Np6U1TqE13C5BnW6IPA==
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
	bh=RDr2lPrmaaV+p7lsCsCIVdhSWO6YVox6sdTmtLKkvY0=;
	b=dftwvNW8Czm/e2dBeZ5teHbRcx+LjiuQN7mHN58Lp+UGTudv6V6fYD+yntpVlLoaBmDP
	 +E8h16ZXX3veR08P9QonCy9XAGdybGZPGDGGT3lpH2LQQ2mm1H5UajyQc+AVWwJkk31qO
	 sMLTPwssfI2jCcXJ5tuI321zxhNFT2ESoPfFCxG4y8zyERUl2+3xyZQGwnJDzErfPf2z7
	 vq0+OnkUjNpeKmnt3BbNxwOo+JmNjxrYATRX4bqjQnGCMKmDQRADnVgvJiCPzhE2zs8Ha
	 iUYm0lpt66lKHNqll+xUc5tlMeNZmcLfYM4AtUYtreek5AE+e5iB7WCiwrvAD6ytVyg==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=kuleuven.be;
	spf=pass smtp.mailfrom=kuleuven.be;
	dkim=pass header.d=kuleuven.be header.i=@kuleuven.be header.a=rsa-sha256 header.s=selector1 header.b="ZtKCEs/g";
	arc=pass header.oldest-pass=0 smtp.remote-ip=52.101.84.133
Received: from DB3PR0202CU003.outbound.protection.outlook.com (mail-northeuropeazon11020133.outbound.protection.outlook.com [52.101.84.133])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (secp384r1) server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 57A20606A327
	for <ell@lists.linux.dev>; Tue, 24 Nov 2026 11:09:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 57A20606A327
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=kuleuven.be
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=kuleuven.be
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=kuleuven.be header.i=@kuleuven.be header.a=rsa-sha256 header.s=selector1 header.b=ZtKCEs/g
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=X5/DkUDHjc6dzhj2hYJUHiKJ/XX7rTylzAqNKiektA+5CRGJ0hkstmATterQlstLy1Ntc2TCmWD5B1Kxfuw84hDdHAAP5cf/3aeuU7xDVJ8OISpBb8ZmqNryKXqjZ7d8WN5E5snIX1Zt2kYRQVxGliE+H8IL7clQ/pfCjgU1a05wYIG5Ikhc91LTVd9OayBT02r5SchttO0hNvnlrNE6s4PdXvHLk9ZtCjCD/vk2M5zplz7lxRYVLKz4YX8N4dUQsJKaRozz3xLWOk/WQ+zqgBFKDyMx/An9lQgfc6KT7Oh8RFJPiYkHIcktk6/r1sD1PlO6hFm2qcDsRS38kiyfsg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=RDr2lPrmaaV+p7lsCsCIVdhSWO6YVox6sdTmtLKkvY0=;
 b=xepuRWTyKkQXsoP3yQtPeXlXTi+Zu7NeBO75llA123xHwZsshcajvQBZ8XfW9m+JfyfZ+PDdoZEFFmlwxQSai1LUNFPyEIZIIW5yYrrcpqUH/ouyWH9IMkaQCafLRaaLrgTmn2gKrMgRcplU0JAUUOHtHq6foxQ1d/B1kkerAP6GaR8g86rAZ6SLISs1b+0/NCW8G6pEenRT+BAlhQ13zWh9iFlCDstGspog37VD1n56JtYBf78mfrdUgvQX+rhec44fhGI33NwcC4jxHGgyi67DwSQX82Orx8obUNsHnTgikeXmruJkhF54nCR68Kg1ju4KDd+MOy8CaeHVS/xemQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=kuleuven.be; dmarc=pass action=none header.from=kuleuven.be;
 dkim=pass header.d=kuleuven.be; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kuleuven.be;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=RDr2lPrmaaV+p7lsCsCIVdhSWO6YVox6sdTmtLKkvY0=;
 b=ZtKCEs/gvC2+FbcFIEmKP6Zce1rRkB1SWM9vipzdeC3BbEFtwrwaa8iphYO7+PmbysFeLLBS29edvpg7dwrGBRWtjmkgh+IlDmUeneN++owwG7rHDtBW3T+k+raydeMpgvRjkP5xM6VAJDgwrAoaTaEG1HUjwf5Vl2JwqDNNtbE=
Authentication-Results: mx.microsoft.com 1; dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=kuleuven.be;
Received: from MI9PR08MB763857.eurprd08.prod.outlook.com
 (2603:10a6:290:c0::16) by DB9PR08MB7698.eurprd08.prod.outlook.com
 (2603:10a6:10:391::17) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.639.14; Tue, 24 Nov
 2026 11:09:25 +0000
Received: from MI9PR08MB763857.eurprd08.prod.outlook.com
 ([fe80::4f1d:a35e:c1b6:8b48]) by MI9PR08MB763857.eurprd08.prod.outlook.com
 ([fe80::4f1d:a35e:c1b6:8b48%7]) with mapi id 15.21.0639.012; Tue, 24 Nov 2026
 11:09:25 +0000
From: Mathy Vanhoef <Mathy.Vanhoef@kuleuven.be>
To: ell@lists.linux.dev
Cc: denkenz@gmail.com,
	marcel@holtmann.org,
	Mathy Vanhoef <Mathy.Vanhoef@kuleuven.be>
Subject: [PATCH 5/7] tls: Add callback for the peer certificate chain
Date: Tue, 24 Nov 2026 12:08:45 +0100
Message-ID: <20261124110847.1254540-6-Mathy.Vanhoef@kuleuven.be>
X-Mailer: git-send-email 2.56.1
In-Reply-To: <20261124110847.1254540-1-Mathy.Vanhoef@kuleuven.be>
References: <20261124110847.1254540-1-Mathy.Vanhoef@kuleuven.be>
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-ClientProxiedBy: AS4P190CA0053.EURP190.PROD.OUTLOOK.COM
 (2603:10a6:20b:656::17) To MI9PR08MB763857.eurprd08.prod.outlook.com
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
X-MS-Office365-Filtering-Correlation-Id: 44ea7b1e-8156-4e4d-0c7e-08df4a1b662a
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|376014|1800799024|10070799003|786006|366016|23010399003|10067099003|11063799006|56012099006|261102123227099003|261022105027099003|261028144727099003|261026121527099003|261022075727099003|261021121427099003|261026140227099003|261102130727099003|261009223027099003|22082099003|6133799003|18002099003;
X-Microsoft-Antispam-Message-Info:
	AGnotIxm7TN5N9pnEhBbFHskDRVyCUskpikdEWJwpxazteD+ADpsLT2HwoIfErvzqof9quQ6iSBH86AjWneDXyxBJgw8IEap41xXsgD4hyxxB8wDkj4wstTUEd5vnNMMINmQsdpx9VQR9ajzuhQINFJS54uidwjVmbeAK9thLOcxWKKAlacsN+OKiHFFGkm2OWb+AX3TGJ5z0EJPLgP/gFmUKELVLdtHaso6tS0860oDV7G8t0aX3PaXDKBFB+2FzERnl03EBzPVEvyHchuI6Aq5VWcIZxfCx3qvfHMZ4r1T9KU3JGMGgxLj6MnMZAtWxvHPVtEQdSht5KEySzZ/LoPR0bYnfZdtmxUmLQ2UF4neVzoPvdvPxGpFGzzPnrvsYZibxmOFz7pkJoVWtRYOFTmIFO2679R27ZHXoWCIlm6kZh+/yCeJnnvF98I0rqgIKmGV31EGkQ1bkRx0xulXz47VU+neDlC35HRq2QdRHNgsIm5fSh9owbcR5A0bW0mPdvSGxpYs1A1bPSlYob19AXvF+Q86dShq/xrTHta4WjAVqBpaAzl8mqZmpTGUEuFX2KCgcGGyk81w5aSHN/lS9KYOJ3ONbYvtVq9Ym4MMqAI7RgUY3mRislAAHnpIZ2NzVEjIvW4mPmsPXKTLsrfJD8sBTknDunGqFa4Qtp2udOA=
X-Forefront-Antispam-Report:
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:MI9PR08MB763857.eurprd08.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(376014)(1800799024)(10070799003)(786006)(366016)(23010399003)(10067099003)(11063799006)(56012099006)(261102123227099003)(261022105027099003)(261028144727099003)(261026121527099003)(261022075727099003)(261021121427099003)(261026140227099003)(261102130727099003)(261009223027099003)(22082099003)(6133799003)(18002099003);DIR:OUT;SFP:1102;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?us-ascii?Q?daQt/GhKtnFI0BjM8iuCX18f/ehxkNnzDYQAxO/avLQJhCIP7urlvASGJ+iw?=
 =?us-ascii?Q?1xE/W8oQTGnJBmYKDt1QckmU7AkQkhLiTFopbfjMSQPtnnShaPSWSCcYhsHA?=
 =?us-ascii?Q?WSZbsvWh4DasmPrDsZt3JNQMgkHJUusVCjeU9N3AGtdQEylSzoH9ITuVF18r?=
 =?us-ascii?Q?tUaUbcDSDINEbUpRBCZvjlO4TFyu+9SQVekZW6Qjm10k6HblIJHuDXv3HR06?=
 =?us-ascii?Q?T3qkHD4miT+WHPAC7SF+ts2u7ZVGksuFcTSNGbSBLrLGp/uLEHQSa0xmMBIW?=
 =?us-ascii?Q?qIWGSF6145sWBxhxlEBKHxk6BStRkCrsnqRPT5sQ8ozSjvVnIHHQOVbsddsm?=
 =?us-ascii?Q?gDUyvqk2TmKkMjtlzpT1+HCN+iOvzj1KbDqJA8gxuYkz++tnNVh/FzmiPc9e?=
 =?us-ascii?Q?Ot93TGcaX1HYXNI9CvQsDA9uNbe2s1daBDA3a2f7xGfi3MJq3l0KK57CgGc7?=
 =?us-ascii?Q?e1M+YKRXWga5ekrTVln7YcPqL4/7wTAP/PpvZ6lHKDaDn6r3aH6t70cl+H+3?=
 =?us-ascii?Q?QnVoFXCcDKGmdWTPqoA9zpnyXYtcRAB8YBbFRqFQ3ZVwDxxz2CO9cxw6cXF/?=
 =?us-ascii?Q?7VhHLkVEFjxE+DxU9D8Esuwbrr6izXn1799pblqgHLwyn3V3awlao1MvvS3n?=
 =?us-ascii?Q?++NLnVysK2RUdwE25u4CiKAhy+MQ7d8P+oRBV1RNBWrjvAt339O+mNU7VBQC?=
 =?us-ascii?Q?TgsbvcbbLFk7Ey6NdoejQOEDHgTDP07GbCJBgM9shpu4xIJDegD9/r4kSbpZ?=
 =?us-ascii?Q?mMiWDuGSGo+PKEuQgGXbFPc5fCKQ1bb+LrlFf0MT98gwtXeUr777Rv3pUksd?=
 =?us-ascii?Q?mGRQ1YljGAOPxNtQ7ABQHZfPTGypdmosaF8csNLM8vkLNtyJgRUShtDJDAjc?=
 =?us-ascii?Q?kq552iiyEEnzlPUSxSKWeC2ZCzvS8KMZD5e004PFWRFKA3dxj7hi80rO3UQb?=
 =?us-ascii?Q?MDPN4yIMgH6qxrW9rGccTwveK94RQPIrayx5Dq2qxBXtFY+JgWWiveV6PKwW?=
 =?us-ascii?Q?SYcmEJuMeiQ0mnKMNpXntxlUYjvW4ktwpx54UVCw1qs5DZ+kTUZc6zEG4DMY?=
 =?us-ascii?Q?WnGEiFI9EORkxHinXfMWsVPKIRlE7RHBFA3ksn4iyYBkGfK7owhJDAHnVfbE?=
 =?us-ascii?Q?2F9pU2iMeaz66/60UDM5nZapkOQK+YISn8TNcRS4vOFfYr8529gJ93kG9rdP?=
 =?us-ascii?Q?ZQpP1Ggb/TIqgE5cRsnGvLfl5T3kKBkcTVVsI17xjWpzlc+HdrrL0ihjUd5t?=
 =?us-ascii?Q?831nylmHxZWQ9ZUjnUG0XXAL8Bbb+8Kvdf2fEy01tHtjkKxkHRjdLe/uD4rI?=
 =?us-ascii?Q?oxhcqKkqFvZh54F+Tp6buNgk5WfAzLbTQ7zhfFfOsFLu5SEjG5VnkYfNetdL?=
 =?us-ascii?Q?RSWD9OkZit8iUvmHLdcESPZd6sYNDB5z+SFz2hhSwdaOiAY23Es1XXRgC1H3?=
 =?us-ascii?Q?fv/xeMVHRKu3Z5jX6znQt3253udDSHu9YAPpgu8VA0NPPCKMY81WlL1C5AGc?=
 =?us-ascii?Q?/dG9E2iko+ObpP8Wn8lfAdMPy7EMFM/jK9Oo32J7SEKOu2BuaLlIwnIW9rz+?=
 =?us-ascii?Q?V2BoIlx79uZadI9lPpMFqvo1+aBiC+1/6640r8TWYtVvo4DdK8HHITBaw8a+?=
 =?us-ascii?Q?Z+pD92BdRrljn2yuCr8PMiESmh4DWrhzyVaEdYbUGI5Rh/LXXzc4+nQtZj+s?=
 =?us-ascii?Q?NpUg5iQ4AIVDqsIEf3mTc2gSpp/MgzdA4BijzR7NrCqsKH+fqXSKlXGGXLVw?=
 =?us-ascii?Q?9AYBrAdgvoryQqMA9GlRDBDmm2ZFKMUpfPFS39QzetidHDQZ+lMw?=
X-OriginatorOrg: kuleuven.be
X-MS-Exchange-CrossTenant-Network-Message-Id: 44ea7b1e-8156-4e4d-0c7e-08df4a1b662a
X-MS-Exchange-CrossTenant-AuthSource: MI9PR08MB763857.eurprd08.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 24 Nov 2026 11:09:24.9452
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 3973589b-9e40-4eb5-800e-b0b6383d1621
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: FCIqU7mXtCe+V+WTAbuJGiB4HNs2GZMUxSe+7+94DfLG/pgnjPlQEfFYnOd4dy4XlCXv4rCink6BIYoiYpTS1ntrxZBvjm8c7An+8MMhvwQ=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DB9PR08MB7698

Add l_tls_set_peer_certchain_cb() to get notified of the certificate
chain received from the peer, as soon as it has been parsed and before
it is verified.  The callback is therefore also called when the
verification then fails.

This allows a client to show the server's certificate to the user, and
to pin it on first use, when the certificate cannot be verified yet.

Co-authored-by: Rathan Appana <rathan.appana@kuleuven.be>
---
 ell/ell.sym       |  1 +
 ell/tls-private.h |  2 ++
 ell/tls.c         | 28 ++++++++++++++++++++++++++++
 ell/tls.h         |  5 +++++
 4 files changed, 36 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index ee876ac..026258f 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -557,6 +557,7 @@ global:
 	l_tls_alert_to_str;
 	l_tls_set_debug;
 	l_tls_set_cert_dump_path;
+	l_tls_set_peer_certchain_cb;
 	/* uintset */
 	l_uintset_new_from_range;
 	l_uintset_new;
diff --git a/ell/tls-private.h b/ell/tls-private.h
index 7581567..cc31ad7 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -192,6 +192,8 @@ struct l_tls {
 	l_tls_destroy_cb_t debug_destroy;
 	void *debug_data;
 	char *cert_dump_path;
+	l_tls_peer_certchain_cb_t peer_certchain_cb;
+	void *peer_certchain_data;
 	enum l_tls_version min_version;
 	enum l_tls_version max_version;
 
diff --git a/ell/tls.c b/ell/tls.c
index ccdc4cb..43cbecc 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -2563,6 +2563,9 @@ static void tls_handle_certificate(struct l_tls *tls,
 		return;
 	}
 
+	if (tls->peer_certchain_cb)
+		tls->peer_certchain_cb(certchain, tls->peer_certchain_data);
+
 	if (tls->cert_dump_path) {
 		int r = pem_write_certificate_chain(certchain,
 							tls->cert_dump_path);
@@ -3945,6 +3948,31 @@ LIB_EXPORT bool l_tls_set_debug(struct l_tls *tls, l_tls_debug_cb_t function,
 	return true;
 }
 
+/**
+ * l_tls_set_peer_certchain_cb:
+ * @tls: TLS object being configured
+ * @function: called with the peer's certificate chain, or NULL to unset
+ * @user_data: user data passed to @function
+ *
+ * Get notified of every certificate chain received from the peer, as
+ * soon as it has been parsed and before it is verified, so it is also
+ * reported when verification then fails.  The chain is only valid for
+ * the duration of the call.
+ *
+ * Returns: true on success, false on invalid @tls.
+ */
+LIB_EXPORT bool l_tls_set_peer_certchain_cb(struct l_tls *tls,
+					l_tls_peer_certchain_cb_t function,
+					void *user_data)
+{
+	if (unlikely(!tls))
+		return false;
+
+	tls->peer_certchain_cb = function;
+	tls->peer_certchain_data = user_data;
+	return true;
+}
+
 LIB_EXPORT bool l_tls_set_cert_dump_path(struct l_tls *tls, const char *path)
 {
 	l_free(tls->cert_dump_path);
diff --git a/ell/tls.h b/ell/tls.h
index d59b5e0..ed48b4f 100644
--- a/ell/tls.h
+++ b/ell/tls.h
@@ -61,6 +61,8 @@ typedef void (*l_tls_disconnect_cb_t)(enum l_tls_alert_desc reason,
 typedef void (*l_tls_debug_cb_t)(const char *str, void *user_data);
 typedef void (*l_tls_destroy_cb_t)(void *user_data);
 typedef void (*l_tls_session_update_cb_t)(void *user_data);
+typedef void (*l_tls_peer_certchain_cb_t)(struct l_certchain *chain,
+						void *user_data);
 
 /*
  * app_data_handler gets called with newly received decrypted data.
@@ -135,6 +137,9 @@ bool l_tls_prf_get_bytes(struct l_tls *tls, bool use_master_secret,
 bool l_tls_set_debug(struct l_tls *tls, l_tls_debug_cb_t function,
 			void *user_data, l_tls_destroy_cb_t destroy);
 bool l_tls_set_cert_dump_path(struct l_tls *tls, const char *path);
+bool l_tls_set_peer_certchain_cb(struct l_tls *tls,
+					l_tls_peer_certchain_cb_t function,
+					void *user_data);
 
 #ifdef __cplusplus
 }
-- 
2.53.0

