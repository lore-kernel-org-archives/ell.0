Received: from gregdf.com (gregdf.com [152.228.171.180])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9CB047F
	for <ell@lists.linux.dev>; Sun,  8 May 2022 00:00:23 +0000 (UTC)
Received: from localhost.localdomain (unknown [37.167.202.147])
	by gregdf.com (Postfix) with ESMTPSA id A910D796F3C;
	Sun,  8 May 2022 01:49:29 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gregdf.com; s=mail;
	t=1651967370; bh=8mX4dgoR696QuxGx3YYhXhk6x7C/d7sbAi6Ruz/96Ms=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=ICzokZ0iQGXvr4TCZyHAE9OdkMkhKE35wgDJkXVHZ5QwvKRthUEzFUi78ZPIXgpDQ
	 +KpG0JnqoD83OMy4XzW+dwss+aM+F2Hcva0ExXNyKFeOWFQH6olRHWFeGBSeCF9M0P
	 9RUDmG1JL+rfTiru9l6CtJKO06fmmBVplWh48GNs=
From: Greg Depoire--Ferrer <greg@gregdf.com>
To: ell@lists.linux.dev
Cc: Greg Depoire--Ferrer <greg@gregdf.com>
Subject: [PATCH 1/3] main: Accept FD 0 as epoll_fd
Date: Sun,  8 May 2022 01:54:32 +0200
Message-Id: <20220507235434.11693-2-greg@gregdf.com>
X-Mailer: git-send-email 2.35.1
In-Reply-To: <20220507235434.11693-1-greg@gregdf.com>
References: <20220507235434.11693-1-greg@gregdf.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

When create_epoll was called and the file descriptor 0 was not open, the
kernel would return it as the epoll FD, but ell would consider it as an
error because it used the value 0 in epoll_fd to signify failure.

Use -1 instead of 0 to signify error to fix the issue.
---
 ell/main.c | 16 +++++++---------
 1 file changed, 7 insertions(+), 9 deletions(-)

diff --git a/ell/main.c b/ell/main.c
index 1a6cd60..6f9a074 100644
--- a/ell/main.c
+++ b/ell/main.c
@@ -61,7 +61,7 @@
 
 #define WATCHDOG_TRIGGER_FREQ	2
 
-static int epoll_fd;
+static int epoll_fd = -1;
 static bool epoll_running;
 static bool epoll_terminate;
 static int idle_id;
@@ -99,10 +99,8 @@ static inline bool __attribute__ ((always_inline)) create_epoll(void)
 	unsigned int i;
 
 	epoll_fd = epoll_create1(EPOLL_CLOEXEC);
-	if (epoll_fd < 0) {
-		epoll_fd = 0;
+	if (epoll_fd < 0)
 		return false;
-	}
 
 	watch_list = malloc(DEFAULT_WATCH_ENTRIES * sizeof(void *));
 	if (!watch_list)
@@ -121,7 +119,7 @@ static inline bool __attribute__ ((always_inline)) create_epoll(void)
 
 close_epoll:
 	close(epoll_fd);
-	epoll_fd = 0;
+	epoll_fd = -1;
 
 	return false;
 }
@@ -136,7 +134,7 @@ int watch_add(int fd, uint32_t events, watch_event_cb_t callback,
 	if (unlikely(fd < 0 || !callback))
 		return -EINVAL;
 
-	if (!epoll_fd)
+	if (epoll_fd < 0)
 		return -EIO;
 
 	if ((unsigned int) fd > watch_entries - 1)
@@ -284,7 +282,7 @@ int idle_add(idle_event_cb_t callback, void *user_data, uint32_t flags,
 	if (unlikely(!callback))
 		return -EINVAL;
 
-	if (!epoll_fd)
+	if (epoll_fd < 0)
 		return -EIO;
 
 	data = l_new(struct idle_data, 1);
@@ -509,7 +507,7 @@ LIB_EXPORT int l_main_run(void)
 	int timeout;
 
 	/* Has l_main_init() been called? */
-	if (unlikely(!epoll_fd))
+	if (unlikely(epoll_fd < 0))
 		return EXIT_FAILURE;
 
 	if (unlikely(epoll_running))
@@ -577,7 +575,7 @@ LIB_EXPORT bool l_main_exit(void)
 	idle_list = NULL;
 
 	close(epoll_fd);
-	epoll_fd = 0;
+	epoll_fd = -1;
 
 	return true;
 }
-- 
2.35.1

