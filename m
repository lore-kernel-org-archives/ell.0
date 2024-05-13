Received: from mx0b-003ede02.pphosted.com (mx0b-003ede02.pphosted.com [205.220.181.153])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4B78F39FCF
	for <ell@lists.linux.dev>; Mon, 13 May 2024 17:58:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=205.220.181.153
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1715623130; cv=none; b=DKKsSIu4+XDILJBCA8parhOv7KKgceRi7XsyFI3TTYrEVanABJ8EoKz6SVCibx7uEPUnqp4ZXPZs+gS14VKiC036hbP65ii/Gp0mBHpS0DT3jSG20oiBw4HZ/sRdnU/O/ZpXLyyfJuIJOQNAdGsWwabkPXEkzSzzWn5wKFsLMkU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1715623130; c=relaxed/simple;
	bh=/Ytb5CWyO+4sDV/BEmChYHI4UZBwEkzlOEM31119zvo=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version:Content-Type; b=gm6sg5Z2MfLcrRw6xzcMtmqL9KHcFRrF221SyGMGIDQqFApNNKaT0pOdfQOhePItnL6yTCfrHWmybjLukQy8N/KIiz8ibYpsGfnUjqb4Qn5aeIJnuW+UCo6EAvFhTNKHBCQ8zo8f41fmXbMXqd0DIaA5vXHRodFy5pJuZAmMkD8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=getcruise.com; spf=pass smtp.mailfrom=getcruise.com; dkim=pass (2048-bit key) header.d=getcruise.com header.i=@getcruise.com header.b=Lo2kscwi; dkim=pass (2048-bit key) header.d=getcruise.com header.i=@getcruise.com header.b=hsqnf9u5; arc=none smtp.client-ip=205.220.181.153
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=getcruise.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=getcruise.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=getcruise.com header.i=@getcruise.com header.b="Lo2kscwi";
	dkim=pass (2048-bit key) header.d=getcruise.com header.i=@getcruise.com header.b="hsqnf9u5"
Received: from pps.filterd (m0286618.ppops.net [127.0.0.1])
	by mx0b-003ede02.pphosted.com (8.18.1.2/8.18.1.2) with ESMTP id 44DCkZcn013499
	for <ell@lists.linux.dev>; Mon, 13 May 2024 10:58:41 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=getcruise.com;
	 h=from:to:cc:subject:date:message-id:mime-version:content-type;
	 s=ppemail; bh=CClgv1svnYfL1DCc5vM+p119+1NELJFQ4XcQv/4qSAA=; b=L
	o2kscwiuym59CNm+qVjke20sp6mtx1OhiOL/BfG6zKA/cHFpiK+qGBJcD0u6hr1W
	fFsbYsu8CGb/l8W2nuc05OagnRNlgTXvSvjdFWlOTqAaYEqJHn9FaMeSJJUbmLgF
	NLDxihJHy83n0/revuUgf+G9yKa73YGSZdGyYVDMsEEzvquFdW5R0IxO52pBYJkw
	IF1AtxhWXZsbZiYxpuuNw9mddvzfeyKd1wGsW6Lp7pBVIGVFxyxIPG74UkX2oacB
	Vg35x29/v84u4qauDArLFl/8SbiKjPyy0ybr8yf2XLJcSkhhG3jeyyYle75uO9wE
	6EM25IPdaDi6rhDtT2qiA==
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by mx0b-003ede02.pphosted.com (PPS) with ESMTPS id 3y26cs9524-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <ell@lists.linux.dev>; Mon, 13 May 2024 10:58:41 -0700 (PDT)
Received: by mail-ot1-f71.google.com with SMTP id 46e09a7af769-6f0fdc57a79so1750872a34.0
        for <ell@lists.linux.dev>; Mon, 13 May 2024 10:58:41 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=getcruise.com; s=google; t=1715623120; x=1716227920; darn=lists.linux.dev;
        h=mime-version:message-id:date:subject:cc:to:from:from:to:cc:subject
         :date:message-id:reply-to;
        bh=CClgv1svnYfL1DCc5vM+p119+1NELJFQ4XcQv/4qSAA=;
        b=hsqnf9u5HXEj/yrlK1hnyOgp2eFjdPEC/bVWNUvzFtcX2DjfUYQwmXuINNYNtEm7yx
         VlCA6e5Yd8SrB7ZfYhp5BWuF3aXhfaJe2gYSyMCgWTKIRhTSIo8SfRIJSYtfj3jzZcnh
         wwHek1hYxM3Xh9Ki6dffMVj4zPwSCXNsBddjhdJ70s/aEi5y86L5IOQTCWEKQlnivzXc
         T4cr1NCIG2tSXjMF3JJMvTkyP9V7dlRMyllvDsw9WIoxjMwSqmJvOvavyuilpIK7UmAI
         D1IUmHXFgNs4v/f8aqsZZuZdNCUmJuhqcWMbh9IxF7fSLdHjUSqihb/QfLMIek0S5YFO
         mxqQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1715623120; x=1716227920;
        h=mime-version:message-id:date:subject:cc:to:from:x-gm-message-state
         :from:to:cc:subject:date:message-id:reply-to;
        bh=CClgv1svnYfL1DCc5vM+p119+1NELJFQ4XcQv/4qSAA=;
        b=Ah8tY24XgSeU4M5+zp0TtIx9LgbzfUj2UTUwpiFQgIFTRE5pC1LDn4Cs4JO42VwuIX
         qZecv1B7uZF5fohMgGaFyJOMlCn724PPsUuGqUsVstRYUGn7+Jhfl0oCuwzf/O/viO2N
         LxbnYVlXxWN98DFSFqUoD6UJ1Hm7/LjaGJHEtbBrVKI5GpmtFx15nPrD+qr9ZesUKKWb
         fNwyLumpV/GxSTGQ05N6HraAwtIcEeqLDmPOQRrroIzUDQ8BB6fnUqlhH4Ly4uge45NL
         FsxwO6wS2SBYCkLdDGWNdHkQFcDF5+wP8tYUckbmz7PA22Gm25cpECThCFo/pD1zFkhx
         kQkQ==
