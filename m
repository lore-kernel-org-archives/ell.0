Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=52.101.84.133
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795518564;
	b=EV09FE+/KO2KUM1Oey0+KYvfOcVtAFYP4Hw4aTeSCqi2tWZ7zRotHS+1qpsEAebeoqek
	 KayCbUqBFJ0TeorRLnR7fHQSXumNfYaQ4Eg2QZXc2BeYfqPiNAne4mxGIgKYOsU1z/Per
	 hm4pe9HYaxYf5ootjs5XoyThO9vxW4m7PCmyI1lhOtjDdv6Y5fISs1r0K8xjplvEfQdAN
	 R5/+0q8iKPJcKHGWq5goLroWHEhCelq8WPi9SRvZff1suwXhj8eu4zwDrCw2fPXwVoueh
	 TjJ2qOSVK9ZV3Ugb7Z1YvRpajofoTS5UDBLx2iCWlz7034qRsl1TiK+vRD+nTrAtabA==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795518564;
	h=DMARC-Filter:DKIM-Signature:Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:Content-Transfer-Encoding:Content-Type:
	 X-ClientProxiedBy:MIME-Version:X-MS-PublicTrafficType:
	 X-MS-TrafficTypeDiagnostic:X-MS-Office365-Filtering-Correlation-Id:
	 X-MS-Exchange-SenderADCheck:X-MS-Exchange-AntiSpam-Relay:
	 X-Microsoft-Antispam:X-Microsoft-Antispam-Message-Info:
	 X-Forefront-Antispam-Report:
	 X-MS-Exchange-AntiSpam-MessageData-ChunkCount:
	 X-MS-Exchange-AntiSpam-MessageData-0:X-OriginatorOrg:
	 X-MS-Exchange-CrossTenant-Network-Message-Id:
	 X-MS-Exchange-CrossTenant-AuthSource:X-MS-Exchange-CrossTenant-AuthAs:
	 X-MS-Exchange-CrossTenant-OriginalArrivalTime:
	 X-MS-Exchange-CrossTenant-FromEntityHeader:
	 X-MS-Exchange-CrossTenant-Id:X-MS-Exchange-CrossTenant-MailboxType:
	 X-MS-Exchange-CrossTenant-UserPrincipalName:
	 X-MS-Exchange-Transport-CrossTenantHeadersStamped;
	bh=VNozNcXyj0OasvJK6mNAcKDXOkh0CkFazFcmtfLzMo4=;
	b=TtKmE2+imejlRLWd978qYiiPkvijGZpNqyG7zGtAwOoaDI0udHTH1Tg0YTNCdEfXLq0Y
	 z0dkwwzGXOXzHLuElh+VuE8RThrqC1eXkpnCTgOXNbRnD7Lc2HVEKiVYUoqFNiCkvEm3v
	 3Cuzci6ppd48hcCo3ZB+aOoSVdqg/J/zlb+p6LNil31RH5MnUoeg5kVyn6CjFSCaOrF3s
	 SzebGWuWAMPWNcu4gBAY5RxC9z6+xA/w2eqXJ7lXJ/FQovagvesK+WlPVwMA7+eYuWoo0
	 dZgaHIORxRBfoh4WGVekK9c367PYjfTKQX/HqojxT6DOTph6gFe5QyWTjdViTAy+fGw==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=kuleuven.be;
	spf=pass smtp.mailfrom=kuleuven.be;
	dkim=pass header.d=kuleuven.be header.i=@kuleuven.be header.a=rsa-sha256 header.s=selector1 header.b=s2UWnINW;
	arc=pass header.oldest-pass=0 smtp.remote-ip=52.101.84.133
