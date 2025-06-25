Received: from MRWPR03CU001.outbound.protection.outlook.com (mail-francesouthazon11011071.outbound.protection.outlook.com [40.107.130.71])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B1F3F2620CB
	for <ell@lists.linux.dev>; Wed, 25 Jun 2025 13:15:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=40.107.130.71
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1750857318; cv=fail; b=qFcaqMEty/TE9WmOa2VveIlnHfLlvKO9ZMuk3SXDEP4mYkDaN+cmR9jcya1AyawjXcN+/QMGOwJOJD7a59Cta54+8lwHlpqq2W7uOEzH+h7Re3VQEeFJPJup7fIXSsktluviAPvhl1ptmfyY4s9+VKHbnBtJ3ZFeAMWGnB+O0yc=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1750857318; c=relaxed/simple;
	bh=wbPucUY0w9n+avySl3M3iCwYWUcJ/JshkuaeF3zrlAM=;
	h=From:To:CC:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=AWLyiYM9ppfIXTtV5uaetv6uCb2Hj4rYi39Jno5bRKqR50sZHx8Y7ik92hj31IS8vRA7FI48U6AdMmfE5V3ZJXahw3zCF0zNMyFzp40iEezvOADgbvz8a2SBFTBlG5/p8xRfYFQ04lvGzyjT+rK4BHvmtaPCNERmyLJCmN+Jk28=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=arri.de; spf=pass smtp.mailfrom=arri.de; dkim=pass (1024-bit key) header.d=arri.de header.i=@arri.de header.b=QXSvqqXB; arc=fail smtp.client-ip=40.107.130.71
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=arri.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=arri.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=arri.de header.i=@arri.de header.b="QXSvqqXB"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=krNGAaMCJ9vig95yLA8L3wLBhxpYJv3T7K59IX6ancMEuofTFqFViXqs7IV9UWlH62UGhwpXSlK9Bi6ROCTsxdK1/y08+N0iJYHhkVpe5pQNDNmF1wRIk07M9y/tEwMC+krbiaZ3AylMl752smuVTo4Ic+zwRNJqKr3AOKsFzpXQ5wxCsYHvC/kbRbSyyej40jjLEVNz1TJIYmniY9f0jKhCqD97Dd+WNOPmPHGq4bxxzKEpD5bpPSv8v8AjJs5qL4RNDxs/Wc3pIwjtEWcaoOaDIW439kSi/uEdJZ7jkl+8+Qkv4xydFw9Mw17BZ+6++PzUHi6ipoL7q5mFN5gXGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=tkuaZAXnS9Hi6bWPanLexO8L+ZV43Ie+CKKgCuL6Y+Q=;
 b=iNi8AYhHrVz7F1IT9dg7MfIl2aSvJE+duP8BjaS3ruD5cH8+mYHd34nIP+pB5XLDyADyZFmDkpBovARHXqCVJi18nRmAwm9hWoiOrlA9kLBa9XU7CDBZ8j77hZuQarNVLbrvOboXpgqC4Lnu3qTazWDeWWOTdHB67qJu3Y3QLe3r/HWRtOuVQM9ld6zQbdYuE5cKIYW8AyZqqEkwSdw7U4fX7Ox8gON8I/I72Hh9Lfzp7odfqiesJzyDw8gHKOBpZEBd2EZw/tfWlxRA9Ilbvcu6yNnCWA9pflLTdix3uVTj4riQDgaabsZQPD7mPv0RG3/qavCll+1hDXSYhNrI5A==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=fail (sender ip is
 217.111.95.7) smtp.rcpttodomain=lists.linux.dev smtp.mailfrom=arri.de;
 dmarc=fail (p=none sp=none pct=100) action=none header.from=arri.de;
 dkim=none (message not signed); arc=none (0)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=arri.de; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=tkuaZAXnS9Hi6bWPanLexO8L+ZV43Ie+CKKgCuL6Y+Q=;
 b=QXSvqqXBO930AnshQNRZui+hQq00TL7ZCnZLXLxW4PGPyfzp6XA1URKI5l2oi5nrMLvAUc4kPwfNRRwY8+C/yryNDLl6VwLWMeIg+/MT7vEkpkBe9kfrB5dOaFNd8HphCEBMUX2tM+cVCOELuuuWV/awU+bIuLFpi+l+q5SYl9U=
