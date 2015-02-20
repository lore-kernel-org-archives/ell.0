Content-Type: multipart/mixed; boundary="===============7588813277490862700=="
MIME-Version: 1.0
From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: [PATCH v4 3/6] dbus: Add filter rule creator
Date: Fri, 20 Feb 2015 14:16:38 +0200
Message-ID: <1424434601-2211-4-git-send-email-jukka.rissanen@linux.intel.com>
In-Reply-To: <1424434601-2211-1-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7588813277490862700==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Create a dbus filter rule here so that the following unit
test is able to test it.
---
 ell/dbus-private.h |  5 +++++
 ell/dbus.c         | 37 +++++++++++++++++++++++++++++++++++++
 ell/dbus.h         |  2 ++
 3 files changed, 44 insertions(+)

diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index 9987294..0123ddb 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -212,3 +212,8 @@ int _dbus_kernel_remove_match(int fd, uint64_t cookie);
 =

 uint8_t _dbus_get_version(struct l_dbus *dbus);
 int _dbus_get_fd(struct l_dbus *dbus);
+
+struct dbus_filter_data;
+
+void _dbus1_format_rule(struct dbus_filter_data *data, char *rule,
+								size_t size);
diff --git a/ell/dbus.c b/ell/dbus.c
index 1d1b166..a3d8070 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -122,6 +122,19 @@ struct signal_callback {
 	void *user_data;
 };
 =

+struct dbus_filter_data {
+	struct l_dbus *dbus;
+	l_dbus_message_func_t handle_func;
+	l_dbus_watch_func_t disconnect_func;
+	char *sender;
+	char *path;
+	char *interface;
+	char *member;
+	char *argument;
+	void *user_data;
+	l_dbus_destroy_func_t destroy_func;
+};
+
 static void message_queue_destroy(void *data)
 {
 	struct message_callback *callback =3D data;
@@ -1253,3 +1266,27 @@ static void dbus1_bus_remove_match(struct l_dbus *db=
us, const char *rule)
 {
 	dbus1_send_match(dbus, rule, "RemoveMatch");
 }
+
+void _dbus1_format_rule(struct dbus_filter_data *data, char *rule,
+			size_t size)
+{
+	int offset;
+
+	offset =3D snprintf(rule, size, "type=3D'signal'");
+
+	if (data->sender)
+		offset +=3D snprintf(rule + offset, size - offset,
+				",sender=3D'%s'", data->sender);
+	if (data->path)
+		offset +=3D snprintf(rule + offset, size - offset,
+				",path=3D'%s'", data->path);
+	if (data->interface)
+		offset +=3D snprintf(rule + offset, size - offset,
+				",interface=3D'%s'", data->interface);
+	if (data->member)
+		offset +=3D snprintf(rule + offset, size - offset,
+				",member=3D'%s'", data->member);
+	if (data->argument)
+		snprintf(rule + offset, size - offset,
+				",arg0=3D'%s'", data->argument);
+}
diff --git a/ell/dbus.h b/ell/dbus.h
index a6ad109..b2469f3 100644
--- a/ell/dbus.h
+++ b/ell/dbus.h
@@ -48,6 +48,8 @@ typedef void (*l_dbus_debug_func_t) (const char *str, voi=
d *user_data);
 typedef void (*l_dbus_destroy_func_t) (void *user_data);
 typedef void (*l_dbus_interface_setup_func_t) (struct l_dbus_interface *);
 =

+typedef void (*l_dbus_watch_func_t) (struct l_dbus *dbus, void *user_data);
+
 struct l_dbus *l_dbus_new(const char *address);
 struct l_dbus *l_dbus_new_default(enum l_dbus_bus bus);
 void l_dbus_destroy(struct l_dbus *dbus);
-- =

2.1.0


--===============7588813277490862700==--