Received: from DB3PR0202CU003.outbound.protection.outlook.com (mail-northeuropeazon11020133.outbound.protection.outlook.com [52.101.84.133])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (secp384r1) server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 695DD606A31E
	for <ell@lists.linux.dev>; Tue, 24 Nov 2026 11:09:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 695DD606A31E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=kuleuven.be
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=kuleuven.be
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=kuleuven.be header.i=@kuleuven.be header.a=rsa-sha256 header.s=selector1 header.b=s2UWnINW
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=AVxGDWIcZQD4DujjmhSM1YCxvzE4JVrPKV8h+fE2K+4rfRLbU/xUk7ccNYfUH+QruS2KMi4AukV2UnV481UTqKmIGOaWMdDseP840dfTESmcRrj4ZuVH6flfCawHamT+PaOusJxmuwp8Y5ncXfQd+i/DsWwRE7rU92GJZ/AB/87GoQ5a844mmXuHLARqhaps5FW7bCKWobqNbNU9vellHOTdR7XwQ0+XX7EQXR/vOdFeCM+Y2VESnssS0mdajT2rP7VT9rt/jyJT+Nupv0JrBYeOnhkOWFh75Ac7Fr+6rMwb+PfLhZzxeVffrnSs3wxm7XKVHzyNus0kNser18/doQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=VNozNcXyj0OasvJK6mNAcKDXOkh0CkFazFcmtfLzMo4=;
 b=i9KK6k0lzvuuOU9oN1dSEgDcn/1hSQaxWKbm35rhOzXGQ5fAEMLr8jZ2yO4kRBG7LY6P5MOy8yGTHNwHkrRnqKtGgxLFQ31pAPHtcnzD+7CVAiD50o9EpKg298qYdoK3tykya4vzmSHleLljL1tQWh0yUJJrGyhE0486//GduI8cQ5riEVvGbKoIPQGOTL3V/hscPpEzhr/N3rEGGr/Fcj818JAcNsGrULsO5naz9f3hxn5DyMb8V9Fes3dqWhueYfBdgr6rYwW1BgeWlAC/nccFmhEZ+bxdr01B14DPJW8pXicQ498B5jwHAevQ5GXD5aghyqRe8GxrHVY3XGYFiQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=kuleuven.be; dmarc=pass action=none header.from=kuleuven.be;
 dkim=pass header.d=kuleuven.be; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kuleuven.be;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=VNozNcXyj0OasvJK6mNAcKDXOkh0CkFazFcmtfLzMo4=;
 b=s2UWnINWMeGCoyE9WdDG1cmLPVxNJ0N3pUAtCAA6JoMnSXSGx6/dSaScLRky2PQAsQ8t+fcTRNkvGlQOet520qpGVeo32jlvjKbxJ09r4Xg7vjP1ok/ZE135mp9uZaZTYr6aXDUbeY2UcL5oONkmfZedBc2K6SEH75QLJsaSHcg=
Authentication-Results: mx.microsoft.com 1; dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=kuleuven.be;
Received: from MI9PR08MB763857.eurprd08.prod.outlook.com
 (2603:10a6:290:c0::16) by DB9PR08MB7698.eurprd08.prod.outlook.com
 (2603:10a6:10:391::17) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.639.14; Tue, 24 Nov
 2026 11:09:18 +0000
Received: from MI9PR08MB763857.eurprd08.prod.outlook.com
 ([fe80::4f1d:a35e:c1b6:8b48]) by MI9PR08MB763857.eurprd08.prod.outlook.com
 ([fe80::4f1d:a35e:c1b6:8b48%7]) with mapi id 15.21.0639.012; Tue, 24 Nov 2026
 11:09:18 +0000
From: Mathy Vanhoef <Mathy.Vanhoef@kuleuven.be>
To: ell@lists.linux.dev
Cc: denkenz@gmail.com,
	marcel@holtmann.org,
	Mathy Vanhoef <Mathy.Vanhoef@kuleuven.be>
Subject: [PATCH 0/7] tls: Add server certificate pinning and peer chain reporting
Date: Tue, 24 Nov 2026 12:08:40 +0100
Message-ID: <20261124110847.1254540-1-Mathy.Vanhoef@kuleuven.be>
X-Mailer: git-send-email 2.56.1
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-ClientProxiedBy: AS8PR04CA0181.eurprd04.prod.outlook.com
 (2603:10a6:20b:2f3::6) To MI9PR08MB763857.eurprd08.prod.outlook.com
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
X-MS-Office365-Filtering-Correlation-Id: c39fbca3-5826-4517-2836-08df4a1b622b
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|376014|1800799024|10070799003|786006|366016|23010399003|10067099003|11063799006|56012099006|261102123227099003|261022105027099003|261028144727099003|261026121527099003|261021121427099003|261026140227099003|261021123027099003|261009223027099003|18002099003;
X-Microsoft-Antispam-Message-Info:
	T7pf1Y8b+6pY/PiFQ1Y2icb3xoNhDi5Gb2DQIVk+W6P1QHK1wCNKWdM0zevzia3fiXMZghzRTIRD2AaokFAZKu1tONcBg86VwxIKqGwaYSRywrOiEVVFAXQDD3LD/AHqamLdYVSIhDRzbvo4QQR5sq69KBU64XCytjUTUE4XBHwJzjl2+ZGeRB9cjHINOwhIJcTFWIeTiSkBpEXb901twixxur+6+Ydwj1qYfkVFQ/OiZdrpTdbxsPX37lyCKnWtH4uFfG3hyZx7NfNZolpRxPGszb0NZN8ciDdaEEnvw2oAdqGiCgMrnr7mkdQDuwI5KnAHY1hFemcMjihX9w9AsSV+qD3joeeyl0aJJChgBNeFodobpC7fnpVHI9eMZXoB1DGgL47oG8jxpIzo33TOD80qTtGtqC/zkKx2y6QfhnjWCHHSfRPYsLuGn+j6h2ORGczfdkHfjmENJkICciW/P0kQ2gESEpMjffbzQ3x1WQ8yMHPTVslpQGYS28aWefd8kVOrQk+rfAHblcppkXNIIaljqpHEOSkM/ORvTxJtQTHzhA77wmMdrD/x0jwPqe0WXAO6hDy9iIHhvS4IjMtLpud8NDXxPJHiBNYEpAtZjuveVEWMAXQwjGC5HPnxeyWeyKe710hAFp5y9aG7LI0aRbzhLlQyZDkUGdFzCteKrS0=
