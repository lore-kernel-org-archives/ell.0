Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=52.101.84.133
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795518569;
	b=vBuWwU5xNJbiRgw9yZUG3zjv0bYfy8Fmw53cqwDDNq6gyLsrQdf8tydeYwx/4UdXuc25
	 0pEHi7wdevz+BvrKA3JP9ZO9iiTugqSRm1CJgeOJSv+i0TSEErNa3zW8il5jMkaJL8qPL
	 EXBq+rsxsMNLXheNwKNLoFApJb9YH84H4kF7wa7/Uv2x6BQk1L7gTxeqjy9NUp/rcd+oK
	 FYdAWv5FpYFWyt3urOS1qKsDRYv+Zp19r0JeUpsBo1Agjq6cgSY6bS1IfcdHcWn7+3UBi
	 CXyFemycYBxEIPHuDq1rgY8k+p3jzQqoRP/bBS7+MFiS5Hy0qfDvYi30KL2sC2OSgrA==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795518569;
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
	bh=jjCf3zuuqaansvKPLe7F/LDUsdzkoqMChUH1XJEpQ2g=;
	b=Tuk/y8oal2z7LsQbtEKTQHUlwGigApH6GEPrHhdKUvyLZECZm1rdIxLjhD+BbDfoGhOv
	 k3MxGHHsyPBQod3xC6Mj+OD0oELNm1mlDcFPTt5XI3htECFBpcvywAXMsqR31ZwbOPpAJ
	 9pACgMbNwFF+7cETteK4OM/deXPfIgaH0V9ehMU26N554brpW7CwxAmqdyckukOCppIrX
	 DULoor9iqym0kort4/IN9jrA0Etaq6IJohwh5rAdxXCAnaq7cwt/uel3VNTUZerkYDajz
	 Pi0DlHyQ42p2+Su+VkHR3+XiMENqTSHd+3ektYbkIze4ZbC/uIZXeHrmKQNNU3NPCWg==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=kuleuven.be;
	spf=pass smtp.mailfrom=kuleuven.be;
	dkim=pass header.d=kuleuven.be header.i=@kuleuven.be header.a=rsa-sha256 header.s=selector1 header.b=fYRo8lxG;
	arc=pass header.oldest-pass=0 smtp.remote-ip=52.101.84.133
Received: from DB3PR0202CU003.outbound.protection.outlook.com (mail-northeuropeazon11020133.outbound.protection.outlook.com [52.101.84.133])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (secp384r1) server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9B4FD606A327
	for <ell@lists.linux.dev>; Tue, 24 Nov 2026 11:09:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 9B4FD606A327
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=kuleuven.be
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=kuleuven.be
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=kuleuven.be header.i=@kuleuven.be header.a=rsa-sha256 header.s=selector1 header.b=fYRo8lxG
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=j3HTn9f8Nr5pNrbN+hpmdQQkWcHDhlgsUxphnpvC6VK5pJI8yL55BZL/nSYsEjgVfEB9nkmCb1sJW+gfclzjU1lsnt/bgIoG9bEs7tLnsnjw8zf7/qUkuasS/Qn1raBglambXXRXC0SSnYBEdnveFBpPlypz7Eu/P6p3SCTyZk8dlO1FCrk1Mkk8wmHjPf4hSwRwZsGQmuqUOXeQqQmbcnPSPkDgHhYPsfV6uW+/tRLdJ4HAl4zfm8/HIlKqRvwY/kv7PsWvU5pPGAhXnxiNcXLYu7kkCMe53IAHkX/bsoquqTtn4zGm0jhsJLA9zwdEcbdpsAa2GXtrV6SswmdxSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=jjCf3zuuqaansvKPLe7F/LDUsdzkoqMChUH1XJEpQ2g=;
 b=PQZUzoUDpM+Kn1I93kOhIqXOJ5IhQst1rySGz2vnfnKjOopjLDvpM9yTOQdQCQ30+eD9fZAdkp5PU5iI/gFOMogQkZaRIWeNTQ7XURYuPFjmbpZOWtzftDXYLV9UX/vSV0Toktn5tzkxOs+bKwrNDl/XvbA7IqVlIxXeNi2vHjtRrPbjzawnuelkSgWW92dNou4YbJ0ikLH6fw5baYlGdg+sC0HaUDQml0HJxCmTc4+0H1XawOcFwWWtks/8/kBx7DbMiSBG4mSkb8iQJ7/bCFfzUMNewIm2AwfTV5L4pb+qje4z20xBX1Djt0IGdTMla+rELVk0P9fti6rBC4EMJQ==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=pass
 smtp.mailfrom=kuleuven.be; dmarc=pass action=none header.from=kuleuven.be;
 dkim=pass header.d=kuleuven.be; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kuleuven.be;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=jjCf3zuuqaansvKPLe7F/LDUsdzkoqMChUH1XJEpQ2g=;
 b=fYRo8lxGklk28J2S52k23jYooHDd5SLr2vk37qHoBcID4f02/UoorU/fQ5qGKtXEO2oJh22PjUzdG4eJhGUp8C43/TkHqbmiV/T7rdVpn+vNzLbvhoyaG4wvdo62Ci11ZICVb7R2vUYLHMJn14SndS3AXyAF8YidmxPjxV4MHZ0=
