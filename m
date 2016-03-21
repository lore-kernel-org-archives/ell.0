Content-Type: multipart/mixed; boundary="===============0624979431187543468=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 02/15] gvariant: Add _gvariant_iter_skip_entry.
Date: Mon, 21 Mar 2016 23:10:11 +0100
Message-ID: <1458598224-29325-2-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1458598224-29325-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0624979431187543468==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This will be used for the get_nth_string_argument function in
dbus-message.c.  There seems to be no other way to skip over an iterator
entry without knowing the data type.
---
 ell/gvariant-private.h |  1 +
 ell/gvariant-util.c    | 10 ++++++++++
 2 files changed, 11 insertions(+)

diff --git a/ell/gvariant-private.h b/ell/gvariant-private.h
index 1acac74..2a20feb 100644
--- a/ell/gvariant-private.h
+++ b/ell/gvariant-private.h
@@ -35,6 +35,7 @@ bool _gvariant_iter_enter_variant(struct l_dbus_message_i=
ter *iter,
 					struct l_dbus_message_iter *variant);
 bool _gvariant_iter_enter_array(struct l_dbus_message_iter *iter,
 					struct l_dbus_message_iter *array);
+bool _gvariant_iter_skip_entry(struct l_dbus_message_iter *iter);
 =

 bool _gvariant_valid_signature(const char *sig);
 int _gvariant_get_alignment(const char *signature);
diff --git a/ell/gvariant-util.c b/ell/gvariant-util.c
index 7534509..1aaddc3 100644
--- a/ell/gvariant-util.c
+++ b/ell/gvariant-util.c
@@ -731,6 +731,16 @@ bool _gvariant_iter_enter_array(struct l_dbus_message_=
iter *iter,
 						start, item_size);
 }
 =

+bool _gvariant_iter_skip_entry(struct l_dbus_message_iter *iter)
+{
+	size_t size;
+
+	if (!next_item(iter, &size))
+		return false;
+
+	return true;
+}
+
 struct dbus_builder {
 	struct l_string *signature;
 	void *body;
-- =

2.5.0


--===============0624979431187543468==--

