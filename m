Received: from mx0a-003ede02.pphosted.com (mx0a-003ede02.pphosted.com [205.220.169.153])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 257DE6AFA1
	for <ell@lists.linux.dev>; Thu, 22 Feb 2024 20:54:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=205.220.169.153
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1708635288; cv=none; b=k2eD08hGgh3/UnfIHDVVu9MdP9EXi0dhrGwS1GVjg8/Zs6plBSJ7N0NUBJvRvKteHNh1tU/OMN9P+k8SZro4lVP5NKUCKshQdda043dsFx2SSwB1jx7b5mZCGE+OLmAliBE4s53dmIIMW+AmyKLViPHIZAarVY8qrfmH+ZV38iQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1708635288; c=relaxed/simple;
	bh=Nng7s6e26440uc0RyUDlYwaBYQPQg0KVHdrGt8mkeLw=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version:Content-Type; b=jsmeOGYfx4qc8EBGdiy9J2GHlNALLArWVbe94As5AAo7SbR0O6hi4GSosRzd3EimYvRp2r1F5jvHRV1Z2YuBRpHs92kKlemjpCHfoH+Wfrfrzv1AO6nocWi/BnA0F285zlmYOvd56iw6y9oO8DFQpVO2Q+WKB2J4ifI81lzB+c4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=getcruise.com; spf=pass smtp.mailfrom=getcruise.com; dkim=pass (2048-bit key) header.d=getcruise.com header.i=@getcruise.com header.b=uabul9W+; dkim=pass (2048-bit key) header.d=getcruise.com header.i=@getcruise.com header.b=NcJ6YKNZ; arc=none smtp.client-ip=205.220.169.153
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=getcruise.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=getcruise.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=getcruise.com header.i=@getcruise.com header.b="uabul9W+";
	dkim=pass (2048-bit key) header.d=getcruise.com header.i=@getcruise.com header.b="NcJ6YKNZ"
Received: from pps.filterd (m0286617.ppops.net [127.0.0.1])
	by mx0b-003ede02.pphosted.com (8.17.1.24/8.17.1.24) with ESMTP id 41MEra6f004838
	for <ell@lists.linux.dev>; Thu, 22 Feb 2024 12:54:46 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=getcruise.com;
	 h=from:to:cc:subject:date:message-id:mime-version:content-type;
	 s=ppemail; bh=DTLyVMGnpWbH0s0b4ytEnVhOP9PEGiXr7/DXogvkixI=; b=u
	abul9W+SZqZIUH76utAuoxejxeexPPGXwA8e0l70bIoQMXQMDK9w9qnG4NrjzjOq
	YOO3pH+atraESt7tgFCFWZarMBg7T0pTcNNfCo8kJjVo/vn0t8Dw5hFeOfuhuYFT
	0bRJNQBCukqC3k9MiDBnj8qnDMfJOO1+sX83/7skcWNaCYqli0l+j8eE0afesIsz
	MijILNTOs+ltEm5f9iPFA//wgQ2bUOMujuMeffsrQUF6nkxqAzt+UAXSuKPatp90
	qxyjPocSDo+QGIpd3Qs2hyggPHQMSYhrCeS4bvO/QRcJJY+V6v5DrCw6nMB3LdCA
	B6F7EkLBqczPiHI8FmP6w==
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by mx0b-003ede02.pphosted.com (PPS) with ESMTPS id 3wd564abgy-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <ell@lists.linux.dev>; Thu, 22 Feb 2024 12:54:45 -0800 (PST)
Received: by mail-qk1-f198.google.com with SMTP id af79cd13be357-787861106aeso13722385a.3
        for <ell@lists.linux.dev>; Thu, 22 Feb 2024 12:54:45 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=getcruise.com; s=google; t=1708635284; x=1709240084; darn=lists.linux.dev;
        h=mime-version:message-id:date:subject:cc:to:from:from:to:cc:subject
         :date:message-id:reply-to;
        bh=DTLyVMGnpWbH0s0b4ytEnVhOP9PEGiXr7/DXogvkixI=;
        b=NcJ6YKNZPNNgylsdyLsOQG/0i1LftGx7xExNRsSO5aUHAe5gadmdow1q+vKBiJSRNe
         XzICaHb5PFSEkhWl2mMGYx/sv09Ej8xOErQ2RMG/U0F3n/X/1qLPL5ZafkLZCmOgkuUJ
         z5mY5zCOAZYjTabCqN3WsbDX0UN4RQnl0xYmW1k48aYqEtZzfJdr6u9efyq/M64QUMIo
         UfSskFWwVMhRo3X7zKSjettL0axChExoHUmE+OG80qJYcOHahHxiZ//0DRre5ikhEY8b
         XdYJUH2tXWQmUL4ypgTeYhXd+QiPYGWoPKzfqk4rvVW2hktDEZ7fBhjUhESXgQNPuK/q
         7A9g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1708635284; x=1709240084;
        h=mime-version:message-id:date:subject:cc:to:from:x-gm-message-state
         :from:to:cc:subject:date:message-id:reply-to;
        bh=DTLyVMGnpWbH0s0b4ytEnVhOP9PEGiXr7/DXogvkixI=;
        b=uO4L3c0fRu4MufC81LdxouBH/nCrs5X/Iw72Juf1orpIUjgnxArwyZHFh/sEqb0GPi
         g/cJtmNJAUsYVhCNbySF7lRY69n/UfbSKWWxHFNF5GJt/rxCQyKudWkE1z+d7XIWed4d
         KInyT6HuoVfHg4MWhpkrKzsl8SxrtwmnB4aVv3TVrTtJbfOCJMDVm08E7t/u9rbBmgd3
         lcjFob7DjdowhzyrknTCyDtE1j7jHAlzU2fQSAGzmU1cbV/sfJ3qc2lV6NwnslITAPkg
         h1NwZVf7G+OKU9CxCxHDZWc+3XlbEN/ulHgkAO4Chd9XcMOCt/Y4xN/bKT4kv9/sKsBQ
         1mJA==
