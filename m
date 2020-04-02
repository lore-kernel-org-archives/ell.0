Content-Type: multipart/mixed; boundary="===============1164244104982651316=="
MIME-Version: 1.0
From: Rosen Penev <rosenp@gmail.com>
Subject: [PATCH 4/4] ell: switch to new __atomic API
Date: Wed, 01 Apr 2020 20:36:32 -0700
Message-ID: <20200402033632.961701-4-rosenp@gmail.com>
In-Reply-To: <20200402033632.961701-1-rosenp@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1164244104982651316==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The __sync API is legacy. __atomic is also explicit. Fixes:

warning: implicit use of sequentially-consistent atomic may incur
stronger memory barriers than necessary [-Watomic-implicit-seq-cst]

from clang.
---
 ell/dbus-message.c | 4 ++--
 ell/genl.c         | 8 ++++----
 ell/hwdb.c         | 4 ++--
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index 32f0428..66c345a 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -397,7 +397,7 @@ LIB_EXPORT struct l_dbus_message *l_dbus_message_ref(st=
ruct l_dbus_message *mess
 	if (unlikely(!message))
 		return NULL;
 =

-	__sync_fetch_and_add(&message->refcount, 1);
+	__atomic_fetch_add(&message->refcount, 1, __ATOMIC_SEQ_CST);
 =

 	return message;
 }
@@ -409,7 +409,7 @@ LIB_EXPORT void l_dbus_message_unref(struct l_dbus_mess=
age *message)
 	if (unlikely(!message))
 		return;
 =

-	if (__sync_sub_and_fetch(&message->refcount, 1))
+	if (__atomic_sub_fetch(&message->refcount, 1, __ATOMIC_SEQ_CST))
 		return;
 =

 	for (i =3D 0; i < message->num_fds; i++)
diff --git a/ell/genl.c b/ell/genl.c
index f65263d..c326a7d 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -1125,7 +1125,7 @@ LIB_EXPORT struct l_genl *l_genl_ref(struct l_genl *g=
enl)
 	if (unlikely(!genl))
 		return NULL;
 =

-	__sync_fetch_and_add(&genl->ref_count, 1);
+	__atomic_fetch_add(&genl->ref_count, 1, __ATOMIC_SEQ_CST);
 =

 	return genl;
 }
@@ -1135,7 +1135,7 @@ LIB_EXPORT void l_genl_unref(struct l_genl *genl)
 	if (unlikely(!genl))
 		return;
 =

-	if (__sync_sub_and_fetch(&genl->ref_count, 1))
+	if (__atomic_sub_fetch(&genl->ref_count, 1, __ATOMIC_SEQ_CST))
 		return;
 =

 	if (genl->discovery) {
@@ -1542,7 +1542,7 @@ LIB_EXPORT struct l_genl_msg *l_genl_msg_ref(struct l=
_genl_msg *msg)
 	if (unlikely(!msg))
 		return NULL;
 =

-	__sync_fetch_and_add(&msg->ref_count, 1);
+	__atomic_fetch_add(&msg->ref_count, 1, __ATOMIC_SEQ_CST);
 =

 	return msg;
 }
@@ -1552,7 +1552,7 @@ LIB_EXPORT void l_genl_msg_unref(struct l_genl_msg *m=
sg)
 	if (unlikely(!msg))
 		return;
 =

-	if (__sync_sub_and_fetch(&msg->ref_count, 1))
+	if (__atomic_sub_fetch(&msg->ref_count, 1, __ATOMIC_SEQ_CST))
 		return;
 =

 	l_free(msg->data);
diff --git a/ell/hwdb.c b/ell/hwdb.c
index 0d5f95a..65276a6 100644
--- a/ell/hwdb.c
+++ b/ell/hwdb.c
@@ -178,7 +178,7 @@ LIB_EXPORT struct l_hwdb *l_hwdb_ref(struct l_hwdb *hwd=
b)
 	if (!hwdb)
 		return NULL;
 =

-	__sync_fetch_and_add(&hwdb->ref_count, 1);
+	__atomic_fetch_add(&hwdb->ref_count, 1, __ATOMIC_SEQ_CST);
 =

 	return hwdb;
 }
@@ -188,7 +188,7 @@ LIB_EXPORT void l_hwdb_unref(struct l_hwdb *hwdb)
 	if (!hwdb)
 		return;
 =

-	if (__sync_sub_and_fetch(&hwdb->ref_count, 1))
+	if (__atomic_sub_fetch(&hwdb->ref_count, 1, __ATOMIC_SEQ_CST))
 		return;
 =

 	munmap(hwdb->addr, hwdb->size);
-- =

2.25.1

--===============1164244104982651316==--

