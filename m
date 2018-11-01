Content-Type: multipart/mixed; boundary="===============5274042778326058172=="
MIME-Version: 1.0
From: maxice8 <thinkabit.ukim@gmail.com>
Subject: [PATCH] ell/signal.h: use sigset_t instead of internal libc
 implementation
Date: Thu, 01 Nov 2018 06:27:42 -0300
Message-ID: <20181101092742.24873-1-thinkabit.ukim@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5274042778326058172==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Fixes compilation on musl libc which doesn't show up the internal
implementation.

Error message:

  CC       ell/main.lo
In file included from ell/main.c:35:
ell/signal.h:39:40: error: unknown type name '__sigset_t'
 struct l_signal *l_signal_create(const __sigset_t *mask,
                                        ^~~~~~~~~~
---
 ell/signal.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/signal.h b/ell/signal.h
index 0d4fdc8..98cf0fa 100644
--- a/ell/signal.h
+++ b/ell/signal.h
@@ -36,7 +36,7 @@ typedef void (*l_signal_notify_cb_t) (struct l_signal *si=
gnal,
 					uint32_t signo, void *user_data);
 typedef void (*l_signal_destroy_cb_t) (void *user_data);
 =

-struct l_signal *l_signal_create(const __sigset_t *mask,
+struct l_signal *l_signal_create(const sigset_t *mask,
 			l_signal_notify_cb_t callback,
 			void *user_data, l_signal_destroy_cb_t destroy);
 void l_signal_remove(struct l_signal *signal);
-- =

2.19.1


--===============5274042778326058172==--

