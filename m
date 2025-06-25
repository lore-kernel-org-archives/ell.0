Received: from OSPPR02CU001.outbound.protection.outlook.com (mail-norwayeastazon11013057.outbound.protection.outlook.com [40.107.159.57])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 011E0175A5
	for <ell@lists.linux.dev>; Wed, 25 Jun 2025 13:14:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=40.107.159.57
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1750857295; cv=fail; b=FYaKf6nBOagsjwRr7PjKMuguwPTNMDdG08ok+7qly7VPx0P3Phx17nLSVQCEtCCumlamBYOZ+64PMZM1TbCqQpX8VqPdUsvZCgryESP3KRG9raEvBdiE93uvtclDU+caVs/RZJl3Ggok4hHwrvxTeVekr3l2TvL5LDD8w4htNos=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1750857295; c=relaxed/simple;
	bh=nLIVhLkCuySeT8SyM3faN5Z8ahITRkNr2VuLssMKfG0=;
	h=From:To:CC:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=lMw9bho5k8FIF5kjziCUUrtfaJIiTsGFpo5J1ViUF70QnqnpIv/v2UFA/9v4PBuWnAxFxF4SFmStHPsc51p8LslH0b/U7luguUmJ7zq0YTTOxYJ0zYnwzzIALGBmv+4Na2j4eFP0Oe3iZgfBLcp3SaAOSHUtEVpyqOuNM386aZo=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=arri.de; spf=pass smtp.mailfrom=arri.de; dkim=pass (1024-bit key) header.d=arri.de header.i=@arri.de header.b=ec/Ta/gx; arc=fail smtp.client-ip=40.107.159.57
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=arri.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=arri.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=arri.de header.i=@arri.de header.b="ec/Ta/gx"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=BmrPZD2Um98ufDlAD6OP8MSHC++4NXcRs3G+4SZzZf07bi/AIA6fw9Mx5R0988vy5JcxWQTiA53Ne1aIcyr7dCfUkkP2r97kykDH8i/Qic49jWH2R3/gDa9p7PqV7hJ8+HTIzMoyg0zb3dN2ozPUeNI/Op8cQQGo+GojudJG+7PXqAuoysZZrRK79TveNLRSgP8N8afD42VjtnIUBTAndknvJlUTQTlG5XIvCr6aE2BMf8yOq/Fdlh+xcngt7+RXDA72zNE+eonZ8MbCpU1bdOTiLZihBoCFxv+d2p/+oaKGkDJ75Q4jzkALJhaBuQOBwWORDs2PvagqV4cuDB93oQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=+mSrYgasuAQfeSeYn3VWQnfqscFvQ+UQ/shThowHtF4=;
 b=RECrxTeZDtwAdyLiaxqi1zqyvGpIPGa+tbET3Fmkmd9MKVon4d6OZ0bCIvL0mGJCZmWAM2fMm0U8jVYLKNKDjhEt8ApLWXiEXbzg7lhF5pffjp+lotaMAG/0esYT8HZFGGEhGQZBU2FHLgZByn2kaR1LyiL4+oIt+KEPo1mVeB3op7CIV5jPHYqdvrRZZYKYCfCR73bW5R53JMiHS/ppRKj6Cnt+ay3dCTN/AsBMLeXqpP8tlY151+enQshmCb+kgXQFsVZZB4H/bm5GV0m5b4eUtCTIJDnIFI9DzK69mSFUL7OBZj7NvVwAUsYdSUpss6D3/kRNUvX07kdqrc05yA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=fail (sender ip is
 217.111.95.7) smtp.rcpttodomain=lists.linux.dev smtp.mailfrom=arri.de;
 dmarc=fail (p=none sp=none pct=100) action=none header.from=arri.de;
 dkim=none (message not signed); arc=none (0)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=arri.de; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=+mSrYgasuAQfeSeYn3VWQnfqscFvQ+UQ/shThowHtF4=;
 b=ec/Ta/gxU3PzC2bO+rDrxRcfjZoEW1Y3xeL7Lj/s50NZJyaeu2xb0Avt/QKS5GC24zRKiWiA6xjFTPv/nCxRdROPJ/15qUzMZvpwMGMEm43wMtL3q0j2T8be28UN/bhw9Es9jdtmLBJIR5zslFaf3d+GRVXuLHJvrbEcTjSsVjM=
Received: from FR4P281CA0184.DEUP281.PROD.OUTLOOK.COM (2603:10a6:d10:ca::19)
 by DB4PR03MB9482.eurprd03.prod.outlook.com (2603:10a6:10:3f6::14) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.8857.27; Wed, 25 Jun
 2025 13:14:49 +0000