X-Gm-Message-State: AOJu0Yyj1TKqEBENsyQ1rI9eYHfWpXF4+qRqH4LxOSkc7S6Hod+4D+g2
	5HBSV3vXml5CwN2rC3KTKbjgtvL0A/H4apgYSNLPTCw34rgyAdXdA2qz9X94npqgLxgxbNT72k1
	pGKES7AbvHcfWTOcAK7OXueLA5j5YztshY30MKy+6v4W4JO7CjFrBycO5QL9XRZIbEzvo/xdG05
	kqDFK3SdeUK3abUCaed4XYupq0gdugqVsBo4hlJK/HpowB3PE=
X-Received: by 2002:a05:6870:d913:b0:22e:935e:7637 with SMTP id 586e51a60fabf-241721b6297mr13158821fac.0.1715623120114;
        Mon, 13 May 2024 10:58:40 -0700 (PDT)
X-Google-Smtp-Source: AGHT+IFWrKbleuppat5xrKzDurwtEhEY2ImOFSM2sRNQpdrHUaXUYmQa0gCF5maur0cGtKmdebnmkw==
X-Received: by 2002:a05:6870:d913:b0:22e:935e:7637 with SMTP id 586e51a60fabf-241721b6297mr13158799fac.0.1715623119646;
        Mon, 13 May 2024 10:58:39 -0700 (PDT)
Received: from BPHKDV2-DT.corp.robot.car ([199.73.127.2])
        by smtp.gmail.com with ESMTPSA id 41be03b00d2f7-6340b76e262sm7031567a12.35.2024.05.13.10.58.38
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 13 May 2024 10:58:39 -0700 (PDT)
From: Ram Subramanian <ram.subramanian@getcruise.com>
To: ell@lists.linux.dev
Cc: Ram Subramanian <ram.subramanian@getcruise.com>,
        Ramon Ribeiro <rhpr@cesar.org.br>
Subject: [PATCH 1/2] dbus: add dbus-over-tcp support
Date: Mon, 13 May 2024 10:58:25 -0700
Message-ID: <20240513175826.2363352-1-ram.subramanian@getcruise.com>
X-Mailer: git-send-email 2.43.2
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
X-Proofpoint-GUID: g4tEMZSNKn-WuvWdPk4sAs7J5nsu3eQD
X-Proofpoint-ORIG-GUID: g4tEMZSNKn-WuvWdPk4sAs7J5nsu3eQD
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1039,Hydra:6.0.650,FMLib:17.11.176.26
 definitions=2024-05-13_12,2024-05-10_02,2023-05-22_02
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 bulkscore=0 adultscore=0
 mlxscore=0 priorityscore=1501 mlxlogscore=999 clxscore=1011 suspectscore=0
 lowpriorityscore=0 malwarescore=0 impostorscore=0 spamscore=0 phishscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.19.0-2405010000
 definitions=main-2405130120

l_dbus_new() will now accept tcp endpoints, however it will only accept
a numeric address for 'host'; it will not resolve hostnames. This is so
we can avoid a potential long, blocking call to getaddrinfo().