Received: from DU2PR04CA0238.eurprd04.prod.outlook.com (2603:10a6:10:2b1::33)
 by PAXPR03MB8167.eurprd03.prod.outlook.com (2603:10a6:102:2bb::11) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.8857.28; Wed, 25 Jun
 2025 13:15:11 +0000
Received: from DB1PEPF000509EC.eurprd03.prod.outlook.com
 (2603:10a6:10:2b1:cafe::aa) by DU2PR04CA0238.outlook.office365.com
 (2603:10a6:10:2b1::33) with Microsoft SMTP Server (version=TLS1_3,
 cipher=TLS_AES_256_GCM_SHA384) id 15.20.8857.30 via Frontend Transport; Wed,
 25 Jun 2025 13:15:11 +0000
X-MS-Exchange-Authentication-Results: spf=fail (sender IP is 217.111.95.7)
 smtp.mailfrom=arri.de; dkim=none (message not signed)
 header.d=none;dmarc=fail action=none header.from=arri.de;
Received-SPF: Fail (protection.outlook.com: domain of arri.de does not
 designate 217.111.95.7 as permitted sender) receiver=protection.outlook.com;
 client-ip=217.111.95.7; helo=mta.arri.de;
Received: from mta.arri.de (217.111.95.7) by
 DB1PEPF000509EC.mail.protection.outlook.com (10.167.242.70) with Microsoft
 SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.8880.14 via Frontend Transport; Wed, 25 Jun 2025 13:15:10 +0000
Received: from N9W6SW14.arri.de (10.30.5.30) by mta.arri.de (10.10.18.5) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.1258.38; Wed, 25 Jun
 2025 15:15:10 +0200
