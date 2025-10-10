Received: from mail-08.mail-europe.com (mail-08.mail-europe.com [57.129.93.249])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B810D1DD543
	for <ell@lists.linux.dev>; Fri, 10 Oct 2025 09:20:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=57.129.93.249
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1760088030; cv=none; b=j6KydQirln8oEDPDhnauq0UJrdJQFhinWz3fWxP+ed1v9kpkeQfAfsAQgwJTkZteIX7cZ9bxD3WStiaLJ2cDGoyQgMgj2WR+u48uHqh94dCtnf0dpnCfQQLG+7aamJIEMHJmsBR7nw9TIg4VJyYB/QeW/DHPuNlkPwPyz03J+O4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1760088030; c=relaxed/simple;
	bh=mABbYO09gPFnPKobiKPAXUryGbIladzjKJh3xo/1Kgc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=CNyC6Y1k+KinYleOX8rTLvLMu20dAFwoZLilnNhaTRNh1gxb9v/PUxnjY0iKIPzRCmNRpoEGFTJhuR+n282VdS6RXsRm78E20p54hpOZmirG33pJBnjnRCCo519Ku/0WFZP4EOzN9iDBJ3wwjFZU6hLT4R7P+TDNxXJYXe/Kgk8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=geanix.com; spf=pass smtp.mailfrom=geanix.com; dkim=pass (2048-bit key) header.d=geanix.com header.i=@geanix.com header.b=Ql5JBRL7; arc=none smtp.client-ip=57.129.93.249
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=geanix.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=geanix.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=geanix.com header.i=@geanix.com header.b="Ql5JBRL7"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=geanix.com;
	s=protonmail2; t=1760088012; x=1760347212;
	bh=+zULC0x+pUhqgL5q5LIpWme/+6pZ4QWAqG2URCtj5Fs=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:From:To:
	 Cc:Date:Subject:Reply-To:Feedback-ID:Message-ID:BIMI-Selector;
	b=Ql5JBRL78M9o8pc5jBmUQAfiSnwQ4oNspgiYVo2IlXT143XWGyyOdzqliu5PLnHr1
	 FQE7uRXCGanvcV6iXqVZYM3oteHTL9AimHP/MzhZaTWfRJFLhQxMNPiX9IAYjY39wi
	 cL1pteerN0ngjPDnkxOQkLzShypEL8VQP/NDsstn1IXqgRnq8nU9bQuPpCU+SdpLiu
	 24CHkCHce5+Zg3qUFzfRMiwrHJQiBWfwkOsJYngcYx01TNvZoqs0xt22BoEc/rxyG4
	 J5FgbiiUkVdfBiclZaEIuWtX3Ywsr61yj8Xv0Um7p8gosO7SURkLNr+DzdTV5wv2P7
	 LdLjyVEtIACug==
X-Pm-Submission-Id: 4cjh6M4stBz2SgN1
From: =?UTF-8?q?Martin=20Hundeb=C3=B8ll?= <martin@geanix.com>
To: ell@lists.linux.dev
Cc: =?UTF-8?q?Martin=20Hundeb=C3=B8ll?= <martin@geanix.com>
Subject: [PATCH 4/4] unit: test sd-notify functionality
Date: Fri, 10 Oct 2025 11:20:05 +0200
Message-ID: <20251010092005.2283540-4-martin@geanix.com>
X-Mailer: git-send-email 2.51.0
In-Reply-To: <20251010092005.2283540-1-martin@geanix.com>
References: <20251010092005.2283540-1-martin@geanix.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

---
 unit/test-main.c | 70 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 70 insertions(+)

diff --git a/unit/test-main.c b/unit/test-main.c
index 4108d98290c9..8e89a506a993 100644
--- a/unit/test-main.c
+++ b/unit/test-main.c
@@ -14,6 +14,9 @@
 #include <assert.h>
 #include <limits.h>
 #include <signal.h>
+#include <stdlib.h>
+#include <sys/socket.h>
+#include <sys/un.h>
 
 #include <ell/ell.h>
 
@@ -123,11 +126,78 @@ static void test_main(const void *data)
 	assert(l_main_exit());
 }
 
+static int sock_bind(const char *sock)
+{
+	struct sockaddr_un addr;
+	socklen_t len;
+	int fd;
+
+	fd = socket(AF_UNIX, SOCK_DGRAM | SOCK_CLOEXEC | SOCK_NONBLOCK, 0);
+	assert(fd >= 0);
+
+	memset(&addr, 0, sizeof(addr));
+	addr.sun_family = AF_UNIX;
+	strncpy(addr.sun_path, sock, sizeof(addr.sun_path) - 1);
+	len = offsetof(struct sockaddr_un, sun_path) + strlen(sock);
+
+	if (addr.sun_path[0] == '@')
+		addr.sun_path[0] = '\0';
+
+	assert(!bind(fd, (struct sockaddr *) &addr, len));
+
+	return fd;
+}
+
+static void test_sd_notify(const void *data)
+{
+	struct l_timeout *timeout_quit;
+	char sock[] = "/tmp/ell-notify.XXXXXX";
+	bool abstract = L_PTR_TO_INT(data);
+	int exit_status;
+	char buf[4096];
+	int fd;
+
+	/* Create a unique temporary path. */
+	assert(!close(mkstemp(sock)));
+	assert(!unlink(sock));
+
+	if (abstract)
+		sock[0] = '@';
+
+	fd = sock_bind(sock);
+
+	setenv("NOTIFY_SOCKET", sock, 1);
+	setenv("WATCHDOG_USEC", "1000000", 1);
+
+	assert(l_main_init());
+
+	timeout_quit = l_timeout_create(1, timeout_quit_handler, NULL, NULL);
+	assert(timeout_quit);
+
+	exit_status = l_main_run_with_signal(signal_handler, NULL);
+	assert(exit_status == EXIT_SUCCESS);
+
+	assert(l_main_exit());
+
+	assert(recv(fd, buf, sizeof(buf), MSG_TRUNC) == 7);
+	assert(strncmp(buf, "READY=1", 7) == 0);
+
+	assert(recv(fd, buf, sizeof(buf), MSG_TRUNC) == 10);
+	assert(strncmp(buf, "WATCHDOG=1", 10) == 0);
+
+	if (!abstract)
+		unlink(sock);
+
+	close(fd);
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
 
 	l_test_add("main", test_main, NULL);
+	l_test_add("sd_notify path", test_sd_notify, L_INT_TO_PTR(false));
+	l_test_add("sd_notify abstract", test_sd_notify, L_INT_TO_PTR(true));
 
 	return l_test_run();
 }
-- 
2.51.0

