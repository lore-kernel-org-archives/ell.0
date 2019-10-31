Content-Type: multipart/mixed; boundary="===============6223726905643883251=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH v2] genl: Add forward declaration to fix build warning
Date: Thu, 31 Oct 2019 10:44:16 -0700
Message-ID: <20191031174416.16580-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6223726905643883251==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The l_genl_msg_append_attrv() declaration in genl.h uses struct iovec *,
but there's no guarantee that sys/uio.h has been included (and
the genl user might not need that header itself).
---

v2: Use forward declaration instead of including system header

 ell/genl.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/ell/genl.h b/ell/genl.h
index 5df688b..c3f641f 100644
--- a/ell/genl.h
+++ b/ell/genl.h
@@ -31,6 +31,8 @@
 extern "C" {
 #endif
 =

+struct iovec;
+
 struct l_genl;
 struct l_genl_family_info;
 struct l_genl_family;
-- =

2.23.0

--===============6223726905643883251==--

