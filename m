Content-Type: multipart/mixed; boundary="===============5170852515658432297=="
MIME-Version: 1.0
From: Szymon Janc <szymon.janc@codecoup.pl>
Subject: [PATCH v2 4/4] examples: Extend dbus-client example
Date: Tue, 05 Dec 2017 17:22:33 +0100
Message-ID: <20171205162233.22452-4-szymon.janc@codecoup.pl>
In-Reply-To: <20171205162233.22452-1-szymon.janc@codecoup.pl>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5170852515658432297==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This adds sample code for using D-Bus proxy interface.
---
 examples/dbus-client.c | 93 +++++++++++++++++++++++++++++++++++++++++++++-=
----
 1 file changed, 84 insertions(+), 9 deletions(-)

diff --git a/examples/dbus-client.c b/examples/dbus-client.c
index 507a4e8..1f60643 100644
--- a/examples/dbus-client.c
+++ b/examples/dbus-client.c
@@ -60,23 +60,81 @@ static void disconnect_callback(void *user_data)
 	l_main_quit();
 }
 =

-static void service_appeared(struct l_dbus *dbus, void *user_data)
+static void iwd_service_appeared(struct l_dbus *dbus, void *user_data)
 {
 	l_info("Service appeared");
 }
 =

-static void service_disappeared(struct l_dbus *dbus, void *user_data)
+static void iwd_service_disappeared(struct l_dbus *dbus, void *user_data)
 {
-	l_info("Service disappeared, quitting...");
-	l_main_quit();
+	l_info("Service disappeared");
+}
+
+static void bluez_client_connected(struct l_dbus *dbus, void *user_data)
+{
+	l_info("client connected");
+}
+
+static void bluez_client_disconnected(struct l_dbus *dbus, void *user_data)
+{
+	l_info("client disconnected");
+}
+
+static void bluez_client_ready(struct l_dbus_client *client, void *user_da=
ta)
+{
+	l_info("client ready");
+}
+
+static void proxy_added(struct l_dbus_proxy *proxy, void *user_data)
+{
+	const char *interface =3D l_dbus_proxy_get_interface(proxy);
+	const char *path =3D l_dbus_proxy_get_path(proxy);
+
+	l_info("proxy added: %s %s", path, interface);
+
+	if (!strcmp(interface, "org.bluez.Adapter1") ||
+				!strcmp(interface, "org.bluez.Device1")) {
+		char *str;
+
+		if (!l_dbus_proxy_get_property(proxy, "Address", "s", &str))
+			return;
+
+		l_info("   Address: %s", str);
+	}
+}
+
+static void proxy_removed(struct l_dbus_proxy *proxy, void *user_data)
+{
+	l_info("proxy removed: %s %s", l_dbus_proxy_get_path(proxy),
+					l_dbus_proxy_get_interface(proxy));
+}
+
+static void property_changed(struct l_dbus_proxy *proxy, const char *name,
+				struct l_dbus_message *msg, void *user_data)
+{
+	l_info("property changed: %s (%s %s)", name,
+					l_dbus_proxy_get_path(proxy),
+					l_dbus_proxy_get_interface(proxy));
+
+	if (!strcmp(name, "Address")) {
+		char *str;
+
+		if (!l_dbus_message_get_arguments(msg, "s", &str)) {
+			return;
+		}
+
+		l_info("   Address: %s", str);
+	}
 }
 =

 int main(int argc, char *argv[])
 {
+	struct l_dbus_client *client;
 	struct l_dbus *dbus;
 	struct l_signal *signal;
 	sigset_t mask;
-	uint32_t watch_id;
+	uint32_t iwd_watch_id;
+
 =

 	if (!l_main_init())
 		return -1;
@@ -93,14 +151,31 @@ int main(int argc, char *argv[])
 	l_dbus_set_ready_handler(dbus, ready_callback, dbus, NULL);
 	l_dbus_set_disconnect_handler(dbus, disconnect_callback, NULL, NULL);
 =

-	watch_id =3D l_dbus_add_service_watch(dbus, "net.connman.iwd",
-						service_appeared,
-						service_disappeared,
+	/* service basic watch */
+	iwd_watch_id =3D l_dbus_add_service_watch(dbus, "net.connman.iwd",
+						iwd_service_appeared,
+						iwd_service_disappeared,
 						NULL, NULL);
 =

+	/* proxy example */
+	client =3D l_dbus_client_new(dbus, "org.bluez", "/org/bluez");
+
+	l_dbus_client_set_connect_handler(client, bluez_client_connected, NULL,
+									NULL);
+	l_dbus_client_set_disconnect_handler(client, bluez_client_disconnected,
+								NULL, NULL);
+
+	l_dbus_client_set_proxy_handlers(client, proxy_added, proxy_removed,
+							property_changed, NULL, NULL);
+
+	l_dbus_client_set_ready_handler(client, bluez_client_ready, NULL, NULL);
+
+
 	l_main_run();
 =

-	l_dbus_remove_watch(dbus, watch_id);
+	l_dbus_remove_watch(dbus, iwd_watch_id);
+
+	l_dbus_client_destroy(client);
 =

 	l_dbus_destroy(dbus);
 	l_signal_remove(signal);
-- =

2.14.3


--===============5170852515658432297==--

