Content-Type: multipart/mixed; boundary="===============7117948281892911568=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 3/3] timeout: Propagate watch_add errors in l_timeout_create
 functions
Date: Tue, 07 Jun 2016 15:30:15 -0700
Message-ID: <20160607223015.26693-3-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20160607223015.26693-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7117948281892911568==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

l_timeout_create functions now free resources and return NULL if
watch_add fails.
---
 ell/timeout.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/ell/timeout.c b/ell/timeout.c
index 4ba4e6e..fc24d60 100644
--- a/ell/timeout.c
+++ b/ell/timeout.c
@@ -135,6 +135,7 @@ LIB_EXPORT struct l_timeout *l_timeout_create_with_nano=
seconds(unsigned int seco
 			void *user_data, l_timeout_destroy_cb_t destroy)
 {
 	struct l_timeout *timeout;
+	int err;
 =

 	if (unlikely(!callback))
 		return NULL;
@@ -160,8 +161,13 @@ LIB_EXPORT struct l_timeout *l_timeout_create_with_nan=
oseconds(unsigned int seco
 		}
 	}
 =

-	watch_add(timeout->fd, EPOLLIN | EPOLLONESHOT, timeout_callback,
-						timeout, timeout_destroy);
+	err =3D watch_add(timeout->fd, EPOLLIN | EPOLLONESHOT, timeout_callback,
+			timeout, timeout_destroy);
+
+	if (err < 0) {
+		l_free(timeout);
+		return NULL;
+	}
 =

 	return timeout;
 }
-- =

2.8.4


--===============7117948281892911568==--

