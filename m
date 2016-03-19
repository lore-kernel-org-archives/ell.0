Content-Type: multipart/mixed; boundary="===============6830249006880032391=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] dbus: Take iter->sig_len into account in
 l_dbus_message_iter_get_variant
Date: Sat, 19 Mar 2016 07:00:42 +0100
Message-ID: <1458367247-14607-4-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1458367247-14607-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6830249006880032391==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus-message.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index f9e13e2..30c09b9 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -1379,7 +1379,8 @@ LIB_EXPORT bool l_dbus_message_iter_get_variant(
 	if (unlikely(!iter))
 		return false;
 =

-	if (!iter->sig_start || strcmp(iter->sig_start, signature))
+	if (!iter->sig_start || strlen(signature) !=3D iter->sig_len ||
+			memcmp(iter->sig_start, signature, iter->sig_len))
 		return false;
 =

 	va_start(args, signature);
-- =

2.5.0


--===============6830249006880032391==--