X-Forefront-Antispam-Report:
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:MI9PR08MB763857.eurprd08.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(376014)(1800799024)(10070799003)(786006)(366016)(23010399003)(10067099003)(11063799006)(56012099006)(261102123227099003)(261022105027099003)(261028144727099003)(261026121527099003)(261021121427099003)(261026140227099003)(261021123027099003)(261009223027099003)(18002099003);DIR:OUT;SFP:1102;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?us-ascii?Q?0XJOOYO7pPlXbVSD7SCNo3/AYXRn6+29TLBVM8aG84NW4NydiLrsoHevNPzz?=
 =?us-ascii?Q?TPRWQRWKAM85mWAxz/hz9EI9L7G6XKCvBHm0melsXwd16Jd3/RZdX/6Bp0ux?=
 =?us-ascii?Q?YYxsNPFsCbYD7YFOeE5mRei4mIJroqpz80zkZU2UvKnF4Jk+MgWlhN2ICGPJ?=
 =?us-ascii?Q?Edz9uMm9vxKynNCOYjkNqpSqWBeQqELA1Za+g0GcOg0sNOKAhq40uEdVDBYg?=
 =?us-ascii?Q?ThNFoHEY37IIvaXA9Bn0ckyxpE3HvBvqwmNvqJXQotSQt7Br9STTZ6N5UEcf?=
 =?us-ascii?Q?Gl1HXlzueV0tviR0VcRniOyeacM0giqGBRbRjt/V/JKo8D3wfIxhrs7C+/hZ?=
 =?us-ascii?Q?2NaTeRsbkT63+Hhox2r5GH3D75EB6GwOV5xlY0BbOXdr2KNhfcCF58GCxH3x?=
 =?us-ascii?Q?ohqK29RlK0/kDDKjy2f4ILJmuHg79u54UnxOdODky2xB4dKzUJ0bHRkSAMxl?=
 =?us-ascii?Q?K4Jt6Q5NCd5/wGma9iFU1vca6B7QSV78sSejJyLjdSf/41m26HvFQng+KmS9?=
 =?us-ascii?Q?Frx7FNILQX2yTDaigbjiW43CWhSG4W0sRwgAxhYR0bZqicEmMwU22w/lGMjM?=
 =?us-ascii?Q?pfddTRRS84XO/I7ZYXxuLQlGvrEfx3M3+cloIesYqsQDP1YkPCXJzTf2nXuc?=
 =?us-ascii?Q?nWk4R0BnFXlFl4++KICyNIt5tkAPsYdldCIHTOWBQF25pD13cQnyxj1Jv9dK?=
 =?us-ascii?Q?tAv/gDXrNhvLFxnMxgmHpnXiR5+8xr4ol4qYzYHf3QIHLkfmdeAGVbn4L8Sl?=
 =?us-ascii?Q?pw63CX+4l/+C1ouatSlsh5v354LV8xqvcicmIHN7ZdHg9yAh1JuFShuLpn3P?=
 =?us-ascii?Q?852ReEwJMsJEdiCkrC+ANKY/h6wP8aBLF35//mYRdNF822fUW/xwMPbH29+p?=
 =?us-ascii?Q?33gAWcuquzEHJcTz/30vK3dTjtmnnRCJKP4303xyHr6YPRJirp54AQJ9n2im?=
 =?us-ascii?Q?xNjSwEJ21HDtF7VuHfv6uGtzMdqLkfVGU/bV7SoxFe+8lLVbgd+Q8nvQT7+u?=
 =?us-ascii?Q?lOPTp8y9+Ex57j0CEA/UMfWSa/XCkYKOxwCGqEOl0VdBHyCXI+kemrDHZ8cv?=
 =?us-ascii?Q?4ZGY8VN3uxv7SO6GWeXVVMrmRKOAr/4pXGEMZgFj4VAaOdLb/rH/5oI/qurO?=
 =?us-ascii?Q?pOnxrUoP7A/U5zyjTjOzi8gmsssdxNhBy2obJeud1kSLL159DIUNqgeBfYxN?=
 =?us-ascii?Q?FeZU0iaq4cBBtIfBqSbbRJ+8a7ftUGYAdkL7ANUaIhHXDT2IaBIFB5ODCon2?=
 =?us-ascii?Q?zB2joRfZv+cXai3JATD1oHMaOSYV08D21tPuigyMMem/e1NVomcp60xASPPX?=
 =?us-ascii?Q?Urg7/IQqJpf6XK92iNxiY4LKXvvARaqzc++92uBIqth/AmB4elSaSXHjl6R+?=
 =?us-ascii?Q?4/CIGKyd44LaSY2aqz4IuDQxLThsmUbVfs4HBzM9qCQd+t1hCTPGN8G3GGmt?=
 =?us-ascii?Q?Vf0nmetR/0qpqmhm1JoMBgr09N4Q+hnoSJTmG1Bh78LCaDyYkRUNaCwifS+I?=
 =?us-ascii?Q?1rjHE9z8fthOFqs+ztMaPIL6CXESeEPRlRxlx1m5HXiuRxONjS7T8g+Nu9rL?=
 =?us-ascii?Q?bwpzxR5EIDSS8HjpYtE6MzNhM2Hplmf8cl+hb0psDfzTQS4ZRnfaufx1WITy?=
 =?us-ascii?Q?+Pd5pGt8LyE2OEF0cwja9Kx+BrODEgtjdYMI+R5j+LC4Ctxgr2Cec5Rn0Bbz?=
 =?us-ascii?Q?eQfzfsk/1J5RfWktv24bLFn2cY6veXy0xwG3RT2crY06ASfuzn7iesvckh1/?=
 =?us-ascii?Q?SalwdsxJdwMrMwat1iLdmliTqqACG2DC7dqmRIZ4E4TCQOOf/A5e?=
