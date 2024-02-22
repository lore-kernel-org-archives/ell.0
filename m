Received: from mx0a-003ede02.pphosted.com (mx0a-003ede02.pphosted.com [205.220.169.153])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8FECCC2E6
	for <ell@lists.linux.dev>; Thu, 22 Feb 2024 00:36:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=205.220.169.153
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1708562169; cv=none; b=VTbNyEjbAzAYv0Tkl5LsdsGHU6lJ+YjgCJNMI6dc5JqYK2aLIrYmflUT+XLH754pyAd8Tf7JMA6/I89AEiYJ9ElCTAWyBZLWksEYptpVfbgUk/ZR3n8hE9uecT+GER9P7dTuhkbbWoampfnXfmrRGoUsneR9GlIX42IvPXjdUBg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1708562169; c=relaxed/simple;
	bh=6wOSXreV3CeMLAccuhbvfU1ihnIlaLh2cqIEt5w004Q=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version:Content-Type; b=KPb8hJsECl8dtHZJhA3B3LEP4jEcxLFyNeReY4tnU7Dm6Lc1RmTqYR7FFcet2n2EccryhM/tGZdvhEaLOM0kY1vYzjSx+zD++Y2nT20eeHSUVg/6qJoxJKD7vOJ9g6HoTOWjjQ4y5I9ljX/KtRiAAX6xYnw48CCUSEXWMDYnJv4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=getcruise.com; spf=pass smtp.mailfrom=getcruise.com; dkim=pass (2048-bit key) header.d=getcruise.com header.i=@getcruise.com header.b=tUK39RDf; dkim=pass (2048-bit key) header.d=getcruise.com header.i=@getcruise.com header.b=BMm1yao2; arc=none smtp.client-ip=205.220.169.153
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=getcruise.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=getcruise.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=getcruise.com header.i=@getcruise.com header.b="tUK39RDf";
	dkim=pass (2048-bit key) header.d=getcruise.com header.i=@getcruise.com header.b="BMm1yao2"
Received: from pps.filterd (m0286617.ppops.net [127.0.0.1])
	by mx0b-003ede02.pphosted.com (8.17.1.24/8.17.1.24) with ESMTP id 41LELZO9009759
	for <ell@lists.linux.dev>; Wed, 21 Feb 2024 16:35:59 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=getcruise.com;
	 h=from:to:cc:subject:date:message-id:mime-version:content-type;
	 s=ppemail; bh=Kdp0DfHYnW7d/x8+r823kWyZGyBuQeKhzXbmSizrh4U=; b=t
	UK39RDf4akQc1KbvTfo6Ba29mb3WF5mMcvtwSD6zxk5kjy5dD96J8FGIFvn6z0rC
	RF6AjPl0RBUJ5pCS4qHxS71L235nh+R8d0yn5G2mMhnhoxAOxMZS9GVwZhCI1rW7
	ZWHyR/pxNOUWvOXhs4XlF0nlbqm0PpqpWPiSb4M7ele4+O61c2OuFxJEJBJhIsFQ
	9TpUcEIBNP9DtHWYaMohNhHBRyKBW8TXkJnhDwCt3CgN8J2AgIHC+B3kDckukUC8
	3FObgLei9NSAKGishhyNVFC55bNiG0eg0lkkKxLW2KZ+HUFDycUehs+Br8Gfqk/6
	8xPBEf926XGlzgljWS+Hg==
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by mx0b-003ede02.pphosted.com (PPS) with ESMTPS id 3wd56497jh-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <ell@lists.linux.dev>; Wed, 21 Feb 2024 16:35:59 -0800 (PST)
Received: by mail-pg1-f197.google.com with SMTP id 41be03b00d2f7-5cfc2041cdfso5120360a12.2
        for <ell@lists.linux.dev>; Wed, 21 Feb 2024 16:35:58 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=getcruise.com; s=google; t=1708562157; x=1709166957; darn=lists.linux.dev;
        h=mime-version:message-id:date:subject:cc:to:from:from:to:cc:subject
         :date:message-id:reply-to;
        bh=Kdp0DfHYnW7d/x8+r823kWyZGyBuQeKhzXbmSizrh4U=;
        b=BMm1yao2ETOSminyvBD0kxUMa2VAqpTsofR4W2kD/JhCNHyXqPT0DM+A4D8gxDvsXM
         FMm/k3dPvaEneXpA1z7fp3sp1YQcLQqU9rq0vMi21l/2b0XN8xDKcNFGr0sOm7EuIvxx
         6QKFyohUVLGN1+x3i3fqB6BqvDhgJ82Z42D81B179JkXzSLXkp253kJ93MB8PbxvwmI/
         2ouB3hMhebmGwCaY1G+RJv+S4jgELSYR7CDbm30scDEDbpIRxEbPGIgKCOiUAVutpe4I
         Dsyb+fenFlwflO4GNNxJMMuX7cLD8bn2U0/ft+hvNnNULsB7NHD42Z6MSZzx16DPKLUu
         J+rA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1708562157; x=1709166957;
        h=mime-version:message-id:date:subject:cc:to:from:x-gm-message-state
         :from:to:cc:subject:date:message-id:reply-to;
        bh=Kdp0DfHYnW7d/x8+r823kWyZGyBuQeKhzXbmSizrh4U=;
        b=HgyRHTHMpxjx6XO2LJawQ9tP1Jx7lQA4t4mOkAq/ZlKJ0b4WBZsTFMEYPWWUTjtSoc
         WpLj+P5w2h5/PdgmUKQuztDCXj+TdVZQyDkEqhaAANWduwIzJF7fU+bdZpnHfJeGmmSl
         EjlxZUDIVZgoVEhKj8yvHpt9hcE3b23RMQthROB4pps82C1kPhyJmjvOXfSv2HEW6P9l
         GEiCV6qJwN2fGjrViAf+HQv5SP4X8H0Vr4Rd3gfht3zDDuOaLYd3Pw01tkvKIvjIqY8y
         m13Dokcs5I2x+7DPl0V16FkvooLV/AmZmcjDMNxdFeOWoBJUf/DGFN+qvcmJGSSeXdv0
         Tn6g==
