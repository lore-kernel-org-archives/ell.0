Content-Type: multipart/mixed; boundary="===============1518574993799054178=="
MIME-Version: 1.0
From: Michael Johnson <mjohnson459 at gmail.com>
To: ell at lists.01.org
Subject: [PATCH] log: Add a max_log_level and limit l_log
Date: Wed, 18 May 2022 15:58:49 +0100
Message-ID: <20220518145849.127256-1-mjohnson459@gmail.com>

--===============1518574993799054178==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This allows the user of ell to limit the logging verbosity to whatever
value they want by calling l_log_set_max_level. The current behavior of
no limit is maintained.
---
 ell/log.c | 16 ++++++++++++++++
 ell/log.h |  1 +
 2 files changed, 17 insertions(+)

diff --git a/ell/log.c b/ell/log.c
index 05af3e5..89e4ffc 100644
--- a/ell/log.c
+++ b/ell/log.c
@@ -37,6 +37,7 @@
 #include "queue.h"
 #include "log.h"
 #include "private.h"
+#include "useful.h"
 =

 struct debug_section {
 	struct l_debug_desc *start;
@@ -67,6 +68,7 @@ static l_log_func_t log_func =3D log_null;
 static const char *log_ident =3D "";
 static int log_fd =3D -1;
 static unsigned long log_pid;
+static int max_log_level =3D L_LOG_DEBUG;
 =

 static inline void close_log(void)
 {
@@ -275,6 +277,17 @@ LIB_EXPORT void l_log_set_journal(void)
 	log_func =3D log_journal;
 }
 =

+/**
+ * l_log_set_max_level:
+ * @priority: max level
+ *
+ * Set the maximum logging level.
+ */
+LIB_EXPORT void l_log_set_max_level(int priority)
+{
+	max_log_level =3D priority;
+}
+
 /**
  * l_log_with_location:
  * @priority: priority level
@@ -292,6 +305,9 @@ LIB_EXPORT void l_log_with_location(int priority,
 {
 	va_list ap;
 =

+	if (unlikely(priority > max_log_level))
+		return;
+
 	va_start(ap, format);
 	log_func(priority, file, line, func, format, ap);
 	va_end(ap);
diff --git a/ell/log.h b/ell/log.h
index 9ae40c0..3fc3867 100644
--- a/ell/log.h
+++ b/ell/log.h
@@ -44,6 +44,7 @@ void l_log_set_null(void);
 void l_log_set_stderr(void);
 void l_log_set_syslog(void);
 void l_log_set_journal(void);
+void l_log_set_max_level(int priority);
 =

 void l_log_with_location(int priority, const char *file, const char *line,
 				const char *func, const char *format, ...)
-- =

2.25.1

--===============1518574993799054178==--

