Received: from AS8PR03CU001.outbound.protection.outlook.com (mail-westeuropeazon11012067.outbound.protection.outlook.com [52.101.71.67])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 25C69261595
	for <ell@lists.linux.dev>; Wed, 25 Jun 2025 13:14:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=fail smtp.client-ip=52.101.71.67
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1750857297; cv=fail; b=EdIP48VZ/RyvencgwAy4+VAYjR+83Z2cJeCJLLW0UWfg4ua3QhE5JI9ihRoUz1IrHVqOOUGnFC9OwK+Q+uU19Ftb+hL6VZciGJMs8lCTGtZFEKmMEsf5dGOqP2Hg6JgGVXSAEgKTCrGKBB44QxsT7qkEdQZ5qL9p64MIl9TJBSk=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1750857297; c=relaxed/simple;
	bh=y/uyM+Ul2Xo+sNcBI7Wt8z6gCwbWywWfIiefJOU0KII=;
	h=From:To:CC:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=P7avpYh1av6DUAPn6zxaPkwpNMXTuFXHq7eIyTi64ZCzSRor717dHQc7QuPOSmCGmaHUy78ta+6uoz/essGAFeIauJLpl7CLmpxqltYE/aOre/CN2rLhAoV0l4PCfPpwkEJJZ4BdYHtzLxQoFl9tvNNPyPVjZhsErZOoOCOp358=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=arri.de; spf=pass smtp.mailfrom=arri.de; dkim=pass (1024-bit key) header.d=arri.de header.i=@arri.de header.b=s/ndC2Ie; arc=fail smtp.client-ip=52.101.71.67
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=arri.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=arri.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=arri.de header.i=@arri.de header.b="s/ndC2Ie"
ARC-Seal: i=1; a=rsa-sha256; s=arcselector10001; d=microsoft.com; cv=none;
 b=bg0iRxl8G96RziTNj/Fe810aXLlyqEhPVgDm4yPnvmZyFU14vYEtvKHFyzc7h/m/h/492iZxzzeP/8dV0LIqGaB6wdmNego5mk5shSvCy4OoAtOAigtWwNw93FGHBmjebE/1gBJN4hIOJcCMFtfhCEC8gRTUZ5eqQz+lRvxZlMb3Hdy8eCtEnUOWgJbmeMWPNA7y4et55ETsia0t1jYgTbVREnzqK8tfjXY/rVYmIC4dHBFr3qIG27Uy0BxQ23vv/AiCAvXVixcxqZG6WBm39NMzlUGJW2E1KJm6vcpK8SoAnRt/c4np1PfoqqcixVYzkNGkUihXfxOYtX06FnSwig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector10001;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-AntiSpam-MessageData-ChunkCount:X-MS-Exchange-AntiSpam-MessageData-0:X-MS-Exchange-AntiSpam-MessageData-1;
 bh=Usy7oQu44C1O9FETskuSOyKqq/VXzVVwZgs+17ypTHI=;
 b=TZmIxKw67wNl4eB1ntzX2YJoQLw0RESex1TcBZECQtivyFrtJpHBge679/3rEXqJHpaiqqbftdHIpsVdG13/mgMiPG1myxA7thgPy/LZK+kKL7OdHsqOaOEbBX0WdWgZQTvLooj2NoakVKh0AfQVKsEYeXRea1LQuP+WLG2QkkiPql1Rabfy3KEGhQuEy/d+KWC1DzLF9bIfhiV56C5jMbd0kTjw2DID3LcoSB6p0KKr8TkZExwADV0mNwspPomFduQhGlm21nRx30rBfn24aqNVGNx+a6rCErTYBNSkjz6g27DWrCLx8V6K5Lq5AK9/rqd+5BHRdT6HUkOw3Eem1Q==
ARC-Authentication-Results: i=1; mx.microsoft.com 1; spf=fail (sender ip is
 217.111.95.7) smtp.rcpttodomain=lists.linux.dev smtp.mailfrom=arri.de;
 dmarc=fail (p=none sp=none pct=100) action=none header.from=arri.de;
 dkim=none (message not signed); arc=none (0)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=arri.de; s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Usy7oQu44C1O9FETskuSOyKqq/VXzVVwZgs+17ypTHI=;
 b=s/ndC2IeKJlVnL8nPBWcJiL5AFmt6VaTVdxC6tq0Dtds4DN5WcG+TFVoEKIat2oYa7MBbNAPyIjVWM1EltIv6Ptr9GqM9Co3SWWKpLVdPxlvQZO6X5QMkL2bYjwpEMpnBUYNYZVscszHWZggi/jfs+ApYhr3TZ/VueVntyX9S1I=
