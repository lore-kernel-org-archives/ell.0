Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=52.101.69.112
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795518571;
	b=lcQzXXxVDmIPEugyosDU6lrjQ/SPuiiIgWhJCrjP/2HH3/CA4BZhkWZhlMzl/DAzQkUI
	 uribTj6dhDPnbdZQeHrxKmjuTmCdoVfRdF8Nc0o2rHM4+myjCnbivwnnmOMgaswB8iNB7
	 ZWP3gS7YyuGqwkFmOYviFXrSB+LeUOUBj93OSlEqBvGwbnmgHW16qY5KxLXSPi7pf33M6
	 9ksAjrWtrgdb/6yY47XIf6TVH5W/t54KUaRN3tqkfLNe1Cvzu6ngK/xc2sCVqfK5+deYi
	 fDCoFZeCelHhdUv5wPNWwbFvoo+egVgTZXnjTd1I/I42oK+IcOGkT4f7k7YD3CoDuZQ==
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
	bh=3jIv8XkkXvNubCnEo7oIkpIIhJe/ggMYrlEi85/a2rs=;
	b=2D/5JCGmwsYld+NC0+AgUj5aPagoIJ4FqXICeZDQwcGlQiKBS6IK0lRMy+dcVU2Qp56U
	 fTr9yOXbJWbUKKp4oP6w0v0TrwBGEXklfcL6vVWa1L5vJqzEon+CHlinkxbw25EZLakPm
	 vqocboTzybJ7f2IY6m7SE+13uZXp9CH/bD3hr/NIkzyCiNkdegQ3fhvaFIOpvIzOsyJ4k
	 Apz++FU/EspEtGaGrMF/ElB90844dJO7nzkNVGwzx+euVrULHzvyfG+6We1e1ECm5ckeV
	 UIDcSg9ZOUJqNDD3Hhgribuxz04ShQGQUxeMw2pQFSoZvO8HL/0WOB4F3AlKp9KW7vw==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=kuleuven.be;
	spf=pass smtp.mailfrom=kuleuven.be;
	dkim=pass header.d=kuleuven.be header.i=@kuleuven.be header.a=rsa-sha256 header.s=selector1 header.b=Lu54Uv6C;
	arc=pass header.oldest-pass=0 smtp.remote-ip=52.101.69.112
Received: from AM0PR83CU005.outbound.protection.outlook.com (mail-westeuropeazon11020112.outbound.protection.outlook.com [52.101.69.112])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (secp384r1) server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 44BCA606A321
	for <ell@lists.linux.dev>; Tue, 24 Nov 2026 11:09:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 44BCA606A321
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=kuleuven.be
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=kuleuven.be
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=kuleuven.be header.i=@kuleuven.be header.a=rsa-sha256 header.s=selector1 header.b=Lu54Uv6C
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=EcXqk+6RNAGXFyWqdI8j2Om8s1g3qNAdbS9NspDb3B6NawMVDlSode3YtDoZARAa8SS4xFvH9xHsE//8DlkHJFuE/fhGRa7ZI9qMYbUjUmuF5APNhDSTbHNCbp1vzfbJ47Q0L5MFLE6sCeWUzQoo+gGSn28WeKAbjJ5ICoyV9nHpftp12ednfLmwONBvP3/8dxBedeJ1OqIi8W4xKpOkt+U2XtOZ5I8RAbp2hqJphpbqQ/dv+NsO/fowJw6FPzQlOFdo88NNzr1VVl05RsPnIG7L3owOcDVoLAZXe1MeAw1Lf+IVyxh6+G9dfK5ntgtNd8UdWCTtSvWVC2oDMZYi9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=3jIv8XkkXvNubCnEo7oIkpIIhJe/ggMYrlEi85/a2rs=;
 b=MRsnkei4zRcl1e152dIxlgpLtn04HaVw/oYuFSD3h68dOuos0kPFUVN88xZOMN9fx/1SEsUzZq7j7ZwOZ/6Wve4hJhTVQK3ibctNP8Ap2U8Z4wP0NKUXigCYRKWGK/5DjZetZy+iA4Fyd/EEb6sUhqgMUFZItGZeIFkJgX0Sl4UFuV7cG8pnmicjhth4x25O+RA39AShJncMs1slVOGI2QyObKW9CQwJWRRQi1b6tkRwVXblBoVSxMJ17PL322mLuZyOdCtoASJHcK4L5QsBeyNZhqmHTXSzBxxs6qnwblut5RhGlY5G64VsLRQ5Bz4ZNOz95bQYGZpTGJSAN5ClNg==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=kuleuven.be; dmarc=pass action=none header.from=kuleuven.be;
 dkim=pass header.d=kuleuven.be; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kuleuven.be;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=3jIv8XkkXvNubCnEo7oIkpIIhJe/ggMYrlEi85/a2rs=;
 b=Lu54Uv6CWSwPw5gd6ADaDcOfX09kbNW6bPKUXXTIRnXxjCnqErEJYhBc08+gO7gIqkOXxzH9lq+NHwa838lE1aDqkQZL+89c3d2uIfB2L+Owen414PaZ2ff4cKSIwwCDRthYflxKvDZYBWXhFp6KYdG7rvzKqRQ4OI/qRIhO+Go=
