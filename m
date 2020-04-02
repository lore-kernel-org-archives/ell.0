Content-Type: multipart/mixed; boundary="===============5507760478669252112=="
MIME-Version: 1.0
From: Rosen Penev <rosenp@gmail.com>
Subject: [PATCH 2/4] ell: add missing format attribute
Date: Wed, 01 Apr 2020 20:36:30 -0700
Message-ID: <20200402033632.961701-2-rosenp@gmail.com>
In-Reply-To: <20200402033632.961701-1-rosenp@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5507760478669252112==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Found with clang's -Wformat-nonliteral
---
 ell/dbus.h    | 3 ++-
 ell/hwdb.h    | 3 ++-
 ell/log.c     | 3 +++
 ell/ringbuf.h | 3 ++-
 ell/string.h  | 3 ++-
 ell/strv.h    | 3 ++-
 ell/util.h    | 3 ++-
 7 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/ell/dbus.h b/ell/dbus.h
index cbfb0b0..af01359 100644
--- a/ell/dbus.h
+++ b/ell/dbus.h
@@ -114,7 +114,8 @@ struct l_dbus_message *l_dbus_message_new_method_return(
 struct l_dbus_message *l_dbus_message_new_error_valist(
 					struct l_dbus_message *method_call,
 					const char *name,
-					const char *format, va_list args);
+					const char *format, va_list args)
+					__attribute__((format(printf, 3, 0)));
 struct l_dbus_message *l_dbus_message_new_error(
 					struct l_dbus_message *method_call,
 					const char *name,
diff --git a/ell/hwdb.h b/ell/hwdb.h
index f37dac7..439f316 100644
--- a/ell/hwdb.h
+++ b/ell/hwdb.h
@@ -46,7 +46,8 @@ struct l_hwdb_entry {
 struct l_hwdb_entry *l_hwdb_lookup(struct l_hwdb *hwdb, const char *format=
, ...)
 					__attribute__((format(printf, 2, 3)));
 struct l_hwdb_entry *l_hwdb_lookup_valist(struct l_hwdb *hwdb,
-					const char *format, va_list args);
+					const char *format, va_list args)
+					__attribute__((format(printf, 2, 0)));
 void l_hwdb_lookup_free(struct l_hwdb_entry *entries);
 =

 typedef void (*l_hwdb_foreach_func_t)(const char *modalias,
diff --git a/ell/log.c b/ell/log.c
index f3f4b0c..4e99b57 100644
--- a/ell/log.c
+++ b/ell/log.c
@@ -139,6 +139,7 @@ LIB_EXPORT void l_log_set_null(void)
 	log_func =3D log_null;
 }
 =

+__attribute__((format(printf, 5, 0)))
 static void log_stderr(int priority, const char *file, const char *line,
 			const char *func, const char *format, va_list ap)
 {
@@ -157,6 +158,7 @@ LIB_EXPORT void l_log_set_stderr(void)
 	log_func =3D log_stderr;
 }
 =

+__attribute__((format(printf, 5, 0)))
 static void log_syslog(int priority, const char *file, const char *line,
 			const char *func, const char *format, va_list ap)
 {
@@ -205,6 +207,7 @@ LIB_EXPORT void l_log_set_syslog(void)
 	log_func =3D log_syslog;
 }
 =

+__attribute__((format(printf, 5, 0)))
 static void log_journal(int priority, const char *file, const char *line,
 			const char *func, const char *format, va_list ap)
 {
diff --git a/ell/ringbuf.h b/ell/ringbuf.h
index 44672ad..e9604c8 100644
--- a/ell/ringbuf.h
+++ b/ell/ringbuf.h
@@ -55,7 +55,8 @@ size_t l_ringbuf_avail(struct l_ringbuf *ringbuf);
 int l_ringbuf_printf(struct l_ringbuf *ringbuf, const char *format, ...)
 					__attribute__((format(printf, 2, 3)));
 int l_ringbuf_vprintf(struct l_ringbuf *ringbuf, const char *format,
-					va_list ap);
+					va_list ap)
+					__attribute__((format(printf, 2, 0)));
 ssize_t l_ringbuf_read(struct l_ringbuf *ringbuf, int fd);
 =

 ssize_t l_ringbuf_append(struct l_ringbuf *ringbuf,
diff --git a/ell/string.h b/ell/string.h
index c1948ec..3f47e0d 100644
--- a/ell/string.h
+++ b/ell/string.h
@@ -41,7 +41,8 @@ struct l_string *l_string_append_fixed(struct l_string *d=
est, const char *src,
 					size_t max);
 =

 void l_string_append_vprintf(struct l_string *dest,
-					const char *format, va_list args);
+					const char *format, va_list args)
+					__attribute__((format(printf, 2, 0)));
 void l_string_append_printf(struct l_string *dest, const char *format, ...)
 					__attribute__((format(printf, 2, 3)));
 =

diff --git a/ell/strv.h b/ell/strv.h
index b0ec17c..3582e56 100644
--- a/ell/strv.h
+++ b/ell/strv.h
@@ -40,7 +40,8 @@ char **l_strv_append(char **str_array, const char *str);
 char **l_strv_append_printf(char **str_array, const char *format, ...)
 					__attribute__((format(printf, 2, 3)));
 char **l_strv_append_vprintf(char **str_array, const char *format,
-							va_list args);
+							va_list args)
+					__attribute__((format(printf, 2, 0)));
 char **l_strv_copy(char **str_array);
 =

 #ifdef __cplusplus
diff --git a/ell/util.h b/ell/util.h
index 3b56d5d..6e88505 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -280,7 +280,8 @@ char *l_strdup(const char *str);
 char *l_strndup(const char *str, size_t max);
 char *l_strdup_printf(const char *format, ...)
 			__attribute__((format(printf, 1, 2)));
-char *l_strdup_vprintf(const char *format, va_list args);
+char *l_strdup_vprintf(const char *format, va_list args)
+			__attribute__((format(printf, 1, 0)));
 =

 size_t l_strlcpy(char* dst, const char *src, size_t len);
 =

-- =

2.25.1

--===============5507760478669252112==--