Received: from FR4P281CA0186.DEUP281.PROD.OUTLOOK.COM (2603:10a6:d10:ca::16)
 by PAVPR03MB9019.eurprd03.prod.outlook.com (2603:10a6:102:321::19) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.20.8857.29; Wed, 25 Jun
 2025 13:14:50 +0000
Received: from DB1PEPF000509EE.eurprd03.prod.outlook.com
 (2603:10a6:d10:ca:cafe::df) by FR4P281CA0186.outlook.office365.com
 (2603:10a6:d10:ca::16) with Microsoft SMTP Server (version=TLS1_3,
 cipher=TLS_AES_256_GCM_SHA384) id 15.20.8880.16 via Frontend Transport; Wed,
 25 Jun 2025 13:14:50 +0000
X-MS-Exchange-Authentication-Results: spf=fail (sender IP is 217.111.95.7)
 smtp.mailfrom=arri.de; dkim=none (message not signed)
 header.d=none;dmarc=fail action=none header.from=arri.de;
Received-SPF: Fail (protection.outlook.com: domain of arri.de does not
 designate 217.111.95.7 as permitted sender) receiver=protection.outlook.com;
 client-ip=217.111.95.7; helo=mta.arri.de;
Received: from mta.arri.de (217.111.95.7) by
 DB1PEPF000509EE.mail.protection.outlook.com (10.167.242.72) with Microsoft
 SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.8880.14 via Frontend Transport; Wed, 25 Jun 2025 13:14:50 +0000
Received: from N9W6SW14.arri.de (10.30.5.30) by mta.arri.de (10.10.18.5) with
 Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.1258.38; Wed, 25 Jun
 2025 15:14:45 +0200
From: Christian Eggers <ceggers@arri.de>
To: <ell@lists.linux.dev>
CC: Christian Eggers <ceggers@arri.de>
Subject: [PATCH 3/4] dbus-client: fix removal of client watch
Date: Wed, 25 Jun 2025 15:14:31 +0200
Message-ID: <20250625131432.19974-3-ceggers@arri.de>
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
X-MS-TrafficTypeDiagnostic: DB1PEPF000509EE:EE_|PAVPR03MB9019:EE_
X-MS-Office365-Filtering-Correlation-Id: d841425c-9308-4fc5-5889-08ddb3ea4423
X-MS-Exchange-SenderADCheck: 1
X-MS-Exchange-AntiSpam-Relay: 0
X-Microsoft-Antispam:
	BCL:0;ARA:13230040|1800799024|82310400026|36860700013|376014;
