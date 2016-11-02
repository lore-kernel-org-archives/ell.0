Content-Type: multipart/mixed; boundary="===============5415289200192586402=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 5/5] unit: Add millisecond timeout overflow check
Date: Wed, 02 Nov 2016 14:50:48 -0700
Message-ID: <20161102215048.19166-5-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20161102215048.19166-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5415289200192586402==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-main.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/unit/test-main.c b/unit/test-main.c
index bd68599..48cb16a 100644
--- a/unit/test-main.c
+++ b/unit/test-main.c
@@ -26,6 +26,8 @@
 =

 #include <ell/ell.h>
 #include <unistd.h>
+#include <assert.h>
+#include <limits.h>
 =

 static void signal_handler(struct l_signal *signal, uint32_t signo,
 							void *user_data)
@@ -116,6 +118,12 @@ int main(int argc, char *argv[])
 =

 	l_debug("hello");
 =

+#if (ULONG_MAX > UINT_MAX)
+	l_debug("Checking timeout time limit");
+	assert(!l_timeout_create_ms((UINT_MAX + 1UL) * 1000,
+					timeout_quit_handler, NULL, NULL));
+#endif
+
 	l_idle_oneshot(oneshot_handler, NULL, NULL);
 =

 	l_main_run();
-- =

2.10.2


--===============5415289200192586402==--

