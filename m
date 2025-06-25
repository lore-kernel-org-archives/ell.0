Received: from OSPPR02CU001.outbound.protection.outlook.com (mail-norwayeastazon11013057.outbound.protection.outlook.com [40.107.159.57])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EE3A4262FC1
	for <ell@lists.linux.dev>; Wed, 25 Jun 2025 13:15:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=40.107.159.57
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1750857314; cv=fail; b=FW2TOEdSunTzLKxpCKzNOhltNJsVO0vOaPdw6Vmfp4rFoQfpDWnmIgfpHZExPj7BTFpF/IqXfks0XVeWdanTrDnsJ8IexDqhmOTjojpLPFMQF+fVwHrOQ6OFB6mpNbijamrbuDdLODtkAqEFwSOIbLwtBcJ7szEX65exW8BKkPM=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1750857314; c=relaxed/simple;
	bh=+1ZBi2KZr+n9LWbBc1pcxhtf8qzJj1qp6im4mJDZfzQ=;
	h=From:To:CC:Subject:Date:Message-ID:MIME-Version:Content-Type; b=qXyc6PqwQObJJNH3LOK0OdHGgCx1odnv8ctXTn3LTeuh7uXSZEVr06Il5CyU4M3HfeFKGwphGLxPYYFE3uvhP3Kv4XWgOD1ItaB1nImVw/VGwqnJLY958fWeq9aanRXpXGZxxEzRQjvvrKL7YX26REVQoVPUCv8cfujq6KV8FMY=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=arri.de; spf=pass smtp.mailfrom=arri.de; dkim=pass (1024-bit key) header.d=arri.de header.i=@arri.de header.b=l2FrNgHR; arc=fail smtp.client-ip=40.107.159.57
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=arri.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=arri.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=arri.de header.i=@arri.de header.b="l2FrNgHR"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=q04RQ/9f7bSbNWBn3JiIbY8IF0qxD4PLam5xbLa4kopoQYbHw4v+eXiKtRDEGZcteMgsNYi/yGc9+iCSDzbr6GviBlFhnb6OOrtNEqlXbYPgqtmmD2ivCp7LKC0VtVUvYVjPj1bNldPg8WdVRH1xToCYgY3mJ9WZWlFO6wwh6YaLnkol/9VvgIkwMksxY+LFSepQUpKFgH96GcPG8yz2AZeHBSIhAhoh43m3hxNX0v0xZVNAW8IROvUpy3sylVMXsbMxr2BPIN6Zyb+2TwCJ4jr5RX11/NEUf+kv8Xu5Yb8Otiscom39NCjFjtpw076g5u+bjgeKfpH4YBpKd/hNKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=ZTd0ginG931CMhUt7tdjl2mes76TcSYQHTDF5ZLuSyA=;
 b=kVViGRauOi7FM1xdkpTemy2e13hgziZ3SZeGJjpLFmUJW3WviyJCeY4pZosaCA0VBa6EVmfCYdNc9YugFsSzl/8OVWCNxJ58WCJSJwmtqM2AJcHtf4Y2GZrKj7wHVPHQ89ZqpJZtVOMeOPHZIC90M6K7KI8h5ogqb6PT/5HtaMQqNsJszcbg+Ip8P7kJgxN2u4BQnK+YP5uMTuOCMi9hGPtwCaMiK0UV3z8IgO6Lw4V9tCXxzEFNzqIZ37vinKMJUHRglQyv7WOmG0ftw/1o0z6RVykRpq82vJjLdZOfwmXV3R06boDvS3vEjx2yeNKIJkLic4g+6lAdBe+XK7vZ6A==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=fail (sender ip is
 217.111.95.7) smtp.rcpttodomain=lists.linux.dev smtp.mailfrom=arri.de;
 dmarc=fail (p=none sp=none pct=100) action=none header.from=arri.de;
 dkim=none (message not signed); arc=none (0)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=arri.de; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ZTd0ginG931CMhUt7tdjl2mes76TcSYQHTDF5ZLuSyA=;
 b=l2FrNgHRESZ1C9IUBxJuhi3JtZs8sj1CjyTklDTHnXhipkf6Xgnru4bxMLmbVsiKqYU4V3sezrU08EhX2oIG7cyMg2yRwLaJXPtPD5G9jPTrJILuOSoJGD9bfLoIbKkbaWlKHuXssplaQgEYPmlJtG+76hwYCZRROYds970tySI=
