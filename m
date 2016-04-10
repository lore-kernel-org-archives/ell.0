Content-Type: multipart/mixed; boundary="===============3605325802513241430=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 10/12] dbus: Rename _dbus_header_is_valid to
 _dbus1_header_is_valid
Date: Sun, 10 Apr 2016 06:03:05 +0200
Message-ID: <1460260987-9235-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3605325802513241430==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus-private.h | 2 +-
 ell/dbus-util.c    | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index b7f00b6..c921cf3 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -153,7 +153,7 @@ bool _dbus_valid_method(const char *method);
 bool _dbus_parse_unique_name(const char *name, uint64_t *out_id);
 bool _dbus_valid_bus_name(const char *bus_name);
 =

-bool _dbus_header_is_valid(void *data, size_t size);
+bool _dbus1_header_is_valid(void *data, size_t size);
 =

 void _dbus_method_introspection(struct _dbus_method *info,
 					struct l_string *buf);
diff --git a/ell/dbus-util.c b/ell/dbus-util.c
index ab0600a..e0e2bc7 100644
--- a/ell/dbus-util.c
+++ b/ell/dbus-util.c
@@ -412,7 +412,7 @@ const char *_dbus_signature_end(const char *signature)
 	return NULL;
 }
 =

-bool _dbus_header_is_valid(void *data, size_t size)
+bool _dbus1_header_is_valid(void *data, size_t size)
 {
 	struct dbus_header *hdr;
 	size_t header_len;
-- =

2.5.0


--===============3605325802513241430==--