Authentication-Results: mx.microsoft.com 1; dkim=none (message not signed)
 header.d=none;dmarc=none action=none header.from=kuleuven.be;
Received: from MI9PR08MB763857.eurprd08.prod.outlook.com
 (2603:10a6:290:c0::16) by DB9PR08MB7698.eurprd08.prod.outlook.com
 (2603:10a6:10:391::17) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.21.639.14; Tue, 24 Nov
 2026 11:09:22 +0000
Received: from MI9PR08MB763857.eurprd08.prod.outlook.com
 ([fe80::4f1d:a35e:c1b6:8b48]) by MI9PR08MB763857.eurprd08.prod.outlook.com
 ([fe80::4f1d:a35e:c1b6:8b48%7]) with mapi id 15.21.0639.012; Tue, 24 Nov 2026
 11:09:22 +0000
From: Mathy Vanhoef <Mathy.Vanhoef@kuleuven.be>
To: ell@lists.linux.dev
Cc: denkenz@gmail.com,
	marcel@holtmann.org,
	Mathy Vanhoef <Mathy.Vanhoef@kuleuven.be>
Subject: [PATCH 3/7] cert: Add l_cert_get_subject_str
Date: Tue, 24 Nov 2026 12:08:43 +0100
Message-ID: <20261124110847.1254540-4-Mathy.Vanhoef@kuleuven.be>
X-Mailer: git-send-email 2.56.1
In-Reply-To: <20261124110847.1254540-1-Mathy.Vanhoef@kuleuven.be>
References: <20261124110847.1254540-1-Mathy.Vanhoef@kuleuven.be>
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-ClientProxiedBy: AS9PR0301CA0024.eurprd03.prod.outlook.com
 (2603:10a6:20b:468::31) To MI9PR08MB763857.eurprd08.prod.outlook.com
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
X-MS-Office365-Filtering-Correlation-Id: f04a44fa-cedf-4e4c-4606-08df4a1b649b
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|376014|1800799024|10070799003|786006|366016|23010399003|10067099003|11063799006|56012099006|261102123227099003|261022105027099003|261028144727099003|261026121527099003|261021121427099003|261026140227099003|261102130727099003|261021123027099003|261009223027099003|22082099003|18002099003;
X-Microsoft-Antispam-Message-Info:
	uOh6OJMU6XnJfOHVbei5mBsfR5/BQ50Rg6NUF6M3qAQlSJLFiBKdUtNrCItUKVT3p64bR8kQ3RDkS9zGtC4b55lj5ZZM3YaXnxgO0fkH1ZNdTwsqASUCuovlTDd7Uwvo1xurlyXKRl8+d9ZlX4+n57qnEgptdfUODs7fF3LXvMgdXGUVNF7JYWow83Zi9UtJ7B7/SA8EpV6fHmxaAs0OCdomi7frQMVmnIu+HPoSOSjkj4HrErSV3yFkGyqycc30Jcvo1SCZl6vN2UI7ccZdQQ0f5enV9w+0o66VS+1/JBUW45qgtRQsHSO941cq2a0iuSwniWOt4mlpapwvWIYfO3A4rvlojGGwpqaShsNi8K6mnsHQH/8/dRjiCdAsYBX+HJKL/5ElB1LfG9YVk3LObtSOT8mdX4Y7AEwu4QnhQeetMmlhH1Nk7W+BsWKdKft8bsBURYnye4pOq4qbE8MjvnImRFqhwGUsL8ryupSh6qS5pTLVGFZA5cyCC9+C5N10wbj2MVxPO3K/z71GjC7vr+VTbOjq3iPySd/xNkyfCj2ezQUdxAVlVBssnXSe9PhN5u7mV1hmEBEH57jcK1eGI0eJ2AJ+0o3T+SQvYUmtIKFusRrQAbtYMU1JCCgqMf8blg5/58vD83Q6H5MLjvkJhMmN7eNVTX5valRcpWheNJM=
