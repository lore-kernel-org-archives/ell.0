Content-Type: multipart/mixed; boundary="===============4074253947178494344=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 4/4] path: Use l_timespec_to_usecs() to avoid overflow.
Date: Mon, 02 Mar 2020 13:28:17 -0800
Message-ID: <20200302212817.15524-5-ossama.othman@intel.com>
In-Reply-To: <20200302212817.15524-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4074253947178494344==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/path.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/ell/path.c b/ell/path.c
index df5a703..e911c01 100644
--- a/ell/path.c
+++ b/ell/path.c
@@ -162,8 +162,7 @@ LIB_EXPORT uint64_t l_path_get_mtime(const char *path)
 	if (ret < 0)
 		return L_TIME_INVALID;
 =

-	return (uint64_t) sb.st_mtim.tv_sec * 1000000 +
-		sb.st_mtim.tv_nsec / 1000;
+	return l_timespec_to_usecs(&sb.st_mtim);
 }
 =

 /**
-- =

2.20.1

--===============4074253947178494344==--

