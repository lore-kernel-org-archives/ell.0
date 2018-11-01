Content-Type: multipart/mixed; boundary="===============7954277303532296335=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 02/11] Add format string checking to a few declarations
Date: Thu, 01 Nov 2018 12:54:44 +0100
Message-ID: <20181101115453.10373-2-andrew.zaborowski@intel.com>
In-Reply-To: <20181101115453.10373-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7954277303532296335==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add the gcc attribute(format(printf)) to function declarations where
this may be useful.
---
 ell/dbus.h   | 3 ++-
 ell/string.h | 3 ++-
 ell/util.h   | 6 ++++--
 3 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/ell/dbus.h b/ell/dbus.h
index a7c08d2..d3af5d7 100644
--- a/ell/dbus.h
+++ b/ell/dbus.h
@@ -118,7 +118,8 @@ struct l_dbus_message *l_dbus_message_new_error_valist(
 struct l_dbus_message *l_dbus_message_new_error(
 					struct l_dbus_message *method_call,
 					const char *name,
-					const char *format, ...);
+					const char *format, ...)
+					__attribute__((format(printf, 3, 4)));
 =

 struct l_dbus_message *l_dbus_message_ref(struct l_dbus_message *message);
 void l_dbus_message_unref(struct l_dbus_message *message);
diff --git a/ell/string.h b/ell/string.h
index c947c14..c1948ec 100644
--- a/ell/string.h
+++ b/ell/string.h
@@ -42,7 +42,8 @@ struct l_string *l_string_append_fixed(struct l_string *d=
est, const char *src,
 =

 void l_string_append_vprintf(struct l_string *dest,
 					const char *format, va_list args);
-void l_string_append_printf(struct l_string *dest, const char *format, ...=
);
+void l_string_append_printf(struct l_string *dest, const char *format, ...)
+					__attribute__((format(printf, 2, 3)));
 =

 struct l_string *l_string_truncate(struct l_string *string, size_t new_siz=
e);
 =

diff --git a/ell/util.h b/ell/util.h
index 381721f..9fd775e 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -258,7 +258,8 @@ static inline void auto_free(void *a)
 =

 char *l_strdup(const char *str);
 char *l_strndup(const char *str, size_t max);
-char *l_strdup_printf(const char *format, ...);
+char *l_strdup_printf(const char *format, ...)
+			__attribute__((format(printf, 1, 2)));
 char *l_strdup_vprintf(const char *format, va_list args);
 =

 size_t l_strlcpy(char* dst, const char *src, size_t len);
@@ -280,7 +281,8 @@ void l_util_hexdumpv(bool in, const struct iovec *iov, =
size_t n_iov,
 					l_util_hexdump_func_t function,
 					void *user_data);
 void l_util_debug(l_util_hexdump_func_t function, void *user_data,
-						const char *format, ...);
+						const char *format, ...)
+			__attribute__((format(printf, 3, 4)));
 =

 const char *l_util_get_debugfs_path(void);
 =

-- =

2.19.1


--===============7954277303532296335==--

