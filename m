Content-Type: multipart/mixed; boundary="===============8498692015194182423=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@gmail.com>
Subject: [PATCH 1/2] util: Fix C++ invalid pointer conversion
Date: Mon, 09 Nov 2020 16:57:57 -0800
Message-ID: <20201110005758.55338-2-ossama.othman@intel.com>
In-Reply-To: <20201110005758.55338-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8498692015194182423==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Cast the void* arguments of l_secure_memcmp() to uint8_t* during
assignment to the latter.  C++ doesn't allow assignment of a void* to
a pointer of another type without a cast.  This allows <ell/util.h> to
once again be used in C++ code.
---
 ell/util.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/ell/util.h b/ell/util.h
index 0b3e1a8..f3dd57a 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -351,8 +351,8 @@ const char *l_util_get_debugfs_path(void);
 static inline int l_secure_memcmp(const void *a, const void *b,
 					size_t size)
 {
-	const volatile uint8_t *aa =3D a;
-	const volatile uint8_t *bb =3D b;
+	const volatile uint8_t *aa =3D (const uint8_t *) a;
+	const volatile uint8_t *bb =3D (const uint8_t *) b;
 	int res =3D 0, diff, mask;
 =

 	/*
-- =

2.25.1

--===============8498692015194182423==--

