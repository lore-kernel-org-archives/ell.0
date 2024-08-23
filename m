Received: from mail-oo1-f49.google.com (mail-oo1-f49.google.com [209.85.161.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DD8DC191477
	for <ell@lists.linux.dev>; Fri, 23 Aug 2024 16:15:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.49
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1724429761; cv=none; b=Kgys5rZ1RKGvGAt84DgqQEZkBuBPdaNlpTLaZrmmO17AyZ8ttcHriiJv/a56xjIb2RBYIVQmCJ0i8YWXlMTqrV/SSv7sw9IbvaeHoQSVU1AHDDRPey0YAW6PP51cVKR51S3JaJMvNlQJG15Nfje2mT+jIiOp6ciJRJcflHZx2TI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1724429761; c=relaxed/simple;
	bh=7kqYP2QTb/vILsf7TDrEhKFkBFqpUyHLVlGdxwFFlgo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=t594B+F/NJK1G5W0fD87OQ+FvqjdwU5MrvKLr/uq1jVQd7gcRxKFjljg3soVEYnl3+UdmbpB6shtAD2mQEfl7awjCS28DELLm2OGMPnk01cs/4K8IX7CGkAfbRG1aifMYCB/SkO0+myAHI5+Dp2ugmRcIHf2IFPfrufV8uY6Ep0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=cMUNXj05; arc=none smtp.client-ip=209.85.161.49
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cMUNXj05"
Received: by mail-oo1-f49.google.com with SMTP id 006d021491bc7-5dca9cc71b2so1520567eaf.2
        for <ell@lists.linux.dev>; Fri, 23 Aug 2024 09:15:59 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1724429759; x=1725034559; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=W37T93nQYjVhwPsq2wKL7gb2Ey+ez8DgaYMWL7GgPUA=;
        b=cMUNXj05JQLljo4Yrh3h53zTVSO0qd73N0xydLZdaDpfDQ/O8vb+VqrhAg6M/v9qFE
         1LmvPXr5v4mjLigYxqbAdZ8+AVIXlHHHjU7jnt+CfdYbLB4rzU17ZEHL/bqZTGVXPhtl
         j544xgxnAlr9jwBdmG3RJeHQFSA/bZaQ8QBdT8BJwddWj6O/dpXCOFZ4k460dZhmqFBo
         CZ33yikpu6DBQWBJCJB4C0LP2VvYXiLBc/IMhry0ZO8/3cR2Ejh+6b6fbh3QwJ8ppa1Z
         rjdkORteSsZnrB2bv6DVKAyWpW6jI9TPvay4HoA0MUMRCVVvrPcVaI49KmUyUKO2DXvr
         bEiw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1724429759; x=1725034559;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=W37T93nQYjVhwPsq2wKL7gb2Ey+ez8DgaYMWL7GgPUA=;
        b=MP6Rxno7f8tcPbI4KhtEw6Y1cmnJjpMU/9aJfjZUjQLLJh3aIJmHOtEIRjwgcPgZcR
         EHCTlnvhia/VeHwfN/Wih5FFRkcJ+5L4qFnAgeVcDmXN7gknGWDHMBW226q8OZ71py5X
         s8CvufMo0rvp8MFb1hEMtZWc3xRZcztg2iaDRlpmavDTBnLbK03/CUg4gLW5zs/2BTIm
         rVmv6suILR4gz4kps5TyVfq5h9BGFc1GtHYPj/f8DNlpTjAdU6YrZ8gCyQYIVnnqq82b
         b/CiBJBjDq6DCs84NJWBb5Js1RwNE5PLaFUwdaWsFyQ5cRWd9GGrwxGF37qFgMTlcZHs
         9EGA==
X-Gm-Message-State: AOJu0YxThfHbQWBFhOQAYP7+7bHOYXi9m1gWMeP+cN6Tfn1aPQccdkEL
	/nxCujEl6DgDElnUqGnwSbx72grE6fHhPG4TTvGKvCLg0kLsLhaaKsOG3Q==
X-Google-Smtp-Source: AGHT+IGvygxjyJwYhwtyp1mg4dM8UYwSlPy2Qr5yPz7DYLhUsC/t1Dab8Ad1cAv57ig4nztikjTotQ==
X-Received: by 2002:a05:6820:1b93:b0:5da:9204:6733 with SMTP id 006d021491bc7-5dcc6214954mr2858204eaf.3.1724429758920;
        Fri, 23 Aug 2024 09:15:58 -0700 (PDT)
Received: from archdev.attlocal.net (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-5dcb5de7c83sm750222eaf.14.2024.08.23.09.15.58
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 23 Aug 2024 09:15:58 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 6/6] rtnl: Add l_rtnl_link_set_mtu
Date: Fri, 23 Aug 2024 11:15:50 -0500
Message-ID: <20240823161553.479576-6-denkenz@gmail.com>
X-Mailer: git-send-email 2.45.2
In-Reply-To: <20240823161553.479576-1-denkenz@gmail.com>
References: <20240823161553.479576-1-denkenz@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

This helper is used to set a given MTU on a network interface (link).
---
 ell/ell.sym |  1 +
 ell/rtnl.c  | 18 ++++++++++++++++++
 ell/rtnl.h  |  4 ++++
 3 files changed, 23 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index cbeb61ff0f46..00123136a527 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -701,6 +701,7 @@ global:
 	l_rtnl_set_linkmode_and_operstate;
 	l_rtnl_set_mac;
 	l_rtnl_set_powered;
+	l_rtnl_link_set_mtu;
 	l_rtnl_ifaddr4_extract;
 	l_rtnl_ifaddr4_dump;
 	l_rtnl_ifaddr4_add;
diff --git a/ell/rtnl.c b/ell/rtnl.c
index da5d219feb48..fbad795949be 100644
--- a/ell/rtnl.c
+++ b/ell/rtnl.c
@@ -787,6 +787,24 @@ LIB_EXPORT uint32_t l_rtnl_set_powered(struct l_netlink *rtnl, int ifindex,
 	return l_netlink_send(rtnl, nlm, cb, user_data, destroy);
 }
 
+LIB_EXPORT uint32_t l_rtnl_link_set_mtu(struct l_netlink *rtnl, int ifindex,
+				uint32_t mtu,
+				l_netlink_command_func_t cb, void *user_data,
+				l_netlink_destroy_func_t destroy)
+{
+	struct l_netlink_message *nlm = l_netlink_message_new(RTM_SETLINK, 0);
+	struct ifinfomsg ifi;
+
+	memset(&ifi, 0, sizeof(ifi));
+	ifi.ifi_family = AF_UNSPEC;
+	ifi.ifi_index = ifindex;
+
+	l_netlink_message_add_header(nlm, &ifi, sizeof(ifi));
+	l_netlink_message_append_u32(nlm, IFLA_MTU, mtu);
+
+	return l_netlink_send(rtnl, nlm, cb, user_data, destroy);
+}
+
 LIB_EXPORT void l_rtnl_ifaddr4_extract(const struct ifaddrmsg *ifa, int bytes,
 				char **label, char **ip, char **broadcast)
 {
diff --git a/ell/rtnl.h b/ell/rtnl.h
index fa5d99eb4b53..d44cda24d6fd 100644
--- a/ell/rtnl.h
+++ b/ell/rtnl.h
@@ -103,6 +103,10 @@ uint32_t l_rtnl_set_powered(struct l_netlink *rtnl, int ifindex, bool powered,
 				l_netlink_command_func_t cb, void *user_data,
 				l_netlink_destroy_func_t destroy);
 
+uint32_t l_rtnl_link_set_mtu(struct l_netlink *rtnl, int ifindex, uint32_t mtu,
+				l_netlink_command_func_t cb, void *user_data,
+				l_netlink_destroy_func_t destroy);
+
 void l_rtnl_ifaddr4_extract(const struct ifaddrmsg *ifa, int bytes,
 				char **label, char **ip, char **broadcast);
 uint32_t l_rtnl_ifaddr4_dump(struct l_netlink *rtnl, l_netlink_command_func_t cb,
-- 
2.45.2

