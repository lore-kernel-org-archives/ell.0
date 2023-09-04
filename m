Received: from gimli.kloenk.dev (gimli.kloenk.dev [49.12.72.200])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D78171367
	for <ell@lists.linux.dev>; Mon,  4 Sep 2023 08:06:58 +0000 (UTC)
From: Finn Behrens <me@kloenk.dev>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kloenk.dev; s=mail;
	t=1693814250; bh=z8afUbnq1Nh4OlCedspJ73qaMvn6JfDXbrf77nfAK/c=;
	h=From:To:Cc:Subject:Date;
	b=sOU3hFQXMAIjaUlXHJd1gSUG1WBzWqmw9EuAIMw/iXFc4wdpDC9MsKiOWtfwBmRHq
	 u0VCPLi8TTZgCbZB0NqES52bGsPsA0UaJsNVoVfOVqY78ntmuz2iK+yOmHDDfLf54a
	 4eQD2RHIfk/zdL0LS3iHKUVepiszURehmLVL7Z8Q=
To: ell@lists.linux.dev
Cc: dev@leona.is
Subject: [PATCH] unit: skip sysctl test if sysfs is not available
Date: Mon, 04 Sep 2023 09:57:22 +0200
Message-ID: <526DA75D-01AB-4D85-BF5C-5F25E5C39480@kloenk.dev>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain

Some build environments that build in a mount namespace do not mount
sysfs which makes sysctl and l_sysctl_* fail. Skip the test, if
the file does not exists.
---
 unit/test-sysctl.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/unit/test-sysctl.c b/unit/test-sysctl.c
index 820c707..3985e41 100644
--- a/unit/test-sysctl.c
+++ b/unit/test-sysctl.c
@@ -28,6 +28,7 @@
 #include <assert.h>
 #include <errno.h>
 #include <stdio.h>
+#include <unistd.h>

 #include <ell/ell.h>

@@ -70,9 +71,18 @@ static void test_sysctl_get_set(const void *data)

 int main(int argc, char *argv[])
 {
+	int ret;
 	l_test_init(&argc, &argv);

-	l_test_add("sysctl/get_set", test_sysctl_get_set, NULL);
+	/*
+	* test is failing if /proc/sys/net/core/somaxconn does not exists
+	* this can happen when either net is not compiled, or running in a namespace
+	* where sysfs is not mounted
+	*/
+	ret = access("/proc/sys/net/core/somaxconn", F_OK);
+	if (!ret)
+		l_test_add("sysctl/get_set", test_sysctl_get_set, NULL);
+

 	return l_test_run();
 }
-- 
2.37.0 (Apple Git-136)

