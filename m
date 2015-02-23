Content-Type: multipart/mixed; boundary="===============7293401330395548101=="
MIME-Version: 1.0
From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: [PATCH v5 2/4] dbus: Add AddMatch and RemoveMatch support
Date: Mon, 23 Feb 2015 13:54:58 +0200
Message-ID: <1424692500-21681-3-git-send-email-jukka.rissanen@linux.intel.com>
In-Reply-To: <1424692500-21681-1-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7293401330395548101==
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
index 803fdf6..7ab71cd 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -1309,3 +1309,29 @@ void _dbus1_filter_data_destroy(void *user_data)
 =

 	l_free(data);
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


--===============7293401330395548101==--