X-Forefront-Antispam-Report:
	CIP:255.255.255.255;CTRY:;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:MI9PR08MB763857.eurprd08.prod.outlook.com;PTR:;CAT:NONE;SFS:(13230040)(376014)(1800799024)(10070799003)(786006)(366016)(23010399003)(10067099003)(11063799006)(56012099006)(261102123227099003)(261022105027099003)(261028144727099003)(261026121527099003)(261021121427099003)(261026140227099003)(261102130727099003)(261021123027099003)(261009223027099003)(22082099003)(18002099003);DIR:OUT;SFP:1102;
X-MS-Exchange-AntiSpam-MessageData-ChunkCount: 1
X-MS-Exchange-AntiSpam-MessageData-0:
	=?us-ascii?Q?2o8rvP0eS1VAnqyAgWw0JBYxPqgUTRy7FywVPi/WJ5Q+1MI9s+Sr9aFTOBZf?=
 =?us-ascii?Q?MYIYT/dbJb+4O0o6fjrmv1pC8WlfvL4VnBLuf0yUxUnLAylacDpIsI3vRi7/?=
 =?us-ascii?Q?GKpy4ulw567XXHNUw1/MdWDnUPLUFXSEe2uUK5P0nT3J8wb9YX10o0Gkv5yB?=
 =?us-ascii?Q?T0HdV4uYHMqeGVLsBGnrAOu1P/mAlLJfKjKoaldt/NMsx09ztdrdLAOFVDD2?=
 =?us-ascii?Q?IKTBVRpj5Vug5GfQXLxg2E17trtf8kGCKowW3E6o4NBZCRHBTu0bkal7SeRx?=
 =?us-ascii?Q?f0z7N9l0m4bNoRPEpabQwCDTbQM6r7MRnQmGD4HBozqMWbL6G5hU69yK4hE5?=
 =?us-ascii?Q?e4ovcf57TeIH6XKMknL5QlvzghlY31z2WjsxkbnoApk/I2RwgnPdl9TIOHfe?=
 =?us-ascii?Q?s2+ceH31dZomeLvsEXxH+6SaUIJr9xHn4r/O3D+Pqj57EFM5AzTxS7eqCgoC?=
 =?us-ascii?Q?kY+OW0S8ts/t4HfXwkEyuefuiGrTDRqVBUuhKtHwafSKITq+W6K9iMvDOGXE?=
 =?us-ascii?Q?nS+CCs1O14Bfu0D7WEA7uZEQMp4uZgk04aGeGtcy0hbTfY69hQm72wnOOK9O?=
 =?us-ascii?Q?sz0g0NSJQF7hOdK1NFrelh9+hXCD5xYYe1WJJLcMkh71m860b8ZsA7rjTDUv?=
 =?us-ascii?Q?IkqE4gU0Rd3MWJDcPq2odTvqfqKTmuVpj/pLPrxrx42oYGIr0xPzeYFuulMn?=
 =?us-ascii?Q?Q9MbXVxqn3B3xp83hArK0QUncYFKTUnPIVczgzMePai2XKC0TaiGj/wsDcap?=
 =?us-ascii?Q?Tw7GXJ35rN6pY52aay4Xg6runmodkHfh7pRYKegRKOeoXyhhyGx/5K8iAd40?=
 =?us-ascii?Q?qojwSNnG0o0yoiGu12JtDXBBHjpDdCQuRsT5sqVnj5s1hC5C7UYAiD9nMgix?=
 =?us-ascii?Q?zM1zLEPrJGUrCbyVCI1pLANv9HE/hxWfLqu/mHelOR8vLkidSWhQMZ+0raLk?=
 =?us-ascii?Q?/MLVXveIukJq5Kxt4e8hGVz7KjuDYAOuchVZj9gt39Sy7r9Vos2PEo9WL4bz?=
 =?us-ascii?Q?nUB+l7pX2pjEgCJO+ADWc20A9MaVk6n0SiiibtBmTghULpdyQgbSpnBng+uf?=
 =?us-ascii?Q?OOF0P7K192PkwmJLOr2dAuq2dhY5IE71m0RXwoS1MPB8aPcIryQTFpAzFuNj?=
 =?us-ascii?Q?3LT+I5LDrHQpMDFlYlgVx2hYRLR9rRsPH/Ju1c/t9PVWj2M8UpWWvXRVJopp?=
 =?us-ascii?Q?OOanj8Nw2AMe+Tr64c2N1D+R/BI+RKHSz/43nK0jW6VDThDqVRv6RLp6DzgD?=
 =?us-ascii?Q?O/7xXtVbdBAzgK+Ir30zcvWl2KxIc5KOvxf9r5SKn6RvDHWNCojAYIYPKtQH?=
 =?us-ascii?Q?pZjTZWK9T20/mwUOqCMJAOKj8AEW06qK7d71VTzV7m0fzOffj0A2ujr575H2?=
 =?us-ascii?Q?IscLC8pFP8O5zqkBAo4JWvHls+kwai3nV6gdactDpT3hSItuHoAc8akPf9Lg?=
 =?us-ascii?Q?eiiD6dpQOw0aMPv5yzZqG2CXUTiJFivFEFcSdbc4ixk+tB5DLFnCjeyfgUz8?=
 =?us-ascii?Q?RClXRh3yihtgZveYMiM0PA+vSutPI9PvtgEpJ9l4lljrie1ojy8ATH4AqyvN?=
 =?us-ascii?Q?sHNwTmQKjHhUYiIhyup8dq6d+9RR8F+eaHqj3m0MtAaXvGnHW2VR0aJq1JP/?=
 =?us-ascii?Q?LwGP+JGEbLib2oE5KzXOilCnm59U6nUxV9ba+o4AM+zdxGQMKYGoVj5MUcG2?=
 =?us-ascii?Q?/C1SNSjxfgN3D813klf+vw/ZOxLkxOlDDKaF3nDbdQ7dXRboQlVY5ABRHBfv?=
 =?us-ascii?Q?kGo8ACtPH7wqejVAP1N2eck92b6ZKXoOSOACYcC20EZYTYMnSa9k?=
