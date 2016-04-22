Content-Type: multipart/mixed; boundary="===============9162045868526959678=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/2] dbus: Check that property signature has one data type
Date: Fri, 22 Apr 2016 02:57:15 +0200
Message-ID: <1461286637-30810-2-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1461286637-30810-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9162045868526959678==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus-service.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index 9d2110f..44baaaf 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -408,7 +408,7 @@ LIB_EXPORT bool l_dbus_interface_property(struct l_dbus=
_interface *interface,
 	if (unlikely(!signature || !getter))
 		return false;
 =

-	if (!_dbus_valid_signature(signature))
+	if (_dbus_num_children(signature) !=3D 1)
 		return false;
 =

 	/* Pre-calculate the needed meta-info length */
-- =

2.5.0


--===============9162045868526959678==--