Received: from DB1PEPF000509EE.eurprd03.prod.outlook.com
 (2603:10a6:d10:ca:cafe::3a) by FR4P281CA0184.outlook.office365.com
 (2603:10a6:d10:ca::19) with Microsoft SMTP Server (version=TLS1_3,
 cipher=TLS_AES_256_GCM_SHA384) id 15.20.8880.17 via Frontend Transport; Wed,
 25 Jun 2025 13:14:47 +0000
X-MS-Exchange-Authentication-Results: spf=fail (sender IP is 217.111.95.7)
 smtp.mailfrom=arri.de; dkim=none (message not signed)
 header.d=none;dmarc=fail action=none header.from=arri.de;
Received-SPF: Fail (protection.outlook.com: domain of arri.de does not
 designate 217.111.95.7 as permitted sender) receiver=protection.outlook.com;
 client-ip=217.111.95.7; helo=mta.arri.de;
Received: from mta.arri.de (217.111.95.7) by
 DB1PEPF000509EE.mail.protection.outlook.com (10.167.242.72) with Microsoft
 SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.8880.14 via Frontend Transport; Wed, 25 Jun 2025 13:14:47 +0000
Received: from N9W6SW14.arri.de (10.30.5.30) by mta.arri.de (10.10.18.5) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.1258.38; Wed, 25 Jun
 2025 15:14:45 +0200
From: Christian Eggers <ceggers@arri.de>
To: <ell@lists.linux.dev>
CC: Christian Eggers <ceggers@arri.de>
Subject: [PATCH 2/4] dbus-client: assign service name before running callback
Date: Wed, 25 Jun 2025 15:14:30 +0200
Message-ID: <20250625131432.19974-2-ceggers@arri.de>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <20250625131432.19974-1-ceggers@arri.de>
References: <20250625131432.19974-1-ceggers@arri.de>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-EOPAttributedMessage: 0
X-MS-PublicTrafficType: Email
X-MS-TrafficTypeDiagnostic: DB1PEPF000509EE:EE_|DB4PR03MB9482:EE_
X-MS-Office365-Filtering-Correlation-Id: d5696b1e-67e2-44fe-0232-08ddb3ea42aa
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|376014|1800799024|36860700013|82310400026;
X-Microsoft-Antispam-Message-Info:
	=?us-ascii?Q?TYQ7e1loppNY36FQ15psF4gujmCol6jXDDJVmN7JcqVqTKAD6UXeXbBLt8Ok?=
 =?us-ascii?Q?JA2YNW/BSMkQk0WDbbvANTT9H1lKpfNRAirQM2mSTIRbHUd2zX0bQNJmn+8F?=
 =?us-ascii?Q?HvC66I2ZKe/ghuDNAJaJpU9nY2+jDZ1XLH2Qg3t6p9uq5Ka0VM1Q3bkqo8u9?=
 =?us-ascii?Q?T7TSa0d+ffiN0GUQUvfiRK7kXIOPkJ6fS+rN0ifx3QnQeTFc6kD4pliqTzWF?=
 =?us-ascii?Q?5PEcZ99GuoblaxB/K01NWzssJo8X5kWrAh9+W2JikODwrAk509jcj+XTQCuv?=
 =?us-ascii?Q?J7jOSR2PVQ1H+AJcZdBSW2fwwGJpH1Pim5fTz/ivR0L95NbapGAIT9AoEvqD?=
 =?us-ascii?Q?O0+fiYtobi6fkcS5eLImeOe0Y4+azYNUHu/LvmXo+qVVbfv9XkTcG9ZKQXQ4?=
 =?us-ascii?Q?3QSfzSuxDp9jZK1NKyH7sDxMTk1An7mrrG7Vsm2eZ379Bbwn7L60OPcEJ+0C?=
 =?us-ascii?Q?3ruXOHAn4DEJ2UqcjDcgV2+U144CNlIZvQ2NU45fbjPDxNuIRwoRkFjgJudc?=
 =?us-ascii?Q?V7tdoCtyolN97+NkYoPwNcyRlqy5eD1xUN74ED00bFv3tllEJlV1ZbG22X9Q?=
 =?us-ascii?Q?sqXfDSTezJMXHVflQnlnc3X+p8Q3WGygtXg2ZEnFxb1tcU2OuusVa46FuEzx?=
 =?us-ascii?Q?9SYi4zfpnvchckB+ACI3U05MPkVR69Bj+9w0sRBLWK3pA+/qHbUUJ62NlMYH?=
 =?us-ascii?Q?R1ORJaoUYyaJkO+B1miRDv6BZvlVwjYw11ypxsJAzsr626CoVNgPrQtcdQJj?=
 =?us-ascii?Q?m0CE+VoxrhZrzpUtvj2ESUYLDQgwQHnzNCuiiUVoZwM3Y3NGmkZmSrSUNQBP?=
 =?us-ascii?Q?TXYJYyRZO2nV2pTbdvfMJwaNuPKsVqCUZk6/wvg8UZpO63pXnvB+JtjHJUFl?=
 =?us-ascii?Q?9pxVewzFwgnt3V5J2hfd4B/0y9Z+/gLQ9s9Md9Saozpb0oezQiTda45n7nHI?=
 =?us-ascii?Q?rtvks0derLbagBGtYFrU+5gUI7lo/OFu/q/E4TgKmWCcMKDFe6U9dNFyCd08?=
 =?us-ascii?Q?S4AUprsaZYdFaw2Luboqt2g+L8Ee72EZ64MUdEVF2j9seaIY+4gxHNpWYFoM?=
 =?us-ascii?Q?EOEijluWj1m3UfeILQmcavqLy88SWxvWZ8RObd+e0paGlPZP5f1DMSZWT4s8?=
 =?us-ascii?Q?XiPgZCaHlOyOU5lK7NzD7IrUGgcN29YnAoercsQVu60IOQBEqm/3KWDf2eQC?=
 =?us-ascii?Q?0iqCo3t3firfkIJ8NlinU/7/ip1bb5OKb9OxecxoT/xWM/TcDOwpRFVgCJaZ?=
 =?us-ascii?Q?d8rVfVebcRR0iUIwq06G2KhSsfAzmxoxaqCszXIMgPrWkO21GutXu+rwdUTF?=
 =?us-ascii?Q?O0MOue5wOh+XT334igqIrIdN1pjzUd8qRwYQAphI6w9tRLSNryElNZo/8DLC?=
 =?us-ascii?Q?2zfgsVZwGwzhlKxt4EW1w8t+qMmZntaAo5Kt+GxdqHSoV6eVT+9cZSTfiDyn?=
 =?us-ascii?Q?vy5dGcbHDGMjer3qzC+Flik9TRt5jJxJOydwxT160sh8XCi5sOjLlbqy0c5B?=
 =?us-ascii?Q?os8t0Uet9ep8AOfDJqD6EC9puC6j6yWxeZqA?=