X-OriginatorOrg: kuleuven.be
X-MS-Exchange-CrossTenant-Network-Message-Id: c39fbca3-5826-4517-2836-08df4a1b622b
X-MS-Exchange-CrossTenant-AuthSource: MI9PR08MB763857.eurprd08.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 24 Nov 2026 11:09:18.2768
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 3973589b-9e40-4eb5-800e-b0b6383d1621
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: 4YW41QEVfyKVwiDPQ4OTEAn07RJlpREdeBQBsVg7NM8LivperN3IvOP7/lDWi+zOz2EHzpsLU5UHYhv8I9qfv/S0vvvKbffDXT62z0sHugs=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DB9PR08MB7698

These patches add support to l_tls for pinning a server certificate, and
for reporting the certificate chain received from the peer before it is
verified.  Together they allow a client to show an authentication
server's certificate to the user and to pin it on first use (TOFU),
for 802.1X networks whose CA certificate is not configured.

- Patches 1-2 add l_tls_set_server_cert_hash(), which pins the server's
  end-entity certificate by its SHA256 hash.  A matching certificate
  authenticates the server even without CA certificates, its validity
  period is still enforced.

- Patches 3-7 add l_tls_set_peer_certchain_cb(), which is called with
  the peer's certificate chain before it is verified, and
  l_cert_get_subject_str() and l_cert_get_altnames(), which report a
  certificate's subject and SubjectAltName entries in the same form
  as wpa_supplicant does.

A separate series for iwd uses these to add an EAP ServerCertHash
setting and a Station Certification signal, and a ConnMan series uses
those for TOFU.

Mathy Vanhoef (7):
  tls: Add support for server certificate pinning
  unit: Add tests for TLS server certificate pinning
  cert: Add l_cert_get_subject_str
  cert: Add l_cert_get_altnames
  tls: Add callback for the peer certificate chain
  unit: Add tests for cert subject and altnames
  unit: Test the TLS peer certificate chain callback

 Makefile.am        |  17 +++-
 ell/cert-private.h |   2 +
 ell/cert.c         | 189 +++++++++++++++++++++++++++++++++++++
 ell/cert.h         |   2 +
 ell/ell.sym        |   4 +
 ell/tls-private.h  |   4 +
 ell/tls.c          | 228 ++++++++++++++++++++++-----------------------
 ell/tls.h          |   7 ++
 unit/gencerts.cnf  |   4 +
 unit/test-tls.c    | 146 +++++++++++++++++++++++++++++
 10 files changed, 485 insertions(+), 118 deletions(-)


base-commit: 002b32d7c091993c5036956bf92d2444aca1c799
-- 
2.53.0

