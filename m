Content-Type: multipart/mixed; boundary="===============7811135153724360971=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 4/5] examples: dbus-service: Use interface name macros.
Date: Thu, 18 Feb 2016 04:20:11 +0100
Message-ID: <1455765612-6577-4-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1455765612-6577-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7811135153724360971==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 examples/dbus-service.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/examples/dbus-service.c b/examples/dbus-service.c
index 964d735..347faae 100644
--- a/examples/dbus-service.c
+++ b/examples/dbus-service.c
@@ -213,7 +213,7 @@ int main(int argc, char *argv[])
 =

 	l_dbus_method_call(dbus, "org.freedesktop.DBus",
 				"/org/freedesktop/DBus",
-				"org.freedesktop.DBus", "RequestName",
+				L_DBUS_INTERFACE_DBUS, "RequestName",
 				request_name_setup,
 				request_name_callback, NULL, NULL);
 =

@@ -240,7 +240,7 @@ int main(int argc, char *argv[])
 	}
 =

 	if (!l_dbus_object_add_interface(dbus, "/test",
-				"org.freedesktop.DBus.Properties", NULL)) {
+					L_DBUS_INTERFACE_PROPERTIES, NULL)) {
 		l_info("Unable to instantiate the properties interface");
 		test_data_destroy(test);
 		goto cleanup;
-- =

2.5.0


--===============7811135153724360971==--

