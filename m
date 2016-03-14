Content-Type: multipart/mixed; boundary="===============7009506147789345435=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 16/20] dbus: Remove now unused filter functions.
Date: Mon, 14 Mar 2016 04:41:32 +0100
Message-ID: <1457926896-9843-16-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1457926896-9843-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7009506147789345435==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus.c | 51 ---------------------------------------------------
 1 file changed, 51 deletions(-)

diff --git a/ell/dbus.c b/ell/dbus.c
index 38b6705..35afd1f 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -1745,57 +1745,6 @@ void _dbus1_filter_data_destroy(void *user_data)
 	l_free(data);
 }
 =

-static void dbus1_send_match(struct l_dbus *dbus, const char *rule,
-						const char *method)
-{
-	struct l_dbus_message *message;
-
-	message =3D l_dbus_message_new_method_call(dbus,
-						DBUS_SERVICE_DBUS,
-						DBUS_PATH_DBUS,
-						L_DBUS_INTERFACE_DBUS,
-						method);
-
-	l_dbus_message_set_arguments(message, "s", rule);
-
-	send_message(dbus, false, message, NULL, NULL, NULL);
-}
-
-static void dbus1_bus_add_match(struct l_dbus *dbus, const char *rule)
-{
-	dbus1_send_match(dbus, rule, "AddMatch");
-}
-
-static void dbus1_bus_remove_match(struct l_dbus *dbus, const char *rule)
-{
-	dbus1_send_match(dbus, rule, "RemoveMatch");
-}
-
-static void add_match(struct dbus1_filter_data *data)
-{
-	char rule[DBUS_MAXIMUM_MATCH_RULE_LENGTH];
-
-	_dbus1_filter_format_match(data, rule, sizeof(rule));
-
-	dbus1_bus_add_match(data->dbus, rule);
-}
-
-static void remove_match(struct dbus1_filter_data *data)
-{
-	char rule[DBUS_MAXIMUM_MATCH_RULE_LENGTH];
-
-	_dbus1_filter_format_match(data, rule, sizeof(rule));
-
-	dbus1_bus_remove_match(data->dbus, rule);
-}
-
-static void filter_data_destroy(void *user_data)
-{
-	remove_match(user_data);
-
-	_dbus1_filter_data_destroy(user_data);
-}
-
 void _dbus1_signal_dispatcher(struct l_dbus_message *message, void *user_d=
ata)
 {
 	struct dbus1_filter_data *data =3D user_data;
-- =

2.5.0


--===============7009506147789345435==--