X-OriginatorOrg: kuleuven.be
X-MS-Exchange-CrossTenant-Network-Message-Id: f04a44fa-cedf-4e4c-4606-08df4a1b649b
X-MS-Exchange-CrossTenant-AuthSource: MI9PR08MB763857.eurprd08.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Internal
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 24 Nov 2026 11:09:22.3046
 (UTC)
X-MS-Exchange-CrossTenant-FromEntityHeader: Hosted
X-MS-Exchange-CrossTenant-Id: 3973589b-9e40-4eb5-800e-b0b6383d1621
X-MS-Exchange-CrossTenant-MailboxType: HOSTED
X-MS-Exchange-CrossTenant-UserPrincipalName: 6jJl2vv2H3Fe+zx0MPVbdV39GPtjtZRTpUHCMe+tHjp6CnEQFy4omBSoFxIL0yM4g/r0U+nj29gFZchSA5d2H1sgMVmXBo2xX5LnLH29yIQ=
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DB9PR08MB7698

Add a function that returns the subject DN of a certificate as a string
of the form "/O=Organization/CN=name", so that it can be reported for
every certificate of a chain.  This is the form in which TLS already
reports the peer's identity, so move that code from tls.c and use the
new function there.

Co-authored-by: Rathan Appana <rathan.appana@kuleuven.be>
---
 ell/cert.c  | 118 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 ell/cert.h  |   1 +
 ell/ell.sym |   1 +
 ell/tls.c   | 114 +-------------------------------------------------
 4 files changed, 122 insertions(+), 112 deletions(-)

