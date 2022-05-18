Content-Type: multipart/mixed; boundary="===============0210318383417109212=="
MIME-Version: 1.0
From: Michael Johnson <mjohnson459 at gmail.com>
To: ell at lists.01.org
Subject: [PATCH] dhcp: CLIENT_ENTER_STATE should log as INFO
Date: Wed, 18 May 2022 17:58:36 +0100
Message-ID: <20220518165836.180763-1-mjohnson459@gmail.com>

--===============0210318383417109212==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This was missed in the d5377c6. Now the state will only log when INFO or
above is enabled.
---
 ell/dhcp.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/ell/dhcp.c b/ell/dhcp.c
index 8ff5594..4e66faa 100644
--- a/ell/dhcp.c
+++ b/ell/dhcp.c
@@ -56,9 +56,7 @@
 #define CLIENT_WARN(fmt, args...)					\
 	CLIENT_LOG(L_LOG_WARNING, fmt, ## args)
 #define CLIENT_ENTER_STATE(s)						\
-	l_util_debug(client->debug_handler, client->debug_data,		\
-			"%s:%i Entering state: " #s,			\
-			__func__, __LINE__);				\
+	CLIENT_INFO("Entering state: " #s);				\
 	client->state =3D (s)
 =

 #define BITS_PER_LONG (sizeof(unsigned long) * 8)
-- =

2.25.1

--===============0210318383417109212==--