Received: from FR4P281CA0192.DEUP281.PROD.OUTLOOK.COM (2603:10a6:d10:ca::10)
 by DBBPR03MB10485.eurprd03.prod.outlook.com (2603:10a6:10:52a::17) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.8857.28; Wed, 25 Jun
 2025 13:14:47 +0000
Received: from DB1PEPF000509EE.eurprd03.prod.outlook.com
 (2603:10a6:d10:ca:cafe::4a) by FR4P281CA0192.outlook.office365.com
 (2603:10a6:d10:ca::10) with Microsoft SMTP Server (version=TLS1_3,
 cipher=TLS_AES_256_GCM_SHA384) id 15.20.8901.7 via Frontend Transport; Wed,
 25 Jun 2025 13:14:46 +0000
X-MS-Exchange-Authentication-Results: spf=fail (sender IP is 217.111.95.7)
 smtp.mailfrom=arri.de; dkim=none (message not signed)
 header.d=none;dmarc=fail action=none header.from=arri.de;
Received-SPF: Fail (protection.outlook.com: domain of arri.de does not
 designate 217.111.95.7 as permitted sender) receiver=protection.outlook.com;
 client-ip=217.111.95.7; helo=mta.arri.de;
Received: from mta.arri.de (217.111.95.7) by
 DB1PEPF000509EE.mail.protection.outlook.com (10.167.242.72) with Microsoft
 SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.8880.14 via Frontend Transport; Wed, 25 Jun 2025 13:14:45 +0000
Received: from N9W6SW14.arri.de (10.30.5.30) by mta.arri.de (10.10.18.5) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.1258.38; Wed, 25 Jun
 2025 15:14:45 +0200
From: Christian Eggers <ceggers@arri.de>
To: <ell@lists.linux.dev>
CC: Christian Eggers <ceggers@arri.de>
Subject: [PATCH 1/4] dbus-filter: avoid NULL pointer dereference after removing all rules
Date: Wed, 25 Jun 2025 15:14:29 +0200
Message-ID: <20250625131432.19974-1-ceggers@arri.de>
X-Mailer: git-send-email 2.43.0
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
X-MS-TrafficTypeDiagnostic: DB1PEPF000509EE:EE_|DBBPR03MB10485:EE_
X-MS-Office365-Filtering-Correlation-Id: f83776f5-accd-4acc-8c3c-08ddb3ea4168
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|1800799024|36860700013|376014|82310400026;
X-Microsoft-Antispam-Message-Info:
	=?us-ascii?Q?ILlz6E0hFjdOgrjba//5tjkb8xf7gdYUQrWQAkWhEFgxvjp/dd70OcLWnN0X?=
 =?us-ascii?Q?c6iSxedF0ZkwPOvTMFaZrxBUkAOqeMzNYIFJkd+5nXDdyCWKwsgLNjf11lIG?=
 =?us-ascii?Q?tYhc04Lx1qSTEGmKWiRgZUl2Id9N5b5pmemEOec7nY81ptB7dRfzLdFwzqWr?=
 =?us-ascii?Q?JvZJcUqt9L8/CsQBnbYNQdFfb9RQzJ7gwl+AOGpkX1Yg0tfMyZ4R1UZpriAV?=
 =?us-ascii?Q?/ilCIV7eluRvd1qixUnXJnlCod+29LD8bKOYurHG7ClVBV+kejzsZAmYtN+T?=
 =?us-ascii?Q?3b/BksfOtl40g0/YxXD38lEWYaW7l0L1topVHV0qW7uQnm9xZrlIjyNKTwLF?=
 =?us-ascii?Q?YiDMUVn5hYJC6ffAWDJpCDN15xbpWwzDfETofl1JWHu0CRtY3ZZrUrLK2SVc?=
 =?us-ascii?Q?MzGqGiTCnvIWkeNL933o38Uc7Ypv7iDUqTjXvIGCo25kSq0sHh66GWzm+utI?=
 =?us-ascii?Q?sLObtIeu3M0AvAghsoh7pTQLzXPagPi00J9FNCMmtxx8/eWIqY58Yi0rb4OY?=
 =?us-ascii?Q?0JP6iql9XSD1SbG4nGhgHssgpMx18KqnFBI6la1Z8Yp4xZzl6tUL8bRyLR0f?=
 =?us-ascii?Q?a7jlG0brefFgjyctfe4VtejxnysEEUw3jQ6i3rqsL/SYEnXcne/VeVkz7jJ/?=
 =?us-ascii?Q?KuoAdDfyNXk4O1zra4iHjFnLjL1JLHfebRfByF7iqYGJQ/bU5KslQxZeJ5LN?=
 =?us-ascii?Q?bLuUjLbC1yMLqgqBiIyH6T3BZpEZ5ltR3V1vTFhovw+q1Vx/nSyabFMJIR6i?=
 =?us-ascii?Q?6IHOtahLqcaCq0I7FR3PIkdksT76gCr3yU0ntyGJSuMQUkKuvhoS5AlFNHRN?=
 =?us-ascii?Q?2KrMoF/sjmrXiEdxF8OxsPBB3TSspRigEdSX349j6EGhafjwy35XvBMx1bEL?=
 =?us-ascii?Q?Xu3EnFPiXBKDVbIXycLePJ5FRs9/uMLj7AOPBMo42dlVcOtlUunN//GtMxhJ?=
 =?us-ascii?Q?mpwpEMC2GstAcISlhWxikSDt4jLt4VO7DxsxmodzCkUbdOouiX7W9KWrBBXa?=
 =?us-ascii?Q?CeFQL5Fo1DJY9lpTVF23Ltb/Uz8DQofTNFQFokxu0wpdqLR6aB3XOqcT1GgJ?=
 =?us-ascii?Q?Ew9hvis22OJXKRY8YN07ov0+ypQu6DZNn1K8ZF2OnVNdAhqjE+62aHfZp02N?=
 =?us-ascii?Q?4e1D6E5hR5E2p0tyD3ykcEnUJTTKoKHWoNfr7nSvi/FbEheGxwf2F7pj8enx?=
 =?us-ascii?Q?728bSqvK9LBPZfMudcQfjqWu9ufIlnmHzXgejPGZnQv10cMXQhZEq3t/Elk+?=
 =?us-ascii?Q?6Rr+MS95uthE7+G52Ki53cox+mKPuoSx7R20XxT0+3WuWjIVpnRmL2PhsMHN?=
 =?us-ascii?Q?Rz8dlLjucOMjGP5k5j3bDOk1+dVhlmO2xegF4t2ITQUbcmFmjSZKKbiwcsLe?=
 =?us-ascii?Q?0wg7/JCVr9trrq6bqYH8c6v4+DaUVOEkMTmHHZ7A/Zw2CyR9PNF3oUcFvJ6C?=
 =?us-ascii?Q?AwbVxlKdcrOZhl83vgrVly1thGcytBM3LS5LmxPPTNv0Z+VeExrqZ9KQbu9P?=
 =?us-ascii?Q?0UPwCHe39HI8Ju4cqL4hBiUYuUvUzLm9w4So?=