diff --git a/ell/cert.c b/ell/cert.c
index ac9bdb7..0ffb5c3 100644
--- a/ell/cert.c
+++ b/ell/cert.c
@@ -25,6 +25,7 @@
 #include "time.h"
 #include "time-private.h"
 #include "utf8.h"
+#include "string.h"
 #include "cert.h"
 #include "cert-private.h"
 #include "tls.h"
@@ -178,6 +179,123 @@ LIB_EXPORT const uint8_t *l_cert_get_dn(struct l_cert *cert, size_t *out_len)
 						-1);
 }
 
+struct dn_element_info {
+	const char *str;
+	const struct asn1_oid oid;
+};
+
+static const struct dn_element_info dn_elements[] = {
+	{ "CN", { 3, { 0x55, 0x04, 0x03 } } },
+	{ "SN", { 3, { 0x55, 0x04, 0x04 } } },
+	{ "serialNumber", { 3, { 0x55, 0x04, 0x05 } } },
+	{ "C", { 3, { 0x55, 0x04, 0x06 } } },
+	{ "ST", { 3, { 0x55, 0x04, 0x07 } } },
+	{ "L", { 3, { 0x55, 0x04, 0x08 } } },
+	{ "street", { 3, { 0x55, 0x04, 0x09 } } },
+	{ "O", { 3, { 0x55, 0x04, 0x0a } } },
+	{ "OU", { 3, { 0x55, 0x04, 0x0b } } },
+	{ "title", { 3, { 0x55, 0x04, 0x0c } } },
+	{ "telephoneNumber", { 3, { 0x55, 0x04, 0x14 } } },
+	{ "givenName", { 3, { 0x55, 0x04, 0x2a } } },
+	{ "initials", { 3, { 0x55, 0x04, 0x2b } } },
+	{ "emailAddress", {
+		9,
+		{ 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x09, 0x01 }
+	} },
+	{ "domainComponent", {
+		10,
+		{ 0x09, 0x92, 0x26, 0x89, 0x93, 0xf2, 0x2c, 0x64, 0x01, 0x19 }
+	} },
+	{}
+};
+
+static void cert_str_escape_append(struct l_string *out, char *str, size_t len)
+{
+	while (len--) {
+		switch (*str) {
+		case '\\':
+		case '/':
+		case '=':
+			l_string_append_c(out, '\\');
+			l_string_append_c(out, *str);
+			break;
+		default:
+			l_string_append_c(out, *str);
+			break;
+		}
+
+		str++;
+	}
+}
+
+/**
+ * l_cert_get_subject_str:
+ * @cert: certificate
+ *
+ * Returns: the subject DN as a newly allocated string of the form
+ * "/O=Organization/CN=name", or NULL on error.
+ */
+LIB_EXPORT char *l_cert_get_subject_str(struct l_cert *cert)
+{
+	const uint8_t *dn, *end;
+	size_t dn_size;
+	struct l_string *id_str;
+
+	if (unlikely(!cert))
+		return NULL;
+
+	dn = l_cert_get_dn(cert, &dn_size);
+	if (!dn)
+		return NULL;
+
+	id_str = l_string_new(200);
+
+	end = dn + dn_size;
+	while (dn < end) {
+		const uint8_t *set, *seq, *oid, *name;
+		uint8_t tag;
+		size_t len, oid_len, name_len;
+		const struct dn_element_info *info;
+
+		set = asn1_der_find_elem(dn, end - dn, 0, &tag, &len);
+		if (!set || tag != ASN1_ID_SET)
+			goto error;
+
+		dn = set + len;
+
+		seq = asn1_der_find_elem(set, len, 0, &tag, &len);
+		if (!seq || tag != ASN1_ID_SEQUENCE)
+			goto error;
+
+		oid = asn1_der_find_elem(seq, len, 0, &tag, &oid_len);
+		if (!oid || tag != ASN1_ID_OID)
+			goto error;
+
+		name = asn1_der_find_elem(seq, len, 1, &tag, &name_len);
+		if (!name || (tag != ASN1_ID_PRINTABLESTRING &&
+					tag != ASN1_ID_UTF8STRING &&
+					tag != ASN1_ID_IA5STRING))
+			continue;
+
+		for (info = dn_elements; info->str; info++)
+			if (asn1_oid_eq(&info->oid, oid_len, oid))
+				break;
+		if (!info->str)
+			continue;
+
+		l_string_append_c(id_str, '/');
+		l_string_append(id_str, info->str);
+		l_string_append_c(id_str, '=');
+		cert_str_escape_append(id_str, (char *) name, name_len);
+	}
+
+	return l_string_unwrap(id_str);
+
+error:
+	l_string_free(id_str);
+	return NULL;
+}
+
 static uint64_t cert_parse_asn1_time(const uint8_t *data, size_t len,
 					uint8_t tag)
 {
diff --git a/ell/cert.h b/ell/cert.h
index 78b2e54..ce6efea 100644
--- a/ell/cert.h
+++ b/ell/cert.h
@@ -33,6 +33,7 @@ DEFINE_CLEANUP_FUNC(l_cert_free);
 
 const uint8_t *l_cert_get_der_data(struct l_cert *cert, size_t *out_len);
 const uint8_t *l_cert_get_dn(struct l_cert *cert, size_t *out_len);
+char *l_cert_get_subject_str(struct l_cert *cert);
 bool l_cert_get_valid_times(struct l_cert *cert, uint64_t *out_not_before_time,
 				uint64_t *out_not_after_time);
 enum l_cert_key_type l_cert_get_pubkey_type(struct l_cert *cert);
diff --git a/ell/ell.sym b/ell/ell.sym
index f428289..fa9788b 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -589,6 +589,7 @@ global:
 	l_cert_free;
 	l_cert_get_der_data;
 	l_cert_get_dn;
+	l_cert_get_subject_str;
 	l_cert_get_valid_times;
 	l_cert_get_pubkey_type;
 	l_cert_get_pubkey;
diff --git a/ell/tls.c b/ell/tls.c
index a5bfbae..78c15cb 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -2886,116 +2886,6 @@ static void tls_handle_certificate_verify(struct l_tls *tls,
 	TLS_SET_STATE(TLS_HANDSHAKE_WAIT_CHANGE_CIPHER_SPEC);
 }
 
-struct dn_element_info {
-	const char *str;
-	const struct asn1_oid oid;
-};
-
-static const struct dn_element_info dn_elements[] = {
-	{ "CN", { 3, { 0x55, 0x04, 0x03 } } },
-	{ "SN", { 3, { 0x55, 0x04, 0x04 } } },
-	{ "serialNumber", { 3, { 0x55, 0x04, 0x05 } } },
-	{ "C", { 3, { 0x55, 0x04, 0x06 } } },
-	{ "ST", { 3, { 0x55, 0x04, 0x07 } } },
-	{ "L", { 3, { 0x55, 0x04, 0x08 } } },
-	{ "street", { 3, { 0x55, 0x04, 0x09 } } },
-	{ "O", { 3, { 0x55, 0x04, 0x0a } } },
-	{ "OU", { 3, { 0x55, 0x04, 0x0b } } },
-	{ "title", { 3, { 0x55, 0x04, 0x0c } } },
-	{ "telephoneNumber", { 3, { 0x55, 0x04, 0x14 } } },
-	{ "givenName", { 3, { 0x55, 0x04, 0x2a } } },
-	{ "initials", { 3, { 0x55, 0x04, 0x2b } } },
-	{ "emailAddress", {
-		9,
-		{ 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x09, 0x01 }
-	} },
-	{ "domainComponent", {
-		10,
-		{ 0x09, 0x92, 0x26, 0x89, 0x93, 0xf2, 0x2c, 0x64, 0x01, 0x19 }
-	} },
-	{}
-};
-
-static void tls_str_escape_append(struct l_string *out, char *str, size_t len)
-{
-	while (len--) {
-		switch (*str) {
-		case '\\':
-		case '/':
-		case '=':
-			l_string_append_c(out, '\\');
-			l_string_append_c(out, *str);
-			break;
-		default:
-			l_string_append_c(out, *str);
-			break;
-		}
-
-		str++;
-	}
-}
-
-static char *tls_get_peer_identity_str(struct l_cert *cert)
-{
-	const uint8_t *dn, *end;
-	size_t dn_size;
-	struct l_string *id_str;
-
-	if (!cert)
-		return NULL;
-
-	dn = l_cert_get_dn(cert, &dn_size);
-	if (!dn)
-		return NULL;
-
-	id_str = l_string_new(200);
-
-	end = dn + dn_size;
-	while (dn < end) {
-		const uint8_t *set, *seq, *oid, *name;
-		uint8_t tag;
-		size_t len, oid_len, name_len;
-		const struct dn_element_info *info;
-
-		set = asn1_der_find_elem(dn, end - dn, 0, &tag, &len);
-		if (!set || tag != ASN1_ID_SET)
-			goto error;
-
-		dn = set + len;
-
-		seq = asn1_der_find_elem(set, len, 0, &tag, &len);
-		if (!seq || tag != ASN1_ID_SEQUENCE)
-			goto error;
-
-		oid = asn1_der_find_elem(seq, len, 0, &tag, &oid_len);
-		if (!oid || tag != ASN1_ID_OID)
-			goto error;
-
-		name = asn1_der_find_elem(seq, len, 1, &tag, &name_len);
-		if (!name || (tag != ASN1_ID_PRINTABLESTRING &&
-					tag != ASN1_ID_UTF8STRING &&
-					tag != ASN1_ID_IA5STRING))
-			continue;
-
-		for (info = dn_elements; info->str; info++)
-			if (asn1_oid_eq(&info->oid, oid_len, oid))
-				break;
-		if (!info->str)
-			continue;
-
-		l_string_append_c(id_str, '/');
-		l_string_append(id_str, info->str);
-		l_string_append_c(id_str, '=');
-		tls_str_escape_append(id_str, (char *) name, name_len);
-	}
-
-	return l_string_unwrap(id_str);
-
-error:
-	l_string_free(id_str);
-	return NULL;
-}
-
 static void tls_finished(struct l_tls *tls)
 {
 	_auto_(l_free) char *peer_cert_identity = NULL;
@@ -3006,10 +2896,10 @@ static void tls_finished(struct l_tls *tls)
 	bool renegotiation = tls->ready;
 
 	if (tls->peer_authenticated && !resuming) {
-		peer_cert_identity = tls_get_peer_identity_str(tls->peer_cert);
+		peer_cert_identity = l_cert_get_subject_str(tls->peer_cert);
 		if (!peer_cert_identity) {
 			TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
-					"tls_get_peer_identity_str failed");
+					"l_cert_get_subject_str failed");
 			return;
 		}
 
-- 
2.53.0

