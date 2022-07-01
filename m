Received: from mail-lf1-f48.google.com (mail-lf1-f48.google.com [209.85.167.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E78BE1C33
	for <ell@lists.linux.dev>; Fri,  1 Jul 2022 13:32:46 +0000 (UTC)
Received: by mail-lf1-f48.google.com with SMTP id y16so3879505lfb.9
        for <ell@lists.linux.dev>; Fri, 01 Jul 2022 06:32:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=FrdumpKgXPp2r6swPM7a1qQnXusW8LjchYX/eWC+yf8=;
        b=7BsOt+gTV/N54lTOZFOvHLkhjHx+/h7BG3RMQ8hUkaURGcdBWpvfgzkVpdzst9Jb0O
         sHNyRG1XvIpMXxl655fX7oECDcW3Fg4WCFF7WaWFs5Ii1MuHpMcRJfbJEfvWsE3gDWCy
         pKPqsRRWzWDyK4b0+aXBwpQqHGJMy/0iB582iHE+630MapwG7tw2kZwtI+wnX94VUhTz
         vixPJHwKmkivytoEOKsg+peCmaEjN5Ot32wRrpvVpntd8iXByP6geW1Hl8JAGmD5OXJY
         l8yW5mLz0bYygB0LCGebQa/mmvmsVZcOioTh3Bb3NCzCWO2JYAgsHlTalEFMEX5o9+rn
         hg7w==
X-Gm-Message-State: AJIora+XutMFhl7a/Mzy9qK7dqUee33UNKa49UML93aev2fq3BZsQYlU
	h1Ngwk+RZ/Qm4BBu+tp7wIYce3382mp1wVS2
X-Google-Smtp-Source: AGRyM1to2GmVQXDryzjRa0jVxX8uwtxLI7cImQonYOSEnkF6BCyBxcawpuK9DWPDzSVr5MrNvnRAWQ==
X-Received: by 2002:a05:6512:3e05:b0:481:2bf2:db06 with SMTP id i5-20020a0565123e0500b004812bf2db06mr8916238lfv.408.1656682364696;
        Fri, 01 Jul 2022 06:32:44 -0700 (PDT)
Received: from iss.home (79.184.238.213.ipv4.supernova.orange.pl. [79.184.238.213])
        by smtp.gmail.com with ESMTPSA id 11-20020a05651c128b00b0025a725af81csm3185815ljc.39.2022.07.01.06.32.43
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 01 Jul 2022 06:32:44 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 2/4] useful: Add a cleanup handler for fd variables
Date: Fri,  1 Jul 2022 15:32:35 +0200
Message-Id: <20220701133237.2887854-2-andrew.zaborowski@intel.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20220701133237.2887854-1-andrew.zaborowski@intel.com>
References: <20220701133237.2887854-1-andrew.zaborowski@intel.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Allow declaring an fd variable with a simple
    _auto_(close) int fd = -1;
to be able to skip the close() call.  This is useful for very simple
file accesses where it's not worth using l_io with
l_io_set_close_on_destroy.

As an example, update netconfig_proc_write_ipv6_setting to use
_auto_(close) where it helps in returning the errno from the read() call
(on error) which would otherwise be clobbered by the close() call.
---
 ell/netconfig.c |  5 ++---
 ell/useful.h    | 14 ++++++++++++++
 2 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/ell/netconfig.c b/ell/netconfig.c
index d4487bd..19aaf56 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -968,7 +968,7 @@ static int netconfig_proc_write_ipv6_setting(struct l_netconfig *nc,
 {
 	char ifname[IF_NAMESIZE];
 	_auto_(l_free) char *filename = NULL;
-	int fd;
+	_auto_(close) int fd = -1;
 	int r;
 
 	if (unlikely(!if_indextoname(nc->ifindex, ifname)))
@@ -982,8 +982,7 @@ static int netconfig_proc_write_ipv6_setting(struct l_netconfig *nc,
 		return -errno;
 
 	r = L_TFR(write(fd, value, strlen(value)));
-	L_TFR(close(fd));
-	return r;
+	return r > 0 ? 0 : -errno;
 }
 
 LIB_EXPORT struct l_netconfig *l_netconfig_new(uint32_t ifindex)
diff --git a/ell/useful.h b/ell/useful.h
index 4c8b23e..791fa20 100644
--- a/ell/useful.h
+++ b/ell/useful.h
@@ -20,6 +20,11 @@
  *
  */
 
+#include <unistd.h>
+#include <errno.h>
+
+#include <ell/util.h>
+
 #define align_len(len, boundary) (((len)+(boundary)-1) & ~((boundary)-1))
 
 #define likely(x)   __builtin_expect(!!(x), 1)
@@ -65,6 +70,15 @@ static inline unsigned char bit_field(const unsigned char oct,
 #define _auto_(func)					\
 	__AUTODESTRUCT(func)
 
+/* Enables declaring _auto_(close) int fd = <-1 or L_TFR(open(...))>; */
+inline __attribute__((always_inline)) void close_cleanup(void *p)
+{
+	int fd = *(int *) p;
+
+	if (fd >= 0)
+		L_TFR(close(fd));
+}
+
 /*
  * Trick the compiler into thinking that var might be changed somehow by
  * the asm
-- 
2.34.1

