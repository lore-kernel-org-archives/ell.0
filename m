Content-Type: multipart/mixed; boundary="===============3019080271758084569=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 1/5] util: Remove semicolons in single-statement macros
Date: Mon, 24 Oct 2016 11:44:52 -0700
Message-ID: <20161024184456.25743-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3019080271758084569==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Including semicolons in L_AUTO_CLEANUP_VAR and L_AUTO_FREE_VAR caused
gcc to emit errors related to mixed declarations and code when there
were multiple L_AUTO_* lines or declarations following an L_AUTO_ macro.
---
 ell/util.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/ell/util.h b/ell/util.h
index 92e7c8a..8d1050e 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -160,10 +160,10 @@ static inline void l_put_be64(uint64_t val, void *ptr)
 }
 =

 #define L_AUTO_CLEANUP_VAR(vartype,varname,destroy) \
-	vartype varname __attribute__((cleanup(destroy)));
+	vartype varname __attribute__((cleanup(destroy)))
 =

 #define L_AUTO_FREE_VAR(vartype,varname) \
-	vartype varname __attribute__((cleanup(auto_free)));
+	vartype varname __attribute__((cleanup(auto_free)))
 =

 #define L_ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
 =

-- =

2.10.1


--===============3019080271758084569==--

