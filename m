Content-Type: multipart/mixed; boundary="===============3581377222049802239=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 2/2] strv: Remove unnecessary post-increment.
Date: Thu, 14 Feb 2019 12:45:49 -0800
Message-ID: <20190214204549.26138-3-ossama.othman@intel.com>
In-Reply-To: <20190214204549.26138-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3581377222049802239==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Remove unecessary post-increment of a string array index in
l_strv_append().  The updated index value was not used after the
post-increment.
---
 ell/strv.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/strv.c b/ell/strv.c
index a507626..89f2df5 100644
--- a/ell/strv.c
+++ b/ell/strv.c
@@ -284,7 +284,7 @@ LIB_EXPORT char **l_strv_append(char **str_array, const=
 char *str)
 	for (i =3D 0; i < len; i++)
 		ret[i] =3D str_array[i];
 =

-	ret[i++] =3D l_strdup(str);
+	ret[i] =3D l_strdup(str);
 =

 	l_free(str_array);
 =

-- =

2.17.1


--===============3581377222049802239==--

