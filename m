Content-Type: multipart/mixed; boundary="===============4026919320162915843=="
MIME-Version: 1.0
From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: [PATCH v4 1/6] dbus: Add AddMatch and RemoveMatch support
Date: Fri, 20 Feb 2015 14:16:36 +0200
Message-ID: <1424434601-2211-2-git-send-email-jukka.rissanen@linux.intel.com>
In-Reply-To: <1424434601-2211-1-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4026919320162915843==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

We do not check for errors as they are typically unrecoverable
in this case and in most cases ignored anyway.

This is the comment from libdbus API documentation for
dbus_bus_add_match() about error checking:

"If you pass NULL for the error, this function will not block;
the match thus won't be added until you flush the connection,
and if there's an error adding the match you won't find out
about it. This is generally acceptable, since the possible
errors (including a lack of resources in the bus, the connection
having exceeded its quota of active match rules, or the match
rule being unparseable) are generally unrecoverable."
---
 ell/dbus.c | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/ell/dbus.c b/ell/dbus.c
index 4c4ba2d..1d1b166 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -1227,3 +1227,29 @@ LIB_EXPORT bool l_dbus_unregister_interface(struct l=
_dbus *dbus,
 =

 	return _dbus_object_tree_unregister(dbus->tree, path, interface);
 }
+
+static void dbus1_send_match(struct l_dbus *dbus, const char *rule,
+						const char *method)
+{
+	struct l_dbus_message *message;
+
+	message =3D l_dbus_message_new_method_call(dbus,
+						DBUS_SERVICE_DBUS,
+						DBUS_PATH_DBUS,
+						DBUS_INTERFACE_DBUS,
+						method);
+
+	l_dbus_message_set_arguments(message, "s", rule);
+
+	send_message(dbus, false, message, NULL, NULL, NULL);
+}
+
+static void dbus1_bus_add_match(struct l_dbus *dbus, const char *rule)
+{
+	dbus1_send_match(dbus, rule, "AddMatch");
+}
+
+static void dbus1_bus_remove_match(struct l_dbus *dbus, const char *rule)
+{
+	dbus1_send_match(dbus, rule, "RemoveMatch");
+}
-- =

2.1.0


--===============4026919320162915843==--

