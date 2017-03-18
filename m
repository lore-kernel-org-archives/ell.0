Content-Type: multipart/mixed; boundary="===============8486359673755590826=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] dbus: Flush pending object manager signals in send_message
Date: Sat, 18 Mar 2017 02:30:23 +0100
Message-ID: <20170318013023.24742-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8486359673755590826==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Try to warrant the original ordering of PropertiesChanged and
InterfacesAdded/Removed signals in relation to other messages for
clients that rely on this ordering.  One case where this may matter
is when a method call causes a property value change followed by the
method return message in the same main loop iteration as the property
change.  In this case the property change would always be seen by
dbus after the method return because of the signals being send from
an idle callback.  Set a barrier for the object manager signals
before queuing other messages like method returns.
---
 ell/dbus-private.h | 2 ++
 ell/dbus-service.c | 8 ++++++++
 ell/dbus.c         | 2 ++
 3 files changed, 12 insertions(+)

diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index a4118c6..c22b95a 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -234,6 +234,8 @@ bool _dbus_object_tree_property_changed(struct l_dbus *=
dbus,
 					const char *interface_name,
 					const char *property_name);
 =

+void _dbus_object_tree_signals_flush(struct l_dbus *dbus);
+
 void _dbus_kernel_bloom_add(uint64_t filter[], size_t size, uint8_t num_ha=
sh,
 				const char *prefix, const char *str);
 void _dbus_kernel_bloom_add_parents(uint64_t filter[], size_t size,
diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index 1df8f1b..f54d2dd 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -1101,6 +1101,14 @@ static void schedule_emit_signals(struct l_dbus *dbu=
s)
 	tree->emit_signals_work =3D l_idle_create(emit_signals, dbus, NULL);
 }
 =

+void _dbus_object_tree_signals_flush(struct l_dbus *dbus)
+{
+	struct _dbus_object_tree *tree =3D _dbus_get_tree(dbus);
+
+	if (tree->emit_signals_work)
+		emit_signals(tree->emit_signals_work, dbus);
+}
+
 static bool match_property_changes_instance(const void *a, const void *b)
 {
 	const struct property_change_record *rec =3D a;
diff --git a/ell/dbus.c b/ell/dbus.c
index ddc51aa..274e4ae 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -346,6 +346,8 @@ static uint32_t send_message(struct l_dbus *dbus, bool =
priority,
 		return callback->serial;
 	}
 =

+	_dbus_object_tree_signals_flush(dbus);
+
 	l_queue_push_tail(dbus->message_queue, callback);
 =

 	if (dbus->is_ready)
-- =

2.9.3


--===============8486359673755590826==--