X-Microsoft-Antispam-Message-Info:
	=?us-ascii?Q?VO9pIacgzj8H/xBnnEyofzcjw5CKraxMYgeMcHyOQuwAiZGykER/zu+y22Ve?=
 =?us-ascii?Q?5QLYp1u7Hwd6o7hwoBQNk9nsAhh7kEuOPEMXWlhwwgDcfcXKSg4O01NMWemm?=
 =?us-ascii?Q?VN+jHz0F/izjEBwjdgKk2f6YcVpxoAurmCBGnLSaUCX2GtaiSu2Fe0BuFSsN?=
 =?us-ascii?Q?y0GVdk1fMa9MQs86MCJVZWXyheAENx5BSNzQOmu8D9l1A/zj2XColRY7s1i9?=
 =?us-ascii?Q?f1PbTABKIjTFJ+zmIpqCqYV9NL4+miDMdrG0dRy25PgBxnLDn3BgoG9l15Hn?=
 =?us-ascii?Q?3EkctyBvspZ7Hv/TVXqT5s2CZ3HDdRkG8uVMuYR6ymEs9y+elcN/pVpvGXs6?=
 =?us-ascii?Q?Mq+Qo7nYn6Ke8xBiXrSbndJVAuHhK6qixmNgeNk9jQNdlUTHjg78NbJCexiY?=
 =?us-ascii?Q?CgxNYUVMia7vdPLAIxfcuGL9DJn6kD5WesQ51kFv8tQoX6m7/xae1SP8xMvj?=
 =?us-ascii?Q?sd8n2DtExc60PhcnzVHFvv5KJKpwJCv6F2CBSZb1ISiQ5TS1k56Zse8snsuW?=
 =?us-ascii?Q?+pZAFa+2Fy2iaI/27cvZdnYG6owxw+rTJawEidZVCOy/hH0HwyxDqDf9QCz5?=
 =?us-ascii?Q?s/OuwHuXSm6f/o0aaUxUI8bIKDkg1QqB3XAkO3LLeC55zcqj0yxT1LFJXa8l?=
 =?us-ascii?Q?HAYtCpcl92edbjYGjRq+UuiKxxz3/Rvb3EATE5+DWWbGMo6vsb4Isqhg7X8t?=
 =?us-ascii?Q?GTw8zGTZ42DcDj7fNBvmtlohdmoBn33dd2WpaqQ08PD2t/IakN1O7bt1kdpN?=
 =?us-ascii?Q?4c4gKJr7X2CKDnAL+iAqqGOdZN/n4zzBuS+G8p1l0UErtwfPCeqCCncGLzDp?=
 =?us-ascii?Q?cL9n1yMwBalgVNqODpUNNNKctuuViGFYyDa13COuATJqKq7w9fNV8VXdx/y0?=
 =?us-ascii?Q?HJkIdCG1eJ3Ts0eHARC9B4nTyU1E0do1AldKNTEuRbEGe72jkXXykfcYcooz?=
 =?us-ascii?Q?h1VN8JZRhwctP/fWL7MvsApSWYmaH0QyqFY/yGS78Y7i93ZV7tcNmMe3jCgn?=
 =?us-ascii?Q?u1+60/IfAe/4e/IJBQMGmsfvrGHPtAY/su3mZ5QWF/J/kDqGWetYK5bPoISg?=
 =?us-ascii?Q?KdB3brUwD8k9V8lrRBsFQk1sLRhNK/ntbWkXedrE7jXCjkA30GvJ788XtH85?=
 =?us-ascii?Q?VcJdTohWdiC4Up11upri/Aj0KvChZID8r2z41OanSaktRfBY1A+4+nXupd21?=
 =?us-ascii?Q?1NrzohmL/QHPDJYwKYajuZlxXJNqL8ZNvAbNldDm1nPACh+adv43rvOlRV1n?=
 =?us-ascii?Q?HhJbileQNdrmmLsv3kqRiwDtkwWpXIexuDKztVOS9UF9q5ltpD65/cEuEgx6?=
 =?us-ascii?Q?enJi5ewfPFDurhejGvGT4hOKtTbTvtqdUijNVmvFQ8i74tsPmsFkha9C5uc0?=
 =?us-ascii?Q?+2NhrM+FnSk+XOB8tM31T0k+C6rfmm//1gNwy4wDH4MRyYmP1CMrUJXOgNXN?=
 =?us-ascii?Q?FVE457nc6uuQVNCQ6zQlETzKnQkXRQDgRd08vP8MDfjx8KVDMZaeVvKZfric?=
 =?us-ascii?Q?qWqAAo10EOAOuHakihkts9MpMLqjXwfJaN6j?=
X-Forefront-Antispam-Report:
	CIP:217.111.95.7;CTRY:DE;LANG:en;SCL:1;SRV:;IPV:NLI;SFV:NSPM;H:mta.arri.de;PTR:InfoDomainNonexistent;CAT:NONE;SFS:(13230040)(1800799024)(82310400026)(36860700013)(376014);DIR:OUT;SFP:1101;
X-OriginatorOrg: arri.de
X-MS-Exchange-CrossTenant-OriginalArrivalTime: 25 Jun 2025 13:14:50.2604
 (UTC)
X-MS-Exchange-CrossTenant-Network-Message-Id: d841425c-9308-4fc5-5889-08ddb3ea4423
X-MS-Exchange-CrossTenant-Id: e6a73a5a-614d-4c51-b3e3-53b660a9433a
X-MS-Exchange-CrossTenant-OriginalAttributedTenantConnectingIp: TenantId=e6a73a5a-614d-4c51-b3e3-53b660a9433a;Ip=[217.111.95.7];Helo=[mta.arri.de]
X-MS-Exchange-CrossTenant-AuthSource:
	DB1PEPF000509EE.eurprd03.prod.outlook.com
X-MS-Exchange-CrossTenant-AuthAs: Anonymous
X-MS-Exchange-CrossTenant-FromEntityHeader: HybridOnPrem
X-MS-Exchange-Transport-CrossTenantHeadersStamped: PAVPR03MB9019

The client watch is of type 'service watch' (rather than 'signal
watch'). Use the correct remove function, otherwise the watch is
actually not removed.
---
 ell/dbus-client.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/dbus-client.c b/ell/dbus-client.c
index 61f068fe66b1..c191c732ffa3 100644
--- a/ell/dbus-client.c
+++ b/ell/dbus-client.c
@@ -617,7 +617,7 @@ LIB_EXPORT void l_dbus_client_destroy(struct l_dbus_client *client)
 		return;
 
 	if (client->watch)
-		l_dbus_remove_signal_watch(client->dbus, client->watch);
+		l_dbus_remove_watch(client->dbus, client->watch);
 
 	if (client->added_watch)
 		l_dbus_remove_signal_watch(client->dbus, client->added_watch);
-- 
2.43.0