X-Gm-Message-State: AOJu0Yxl3wbX69fLPGDw7PXeKKvgUJNq1yxkZySEpggo89rh+XypMEj3
	5rKlaZSkm7go7XO6JaAiUu1lz0TFw5QR0SU3cq6zSEwUpiw+xH5mEV+z4Fzt4lWxpvN5vgFhcgn
	O4/eCQNVqAWYMqmsC6pRyA4aI+nhJJ7zPQdV+d+R85TFSXiMHQXFHf/yJrwkXQib056F6jyjsLq
	hYS0kZ8rbIUTVBrFBctt18U/L4ce5qbFsmVGxUj7QWAPFy
X-Received: by 2002:a05:620a:271e:b0:787:a7d6:f8f4 with SMTP id b30-20020a05620a271e00b00787a7d6f8f4mr272808qkp.5.1708635284271;
        Thu, 22 Feb 2024 12:54:44 -0800 (PST)
X-Google-Smtp-Source: AGHT+IGkkqIQpbp4q+QwEY8Cw8WheRwlYHxb5RTTad7Oue+xHndbdxuJMr5PnpMLtLaOtvkcGoQrzg==
X-Received: by 2002:a05:620a:271e:b0:787:a7d6:f8f4 with SMTP id b30-20020a05620a271e00b00787a7d6f8f4mr272792qkp.5.1708635283901;
        Thu, 22 Feb 2024 12:54:43 -0800 (PST)
Received: from localhost.localdomain ([140.177.180.84])
        by smtp.gmail.com with ESMTPSA id z4-20020ae9c104000000b007874e64c879sm5451825qki.116.2024.02.22.12.54.43
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 22 Feb 2024 12:54:43 -0800 (PST)
From: Steve Schrock <steve.schrock@getcruise.com>
To: ell@lists.linux.dev
Cc: Steve Schrock <steve.schrock@getcruise.com>
Subject: [PATCH] queue: Fix names of l_queue_match_func_t parameters
Date: Thu, 22 Feb 2024 20:53:27 +0000
Message-Id: <20240222205327.18929-1-steve.schrock@getcruise.com>
X-Mailer: git-send-email 2.40.1
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
X-Proofpoint-GUID: 9XBuxjgO_YnXVC7fo12Tb3VpNl8Mf3-a
X-Proofpoint-ORIG-GUID: 9XBuxjgO_YnXVC7fo12Tb3VpNl8Mf3-a
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.272,Aquarius:18.0.1011,Hydra:6.0.619,FMLib:17.11.176.26
 definitions=2024-02-22_15,2024-02-22_01,2023-05-22_02
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 suspectscore=0 bulkscore=0
 adultscore=0 phishscore=0 malwarescore=0 mlxlogscore=999 spamscore=0
 mlxscore=0 lowpriorityscore=0 priorityscore=1501 impostorscore=0
 clxscore=1011 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.19.0-2402120000 definitions=main-2402220163

---
 ell/queue.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/queue.h b/ell/queue.h
index f595d4d..517298c 100644
--- a/ell/queue.h
+++ b/ell/queue.h
@@ -18,7 +18,7 @@ typedef void (*l_queue_foreach_func_t) (void *data, void *user_data);
 typedef void (*l_queue_destroy_func_t) (void *data);
 typedef int (*l_queue_compare_func_t) (const void *a, const void *b,
 							void *user_data);
-typedef bool (*l_queue_match_func_t) (const void *a, const void *b);
+typedef bool (*l_queue_match_func_t) (const void *data, const void *user_data);
 typedef bool (*l_queue_remove_func_t) (void *data, void *user_data);
 
 struct l_queue;
-- 
2.40.1


-- 


*Confidentiality Note:* We care about protecting our proprietary 
information, confidential material, and trade secrets. This message may 
contain some or all of those things. Cruise will suffer material harm if 
anyone other than the intended recipient disseminates or takes any action 
based on this message. If you have received this message (including any 
attachments) in error, please delete it immediately and notify the sender 
promptly.
