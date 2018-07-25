Content-Type: multipart/mixed; boundary="===============2194259195480489859=="
MIME-Version: 1.0
From: maxice8 <thinkabit.ukim@gmail.com>
Subject: [PATCH] fswatch: add missing limits.h include for NAME_MAX
Date: Wed, 25 Jul 2018 13:48:17 -0300
Message-ID: <20180725164817.22908-1-thinkabit.ukim@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2194259195480489859==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

From: William Maxwell <thinkabit.ukim@gmail.com>

fixes compilation on stricter libcs like Musl.

ell/fswatch.c: In function 'inotify_read_cb':
ell/fswatch.c:80:45: error: 'NAME_MAX' undeclared (first use in this functi=
on); did you mean 'SIZE_MAX'?
  uint8_t buf[sizeof(struct inotify_event) + NAME_MAX + 1]
                                             ^~~~~~~~
                                             SIZE_MAX
---
 ell/fswatch.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ell/fswatch.c b/ell/fswatch.c
index c65a1b9..c5980d3 100644
--- a/ell/fswatch.c
+++ b/ell/fswatch.c
@@ -26,6 +26,7 @@
 =

 #include <dirent.h>
 #include <unistd.h>
+#include <limits.h>
 #include <sys/inotify.h>
 =

 #include "private.h"
-- =

2.18.0


--===============2194259195480489859==--