From: Christian Eggers <ceggers@arri.de>
To: <ell@lists.linux.dev>
CC: Christian Eggers <ceggers@arri.de>
Subject: [PATCH 4/4] util: remove invalid 'const' qualification
Date: Wed, 25 Jun 2025 15:14:32 +0200
Message-ID: <20250625131432.19974-4-ceggers@arri.de>
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
X-MS-TrafficTypeDiagnostic: DB1PEPF000509EC:EE_|PAXPR03MB8167:EE_
X-MS-Office365-Filtering-Correlation-Id: 3ecdba53-56ad-484f-0d28-08ddb3ea5083
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|36860700013|1800799024|82310400026|376014;
X-Microsoft-Antispam-Message-Info:
	=?us-ascii?Q?PNe6MZ4nnIhLmZVYW3kC5IhvdYby9zc8eQ7iwIcpmrvig+bIh5JZSwHi/O/N?=
 =?us-ascii?Q?Awv1yWy0Pg1Tt0eoYJNxcV+RnWlcVKvDYymSsAnbvCnSFkOq6c6KTmlg/ew5?=
 =?us-ascii?Q?qYlEztgw9LvdhWixea/WeBssICzBLJd0aDlID9ui5dJX+iH2r8vDyh0cJBv1?=
 =?us-ascii?Q?/Jvo7pgcfjKYgzHflVcKpwVva1c42SthVoaw2CsiOHXawC8WtQBASfuF5TOA?=
 =?us-ascii?Q?aNcCQyC5ez+2QBoJV+nDhoZrDMw8mdA3x+cbXnh0hnZNshbvixTnkvBQPS5c?=
 =?us-ascii?Q?8vpJTbo3S4LWJJDNaCGzmGhYAwJ+2I+cyBX6Wm9LmsfkMxe/Sa6T+/khYRyO?=
 =?us-ascii?Q?bOni1bUC7iIalqmJGDSIYCNqC0gA39ZrFPq0Q5Sq1Ny7xT/H8f4hgFrd94vZ?=
 =?us-ascii?Q?Tx15uWUEntMLAkr5KUPU0NyiscvKJvGF6ZD6mmtTD6XSJ3q6h10J1BDiQb1m?=
 =?us-ascii?Q?5idnQ0NTgueJmVSJ1AgxFIjTayo3u1gQPSk2rNMD1YQh5x5zK3o/+0ro0EZR?=
 =?us-ascii?Q?P3bzXqK6ivHTZxJlw1YmjgKBxEIhSllwRpkSNDdNZXL1IVGNdZ3ZdlnGnIY0?=
 =?us-ascii?Q?HlVDVgICFG7IZEkyGApHodcUzaFriHC86o15E/eXJkLgi3X8cdhaBZWLkBEb?=
 =?us-ascii?Q?I5qQZGQLZ8VkmuPB7YintR8kCNAjfFBWEs1g//NjKsi73qsK5JrCZ3XXRoll?=
 =?us-ascii?Q?VpR4qcwWXjMzD6WdK4l0lWj2sgdVshc0zvG4aiR2nBEFP1/47XCX8M5HXXAr?=
 =?us-ascii?Q?SwmBSZ7o/BgTUIldw6G3Yl+H7dStgh83RjAUzgBntM0XPHWUokc4DM08bwQS?=
 =?us-ascii?Q?wsZAAqjIIOE4UPJBog4AoLuAtQs5z6YXA6bOIGiDq1F8sG2N3l2UZiLaC1ia?=
 =?us-ascii?Q?F9BCyNnDf394H5qK7Jp0corsa6PljslM7EALPAwnE6C25Ib7rLRlBkmWKQ66?=
 =?us-ascii?Q?efQONKkG99j8iKVS+eIpZj02kfLheeo7teYeH9Zks1OAUMC24KOkRCg8naqh?=
 =?us-ascii?Q?UohsM4iEFyK0jrHtdNyFHJbumqyBCojv7dBUGe6zenoFk7eQ0vnrFTN0br1c?=
 =?us-ascii?Q?i5IdKBr3ha4axB1MCsgruLtseZhQKM0WBqeOPDVDBvH7TaUGYrDbrkQ8Y+no?=
 =?us-ascii?Q?LfOMPWuEA6YgLPacYK291CVMyntKACGn/HdTDLM3naIys/UwaGNlIbHY9H+Y?=
 =?us-ascii?Q?NBvD0uP1Za0THh0C9cYjENQkIjiqFILuWZWB+Z4TjeBXo5EBhGEZAxItpSE/?=
 =?us-ascii?Q?NyPmbozg4AhqT2b0/QS16uu6z4XfodmOwkkMREErE1469nmi/GUTQOcNwizr?=
 =?us-ascii?Q?5rRwUxNE96ybFptAhjom7Ib2nBvu23Kxf0GA3K2rgVXSj6a33hmY9jirc3u7?=
 =?us-ascii?Q?581ohjjE+oaoPo83IgwjeFRTW3oMEPTQRlXJtGz9N2e5EwbGtVR9lyo+Ig3q?=
 =?us-ascii?Q?Kk5jwQliiu+ny3EOP7VZcsi+wwzPOafJRZBUZWcm1jUeC1k7E5wmsXSRMMqO?=
 =?us-ascii?Q?KVUyudlR4SVCV9ik4x1gTbionuZhXkgBs1V8?=
X-Forefront-Antispam-Report:
	CIP:217.111.95.7;CTRY:DE;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:mta.arri.de;PTR:InfoDomainNonexistent;CAT:NONE;SFS:(13230040)(36860700013)(1800799024)(82310400026)(376014);DIR:OUT;SFP:1101;
X-OriginatorOrg: arri.de
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 25 Jun 2025 13:15:10.9407
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: 3ecdba53-56ad-484f-0d28-08ddb3ea5083
X-MS-Exchange-CrossTenant-Id: e6a73a5a-614d-4c51-b3e3-53b660a9433a
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=e6a73a5a-614d-4c51-b3e3-53b660a9433a;Ip=[217.111.95.7];Helo=[mta.arri.de]
X-MS-Exchange-CrossTenant-AuthSource:
	DB1PEPF000509EC.eurprd03.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Anonymous
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: PAXPR03MB8167

l_put_be16() actually modifies the provided memory area
---
 ell/util.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/util.h b/ell/util.h
index 939391964ca1..da0741d2cbba 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -210,7 +210,7 @@ static inline void l_put_le16(uint16_t val, void *ptr)
 	L_PUT_UNALIGNED(L_CPU_TO_LE16(val), (uint16_t *) ptr);
 }
 
-static inline void l_put_be16(uint16_t val, const void *ptr)
+static inline void l_put_be16(uint16_t val, void *ptr)
 {
 	L_PUT_UNALIGNED(L_CPU_TO_BE16(val), (uint16_t *) ptr);
 }
-- 
2.43.0

