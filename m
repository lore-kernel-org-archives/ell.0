Content-Type: multipart/mixed; boundary="===============2092105839528993255=="
MIME-Version: 1.0
From: maxice8 <thinkabit.ukim@gmail.com>
Subject: [PATCH] ell/dir.c: include limits.h for NAME_MAX
Date: Sat, 20 Oct 2018 18:01:29 -0300
Message-ID: <20181020210129.27142-1-thinkabit.ukim@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2092105839528993255==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

From: William Maxwell <thinkabit.ukim@gmail.com>

fixes compilation on musl libc systems that are stricter

the error:

ell/dir.c: In function 'inotify_read_cb':
ell/dir.c:176:45: error: 'NAME_MAX' undeclared (first use in this function)=
; did you mean 'SIZE_MAX'?
  uint8_t buf[sizeof(struct inotify_event) + NAME_MAX + 1]
                                             ^~~~~~~~
                                             SIZE_MAX
ell/dir.c:176:45: note: each undeclared identifier is reported only once fo=
r each function it appears in

Signed-off-by: William Maxwell <thinkabit.ukim@gmail.com>
---
 ell/dir.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ell/dir.c b/ell/dir.c
index d1870c8..7917664 100644
--- a/ell/dir.c
+++ b/ell/dir.c
@@ -27,6 +27,7 @@
 #include <unistd.h>
 #include <dirent.h>
 #include <sys/inotify.h>
+#include <limits.h>
 =

 #include "private.h"
 #include "queue.h"
-- =

2.19.1


--===============2092105839528993255==--

