Content-Type: multipart/mixed; boundary="===============5346072800708373907=="
MIME-Version: 1.0
From: Szymon Janc <szymon.janc@codecoup.pl>
Subject: [PATCH 2/4] ringbuf: Remove dead code
Date: Wed, 21 Oct 2015 23:13:13 +0200
Message-ID: <1445461995-22036-2-git-send-email-szymon.janc@codecoup.pl>
In-Reply-To: <1445461995-22036-1-git-send-email-szymon.janc@codecoup.pl>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5346072800708373907==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

l_malloc cannot fail if size>0.
---
 ell/ringbuf.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/ell/ringbuf.c b/ell/ringbuf.c
index 9049618..4f1f280 100644
--- a/ell/ringbuf.c
+++ b/ell/ringbuf.c
@@ -93,14 +93,7 @@ LIB_EXPORT struct l_ringbuf *l_ringbuf_new(size_t size)
 	real_size =3D align_power2(size);
 =

 	ringbuf =3D l_new(struct l_ringbuf, 1);
-	if (!ringbuf)
-		return NULL;
-
 	ringbuf->buffer =3D l_malloc(real_size);
-	if (!ringbuf->buffer) {
-		l_free(ringbuf);
-		return NULL;
-	}
 =

 	ringbuf->size =3D real_size;
 	ringbuf->in =3D RINGBUF_RESET;
-- =

2.6.2


--===============5346072800708373907==--

