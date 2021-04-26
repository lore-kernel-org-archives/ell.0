Content-Type: multipart/mixed; boundary="===============9128746890179648476=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/2] util: Add l_steal_ptr
Date: Mon, 26 Apr 2021 18:06:22 +0200
Message-ID: <20210426160622.761540-2-andrew.zaborowski@intel.com>
In-Reply-To: <20210426160622.761540-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9128746890179648476==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add the l_steal_ptr macro, similar to g_steal_pointer except for being a
macro and taking the variable name as a parameter, rather than a
pointer to that variable.  From g_steal_pointer(pp) documentation:

> Sets `pp` to `NULL`, returning the value that was there before.
>
> Conceptually, this transfers the ownership of the pointer from the
> referenced variable to the "caller" of the macro (ie: "steals" the
> reference).
---
 ell/util.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/ell/util.h b/ell/util.h
index 9400657..bdf6935 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -245,6 +245,9 @@ static inline void auto_free(void *a)
 	l_free(*p);
 }
 =

+#define l_steal_ptr(ptr) \
+	(__extension__ ({ typeof(ptr) _tmp =3D (ptr); (ptr) =3D NULL; _tmp; }))
+
 /**
  * l_new:
  * @type: type of structure
-- =

2.27.0

--===============9128746890179648476==--

