Content-Type: multipart/mixed; boundary="===============4381958899395427244=="
MIME-Version: 1.0
From: =?unknown-8bit?q?Micha=C5=82?= 'Khorne' Lowas-Rzechonek <michal.lowas-rzechonek@silvair.com>
Subject: [PATCH] util: Added l_container_of macro
Date: Tue, 02 Apr 2019 09:36:54 +0200
Message-ID: <20190402073654.28012-1-michal.lowas-rzechonek@silvair.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4381958899395427244==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

From: Micha=C5=82 Lowas-Rzechonek <michal.lowas-rzechonek@silvair.com>

The macro is useful when e.g. scheduling timeouts, where l_timeout
passed to l_timeout_notify_cb_t is a member of a larger object, and we
would like to access this object while passing something else as
user_data.
---
 ell/util.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/ell/util.h b/ell/util.h
index c4ba7f8..95503de 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -35,6 +35,11 @@
 extern "C" {
 #endif
 =

+#define l_container_of(ptr, type, member) ({					\
+		const typeof( ((type *)0)->member ) *__mptr =3D (ptr);	\
+		(type *)( (char *)__mptr - offsetof(type,member) );		\
+	})
+
 #define likely(x)   __builtin_expect(!!(x), 1)
 #define unlikely(x) __builtin_expect(!!(x), 0)
 =

-- =

2.19.1


--===============4381958899395427244==--

