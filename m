Content-Type: multipart/mixed; boundary="===============6588066544686366069=="
MIME-Version: 1.0
From: ell@ongy.net
Subject: [PATCH 2/4] dbus: Make adjustments for compilation with clang
Date: Wed, 14 Dec 2016 23:51:19 +0100
Message-ID: <20161214225121.9439-3-ell@ongy.net>
In-Reply-To: <20161214225121.9439-1-ell@ongy.net>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6588066544686366069==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

From: Markus Ongyerth <ongy@ongy.net>

clang errors if KDBUS_ITEM_SIZE is a function, because it is used in an
array size inside a struct, where clang does not accept dynamic values.

clang warns about va_lists with elements of type char, since they are
subject to auto-expansion and will be converted to ints either way.
---
 ell/dbus-kernel.c  | 6 ++----
 ell/dbus-message.c | 2 +-
 2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/ell/dbus-kernel.c b/ell/dbus-kernel.c
index 6544a87..4d7cae3 100644
--- a/ell/dbus-kernel.c
+++ b/ell/dbus-kernel.c
@@ -58,10 +58,8 @@
         { 0x##v0, 0x##v1, 0x##v2, 0x##v3, 0x##v4, 0x##v5, 0x##v6, 0x##v7, \
 	0x##v8, 0x##v9, 0x##v10, 0x##v11, 0x##v12, 0x##v13, 0x##v14, 0x##v15 }
 =

-static inline size_t KDBUS_ITEM_SIZE(size_t actual)
-{
-	return align_len(actual + offsetof(struct kdbus_item, data), 8);
-}
+#define KDBUS_ITEM_SIZE(actual) \
+	align_len(actual + offsetof(struct kdbus_item, data), 8)
 =

 static inline struct kdbus_item *KDBUS_ITEM_NEXT(struct kdbus_item *item)
 {
diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index 3b44fb8..ef5dd22 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -660,7 +660,7 @@ static bool get_header_field_from_iter_valist(struct l_=
dbus_message *message,
 }
 =

 static inline bool get_header_field(struct l_dbus_message *message,
-					uint8_t type, char data_type, ...)
+					uint8_t type, int data_type, ...)
 {
 	va_list args;
 	bool result;
-- =

2.10.2


--===============6588066544686366069==--