X-Gm-Message-State: AOJu0Yz1nPiwyAYLKgOdTbAHWADcN4l+6bQW4Y8g/YsnVxYYkaw5CLkb
	JZ/J9CyZ0l+ISOfdKVcG1xGxJhVj+eHzsT1dwti3tCZbPRElaB8MCIhgPG9JE9nG6bM2+Fbenxi
	wb/8gWzd5m7Em40cVFZJSVbX0pboBJgYJHDTYyI7QKXelJWQ9Zp7unNbyUvo0UjoLMK/264AglN
	YPv46uCvK6mZUUDPcvhhQZFAq1VvFCvX4zAaMelXwpe5PUqfs=
X-Received: by 2002:a17:902:c942:b0:1db:d13e:26fb with SMTP id i2-20020a170902c94200b001dbd13e26fbmr14163014pla.5.1708562157553;
        Wed, 21 Feb 2024 16:35:57 -0800 (PST)
X-Google-Smtp-Source: AGHT+IG3p4DXpm+cExrxVsY08q9AH5SYGIRQwxSckjrfdOLB3tGA5W73w4Vml9a4Wi3/ToT6pkQQrg==
X-Received: by 2002:a17:902:c942:b0:1db:d13e:26fb with SMTP id i2-20020a170902c94200b001dbd13e26fbmr14162996pla.5.1708562157158;
        Wed, 21 Feb 2024 16:35:57 -0800 (PST)
Received: from BPHKDV2-DT.corp.robot.car ([199.73.127.2])
        by smtp.gmail.com with ESMTPSA id km14-20020a17090327ce00b001db535f1549sm8633216plb.235.2024.02.21.16.35.56
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 21 Feb 2024 16:35:56 -0800 (PST)
From: Ram Subramanian <ram.subramanian@getcruise.com>
To: ell@lists.linux.dev
Cc: Ram Subramanian <ram.subramanian@getcruise.com>
Subject: [PATCH] pem: fix typo in a conditional in pem_next()
Date: Wed, 21 Feb 2024 16:35:49 -0800
Message-ID: <20240222003549.786095-1-ram.subramanian@getcruise.com>
X-Mailer: git-send-email 2.43.2
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
X-Proofpoint-GUID: l90QUeEXLsXaIeEEl36fwVBRqXffg6a7
X-Proofpoint-ORIG-GUID: l90QUeEXLsXaIeEEl36fwVBRqXffg6a7
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.272,Aquarius:18.0.1011,Hydra:6.0.619,FMLib:17.11.176.26
 definitions=2024-02-21_09,2024-02-21_02,2023-05-22_02
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 suspectscore=0 bulkscore=0
 adultscore=0 phishscore=0 malwarescore=0 mlxlogscore=908 spamscore=0
 mlxscore=0 lowpriorityscore=0 priorityscore=1501 impostorscore=0
 clxscore=1011 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.19.0-2402120000 definitions=main-2402220002

This conditional is supposed to check if there is an extra (whitespace)
character after the ending boundary of the PEM. However, it does not
accomplish that goal as it is written because of a typo.
---
 ell/pem.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/pem.c b/ell/pem.c
index 052e4c6..24e8372 100644
--- a/ell/pem.c
+++ b/ell/pem.c
@@ -148,7 +148,7 @@ const char *pem_next(const void *buf, size_t buf_len, char **type_label,
 				*base64_len = buf_ptr - base64_data;
 
 			if (endp) {
-				if (eol == buf + buf_len)
+				if (eol == buf_ptr + buf_len)
 					*endp = eol;
 				else
 					*endp = eol + 1;
-- 
2.43.2


-- 


*Confidentiality Note:* We care about protecting our proprietary 
information, confidential material, and trade secrets. This message may 
contain some or all of those things. Cruise will suffer material harm if 
anyone other than the intended recipient disseminates or takes any action 
based on this message. If you have received this message (including any 
attachments) in error, please delete it immediately and notify the sender 
promptly.