Authentication-Results: mx.microsoft.com 1; dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=kuleuven.be;
Received: from MI9PR08MB763857.eurprd08.prod.outlook.com
 (2603:10a6:290:c0::16) by AS8PR08MB6487.eurprd08.prod.outlook.com
 (2603:10a6:20b:33e::10) with Microsoft SMTP Server (version=TLS1_2,
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
Subject: [PATCH 6/7] unit: Add tests for cert subject and altnames
Date: Tue, 24 Nov 2026 12:08:46 +0100
Message-ID: <20261124110847.1254540-7-Mathy.Vanhoef@kuleuven.be>
X-Mailer: git-send-email 2.56.1
In-Reply-To: <20261124110847.1254540-1-Mathy.Vanhoef@kuleuven.be>
References: <20261124110847.1254540-1-Mathy.Vanhoef@kuleuven.be>
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-ClientProxiedBy: AS4P191CA0030.EURP191.PROD.OUTLOOK.COM
 (2603:10a6:20b:5d9::16) To MI9PR08MB763857.eurprd08.prod.outlook.com
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
X-MS-TrafficTypeDiagnostic: MI9PR08MB763857:EE_|AS8PR08MB6487:EE_
X-MS-Office365-Filtering-Correlation-Id: bd0c0517-fba4-41b2-2294-08df4a1b671d
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|23010399003|10070799003|376014|786006|366016|1800799024|10067099003|11063799006|56012099006|261022105027099003|261021123027099003|261021121427099003|261022075727099003|261009223027099003|261026140227099003|261102123227099003|261028144727099003|261102124527099003|18002099003|22082099003|3023799007;
X-Microsoft-Antispam-Message-Info:
	SIRG25A5yufpsr/Fm2SH/GfTimNF2Sys1sRngj+XUbCCfB82xB8M0rVNZLfkpotQ1jFqDdqfzrSo6FTuLBH5Ng6/yZWjvnWAzejzlCfpC8GcxyFD8eBpfp5H9SrrFrQ8hZMyuOSoESyQKvL/GSsLm2XFMISeWCqDzilS/0c5FmKQmqqHXsC6dxA+rwXYF1JXrWdp5YaLaRgVHFXm4slVEUD7hb5xP4oqcbEiKTE3ptcJ9bOVMpyNhzHUQtPPUqN25xQL7/dZkLurFZL97EjOF5ToxdvrjowKoRmS4LvFzXzuk7stMQ9R4RrhrEpDYRbbL1BZ27UUM5RJ647jyUHKLde/C4H3Kg6dJZFUEtXVqwdysORQn4NaGZV/gmFrNMDbS2N891jXDM16FI1B/sRMHuCB2+bEBvNxnVtQwsAaEYt43B0282eNbnVbuyNyPEEll9K3dpCRiqDg0aY+bu2Lh6L4O8idu0o4RKMbashcB/4oSw28WMJcKmTfyOLqCQAgV9HgQ1tbR9CHBb9rsIz1SkuoeS/VFH96SArcVhDhWrdUqgQ5AqVwipWl9bZugCgQvJCpW7LA2Oa7ja12RGTsxWATRlzlNCwlNOliYrTX8GM=
X-Forefront-Antispam-Report:
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:MI9PR08MB763857.eurprd08.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(23010399003)(10070799003)(376014)(786006)(366016)(1800799024)(10067099003)(11063799006)(56012099006)(261022105027099003)(261021123027099003)(261021121427099003)(261022075727099003)(261009223027099003)(261026140227099003)(261102123227099003)(261028144727099003)(261102124527099003)(18002099003)(22082099003)(3023799007);DIR:OUT;SFP:1102;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?us-ascii?Q?hx94Ec3UDx9AYY62RM3E9qHL7ALlernG0pKONUwwXzjFEcSPs5H8kEaXaryx?=
 =?us-ascii?Q?2zvFwHjhjUjFYO/qRxfZ9TpV7BPfq4jvRXMOKCiHE3LfA6zr7bljUZqTD0NC?=
 =?us-ascii?Q?MvVaGR2XNkKwK/8PpmR+GBHs5EykeCkohIwlp03OEYTEpGNr1ZXZKa7HRvxh?=
 =?us-ascii?Q?tz8h4XPCmRJy/f2vd/ld2G3N6IwbKQx0IRBlF8QnJMPoMAu5xodpKysgbHgi?=
 =?us-ascii?Q?PNcylxB2nNDMcun7LBk18s7GqsQdEbuN282U0TeUQBErLewOxo2sbWKhEh5M?=
 =?us-ascii?Q?8eJvDvIBuVjAGUe10w/CUrxtCrDqTbMMw44/VA2B3sMULzQOlv6ilILkhsdx?=
 =?us-ascii?Q?jcE6Ns9eWS47LGiQinFS+llX3wHZ+ZlulfeMgN8Bml4IOPbNOEkrrazQ/Yxm?=
 =?us-ascii?Q?7OF35vfJHo659p+bYQDJIp8vcrPaLl/T2kag1WV585WoVFXeC03uJUOHDSt+?=
 =?us-ascii?Q?0H7oqBCP2FYDyXIp2v4fa/bVkRU9Nbj+7AJeia4Dl02X0DID6YCZojGFaKNQ?=
 =?us-ascii?Q?2JG3QB26FPdKe94NJUKWLODxXJxr0JOI3HLrz+0aq3KM0j6nGScXrlC9wyKZ?=
 =?us-ascii?Q?wEgEFkEqKle8uWVJHJ5mFyDRAXnmGSmLGc9Cx6Ppwi42e1g1Zzgscyzi84z5?=
 =?us-ascii?Q?NN9Kye2Ea4fUIxU1J3uXVGnekf9IJRYAmK4uTLaqjok47IYvEwppliDfji17?=
 =?us-ascii?Q?m1io8yIuWPs1p4IDyIwPCK/E99eDOe/OIXef/qJacH2e0HniXLLScZtBzXR0?=
 =?us-ascii?Q?XWRX6PmngmOQEcAavzBaeVtnx/uV6+9aEMXN4VnB3ZPtYqAHxCbJj96j3Taj?=
 =?us-ascii?Q?32axNOAU/z2ayRxYjA3pHCEWs55nsC6ooTITpNp6jwUSTafC1gn+2KkT0+J1?=
 =?us-ascii?Q?UZFhMGIHs4/r6dVXHmnFDBZV7OGhLj8bPEJCP+4RsR0wDLYsG77htPsovlNp?=
 =?us-ascii?Q?MVqCt+qvx3GyzAA9xrGrU7bYQ1jtmQd/iRMtSof0dBmkGKiOG3BiXVwAC6bz?=
 =?us-ascii?Q?uvwQPRw82ASZCXCsFH+kjIeb6rpd+3cFj70EDaS/bwTqvUJvvHzOgq6a8IFt?=
 =?us-ascii?Q?F/gP94OeFcvypC750VUcuXZqC07vnrXXFlXLXkvQtRBjc8y4Z0iA45IiA1hm?=
 =?us-ascii?Q?4rnsb92qQUi2tJngzJTx0oFiSbeQMMTSLS3tPUdB4+gIOMxPcL+5T5FSUP5+?=
 =?us-ascii?Q?I3fR0Eu5H6v9M9h2AI662nqEnTdlYJ6J8j/hPFFJbcVAqVZQcFeBRwSHDWyk?=
 =?us-ascii?Q?YJixYr6qn9XEeFoL+M1ly7F/LoBanbuPEb72Ko4DD4Sq6uf8HlxfsFHk1Ffm?=
 =?us-ascii?Q?yL/CmeQEvcUKyQjCnLhbN5Ehsdu8Nv/Y2sjeT6y+niaCy/LGu7VNTMrM5YoS?=
 =?us-ascii?Q?pv2MY6KJH9bDNiDG+YUy3dFUHJBmCv6OAM8P4ldrNGlu7jBglxjBFp9shtlG?=
 =?us-ascii?Q?40UHaHTiC1CfBhuMyLesmQ4ENox4g1N9nKEX0sYeBJ4kSQ1ENHOLCQM+rLET?=
 =?us-ascii?Q?uQbcyokLuuf1jSYFVFso0sZH4LRHFSOgKwKw2c/fAnPbd7JCTi9JHXj6V3gl?=
 =?us-ascii?Q?Vo12L87t20Wn4/aV9mcUaEtW5e2CPGsZoKbJo0Gm7Cmr/jUxL7MgKr0JqbBd?=
 =?us-ascii?Q?djm/5VC8L7nl3oCKUCIrSpXqGrKgJmTGtJCkk1aO5k6TCDoKIH157bQxppIh?=
 =?us-ascii?Q?rgbo2IsAyP7LgsxLavG8fv2EDzRxD4+ROy4743xDK+sWqHQf4lX2Xvk1f6BV?=
 =?us-ascii?Q?4OmF+XXz/z8wQZGihThXR2g32MNObzb0yEi5vjWKh68CUd5XMwIW?=
X-OriginatorOrg: kuleuven.be
X-MS-Exchange-CrossTenant-Network-Message-Id: bd0c0517-fba4-41b2-2294-08df4a1b671d
X-MS-Exchange-CrossTenant-AuthSource: MI9PR08MB763857.eurprd08.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 24 Nov 2026 11:09:26.4999
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 3973589b-9e40-4eb5-800e-b0b6383d1621
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: niUhVrZw2sdyMdkxfgUzG8JYqN904Prn1+06paU0+4yZ1KYe9xFBKInGk/dsCQKuY5hxrDOUL1Z/FPWkv4IhsXORnYXV3Nc+ytEi/0hxSOA=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: AS8PR08MB6487

Check l_cert_get_subject_str() and l_cert_get_altnames() against the
test certificates.  Add a certificate with SubjectAltName entries of
mixed types to check that they are returned in the certificate's order
and that unsupported types are skipped.

Co-authored-by: Rathan Appana <rathan.appana@kuleuven.be>
---
 Makefile.am       | 17 ++++++++++++++++-
 unit/gencerts.cnf |  4 ++++
 unit/test-tls.c   | 41 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 61 insertions(+), 1 deletion(-)

diff --git a/Makefile.am b/Makefile.am
index eebf0de..9ce21c2 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -253,7 +253,8 @@ cert_files = unit/cert-chain.pem \
 			unit/cert-entity-pkcs12-pkcs5-sha512.p12 \
 			unit/cert-entity-combined.pem \
 			unit/cert-no-keyid.pem \
-			unit/cert-expired.pem
+			unit/cert-expired.pem \
+			unit/cert-altnames.pem
 
 cert_checks = unit/cert-intca \
 			unit/cert-entity-int \
@@ -642,6 +643,20 @@ unit/cert-no-keyid.pem: unit/cert-no-keyid.csr unit/cert-ca2.pem unit/gencerts.c
 unit/cert-no-keyid: unit/cert-no-keyid.pem unit/cert-ca2.pem
 	$(AM_V_GEN)openssl verify -CAfile $(builddir)/unit/cert-ca2.pem $<
 
+unit/cert-altnames.csr: unit/cert-client-key-pkcs1.pem unit/gencerts.cnf
+	$(AM_V_GEN)openssl req -new \
+			-config $(srcdir)/unit/gencerts.cnf \
+			-subj '/O=Bar Example Organization/CN=Bar Example Organization' \
+			-key $< -out $@
+
+unit/cert-altnames.pem: unit/cert-altnames.csr unit/cert-ca.pem unit/gencerts.cnf
+	$(AM_V_GEN)openssl x509 -req -extensions altnames_ext \
+			-extfile $(srcdir)/unit/gencerts.cnf \
+			-in $< -CA $(builddir)/unit/cert-ca.pem \
+			-CAkey $(builddir)/unit/cert-ca-key.pem \
+			-CAserial $(builddir)/unit/cert-ca.srl \
+			-CAcreateserial -sha256 -days 10000 -out $@ $($(AM_V_P)_redirect_openssl)
+
 unit/cert-expired.csr: unit/cert-client-key-pkcs1.pem unit/gencerts.cnf
 	$(AM_V_GEN)openssl req -new -extensions cert_ext \
 			-config $(srcdir)/unit/gencerts.cnf \
diff --git a/unit/gencerts.cnf b/unit/gencerts.cnf
index 22c7058..99de770 100644
--- a/unit/gencerts.cnf
+++ b/unit/gencerts.cnf
@@ -22,6 +22,10 @@ subjectKeyIdentifier = hash
 authorityKeyIdentifier = keyid:always,issuer:always
 subjectAltName = DNS:foo.int.example,DNS:foo.int.com
 
+[ altnames_ext ]
+basicConstraints = CA:FALSE
+subjectAltName = URI:https://bar.example/,email:bar@mail.example,DNS:bar.example,IP:192.0.2.1,DNS:bar.example.org
+
 [ ca_no_akid_ext ]
 basicConstraints = CA:TRUE
 
diff --git a/unit/test-tls.c b/unit/test-tls.c
index 669e5e5..e6b083c 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -550,6 +550,45 @@ static void tls_debug_cb(const char *str, void *user_data)
 	l_info("%s %s", (const char *) user_data, str);
 }
 
