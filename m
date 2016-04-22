Content-Type: multipart/mixed; boundary="===============6510501305735383797=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/2] dbus: Make _dbus_num_children a dbus-private function
Date: Fri, 22 Apr 2016 02:57:14 +0200
Message-ID: <1461286637-30810-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6510501305735383797==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus-private.h | 1 +
 ell/dbus-util.c    | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index 6f39a2d..be43aba 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -156,6 +156,7 @@ const char *_dbus_signature_end(const char *signature);
 =

 bool _dbus_valid_object_path(const char *path);
 bool _dbus_valid_signature(const char *sig);
+int _dbus_num_children(const char *sig);
 bool _dbus_valid_interface(const char *interface);
 bool _dbus_valid_method(const char *method);
 bool _dbus_parse_unique_name(const char *name, uint64_t *out_id);
diff --git a/ell/dbus-util.c b/ell/dbus-util.c
index 4d79d11..6414216 100644
--- a/ell/dbus-util.c
+++ b/ell/dbus-util.c
@@ -249,7 +249,7 @@ bool _dbus_valid_signature(const char *sig)
 	return true;
 }
 =

-static int _dbus_num_children(const char *sig)
+int _dbus_num_children(const char *sig)
 {
 	const char *s =3D sig;
 	int num_children =3D 0;
-- =

2.5.0


--===============6510501305735383797==--