The connect() call to the host is also non-blocking. This means that
auth will not happen until you start the event loop (with a call to
l_main_run() et. al.).

Co-authored-by: Ramon Ribeiro <rhpr@cesar.org.br>
---
 ell/dbus.c | 111 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 111 insertions(+)

diff --git a/ell/dbus.c b/ell/dbus.c
index d610532..22deaba 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -15,8 +15,10 @@
 #include <unistd.h>
 #include <stdlib.h>
 #include <string.h>
+#include <sys/types.h>
 #include <sys/socket.h>
 #include <sys/un.h>
+#include <netdb.h>
 #include <errno.h>
 
 #include "util.h"
@@ -1133,6 +1135,112 @@ static struct l_dbus *setup_unix(char *params)
 	return setup_dbus1(fd, guid);
 }
 
+static bool setup_tcp_cb(struct l_io *io, void *user_data)
+{
+	static const unsigned char creds = 0x00;
+	struct l_dbus *dbus = user_data;
+	struct l_dbus_classic *classic;
+	ssize_t written;
+	int fd = l_io_get_fd(io);
+
+	/* Send special credentials-passing nul byte */
+	written = L_TFR(send(fd, &creds, 1, 0));
+	if (written < 1) {
+		l_util_debug(dbus->debug_handler, dbus->debug_handler,
+						"error writing NUL byte");
+		close(fd);
+		return false;
+	}
+
+	dbus->driver = &classic_ops;
+	dbus->negotiate_unix_fd = false;
+	dbus->support_unix_fd = false;
+
+	classic = l_container_of(dbus, struct l_dbus_classic, super);
+	classic->match_strings = l_hashmap_new();
+	classic->auth_command = l_strdup("AUTH ANONYMOUS\r\n");
+	classic->auth_state = WAITING_FOR_OK;
+
+	l_io_set_read_handler(dbus->io, auth_read_handler, dbus, NULL);
+	l_io_set_write_handler(dbus->io, auth_write_handler, dbus, NULL);
+
+	return auth_write_handler(dbus->io, dbus);
+}
+
+static struct l_dbus *setup_tcp(char *params)
+{
+	char *host = NULL;
+	char *port = NULL;
+	char *family = NULL;
+	struct addrinfo hints = { 0 };
+	struct addrinfo *res;
+	struct addrinfo *iter;
+	struct l_dbus *dbus;
+
+	while (params) {
+		char *key = strsep(&params, ",");
+		char *value;
+
+		value = strchr(key, '=');
+		if (!value)
+			continue;
+
+		*value++ = '\0';
+
+		if (!strcmp(key, "host"))
+			host = value;
+		else if (!strcmp(key, "port"))
+			port = value;
+		else if (!strcmp(key, "family"))
+			family = value;
+	}
+
+	if (!host || !port)
+		return NULL;
+
+	if (!family)
+		hints.ai_family = AF_UNSPEC;
+	else if (!strcmp(family, "ipv4"))
+		hints.ai_family = AF_INET;
+	else if (!strcmp(family, "ipv6"))
+		hints.ai_family = AF_INET6;
+	else
+		return NULL;
+
+	hints.ai_socktype = SOCK_STREAM;
+	hints.ai_flags = AI_NUMERICHOST | AI_NUMERICSERV;
+	hints.ai_protocol = IPPROTO_TCP;
+
+	if (getaddrinfo(host, port, &hints, &res) != 0)
+		return NULL;
+
+	for (iter = res; iter; iter = iter->ai_next) {
+		int fd;
+		struct l_dbus_classic *classic;
+
+		fd = socket(iter->ai_family, iter->ai_socktype | SOCK_NONBLOCK,
+					iter->ai_protocol);
+		if (fd < 0)
+			continue;
+
+		if (connect(fd, iter->ai_addr, iter->ai_addrlen) < 0) {
+			if (errno != EINPROGRESS) {
+				close(fd);
+				continue;
+			}
+		}
+
+		classic = l_new(struct l_dbus_classic, 1);
+		dbus = &classic->super;
+		dbus_init(dbus, fd);
+		l_io_set_write_handler(dbus->io, setup_tcp_cb, dbus, NULL);
+		break;
+	}
+
+	freeaddrinfo(res);
+	return dbus;
+}
+
 static struct l_dbus *setup_address(const char *address)
 {
 	struct l_dbus *dbus = NULL;
@@ -1155,6 +1263,9 @@ static struct l_dbus *setup_address(const char *address)
 			/* Function will modify params string */
 			dbus = setup_unix(params);
 			break;
+		} else if (!strcmp(transport, "tcp")) {
+			dbus = setup_tcp(params);
+			break;
 		}
 	}
 
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
