Received: from fx.arvanta.net (static-213-198-238-194.adsl.eunet.rs [213.198.238.194])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 3CE807E
	for <ell@lists.linux.dev>; Mon,  6 Jun 2022 20:11:17 +0000 (UTC)
Received: from m1.arvanta.net (kcl.arvanta.net [10.5.1.8])
	by fx.arvanta.net (Postfix) with ESMTP id 0F771237A3;
	Mon,  6 Jun 2022 22:05:16 +0200 (CEST)
From: =?UTF-8?q?Milan=20P=2E=20Stani=C4=87?= <mps@arvanta.net>
To: ell@lists.linux.dev
Cc: =?UTF-8?q?Milan=20P=2E=20Stani=C4=87?= <mps@arvanta.net>
Subject: [PATCH] build: fix time.h related breakage on musl
Date: Mon,  6 Jun 2022 22:05:39 +0200
Message-Id: <20220606200539.28575-1-mps@arvanta.net>
X-Mailer: git-send-email 2.36.1
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

missing time.h for struct timeval usage
forward declaration of struct timeval in time-private.h
---
 ell/dhcp-transport.c  | 1 +
 ell/dhcp6-transport.c | 1 +
 ell/icmp6.c           | 1 +
 ell/time-private.h    | 2 +-
 ell/time.c            | 1 +
 5 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/ell/dhcp-transport.c b/ell/dhcp-transport.c
index ef030de..c4cf0ca 100644
--- a/ell/dhcp-transport.c
+++ b/ell/dhcp-transport.c
@@ -40,6 +40,7 @@
 #include <linux/filter.h>
 #include <net/if_arp.h>
 #include <errno.h>
+#include <sys/time.h>
 
 #include "io.h"
 #include "util.h"
diff --git a/ell/dhcp6-transport.c b/ell/dhcp6-transport.c
index 30c425f..5ff6516 100644
--- a/ell/dhcp6-transport.c
+++ b/ell/dhcp6-transport.c
@@ -35,6 +35,7 @@
 #include <net/if.h>
 #include <unistd.h>
 #include <errno.h>
+#include <sys/time.h>
 
 #include "private.h"
 #include "missing.h"
diff --git a/ell/icmp6.c b/ell/icmp6.c
index 368977f..7319903 100644
--- a/ell/icmp6.c
+++ b/ell/icmp6.c
@@ -36,6 +36,7 @@
 #include <net/if.h>
 #include <unistd.h>
 #include <errno.h>
+#include <sys/time.h>
 
 #include "private.h"
 #include "useful.h"
diff --git a/ell/time-private.h b/ell/time-private.h
index 5295d94..83c23dd 100644
--- a/ell/time-private.h
+++ b/ell/time-private.h
@@ -19,7 +19,7 @@
  *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
  *
  */
-
+struct timeval;
 uint64_t _time_pick_interval_secs(uint32_t min_secs, uint32_t max_secs);
 uint64_t _time_fuzz_msecs(uint64_t ms);
 uint64_t _time_fuzz_secs(uint32_t secs, uint32_t max_offset);
diff --git a/ell/time.c b/ell/time.c
index 10e10b0..41e5725 100644
--- a/ell/time.c
+++ b/ell/time.c
@@ -26,6 +26,7 @@
 
 #define _GNU_SOURCE
 #include <time.h>
+#include <sys/time.h>
 
 #include "time.h"
 #include "time-private.h"
-- 
2.36.1

