Content-Type: multipart/mixed; boundary="===============3008217857486033774=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 1/5] ell: Use __typeof__ instead of typeof in headers.
Date: Mon, 29 Oct 2018 13:07:11 -0700
Message-ID: <20181029200715.28427-2-ossama.othman@intel.com>
In-Reply-To: <20181029200715.28427-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3008217857486033774==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The typeof keyword is disabled by gcc when compiling with the -ansi or
-std command line options.  Use __typeof__ instead.  This is
particularly important for headers exposed to users that contain uses
of typeof.
---
 ell/private.h | 2 +-
 ell/util.h    | 8 ++++----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/ell/private.h b/ell/private.h
index a77f677..f132577 100644
--- a/ell/private.h
+++ b/ell/private.h
@@ -28,7 +28,7 @@
 #define uninitialized_var(x) x =3D x
 =

 #define container_of(ptr, type, member) ({			\
-	const typeof( ((type *)0)->member ) *__mptr =3D (ptr);	\
+	const __typeof__( ((type *)0)->member ) *__mptr =3D (ptr);	\
 	(type *)( (char *)__mptr - offsetof(type,member) );})
 =

 #define align_len(len, boundary) (((len)+(boundary)-1) & ~((boundary)-1))
diff --git a/ell/util.h b/ell/util.h
index 5021300..381721f 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -59,16 +59,16 @@ extern "C" {
 #define L_GET_UNALIGNED(ptr) __extension__	\
 ({						\
 	struct __attribute__((packed)) {	\
-		typeof(*(ptr)) __v;		\
-	} *__p =3D (typeof(__p)) (ptr);		\
+            __typeof__(*(ptr)) __v;		\
+	} *__p =3D (__typeof__(__p)) (ptr);	\
 	__p->__v;				\
 })
 =

 #define L_PUT_UNALIGNED(val, ptr)		\
 do {						\
 	struct __attribute__((packed)) {	\
-		typeof(*(ptr)) __v;		\
-	} *__p =3D (typeof(__p)) (ptr);		\
+		__typeof__(*(ptr)) __v;		\
+	} *__p =3D (__typeof__(__p)) (ptr);	\
 	__p->__v =3D (val);			\
 } while(0)
 =

-- =

2.17.1


--===============3008217857486033774==--

