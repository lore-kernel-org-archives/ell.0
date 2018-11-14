Content-Type: multipart/mixed; boundary="===============5319204159234247848=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH] signal: Restrict signal_mask to file scope
Date: Wed, 14 Nov 2018 13:56:43 -0800
Message-ID: <20181114215643.21087-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5319204159234247848==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/signal.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/signal.c b/ell/signal.c
index 710dc5c..36d6326 100644
--- a/ell/signal.c
+++ b/ell/signal.c
@@ -64,7 +64,7 @@ struct signal_desc {
 =

 static struct l_io *signalfd_io =3D NULL;
 static struct l_queue *signal_list =3D NULL;
-sigset_t signal_mask;
+static sigset_t signal_mask;
 =

 static void handle_callback(struct signal_desc *desc)
 {
-- =

2.19.1


--===============5319204159234247848==--