X-Forefront-Antispam-Report:
	CIP:217.111.95.7;CTRY:DE;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:mta.arri.de;PTR:InfoDomainNonexistent;CAT:NONE;SFS:(13230040)(376014)(1800799024)(36860700013)(82310400026);DIR:OUT;SFP:1101;
X-OriginatorOrg: arri.de
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 25 Jun 2025 13:14:47.7915
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: d5696b1e-67e2-44fe-0232-08ddb3ea42aa
X-MS-Exchange-CrossTenant-Id: e6a73a5a-614d-4c51-b3e3-53b660a9433a
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=e6a73a5a-614d-4c51-b3e3-53b660a9433a;Ip=[217.111.95.7];Helo=[mta.arri.de]
X-MS-Exchange-CrossTenant-AuthSource:
	DB1PEPF000509EE.eurprd03.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Anonymous
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DB4PR03MB9482

If the service name we are looking for is already in the cache,
_dbus_name_cache_add_watch() will call the connect_func callback
immediately (before client->service has been assigned). This breaks
service_appeared_callback(), where the service name is required for
making the initial GetManagedObjects call.
---
 ell/dbus-client.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/ell/dbus-client.c b/ell/dbus-client.c
index e29c6fae3288..61f068fe66b1 100644
--- a/ell/dbus-client.c
+++ b/ell/dbus-client.c
@@ -594,17 +594,18 @@ LIB_EXPORT struct l_dbus_client *l_dbus_client_new(struct l_dbus *dbus,
 
 	client->dbus = dbus;
 
+	client->service = l_strdup(service);
 	client->watch = l_dbus_add_service_watch(dbus, service,
 						service_appeared_callback,
 						service_disappeared_callback,
 						client, NULL);
 
 	if (!client->watch) {
+		l_free(client->service);
 		l_free(client);
 		return NULL;
 	}
 
-	client->service = l_strdup(service);
 	client->proxies = l_queue_new();
 
 	return client;
-- 
2.43.0

