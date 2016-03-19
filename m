Content-Type: multipart/mixed; boundary="===============0078855445150594576=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] unit: Add int64_t casts in dbus tests failing on i386.
Date: Sat, 19 Mar 2016 07:00:41 +0100
Message-ID: <1458367247-14607-3-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1458367247-14607-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0078855445150594576==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Make sure the values are passed as 64-bit ones, adding LL would probably
also work for gcc.
---
 unit/test-dbus-message.c     | 2 +-
 unit/test-gvariant-message.c | 3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/unit/test-dbus-message.c b/unit/test-dbus-message.c
index 4008d2b..ce58769 100644
--- a/unit/test-dbus-message.c
+++ b/unit/test-dbus-message.c
@@ -1555,7 +1555,7 @@ static void build_basic_7(const void *data)
 {
 	struct l_dbus_message *msg =3D build_message(data);
 =

-	l_dbus_message_set_arguments(msg, "t", 10000);
+	l_dbus_message_set_arguments(msg, "t", (uint64_t) 10000);
 =

 	compare_message(msg, data);
 }
diff --git a/unit/test-gvariant-message.c b/unit/test-gvariant-message.c
index 324c341..5573e63 100644
--- a/unit/test-gvariant-message.c
+++ b/unit/test-gvariant-message.c
@@ -208,7 +208,8 @@ static void build_basic_1(const void *data)
 =

 	result =3D l_dbus_message_set_arguments(msg, "bynqiuxtd", true, 255,
 						-32, 32, -24, 24,
-						140179142606749, 99L, 5.0);
+						(uint64_t) 140179142606749,
+						(int64_t) 99, 5.0);
 	assert(result);
 =

 	_dbus_message_set_serial(msg, 1111);
-- =

2.5.0


--===============0078855445150594576==--

