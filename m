Content-Type: multipart/mixed; boundary="===============0607665900239775192=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] path: Fix an integer overflow in l_path_get_mtime
Date: Mon, 02 Mar 2020 16:10:11 +0100
Message-ID: <20200302151011.2125-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0607665900239775192==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

time_t may be 32 bits wide (also signed) so we need to cast
timespec.tv_sec to uint64_t before multiplying by 1000000.
---
 ell/path.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/ell/path.c b/ell/path.c
index dfede14..df5a703 100644
--- a/ell/path.c
+++ b/ell/path.c
@@ -162,7 +162,8 @@ LIB_EXPORT uint64_t l_path_get_mtime(const char *path)
 	if (ret < 0)
 		return L_TIME_INVALID;
 =

-	return sb.st_mtim.tv_sec * 1000000 + sb.st_mtim.tv_nsec / 1000;
+	return (uint64_t) sb.st_mtim.tv_sec * 1000000 +
+		sb.st_mtim.tv_nsec / 1000;
 }
 =

 /**
-- =

2.20.1

--===============0607665900239775192==--