X-Forefront-Antispam-Report:
	CIP:217.111.95.7;CTRY:DE;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:mta.arri.de;PTR:InfoDomainNonexistent;CAT:NONE;SFS:(13230040)(1800799024)(36860700013)(376014)(82310400026);DIR:OUT;SFP:1101;
X-OriginatorOrg: arri.de
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 25 Jun 2025 13:14:45.6822
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: f83776f5-accd-4acc-8c3c-08ddb3ea4168
X-MS-Exchange-CrossTenant-Id: e6a73a5a-614d-4c51-b3e3-53b660a9433a
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=e6a73a5a-614d-4c51-b3e3-53b660a9433a;Ip=[217.111.95.7];Helo=[mta.arri.de]
X-MS-Exchange-CrossTenant-AuthSource:
	DB1PEPF000509EE.eurprd03.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Anonymous
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DBBPR03MB10485

l_dbus_register() is called by _dbus_filter_new() directly before the
first filter rule is added (so filter->root is only transitional NULL).
Later, if all filter rules have been removed, filter->root is
permanently NULL which causes NULL pointer dereference in
_dbus_filter_dispatch() / filter_dispatch_match_recurse().

I get this situation after creating a D-Bus proxy and destroying the
proxy later (so that no filter rules are left, but the D-Bus' filter is
still registered).
---
 ell/dbus-filter.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/ell/dbus-filter.c b/ell/dbus-filter.c
index 7853c2b087a3..91f96718fcd6 100644
--- a/ell/dbus-filter.c
+++ b/ell/dbus-filter.c
@@ -141,7 +141,8 @@ void _dbus_filter_dispatch(struct l_dbus_message *message, void *user_data)
 {
 	struct _dbus_filter *filter = user_data;
 
-	filter_dispatch_match_recurse(filter, filter->root, message);
+	if (filter->root)
+		filter_dispatch_match_recurse(filter, filter->root, message);
 }
 
 struct _dbus_filter *_dbus_filter_new(struct l_dbus *dbus,
-- 
2.43.0

