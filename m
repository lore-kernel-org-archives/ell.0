Content-Type: multipart/mixed; boundary="===============1282500404105579489=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 2/4] unit: Add l_timespec_to_usecs() unit test.
Date: Mon, 02 Mar 2020 13:28:15 -0800
Message-ID: <20200302212817.15524-3-ossama.othman@intel.com>
In-Reply-To: <20200302212817.15524-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1282500404105579489==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-time.c | 34 ++++++++++++++++++++++++++++++++++
 1 file changed, 34 insertions(+)

diff --git a/unit/test-time.c b/unit/test-time.c
index 1301891..3c8fd0d 100644
--- a/unit/test-time.c
+++ b/unit/test-time.c
@@ -25,6 +25,7 @@
 #endif
 =

 #include <assert.h>
+#include <limits.h>
 =

 #include <ell/ell.h>
 =

@@ -49,12 +50,45 @@ static void test_offset(const void *data)
 	assert(l_time_offset(max_minus, 1001) =3D=3D UINT64_MAX);
 }
 =

+static void test_timespec_to_usecs(const void *data)
+{
+	static const time_t max_secs =3D
+		sizeof(time_t) =3D=3D 4 ? UINT32_MAX : UINT64_MAX;
+	static const long max_nsecs =3D LONG_MAX;
+
+	static const time_t secs =3D 2000;
+	static const long nsecs =3D 1001;
+
+	/* force integer multiplication overflow */
+	static const struct timespec t_max_secs =3D { .tv_sec  =3D max_secs };
+
+	/* force integer addition overflow */
+	static const struct timespec t_max_nsecs =3D {
+		.tv_sec	 =3D (max_secs / L_USEC_PER_SEC) - 1,
+		.tv_nsec =3D max_nsecs
+	};
+
+	static const struct timespec t =3D {
+		.tv_sec	 =3D secs,
+		.tv_nsec =3D nsecs
+	};
+
+	uint64_t usecs =3D t.tv_sec * L_USEC_PER_SEC +
+		t.tv_nsec / L_NSEC_PER_USEC;
+
+	assert(l_timespec_to_usecs(&t_max_secs) =3D=3D UINT64_MAX);
+	assert(l_timespec_to_usecs(&t_max_nsecs) =3D=3D UINT64_MAX);
+	assert(l_timespec_to_usecs(&t) =3D=3D usecs);
+	assert(l_timespec_to_usecs(NULL) =3D=3D 0);
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
 =

 	l_test_add("Test before/after/diff", test_before_after_diff, NULL);
 	l_test_add("Test offset", test_offset, NULL);
+	l_test_add("Test timespec to usecs", test_timespec_to_usecs, NULL);
 =

 	return l_test_run();
 }
-- =

2.20.1

--===============1282500404105579489==--

