Content-Type: multipart/mixed; boundary="===============5090294943379161389=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 1/4] time: Add timespec to microseconds converter
Date: Mon, 02 Mar 2020 13:28:14 -0800
Message-ID: <20200302212817.15524-2-ossama.othman@intel.com>
In-Reply-To: <20200302212817.15524-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5090294943379161389==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Implement a new function, l_timespec_to_usecs(), that checks for
integer overflow in the multiplication and addition operations that
occur during the conversion of the timespec members to microseconds.
---
 ell/ell.sym |  1 +
 ell/time.c  | 24 ++++++++++++++++++++++++
 ell/time.h  |  3 +++
 3 files changed, 28 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index 0c83b87..776a94c 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -526,6 +526,7 @@ global:
 	l_ecdh_generate_key_pair;
 	l_ecdh_generate_shared_secret;
 	/* time */
+	l_timespec_to_usecs;
 	l_time_now;
 	/* gpio */
 	l_gpio_chips_with_line_label;
diff --git a/ell/time.c b/ell/time.c
index 6150d03..becf985 100644
--- a/ell/time.c
+++ b/ell/time.c
@@ -30,6 +30,30 @@
 #include "time.h"
 #include "private.h"
 =

+/**
+ * l_timespec_to_usecs() - convert timespec value to microseconds
+ * @t: pointer to timespec value to be converted to microseconds.
+ *
+ * Convert the timespec value @t to microseconds, being careful to
+ * avoid integer overflows during the conversion.
+ *
+ * Return: Number of microseconds in @t, UINT64_MAX on overflow, and
+ *         zero if @t is NULL.
+ */
+LIB_EXPORT uint64_t l_timespec_to_usecs(const struct timespec *t)
+{
+	if (!t)
+		return 0;
+
+	uint64_t usecs =3D t->tv_sec * L_USEC_PER_SEC;
+
+	/* check overflow */
+	if (usecs / L_USEC_PER_SEC !=3D t->tv_sec)
+		return UINT64_MAX;
+
+	return l_time_offset(usecs, t->tv_nsec / L_NSEC_PER_USEC);
+}
+
 /**
  * l_time_now:
  *
diff --git a/ell/time.h b/ell/time.h
index 6976280..6011b80 100644
--- a/ell/time.h
+++ b/ell/time.h
@@ -38,6 +38,9 @@ extern "C" {
 #define L_NSEC_PER_USEC 1000ULL
 #define L_TIME_INVALID ((uint64_t) -1)
 =

+struct timespec;
+
+uint64_t l_timespec_to_usecs(const struct timespec *t);
 uint64_t l_time_now(void);
 =

 static inline bool l_time_after(uint64_t a, uint64_t b)
-- =

2.20.1

--===============5090294943379161389==--