+static void test_cert_strings(const void *data)
+{
+	struct l_cert *cert;
+	char *subject;
+	char **altnames;
+
+	cert = load_cert_file(CERTDIR "cert-server.pem");
+	assert(cert);
+
+	subject = l_cert_get_subject_str(cert);
+	assert(subject && !strcmp(subject, "/O=Foo Example Organization"
+		"/CN=Foo Example Organization/emailAddress=foo@mail.example"));
+	l_free(subject);
+
+	altnames = l_cert_get_altnames(cert);
+	assert(altnames && l_strv_length(altnames) == 2);
+	assert(!strcmp(altnames[0], "DNS:foo.int.example"));
+	assert(!strcmp(altnames[1], "DNS:foo.int.com"));
+	l_strv_free(altnames);
+	l_cert_free(cert);
+
+	cert = load_cert_file(CERTDIR "cert-client.pem");
+	assert(cert);
+	assert(!l_cert_get_altnames(cert));
+	l_cert_free(cert);
+
+	cert = load_cert_file(CERTDIR "cert-altnames.pem");
+	assert(cert);
+
+	altnames = l_cert_get_altnames(cert);
+	assert(altnames && l_strv_length(altnames) == 4);
+	assert(!strcmp(altnames[0], "URI:https://bar.example/"));
+	assert(!strcmp(altnames[1], "EMAIL:bar@mail.example"));
+	assert(!strcmp(altnames[2], "DNS:bar.example"));
+	assert(!strcmp(altnames[3], "DNS:bar.example.org"));
+	l_strv_free(altnames);
+	l_cert_free(cert);
+}
+
 static void test_tls_with_ver(const struct tls_conn_test *test,
 				uint16_t server_ver, uint16_t client_ver)
 {
@@ -1028,6 +1067,8 @@ int main(int argc, char *argv[])
 
 	if (l_key_is_supported(L_KEY_FEATURE_RESTRICT)) {
 		l_test_add_func("Certificate chains", test_certificates, 0);
+		l_test_add_func("Certificate subject and altnames",
+						test_cert_strings, 0);
 		l_test_add_func("ECDSA Certificates", test_ec_certificates,
 						L_TEST_FLAG_ALLOW_FAILURE);
 	}
-- 
2.53.0

