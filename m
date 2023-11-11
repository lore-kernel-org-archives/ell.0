Received: from mail.holtmann.org (coyote.holtmann.net [212.227.132.17])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id D6E531BDFC
	for <ell@lists.linux.dev>; Sat, 11 Nov 2023 18:07:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; dkim=none
Received: from fedora.. (p4fefc822.dip0.t-ipconnect.de [79.239.200.34])
	by mail.holtmann.org (Postfix) with ESMTPSA id 8D24FCED03
	for <ell@lists.linux.dev>; Sat, 11 Nov 2023 19:07:56 +0100 (CET)
From: Marcel Holtmann <marcel@holtmann.org>
To: ell@lists.linux.dev
Subject: [RFC PATCH 2/2] rtnl: Check if RTA_EXPIRES enum value is available
Date: Sat, 11 Nov 2023 19:07:53 +0100
Message-ID: <20231111180753.51488-2-marcel@holtmann.org>
X-Mailer: git-send-email 2.41.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Work around the missing RTA_EXPIRES settings of really really old
kernels and disable setting that attribute if the enum value is not
present.
---
 acinclude.m4 | 15 +++++++++++++++
 configure.ac |  2 ++
 ell/rtnl.c   |  4 ++++
 3 files changed, 21 insertions(+)

diff --git a/acinclude.m4 b/acinclude.m4
index 6fb1de565a1d..3bb7b51d9ee6 100644
--- a/acinclude.m4
+++ b/acinclude.m4
@@ -75,3 +75,18 @@ AC_DEFUN([COMPILER_FLAGS], [
 		CFLAGS+=" -Wno-unknown-pragmas"
 	fi
 ])
+
+AC_DEFUN([TEST_RTNL], [
+	AC_MSG_CHECKING([for RTA_EXPIRES])
+	AC_LANG_PUSH([C])
+	ac_rtnl_save_CFLAGS="$CFLAGS"
+	CFLAGS=""
+	AC_COMPILE_IFELSE([
+		AC_LANG_PROGRAM([#include <linux/rtnetlink.h>],
+			[enum rtattr_type_t t = RTA_EXPIRES;])],
+		AC_DEFINE(HAVE_RTA_EXPIRES, 1,
+			[Define to 1 if you have the RTA_EXPIRES enum value.])
+		AC_MSG_RESULT([yes]), AC_MSG_RESULT([no]))
+	CFLAGS=$ac_rtnl_save_CFLAGS
+	AC_LANG_POP([C])
+])
diff --git a/configure.ac b/configure.ac
index cf3b53cfb574..44084bc4384b 100644
--- a/configure.ac
+++ b/configure.ac
@@ -111,6 +111,8 @@ AC_CHECK_FUNC(epoll_create, dummy=yes,
 
 AC_CHECK_HEADERS(linux/types.h linux/if_alg.h)
 
+TEST_RTNL
+
 AC_ARG_ENABLE(glib, AS_HELP_STRING([--enable-glib],
 				[enable ell/glib main loop example]),
 					[enable_glib=${enableval}])
diff --git a/ell/rtnl.c b/ell/rtnl.c
index ad2dca2f9e3c..5b392eae3fb3 100644
--- a/ell/rtnl.c
+++ b/ell/rtnl.c
@@ -1348,7 +1348,9 @@ static uint32_t _rtnl_route_change(struct l_netlink *rtnl,
 	size_t bufsize;
 	void *rta_buf;
 	uint16_t flags;
+#ifdef HAVE_RTA_EXPIRES
 	uint64_t now = l_time_now();
+#endif
 
 	bufsize = NLMSG_ALIGN(sizeof(struct rtmsg)) +
 			RTA_SPACE(sizeof(uint32_t)) +        /* RTA_OIF */
@@ -1404,9 +1406,11 @@ static uint32_t _rtnl_route_change(struct l_netlink *rtnl,
 	if (rt->preference)
 		rta_buf += rta_add_u8(rta_buf, RTA_PREF, rt->preference);
 
+#ifdef HAVE_RTA_EXPIRES
 	if (rt->expiry_time > now)
 		rta_buf += rta_add_u32(rta_buf, RTA_EXPIRES,
 					l_time_to_secs(rt->expiry_time - now));
+#endif
 
 	return l_netlink_send(rtnl, nlmsg_type, flags, rtmmsg,
 				rta_buf - (void *) rtmmsg, cb, user_data,
-- 
2.41.0

