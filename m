Content-Type: multipart/mixed; boundary="===============6831660402143716413=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] dbus: Handle optional properties in PropertiesChanged
Date: Wed, 21 Sep 2016 18:41:45 +0200
Message-ID: <1474476105-10906-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6831660402143716413==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Handle property getter returning an error when building the
PropertiesChanged signal instead of returning NULL.  This is important
because the signal may include multiple properties and if one getter
fails other properties should still be included.  One options is to only
error out if all getters fail, another is to add them to the invalidated
properties list of the signal.  The latter seems to be the right thing
to do for optional properties that may appear and disappear.
---
 ell/dbus-service.c | 26 +++++++++++++++++++++++---
 1 file changed, 23 insertions(+), 3 deletions(-)

diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index deffc07..57cafbe 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -962,6 +962,7 @@ static struct l_dbus_message *build_properties_changed_=
signal(
 	const struct l_queue_entry *entry;
 	const struct _dbus_property *property;
 	const char *signature;
+	struct l_queue *invalidated;
 =

 	signal =3D l_dbus_message_new_signal(dbus, rec->path,
 						L_DBUS_INTERFACE_PROPERTIES,
@@ -969,6 +970,8 @@ static struct l_dbus_message *build_properties_changed_=
signal(
 =

 	builder =3D l_dbus_message_builder_new(signal);
 =

+	invalidated =3D l_queue_new();
+
 	l_dbus_message_builder_append_basic(builder, 's',
 						rec->instance->interface->name);
 	l_dbus_message_builder_enter_array(builder, "{sv}");
@@ -978,6 +981,8 @@ static struct l_dbus_message *build_properties_changed_=
signal(
 		property =3D entry->data;
 		signature =3D property->metainfo + strlen(property->metainfo) + 1;
 =

+		_dbus_message_builder_mark(builder);
+
 		l_dbus_message_builder_enter_dict(builder, "sv");
 		l_dbus_message_builder_append_basic(builder, 's',
 							property->metainfo);
@@ -985,10 +990,16 @@ static struct l_dbus_message *build_properties_change=
d_signal(
 =

 		if (!property->getter(dbus, signal, builder,
 					rec->instance->user_data)) {
-			l_dbus_message_builder_destroy(builder);
-			l_dbus_message_unref(signal);
+			if (!_dbus_message_builder_rewind(builder)) {
+				l_dbus_message_unref(signal);
+				signal =3D NULL;
 =

-			return NULL;
+				goto done;
+			}
+
+			l_queue_push_tail(invalidated, (void *) property);
+
+			continue;
 		}
 =

 		l_dbus_message_builder_leave_variant(builder);
@@ -997,10 +1008,19 @@ static struct l_dbus_message *build_properties_chang=
ed_signal(
 =

 	l_dbus_message_builder_leave_array(builder);
 	l_dbus_message_builder_enter_array(builder, "s");
+
+	while ((property =3D l_queue_pop_head(invalidated)))
+		l_dbus_message_builder_append_basic(builder, 's',
+							property->metainfo);
+
 	l_dbus_message_builder_leave_array(builder);
 	l_dbus_message_builder_finalize(builder);
+
+done:
 	l_dbus_message_builder_destroy(builder);
 =

+	l_queue_destroy(invalidated, NULL);
+
 	return signal;
 }
 =

-- =

2.7.4


--===============6831660402143716413==--

