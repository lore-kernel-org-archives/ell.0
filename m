Content-Type: multipart/mixed; boundary="===============5733727490087995327=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 10/20] linux: Update kdbus.h to current github version.
Date: Mon, 14 Mar 2016 04:41:26 +0100
Message-ID: <1457926896-9843-10-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1457926896-9843-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5733727490087995327==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 linux/kdbus.h | 1061 +++++++++++++++++++++++++++++------------------------=
----
 1 file changed, 547 insertions(+), 514 deletions(-)

diff --git a/linux/kdbus.h b/linux/kdbus.h
index 8f98396..4fc44cb 100644
--- a/linux/kdbus.h
+++ b/linux/kdbus.h
@@ -1,33 +1,22 @@
 /*
- * Copyright (C) 2013 Kay Sievers
- * Copyright (C) 2013 Greg Kroah-Hartman <gregkh@linuxfoundation.org>
- * Copyright (C) 2013 Linux Foundation
- * Copyright (C) 2013 Lennart Poettering
- * Copyright (C) 2013 Daniel Mack <daniel@zonque.org>
- *
  * kdbus is free software; you can redistribute it and/or modify it under
  * the terms of the GNU Lesser General Public License as published by the
  * Free Software Foundation; either version 2.1 of the License, or (at
  * your option) any later version.
- *
- * "Everything should be made as simple as possible, but not simpler."
- *   -- Albert Einstein
  */
 =

-#ifndef _KDBUS_H_
-#define _KDBUS_H_
+#ifndef _UAPI_KDBUS_H_
+#define _UAPI_KDBUS_H_
 =

-#ifndef __KERNEL__
-#include <sys/ioctl.h>
-#include <sys/types.h>
+#include <linux/ioctl.h>
 #include <linux/types.h>
-#endif
 =

 #define KDBUS_IOCTL_MAGIC		0x95
 #define KDBUS_SRC_ID_KERNEL		(0)
 #define KDBUS_DST_ID_NAME		(0)
 #define KDBUS_MATCH_ID_ANY		(~0ULL)
 #define KDBUS_DST_ID_BROADCAST		(~0ULL)
+#define KDBUS_FLAG_NEGOTIATE		(1ULL << 63)
 =

 /**
  * struct kdbus_notify_id_change - name registry change message
@@ -44,12 +33,12 @@
 struct kdbus_notify_id_change {
 	__u64 id;
 	__u64 flags;
-};
+} __attribute__((__aligned__(8)));
 =

 /**
  * struct kdbus_notify_name_change - name registry change message
- * @old:		ID and flags of former owner of a name
- * @new:		ID and flags of new owner of a name
+ * @old_id:		ID and flags of former owner of a name
+ * @new_id:		ID and flags of new owner of a name
  * @name:		Well-known name
  *
  * Sent from kernel to userspace when the owner or activator of
@@ -61,34 +50,67 @@ struct kdbus_notify_id_change {
  *   KDBUS_ITEM_NAME_CHANGE
  */
 struct kdbus_notify_name_change {
-	struct kdbus_notify_id_change old;
-	struct kdbus_notify_id_change new;
+	struct kdbus_notify_id_change old_id;
+	struct kdbus_notify_id_change new_id;
 	char name[0];
-};
+} __attribute__((__aligned__(8)));
 =

 /**
  * struct kdbus_creds - process credentials
  * @uid:		User ID
+ * @euid:		Effective UID
+ * @suid:		Saved UID
+ * @fsuid:		Filesystem UID
  * @gid:		Group ID
- * @pid:		Process ID
- * @tid:		Thread ID
- * @starttime:		Starttime of the process
- *
- * The starttime of the process PID. This is useful to detect PID overruns
- * from the client side. i.e. if you use the PID to look something up in
- * /proc/$PID/ you can afterwards check the starttime field of it, to ensu=
re
- * you didn't run into a PID overrun.
+ * @egid:		Effective GID
+ * @sgid:		Saved GID
+ * @fsgid:		Filesystem GID
  *
  * Attached to:
  *   KDBUS_ITEM_CREDS
  */
 struct kdbus_creds {
 	__u64 uid;
+	__u64 euid;
+	__u64 suid;
+	__u64 fsuid;
 	__u64 gid;
+	__u64 egid;
+	__u64 sgid;
+	__u64 fsgid;
+} __attribute__((__aligned__(8)));
+
+/**
+ * struct kdbus_pids - process identifiers
+ * @pid:		Process ID
+ * @tid:		Thread ID
+ * @ppid:		Parent process ID
+ *
+ * The PID and TID of a process.
+ *
+ * Attached to:
+ *   KDBUS_ITEM_PIDS
+ */
+struct kdbus_pids {
 	__u64 pid;
 	__u64 tid;
-	__u64 starttime;
-};
+	__u64 ppid;
+} __attribute__((__aligned__(8)));
+
+/**
+ * struct kdbus_caps - process capabilities
+ * @last_cap:	Highest currently known capability bit
+ * @caps:	Variable number of 32-bit capabilities flags
+ *
+ * Contains a variable number of 32-bit capabilities flags.
+ *
+ * Attached to:
+ *   KDBUS_ITEM_CAPS
+ */
+struct kdbus_caps {
+	__u32 last_cap;
+	__u32 caps[0];
+} __attribute__((__aligned__(8)));
 =

 /**
  * struct kdbus_audit - audit information
@@ -99,9 +121,9 @@ struct kdbus_creds {
  *   KDBUS_ITEM_AUDIT
  */
 struct kdbus_audit {
-	__u64 sessionid;
-	__u64 loginuid;
-};
+	__u32 sessionid;
+	__u32 loginuid;
+} __attribute__((__aligned__(8)));
 =

 /**
  * struct kdbus_timestamp
@@ -116,17 +138,17 @@ struct kdbus_timestamp {
 	__u64 seqnum;
 	__u64 monotonic_ns;
 	__u64 realtime_ns;
-};
+} __attribute__((__aligned__(8)));
 =

 /**
  * struct kdbus_vec - I/O vector for kdbus payload items
  * @size:		The size of the vector
- * @address:		Memory address for memory addresses
+ * @address:		Memory address of data buffer
  * @offset:		Offset in the in-message payload memory,
  *			relative to the message head
  *
  * Attached to:
- *   KDBUS_ITEM_PAYLOAD_VEC
+ *   KDBUS_ITEM_PAYLOAD_VEC, KDBUS_ITEM_PAYLOAD_OFF
  */
 struct kdbus_vec {
 	__u64 size;
@@ -134,7 +156,7 @@ struct kdbus_vec {
 		__u64 address;
 		__u64 offset;
 	};
-};
+} __attribute__((__aligned__(8)));
 =

 /**
  * struct kdbus_bloom_parameter - bus-wide bloom parameters
@@ -144,7 +166,7 @@ struct kdbus_vec {
 struct kdbus_bloom_parameter {
 	__u64 size;
 	__u64 n_hash;
-};
+} __attribute__((__aligned__(8)));
 =

 /**
  * struct kdbus_bloom_filter - bloom filter containing n elements
@@ -154,22 +176,24 @@ struct kdbus_bloom_parameter {
 struct kdbus_bloom_filter {
 	__u64 generation;
 	__u64 data[0];
-};
+} __attribute__((__aligned__(8)));
 =

 /**
  * struct kdbus_memfd - a kdbus memfd
- * @size:		The memfd's size
+ * @start:		The offset into the memfd where the segment starts
+ * @size:		The size of the memfd segment
  * @fd:			The file descriptor number
- * @__pad:		Padding to ensure proper alignement and size
+ * @__pad:		Padding to ensure proper alignment and size
  *
  * Attached to:
  *   KDBUS_ITEM_PAYLOAD_MEMFD
  */
 struct kdbus_memfd {
+	__u64 start;
 	__u64 size;
 	int fd;
 	__u32 __pad;
-};
+} __attribute__((__aligned__(8)));
 =

 /**
  * struct kdbus_name - a registered well-known name with its flags
@@ -177,11 +201,39 @@ struct kdbus_memfd {
  * @name:		Well-known name
  *
  * Attached to:
- *   KDBUS_ITEM_NAME
+ *   KDBUS_ITEM_OWNED_NAME
  */
 struct kdbus_name {
 	__u64 flags;
 	char name[0];
+} __attribute__((__aligned__(8)));
+
+/**
+ * enum kdbus_policy_access_type - permissions of a policy record
+ * @_KDBUS_POLICY_ACCESS_NULL:	Uninitialized/invalid
+ * @KDBUS_POLICY_ACCESS_USER:	Grant access to a uid
+ * @KDBUS_POLICY_ACCESS_GROUP:	Grant access to gid
+ * @KDBUS_POLICY_ACCESS_WORLD:	World-accessible
+ */
+enum kdbus_policy_access_type {
+	_KDBUS_POLICY_ACCESS_NULL,
+	KDBUS_POLICY_ACCESS_USER,
+	KDBUS_POLICY_ACCESS_GROUP,
+	KDBUS_POLICY_ACCESS_WORLD,
+};
+
+/**
+ * enum kdbus_policy_access_flags - mode flags
+ * @KDBUS_POLICY_OWN:		Allow to own a well-known name
+ *				Implies KDBUS_POLICY_TALK and KDBUS_POLICY_SEE
+ * @KDBUS_POLICY_TALK:		Allow communication to a well-known name
+ *				Implies KDBUS_POLICY_SEE
+ * @KDBUS_POLICY_SEE:		Allow to see a well-known name
+ */
+enum kdbus_policy_type {
+	KDBUS_POLICY_SEE	=3D 0,
+	KDBUS_POLICY_TALK,
+	KDBUS_POLICY_OWN,
 };
 =

 /**
@@ -195,83 +247,151 @@ struct kdbus_policy_access {
 	__u64 type;	/* USER, GROUP, WORLD */
 	__u64 access;	/* OWN, TALK, SEE */
 	__u64 id;	/* uid, gid, 0 */
+} __attribute__((__aligned__(8)));
+
+/**
+ * enum kdbus_attach_flags - flags for metadata attachments
+ * @KDBUS_ATTACH_TIMESTAMP:		Timestamp
+ * @KDBUS_ATTACH_CREDS:			Credentials
+ * @KDBUS_ATTACH_PIDS:			PIDs
+ * @KDBUS_ATTACH_AUXGROUPS:		Auxiliary groups
+ * @KDBUS_ATTACH_NAMES:			Well-known names
+ * @KDBUS_ATTACH_TID_COMM:		The "comm" process identifier of the TID
+ * @KDBUS_ATTACH_PID_COMM:		The "comm" process identifier of the PID
+ * @KDBUS_ATTACH_EXE:			The path of the executable
+ * @KDBUS_ATTACH_CMDLINE:		The process command line
+ * @KDBUS_ATTACH_CGROUP:		The croup membership
+ * @KDBUS_ATTACH_CAPS:			The process capabilities
+ * @KDBUS_ATTACH_SECLABEL:		The security label
+ * @KDBUS_ATTACH_AUDIT:			The audit IDs
+ * @KDBUS_ATTACH_CONN_DESCRIPTION:	The human-readable connection name
+ * @_KDBUS_ATTACH_ALL:			All of the above
+ * @_KDBUS_ATTACH_ANY:			Wildcard match to enable any kind of
+ *					metatdata.
+ */
+enum kdbus_attach_flags {
+	KDBUS_ATTACH_TIMESTAMP		=3D  1ULL <<  0,
+	KDBUS_ATTACH_CREDS		=3D  1ULL <<  1,
+	KDBUS_ATTACH_PIDS		=3D  1ULL <<  2,
+	KDBUS_ATTACH_AUXGROUPS		=3D  1ULL <<  3,
+	KDBUS_ATTACH_NAMES		=3D  1ULL <<  4,
+	KDBUS_ATTACH_TID_COMM		=3D  1ULL <<  5,
+	KDBUS_ATTACH_PID_COMM		=3D  1ULL <<  6,
+	KDBUS_ATTACH_EXE		=3D  1ULL <<  7,
+	KDBUS_ATTACH_CMDLINE		=3D  1ULL <<  8,
+	KDBUS_ATTACH_CGROUP		=3D  1ULL <<  9,
+	KDBUS_ATTACH_CAPS		=3D  1ULL << 10,
+	KDBUS_ATTACH_SECLABEL		=3D  1ULL << 11,
+	KDBUS_ATTACH_AUDIT		=3D  1ULL << 12,
+	KDBUS_ATTACH_CONN_DESCRIPTION	=3D  1ULL << 13,
+	_KDBUS_ATTACH_ALL		=3D  (1ULL << 14) - 1,
+	_KDBUS_ATTACH_ANY		=3D  ~0ULL
 };
 =

 /**
  * enum kdbus_item_type - item types to chain data in a list
- * @_KDBUS_ITEM_NULL:		Uninitialized/invalid
- * @_KDBUS_ITEM_USER_BASE:	Start of user items
- * @KDBUS_ITEM_PAYLOAD_VEC:	Vector to data
- * @KDBUS_ITEM_PAYLOAD_OFF:	Data at returned offset to message head
- * @KDBUS_ITEM_PAYLOAD_MEMFD:	Data as sealed memfd
- * @KDBUS_ITEM_FDS:		Attached file descriptors
- * @KDBUS_ITEM_BLOOM_PARAMETER:	Bus-wide bloom parameters, used with
- *				KDBUS_CMD_BUS_MAKE, carries a
- *				struct kdbus_bloom_parameter
- * @KDBUS_ITEM_BLOOM_FILTER:	Bloom filter carried with a message, used to
- *				match against a bloom mask of a connection,
- *				carries a struct kdbus_bloom_filter
- * @KDBUS_ITEM_BLOOM_MASK:	Bloom mask used to match against a message's
- *				bloom filter
- * @KDBUS_ITEM_DST_NAME:	Destination's well-known name
- * @KDBUS_ITEM_MAKE_NAME:	Name of domain, bus, endpoint
- * @KDBUS_ITEM_MEMFD_NAME:	The human readable name of a memfd (debugging)
- * @KDBUS_ITEM_ATTACH_FLAGS:	Attach-flags, used for updating which metadata
- *				a connection subscribes to
- * @_KDBUS_ITEM_ATTACH_BASE:	Start of metadata attach items
- * @KDBUS_ITEM_NAME:		Well-know name with flags
- * @KDBUS_ITEM_ID:		Connection ID
- * @KDBUS_ITEM_TIMESTAMP:	Timestamp
- * @KDBUS_ITEM_CREDS:		Process credential
- * @KDBUS_ITEM_PID_COMM:	Process ID "comm" identifier
- * @KDBUS_ITEM_TID_COMM:	Thread ID "comm" identifier
- * @KDBUS_ITEM_EXE:		The path of the executable
- * @KDBUS_ITEM_CMDLINE:		The process command line
- * @KDBUS_ITEM_CGROUP:		The croup membership
- * @KDBUS_ITEM_CAPS:		The process capabilities
- * @KDBUS_ITEM_SECLABEL:	The security label
- * @KDBUS_ITEM_AUDIT:		The audit IDs
- * @KDBUS_ITEM_CONN_NAME:	The connection's human-readable name (debugging)
- * @_KDBUS_ITEM_POLICY_BASE:	Start of policy items
- * @KDBUS_ITEM_POLICY_ACCESS:	Policy access block
- * @_KDBUS_ITEM_KERNEL_BASE:	Start of kernel-generated message items
- * @KDBUS_ITEM_NAME_ADD:	Notify in struct kdbus_notify_name_change
- * @KDBUS_ITEM_NAME_REMOVE:	Notify in struct kdbus_notify_name_change
- * @KDBUS_ITEM_NAME_CHANGE:	Notify in struct kdbus_notify_name_change
- * @KDBUS_ITEM_ID_ADD:		Notify in struct kdbus_notify_id_change
- * @KDBUS_ITEM_ID_REMOVE:	Notify in struct kdbus_notify_id_change
- * @KDBUS_ITEM_REPLY_TIMEOUT:	Timeout has been reached
- * @KDBUS_ITEM_REPLY_DEAD:	Destination died
+ * @_KDBUS_ITEM_NULL:			Uninitialized/invalid
+ * @_KDBUS_ITEM_USER_BASE:		Start of user items
+ * @KDBUS_ITEM_NEGOTIATE:		Negotiate supported items
+ * @KDBUS_ITEM_PAYLOAD_VEC:		Vector to data
+ * @KDBUS_ITEM_PAYLOAD_OFF:		Data at returned offset to message head
+ * @KDBUS_ITEM_PAYLOAD_MEMFD:		Data as sealed memfd
+ * @KDBUS_ITEM_FDS:			Attached file descriptors
+ * @KDBUS_ITEM_CANCEL_FD:		FD used to cancel a synchronous
+ *					operation by writing to it from
+ *					userspace
+ * @KDBUS_ITEM_BLOOM_PARAMETER:		Bus-wide bloom parameters, used with
+ *					KDBUS_CMD_BUS_MAKE, carries a
+ *					struct kdbus_bloom_parameter
+ * @KDBUS_ITEM_BLOOM_FILTER:		Bloom filter carried with a message,
+ *					used to match against a bloom mask of a
+ *					connection, carries a struct
+ *					kdbus_bloom_filter
+ * @KDBUS_ITEM_BLOOM_MASK:		Bloom mask used to match against a
+ *					message'sbloom filter
+ * @KDBUS_ITEM_DST_NAME:		Destination's well-known name
+ * @KDBUS_ITEM_MAKE_NAME:		Name of domain, bus, endpoint
+ * @KDBUS_ITEM_ATTACH_FLAGS_SEND:	Attach-flags, used for updating which
+ *					metadata a connection opts in to send
+ * @KDBUS_ITEM_ATTACH_FLAGS_RECV:	Attach-flags, used for updating which
+ *					metadata a connection requests to
+ *					receive for each reeceived message
+ * @KDBUS_ITEM_ID:			Connection ID
+ * @KDBUS_ITEM_NAME:			Well-know name with flags
+ * @_KDBUS_ITEM_ATTACH_BASE:		Start of metadata attach items
+ * @KDBUS_ITEM_TIMESTAMP:		Timestamp
+ * @KDBUS_ITEM_CREDS:			Process credentials
+ * @KDBUS_ITEM_PIDS:			Process identifiers
+ * @KDBUS_ITEM_AUXGROUPS:		Auxiliary process groups
+ * @KDBUS_ITEM_OWNED_NAME:		A name owned by the associated
+ *					connection
+ * @KDBUS_ITEM_TID_COMM:		Thread ID "comm" identifier
+ *					(Don't trust this, see below.)
+ * @KDBUS_ITEM_PID_COMM:		Process ID "comm" identifier
+ *					(Don't trust this, see below.)
+ * @KDBUS_ITEM_EXE:			The path of the executable
+ *					(Don't trust this, see below.)
+ * @KDBUS_ITEM_CMDLINE:			The process command line
+ *					(Don't trust this, see below.)
+ * @KDBUS_ITEM_CGROUP:			The croup membership
+ * @KDBUS_ITEM_CAPS:			The process capabilities
+ * @KDBUS_ITEM_SECLABEL:		The security label
+ * @KDBUS_ITEM_AUDIT:			The audit IDs
+ * @KDBUS_ITEM_CONN_DESCRIPTION:	The connection's human-readable name
+ *					(debugging)
+ * @_KDBUS_ITEM_POLICY_BASE:		Start of policy items
+ * @KDBUS_ITEM_POLICY_ACCESS:		Policy access block
+ * @_KDBUS_ITEM_KERNEL_BASE:		Start of kernel-generated message items
+ * @KDBUS_ITEM_NAME_ADD:		Notification in kdbus_notify_name_change
+ * @KDBUS_ITEM_NAME_REMOVE:		Notification in kdbus_notify_name_change
+ * @KDBUS_ITEM_NAME_CHANGE:		Notification in kdbus_notify_name_change
+ * @KDBUS_ITEM_ID_ADD:			Notification in kdbus_notify_id_change
+ * @KDBUS_ITEM_ID_REMOVE:		Notification in kdbus_notify_id_change
+ * @KDBUS_ITEM_REPLY_TIMEOUT:		Timeout has been reached
+ * @KDBUS_ITEM_REPLY_DEAD:		Destination died
+ *
+ * N.B: The process and thread COMM fields, as well as the CMDLINE and
+ * EXE fields may be altered by unprivileged processes und should
+ * hence *not* used for security decisions. Peers should make use of
+ * these items only for informational purposes, such as generating log
+ * records.
  */
 enum kdbus_item_type {
 	_KDBUS_ITEM_NULL,
 	_KDBUS_ITEM_USER_BASE,
-	KDBUS_ITEM_PAYLOAD_VEC	=3D _KDBUS_ITEM_USER_BASE,
+	KDBUS_ITEM_NEGOTIATE	=3D _KDBUS_ITEM_USER_BASE,
+	KDBUS_ITEM_PAYLOAD_VEC,
 	KDBUS_ITEM_PAYLOAD_OFF,
 	KDBUS_ITEM_PAYLOAD_MEMFD,
 	KDBUS_ITEM_FDS,
+	KDBUS_ITEM_CANCEL_FD,
 	KDBUS_ITEM_BLOOM_PARAMETER,
 	KDBUS_ITEM_BLOOM_FILTER,
 	KDBUS_ITEM_BLOOM_MASK,
 	KDBUS_ITEM_DST_NAME,
 	KDBUS_ITEM_MAKE_NAME,
-	KDBUS_ITEM_MEMFD_NAME,
-	KDBUS_ITEM_ATTACH_FLAGS,
+	KDBUS_ITEM_ATTACH_FLAGS_SEND,
+	KDBUS_ITEM_ATTACH_FLAGS_RECV,
+	KDBUS_ITEM_ID,
+	KDBUS_ITEM_NAME,
+	KDBUS_ITEM_DST_ID,
 =

+	/* keep these item types in sync with KDBUS_ATTACH_* flags */
 	_KDBUS_ITEM_ATTACH_BASE	=3D 0x1000,
-	KDBUS_ITEM_NAME		=3D _KDBUS_ITEM_ATTACH_BASE,
-	KDBUS_ITEM_ID,
-	KDBUS_ITEM_TIMESTAMP,
+	KDBUS_ITEM_TIMESTAMP	=3D _KDBUS_ITEM_ATTACH_BASE,
 	KDBUS_ITEM_CREDS,
-	KDBUS_ITEM_PID_COMM,
+	KDBUS_ITEM_PIDS,
+	KDBUS_ITEM_AUXGROUPS,
+	KDBUS_ITEM_OWNED_NAME,
 	KDBUS_ITEM_TID_COMM,
+	KDBUS_ITEM_PID_COMM,
 	KDBUS_ITEM_EXE,
 	KDBUS_ITEM_CMDLINE,
 	KDBUS_ITEM_CGROUP,
 	KDBUS_ITEM_CAPS,
 	KDBUS_ITEM_SECLABEL,
 	KDBUS_ITEM_AUDIT,
-	KDBUS_ITEM_CONN_NAME,
+	KDBUS_ITEM_CONN_DESCRIPTION,
 =

 	_KDBUS_ITEM_POLICY_BASE	=3D 0x2000,
 	KDBUS_ITEM_POLICY_ACCESS =3D _KDBUS_ITEM_POLICY_BASE,
@@ -322,7 +442,9 @@ struct kdbus_item {
 		__u64 id;
 		struct kdbus_vec vec;
 		struct kdbus_creds creds;
+		struct kdbus_pids pids;
 		struct kdbus_audit audit;
+		struct kdbus_caps caps;
 		struct kdbus_timestamp timestamp;
 		struct kdbus_name name;
 		struct kdbus_bloom_parameter bloom_parameter;
@@ -333,38 +455,34 @@ struct kdbus_item {
 		struct kdbus_notify_id_change id_change;
 		struct kdbus_policy_access policy_access;
 	};
-};
+} __attribute__((__aligned__(8)));
 =

 /**
  * enum kdbus_msg_flags - type of message
- * @KDBUS_MSG_FLAGS_EXPECT_REPLY:	Expect a reply message, used for
- *					method calls. The userspace-supplied
- *					cookie identifies the message and the
- *					respective reply carries the cookie
- *					in cookie_reply
- * @KDBUS_MSG_FLAGS_SYNC_REPLY:		Wait for destination connection to
- *					reply to this message. The
- *					KDBUS_CMD_MSG_SEND ioctl() will block
- *					until the reply is received, and
- *					offset_reply in struct kdbus_msg will
- *					yield the offset in the sender's pool
- *					where the reply can be found.
- *					This flag is only valid if
- *					@KDBUS_MSG_FLAGS_EXPECT_REPLY is set as
- *					well.
- * @KDBUS_MSG_FLAGS_NO_AUTO_START:	Do not start a service, if the addressed
- *					name is not currently active
+ * @KDBUS_MSG_EXPECT_REPLY:	Expect a reply message, used for
+ *				method calls. The userspace-supplied
+ *				cookie identifies the message and the
+ *				respective reply carries the cookie
+ *				in cookie_reply
+ * @KDBUS_MSG_NO_AUTO_START:	Do not start a service if the addressed
+ *				name is not currently active. This flag is
+ *				not looked at by the kernel but only
+ *				serves as hint for userspace implementations.
+ * @KDBUS_MSG_SIGNAL:		Treat this message as signal
  */
 enum kdbus_msg_flags {
-	KDBUS_MSG_FLAGS_EXPECT_REPLY	=3D 1 << 0,
-	KDBUS_MSG_FLAGS_SYNC_REPLY	=3D 1 << 1,
-	KDBUS_MSG_FLAGS_NO_AUTO_START	=3D 1 << 2,
+	KDBUS_MSG_EXPECT_REPLY	=3D 1ULL << 0,
+	KDBUS_MSG_NO_AUTO_START	=3D 1ULL << 1,
+	KDBUS_MSG_SIGNAL	=3D 1ULL << 2,
 };
 =

 /**
  * enum kdbus_payload_type - type of payload carried by message
  * @KDBUS_PAYLOAD_KERNEL:	Kernel-generated simple message
  * @KDBUS_PAYLOAD_DBUS:		D-Bus marshalling "DBusDBus"
+ *
+ * Any payload-type is accepted. Common types will get added here once
+ * established.
  */
 enum kdbus_payload_type {
 	KDBUS_PAYLOAD_KERNEL,
@@ -374,7 +492,7 @@ enum kdbus_payload_type {
 /**
  * struct kdbus_msg - the representation of a kdbus message
  * @size:		Total size of the message
- * @flags:		Message flags (KDBUS_MSG_FLAGS_*)
+ * @flags:		Message flags (KDBUS_MSG_*), userspace =E2=86=92 kernel
  * @priority:		Message queue priority value
  * @dst_id:		64-bit ID of the destination connection
  * @src_id:		64-bit ID of the source connection
@@ -382,15 +500,16 @@ enum kdbus_payload_type {
  * @cookie:		Userspace-supplied cookie, for the connection
  *			to identify its messages
  * @timeout_ns:		The time to wait for a message reply from the peer.
- *			If there is no reply, a kernel-generated message
+ *			If there is no reply, and the send command is
+ *			executed asynchronously, a kernel-generated message
  *			with an attached KDBUS_ITEM_REPLY_TIMEOUT item
- *			is sent to @src_id.
+ *			is sent to @src_id. For synchronously executed send
+ *			command, the value denotes the maximum time the call
+ *			blocks to wait for a reply. The timeout is expected in
+ *			nanoseconds and as absolute CLOCK_MONOTONIC value.
  * @cookie_reply:	A reply to the requesting message with the same
  *			cookie. The requesting connection can match its
  *			request and the reply with this value
- * @offset_reply:	If KDBUS_MSG_FLAGS_EXPECT_REPLY, this field will
- *			contain the offset in the sender's pool where the
- *			reply is stored.
  * @items:		A list of kdbus_items containing the message payload
  */
 struct kdbus_msg {
@@ -404,10 +523,56 @@ struct kdbus_msg {
 	union {
 		__u64 timeout_ns;
 		__u64 cookie_reply;
-		__u64 offset_reply;
 	};
 	struct kdbus_item items[0];
-} __attribute__((aligned(8)));
+} __attribute__((__aligned__(8)));
+
+/**
+ * struct kdbus_msg_info - returned message container
+ * @offset:		Offset of kdbus_msg slice in pool
+ * @msg_size:		Copy of the kdbus_msg.size field
+ * @return_flags:	Command return flags, kernel =E2=86=92 userspace
+ */
+struct kdbus_msg_info {
+	__u64 offset;
+	__u64 msg_size;
+	__u64 return_flags;
+} __attribute__((__aligned__(8)));
+
+/**
+ * enum kdbus_send_flags - flags for sending messages
+ * @KDBUS_SEND_SYNC_REPLY:	Wait for destination connection to
+ *				reply to this message. The
+ *				KDBUS_CMD_SEND ioctl() will block
+ *				until the reply is received, and
+ *				reply in struct kdbus_cmd_send will
+ *				yield the offset in the sender's pool
+ *				where the reply can be found.
+ *				This flag is only valid if
+ *				@KDBUS_MSG_EXPECT_REPLY is set as well.
+ */
+enum kdbus_send_flags {
+	KDBUS_SEND_SYNC_REPLY		=3D 1ULL << 0,
+};
+
+/**
+ * struct kdbus_cmd_send - send message
+ * @size:		Overall size of this structure
+ * @flags:		Flags to change send behavior (KDBUS_SEND_*)
+ * @return_flags:	Command return flags, kernel =E2=86=92 userspace
+ * @msg_address:	Storage address of the kdbus_msg to send
+ * @reply:		Storage for message reply if KDBUS_SEND_SYNC_REPLY
+ *			was given
+ * @items:		Additional items for this command
+ */
+struct kdbus_cmd_send {
+	__u64 size;
+	__u64 flags;
+	__u64 return_flags;
+	__u64 msg_address;
+	struct kdbus_msg_info reply;
+	struct kdbus_item items[0];
+} __attribute__((__aligned__(8)));
 =

 /**
  * enum kdbus_recv_flags - flags for de-queuing messages
@@ -423,59 +588,77 @@ struct kdbus_msg {
  *				the priority value is ignored.
  */
 enum kdbus_recv_flags {
-	KDBUS_RECV_PEEK		=3D 1 <<  0,
-	KDBUS_RECV_DROP		=3D 1 <<  1,
-	KDBUS_RECV_USE_PRIORITY	=3D 1 <<  2,
+	KDBUS_RECV_PEEK		=3D 1ULL <<  0,
+	KDBUS_RECV_DROP		=3D 1ULL <<  1,
+	KDBUS_RECV_USE_PRIORITY	=3D 1ULL <<  2,
+};
+
+/**
+ * enum kdbus_recv_return_flags - return flags for message receive commands
+ * @KDBUS_RECV_RETURN_INCOMPLETE_FDS:	One or more file descriptors could n=
ot
+ *					be installed. These descriptors in
+ *					KDBUS_ITEM_FDS will carry the value -1.
+ * @KDBUS_RECV_RETURN_DROPPED_MSGS:	There have been dropped messages since
+ *					the last time a message was received.
+ *					The 'dropped_msgs' counter contains the
+ *					number of messages dropped pool
+ *					overflows or other missed broadcasts.
+ */
+enum kdbus_recv_return_flags {
+	KDBUS_RECV_RETURN_INCOMPLETE_FDS	=3D 1ULL <<  0,
+	KDBUS_RECV_RETURN_DROPPED_MSGS		=3D 1ULL <<  1,
 };
 =

 /**
  * struct kdbus_cmd_recv - struct to de-queue a buffered message
- * @flags:		KDBUS_RECV_* flags
+ * @size:		Overall size of this object
+ * @flags:		KDBUS_RECV_* flags, userspace =E2=86=92 kernel
+ * @return_flags:	Command return flags, kernel =E2=86=92 userspace
  * @priority:		Minimum priority of the messages to de-queue. Lowest
  *			values have the highest priority.
- * @offset:		Returned offset in the pool where the message is
- *			stored. The user must use KDBUS_CMD_FREE to free
- *			the allocated memory.
+ * @dropped_msgs:	In case there were any dropped messages since the last
+ *			time a message was received, this will be set to the
+ *			number of lost messages and
+ *			KDBUS_RECV_RETURN_DROPPED_MSGS will be set in
+ *			'return_flags'. This can only happen if the ioctl
+ *			returns 0 or EAGAIN.
+ * @msg:		Return storage for received message.
+ * @items:		Additional items for this command.
  *
- * This struct is used with the KDBUS_CMD_MSG_RECV ioctl.
+ * This struct is used with the KDBUS_CMD_RECV ioctl.
  */
 struct kdbus_cmd_recv {
+	__u64 size;
 	__u64 flags;
+	__u64 return_flags;
 	__s64 priority;
-	__u64 offset;
-} __attribute__((aligned(8)));
-
-/**
- * enum kdbus_policy_access_type - permissions of a policy record
- * @_KDBUS_POLICY_ACCESS_NULL:	Uninitialized/invalid
- * @KDBUS_POLICY_ACCESS_USER:	Grant access to a uid
- * @KDBUS_POLICY_ACCESS_GROUP:	Grant access to gid
- * @KDBUS_POLICY_ACCESS_WORLD:	World-accessible
- */
-enum kdbus_policy_access_type {
-	_KDBUS_POLICY_ACCESS_NULL,
-	KDBUS_POLICY_ACCESS_USER,
-	KDBUS_POLICY_ACCESS_GROUP,
-	KDBUS_POLICY_ACCESS_WORLD,
-};
+	__u64 dropped_msgs;
+	struct kdbus_msg_info msg;
+	struct kdbus_item items[0];
+} __attribute__((__aligned__(8)));
 =

 /**
- * enum kdbus_policy_access_flags - mode flags
- * @KDBUS_POLICY_OWN:		Allow to own a well-known name
- *				Implies KDBUS_POLICY_TALK and KDBUS_POLICY_SEE
- * @KDBUS_POLICY_TALK:		Allow communication to a well-known name
- *				Implies KDBUS_POLICY_SEE
- * @KDBUS_POLICY_SEE:		Allow to see a well-known name
+ * struct kdbus_cmd_free - struct to free a slice of memory in the pool
+ * @size:		Overall size of this structure
+ * @flags:		Flags for the free command, userspace =E2=86=92 kernel
+ * @return_flags:	Command return flags, kernel =E2=86=92 userspace
+ * @offset:		The offset of the memory slice, as returned by other
+ *			ioctls
+ * @items:		Additional items to modify the behavior
+ *
+ * This struct is used with the KDBUS_CMD_FREE ioctl.
  */
-enum kdbus_policy_type {
-	KDBUS_POLICY_SEE	=3D 0,
-	KDBUS_POLICY_TALK,
-	KDBUS_POLICY_OWN,
-};
+struct kdbus_cmd_free {
+	__u64 size;
+	__u64 flags;
+	__u64 return_flags;
+	__u64 offset;
+	struct kdbus_item items[0];
+} __attribute__((__aligned__(8)));
 =

 /**
  * enum kdbus_hello_flags - flags for struct kdbus_cmd_hello
- * @KDBUS_HELLO_ACCEPT_FD:	The connection allows the receiving of
+ * @KDBUS_HELLO_ACCEPT_FD:	The connection allows the reception of
  *				any passed file descriptors
  * @KDBUS_HELLO_ACTIVATOR:	Special-purpose connection which registers
  *				a well-know name for a process to be started
@@ -484,55 +667,27 @@ enum kdbus_policy_type {
  *				policy entries for a name. The provided name
  *				is not activated and not registered with the
  *				name database, it only allows unprivileged
- *				connections to aquire a name, talk or discover
+ *				connections to acquire a name, talk or discover
  *				a service
  * @KDBUS_HELLO_MONITOR:	Special-purpose connection to monitor
  *				bus traffic
  */
 enum kdbus_hello_flags {
-	KDBUS_HELLO_ACCEPT_FD		=3D  1 <<  0,
-	KDBUS_HELLO_ACTIVATOR		=3D  1 <<  1,
-	KDBUS_HELLO_POLICY_HOLDER	=3D  1 <<  2,
-	KDBUS_HELLO_MONITOR		=3D  1 <<  3,
-};
-
-/**
- * enum kdbus_attach_flags - flags for metadata attachments
- * @KDBUS_ATTACH_TIMESTAMP:	Timestamp
- * @KDBUS_ATTACH_CREDS:		Credentials
- * @KDBUS_ATTACH_NAMES:		Well-known names
- * @KDBUS_ATTACH_COMM:		The "comm" process identifier
- * @KDBUS_ATTACH_EXE:		The path of the executable
- * @KDBUS_ATTACH_CMDLINE:	The process command line
- * @KDBUS_ATTACH_CGROUP:	The croup membership
- * @KDBUS_ATTACH_CAPS:		The process capabilities
- * @KDBUS_ATTACH_SECLABEL:	The security label
- * @KDBUS_ATTACH_AUDIT:		The audit IDs
- * @KDBUS_ATTACH_CONN_NAME:	The human-readable connection name
- * @_KDBUS_ATTACH_ALL:		All of the above
- */
-enum kdbus_attach_flags {
-	KDBUS_ATTACH_TIMESTAMP		=3D  1 <<  0,
-	KDBUS_ATTACH_CREDS		=3D  1 <<  1,
-	KDBUS_ATTACH_NAMES		=3D  1 <<  2,
-	KDBUS_ATTACH_COMM		=3D  1 <<  3,
-	KDBUS_ATTACH_EXE		=3D  1 <<  4,
-	KDBUS_ATTACH_CMDLINE		=3D  1 <<  5,
-	KDBUS_ATTACH_CGROUP		=3D  1 <<  6,
-	KDBUS_ATTACH_CAPS		=3D  1 <<  7,
-	KDBUS_ATTACH_SECLABEL		=3D  1 <<  8,
-	KDBUS_ATTACH_AUDIT		=3D  1 <<  9,
-	KDBUS_ATTACH_CONN_NAME		=3D  1 << 10,
-	_KDBUS_ATTACH_ALL		=3D  (1 << 11) - 1,
+	KDBUS_HELLO_ACCEPT_FD		=3D  1ULL <<  0,
+	KDBUS_HELLO_ACTIVATOR		=3D  1ULL <<  1,
+	KDBUS_HELLO_POLICY_HOLDER	=3D  1ULL <<  2,
+	KDBUS_HELLO_MONITOR		=3D  1ULL <<  3,
 };
 =

 /**
  * struct kdbus_cmd_hello - struct to say hello to kdbus
  * @size:		The total size of the structure
- * @conn_flags:		Connection flags (KDBUS_HELLO_*). The kernel will
- *			return its capabilities in that field.
- * @attach_flags:	Mask of metadata to attach to each message sent
- *			(KDBUS_ATTACH_*)
+ * @flags:		Connection flags (KDBUS_HELLO_*), userspace =E2=86=92 kernel
+ * @return_flags:	Command return flags, kernel =E2=86=92 userspace
+ * @attach_flags_send:	Mask of metadata to attach to each message sent
+ *			off by this connection (KDBUS_ATTACH_*)
+ * @attach_flags_recv:	Mask of metadata to attach to each message receieved
+ *			by the new connection (KDBUS_ATTACH_*)
  * @bus_flags:		The flags field copied verbatim from the original
  *			KDBUS_CMD_BUS_MAKE ioctl. It's intended to be useful
  *			to do negotiation of features of the payload that is
@@ -540,8 +695,10 @@ enum kdbus_attach_flags {
  * @id:			The ID of this connection (kernel =E2=86=92 userspace)
  * @pool_size:		Size of the connection's buffer where the received
  *			messages are placed
- * @bloom:		The bloom properties of the bus, specified
- *			by the bus creator (kernel =E2=86=92 userspace)
+ * @offset:		Pool offset where items are returned to report
+ *			additional information about the bus and the newly
+ *			created connection.
+ * @items_size:		Size of buffer returned in the pool slice at @offset.
  * @id128:		Unique 128-bit ID of the bus (kernel =E2=86=92 userspace)
  * @items:		A list of items
  *
@@ -549,403 +706,279 @@ enum kdbus_attach_flags {
  */
 struct kdbus_cmd_hello {
 	__u64 size;
-	__u64 conn_flags;
-	__u64 attach_flags;
+	__u64 flags;
+	__u64 return_flags;
+	__u64 attach_flags_send;
+	__u64 attach_flags_recv;
 	__u64 bus_flags;
 	__u64 id;
 	__u64 pool_size;
-	struct kdbus_bloom_parameter bloom;
+	__u64 offset;
+	__u64 items_size;
 	__u8 id128[16];
 	struct kdbus_item items[0];
-} __attribute__((aligned(8)));
+} __attribute__((__aligned__(8)));
 =

 /**
- * enum kdbus_make_flags - Flags for KDBUS_CMD_{BUS,EP,NS}_MAKE
- * @KDBUS_MAKE_ACCESS_GROUP:	Make the device node group-accessible
- * @KDBUS_MAKE_ACCESS_WORLD:	Make the device node world-accessible
- */
-enum kdbus_make_flags {
-	KDBUS_MAKE_ACCESS_GROUP		=3D 1 <<  0,
-	KDBUS_MAKE_ACCESS_WORLD		=3D 1 <<  1,
-};
-
-/**
- * struct kdbus_cmd_make - struct to make a bus, an endpoint or a domain
- * @size:		The total size of the struct
- * @flags:		Properties for the bus/ep/domain to create
- * @items:		Items describing details
+ * struct kdbus_info - connection information
+ * @size:		total size of the struct
+ * @id:			64bit object ID
+ * @flags:		object creation flags
+ * @items:		list of items
  *
- * This structure is used with the KDBUS_CMD_BUS_MAKE, KDBUS_CMD_EP_MAKE a=
nd
- * KDBUS_CMD_DOMAIN_MAKE ioctls.
+ * Note that the user is responsible for freeing the allocated memory with
+ * the KDBUS_CMD_FREE ioctl.
  */
-struct kdbus_cmd_make {
+struct kdbus_info {
 	__u64 size;
+	__u64 id;
 	__u64 flags;
 	struct kdbus_item items[0];
-} __attribute__((aligned(8)));
+} __attribute__((__aligned__(8)));
 =

 /**
- * enum kdbus_name_flags - properties of a well-known name
- * @KDBUS_NAME_REPLACE_EXISTING:	Try to replace name of other connections
- * @KDBUS_NAME_ALLOW_REPLACEMENT:	Allow the replacement of the name
- * @KDBUS_NAME_QUEUE:			Name should be queued if busy
- * @KDBUS_NAME_IN_QUEUE:		Name is queued
- * @KDBUS_NAME_ACTIVATOR:		Name is owned by a activator connection
+ * enum kdbus_list_flags - what to include into the returned list
+ * @KDBUS_LIST_UNIQUE:		active connections
+ * @KDBUS_LIST_ACTIVATORS:	activator connections
+ * @KDBUS_LIST_NAMES:		known well-known names
+ * @KDBUS_LIST_QUEUED:		queued-up names
  */
-enum kdbus_name_flags {
-	KDBUS_NAME_REPLACE_EXISTING	=3D 1 <<  0,
-	KDBUS_NAME_ALLOW_REPLACEMENT	=3D 1 <<  1,
-	KDBUS_NAME_QUEUE		=3D 1 <<  2,
-	KDBUS_NAME_IN_QUEUE		=3D 1 <<  3,
-	KDBUS_NAME_ACTIVATOR		=3D 1 <<  4,
+enum kdbus_list_flags {
+	KDBUS_LIST_UNIQUE		=3D 1ULL <<  0,
+	KDBUS_LIST_NAMES		=3D 1ULL <<  1,
+	KDBUS_LIST_ACTIVATORS		=3D 1ULL <<  2,
+	KDBUS_LIST_QUEUED		=3D 1ULL <<  3,
 };
 =

 /**
- * struct kdbus_cmd_name - struct to describe a well-known name
- * @size:		The total size of the struct
- * @flags:		Flags for a name entry (KDBUS_NAME_*)
- * @owner_id:		The current owner of the name.
- * @conn_flags:		The flags of the owning connection (KDBUS_HELLO_*)
- * @name:		The well-known name
- *
- * This structure is used with the KDBUS_CMD_NAME_ACQUIRE ioctl.
- */
-struct kdbus_cmd_name {
-	__u64 size;
-	__u64 flags;
-	__u64 owner_id;
-	__u64 conn_flags;
-	char name[0];
-} __attribute__((aligned(8)));
-
-/**
- * enum kdbus_name_list_flags - what to include into the returned list
- * @KDBUS_NAME_LIST_UNIQUE:	All active connections
- * @KDBUS_NAME_LIST_NAMES:	All known well-known names
- * @KDBUS_NAME_LIST_ACTIVATORS:	All activator connections
- * @KDBUS_NAME_LIST_QUEUED:	All queued-up names
- */
-enum kdbus_name_list_flags {
-	KDBUS_NAME_LIST_UNIQUE		=3D 1 <<  0,
-	KDBUS_NAME_LIST_NAMES		=3D 1 <<  1,
-	KDBUS_NAME_LIST_ACTIVATORS	=3D 1 <<  2,
-	KDBUS_NAME_LIST_QUEUED		=3D 1 <<  3,
-};
-
-/**
- * struct kdbus_cmd_name_list - request a list of name entries
- * @flags:		Flags for the query (KDBUS_NAME_LIST_*)
- * @offset:		The returned offset in the caller's pool buffer.
+ * struct kdbus_cmd_list - list connections
+ * @size:		overall size of this object
+ * @flags:		flags for the query (KDBUS_LIST_*), userspace =E2=86=92 kernel
+ * @return_flags:	command return flags, kernel =E2=86=92 userspace
+ * @offset:		Offset in the caller's pool buffer where an array of
+ *			kdbus_info objects is stored.
  *			The user must use KDBUS_CMD_FREE to free the
  *			allocated memory.
+ * @list_size:		size of returned list in bytes
+ * @items:		Items for the command. Reserved for future use.
  *
- * This structure is used with the KDBUS_CMD_NAME_LIST ioctl.
+ * This structure is used with the KDBUS_CMD_LIST ioctl.
  */
-struct kdbus_cmd_name_list {
+struct kdbus_cmd_list {
+	__u64 size;
 	__u64 flags;
+	__u64 return_flags;
 	__u64 offset;
-} __attribute__((aligned(8)));
-
-/**
- * struct kdbus_name_list - information returned by KDBUS_CMD_NAME_LIST
- * @size:		The total size of the structure
- * @names:		A list of names
- *
- * Note that the user is responsible for freeing the allocated memory with
- * the KDBUS_CMD_FREE ioctl.
- */
-struct kdbus_name_list {
-	__u64 size;
-	struct kdbus_cmd_name names[0];
-};
+	__u64 list_size;
+	struct kdbus_item items[0];
+} __attribute__((__aligned__(8)));
 =

 /**
- * struct kdbus_cmd_conn_info - struct used for KDBUS_CMD_CONN_INFO ioctl
+ * struct kdbus_cmd_info - struct used for KDBUS_CMD_CONN_INFO ioctl
  * @size:		The total size of the struct
- * @flags:		KDBUS_ATTACH_* flags
+ * @flags:		Flags for this ioctl, userspace =E2=86=92 kernel
+ * @return_flags:	Command return flags, kernel =E2=86=92 userspace
  * @id:			The 64-bit ID of the connection. If set to zero, passing
  *			@name is required. kdbus will look up the name to
  *			determine the ID in this case.
+ * @attach_flags:	Set of attach flags to specify the set of information
+ *			to receive, userspace =E2=86=92 kernel
  * @offset:		Returned offset in the caller's pool buffer where the
- *			kdbus_conn_info struct result is stored. The user must
+ *			kdbus_info struct result is stored. The user must
  *			use KDBUS_CMD_FREE to free the allocated memory.
- * @name:		The optional well-known name to look up. Only needed in
- *			case @id is zero.
+ * @info_size:		Output buffer to report size of data at @offset.
+ * @items:		The optional item list, containing the
+ *			well-known name to look up as a KDBUS_ITEM_NAME.
+ *			Only needed in case @id is zero.
  *
  * On success, the KDBUS_CMD_CONN_INFO ioctl will return 0 and @offset will
  * tell the user the offset in the connection pool buffer at which to find=
 the
- * result in a struct kdbus_conn_info.
+ * result in a struct kdbus_info.
  */
-struct kdbus_cmd_conn_info {
+struct kdbus_cmd_info {
 	__u64 size;
 	__u64 flags;
+	__u64 return_flags;
 	__u64 id;
+	__u64 attach_flags;
 	__u64 offset;
-	char name[0];
-} __attribute__((aligned(8)));
-
-/**
- * struct kdbus_conn_info - information returned by KDBUS_CMD_CONN_INFO
- * @size:		The total size of the struct
- * @id:			The connection's 64-bit ID
- * @flags:		The connection's flags
- * @items:		A list of struct kdbus_item
- *
- * Note that the user is responsible for freeing the allocated memory with
- * the KDBUS_CMD_FREE ioctl.
- */
-struct kdbus_conn_info {
-	__u64 size;
-	__u64 id;
-	__u64 flags;
+	__u64 info_size;
 	struct kdbus_item items[0];
-};
+} __attribute__((__aligned__(8)));
 =

 /**
- * struct kdbus_cmd_update - update flags of a connection
- * @size:		The total size of the struct
- * @items:		A list of struct kdbus_item
- *
- * This struct is used with the KDBUS_CMD_CONN_UPDATE ioctl.
+ * enum kdbus_cmd_match_flags - flags to control the KDBUS_CMD_MATCH_ADD i=
octl
+ * @KDBUS_MATCH_REPLACE:	If entries with the supplied cookie already
+ *				exists, remove them before installing the new
+ *				matches.
  */
-struct kdbus_cmd_update {
-	__u64 size;
-	struct kdbus_item items[0];
-} __attribute__((aligned(8)));
+enum kdbus_cmd_match_flags {
+	KDBUS_MATCH_REPLACE	=3D 1ULL <<  0,
+};
 =

 /**
  * struct kdbus_cmd_match - struct to add or remove matches
  * @size:		The total size of the struct
+ * @flags:		Flags for match command (KDBUS_MATCH_*),
+ *			userspace =E2=86=92 kernel
+ * @return_flags:	Command return flags, kernel =E2=86=92 userspace
  * @cookie:		Userspace supplied cookie. When removing, the cookie
  *			identifies the match to remove
  * @items:		A list of items for additional information
  *
- * This structure is used with the KDBUS_CMD_ADD_MATCH and
- * KDBUS_CMD_REMOVE_MATCH ioctl.
+ * This structure is used with the KDBUS_CMD_MATCH_ADD and
+ * KDBUS_CMD_MATCH_REMOVE ioctl.
  */
 struct kdbus_cmd_match {
 	__u64 size;
+	__u64 flags;
+	__u64 return_flags;
 	__u64 cookie;
 	struct kdbus_item items[0];
-} __attribute__((aligned(8)));
+} __attribute__((__aligned__(8)));
 =

 /**
- * struct kdbus_cmd_memfd_make - create a kdbus memfd
- * @size:		The total size of the struct
- * @file_size:		The initial file size
- * @fd:			The returned file descriptor number
- * @__pad:		Padding to ensure proper alignement
- * @items:		A list of items for additional information
+ * enum kdbus_make_flags - Flags for KDBUS_CMD_{BUS,ENDPOINT}_MAKE
+ * @KDBUS_MAKE_ACCESS_GROUP:	Make the bus or endpoint node group-accessible
+ * @KDBUS_MAKE_ACCESS_WORLD:	Make the bus or endpoint node world-accessible
+ */
+enum kdbus_make_flags {
+	KDBUS_MAKE_ACCESS_GROUP		=3D 1ULL <<  0,
+	KDBUS_MAKE_ACCESS_WORLD		=3D 1ULL <<  1,
+};
+
+/**
+ * enum kdbus_name_flags - flags for KDBUS_CMD_NAME_ACQUIRE
+ * @KDBUS_NAME_REPLACE_EXISTING:	Try to replace name of other connections
+ * @KDBUS_NAME_ALLOW_REPLACEMENT:	Allow the replacement of the name
+ * @KDBUS_NAME_QUEUE:			Name should be queued if busy
+ * @KDBUS_NAME_IN_QUEUE:		Name is queued
+ * @KDBUS_NAME_ACTIVATOR:		Name is owned by a activator connection
+ * @KDBUS_NAME_PRIMARY:			Primary owner of the name
+ * @KDBUS_NAME_ACQUIRED:		Name was acquired/queued _now_
+ */
+enum kdbus_name_flags {
+	KDBUS_NAME_REPLACE_EXISTING	=3D 1ULL <<  0,
+	KDBUS_NAME_ALLOW_REPLACEMENT	=3D 1ULL <<  1,
+	KDBUS_NAME_QUEUE		=3D 1ULL <<  2,
+	KDBUS_NAME_IN_QUEUE		=3D 1ULL <<  3,
+	KDBUS_NAME_ACTIVATOR		=3D 1ULL <<  4,
+	KDBUS_NAME_PRIMARY		=3D 1ULL <<  5,
+	KDBUS_NAME_ACQUIRED		=3D 1ULL <<  6,
+};
+
+/**
+ * struct kdbus_cmd - generic ioctl payload
+ * @size:		Overall size of this structure
+ * @flags:		Flags for this ioctl, userspace =E2=86=92 kernel
+ * @return_flags:	Ioctl return flags, kernel =E2=86=92 userspace
+ * @items:		Additional items to modify the behavior
  *
- * This structure is used with the KDBUS_CMD_MEMFD_NEW ioctl.
+ * This is a generic ioctl payload object. It's used by all ioctls that on=
ly
+ * take flags and items as input.
  */
-struct kdbus_cmd_memfd_make {
+struct kdbus_cmd {
 	__u64 size;
-	__u64 file_size;
-	int fd;
-	__u32 __pad;
+	__u64 flags;
+	__u64 return_flags;
 	struct kdbus_item items[0];
-} __attribute__((aligned(8)));
+} __attribute__((__aligned__(8)));
 =

 /**
- * enum kdbus_ioctl_type - Ioctl API
- * @KDBUS_CMD_BUS_MAKE:		After opening the "control" device node, this
- *				command creates a new bus with the specified
+ * Ioctl API
+ *
+ * KDBUS_CMD_BUS_MAKE:		After opening the "control" node, this command
+ *				creates a new bus with the specified
  *				name. The bus is immediately shut down and
- *				cleaned up when the opened "control" device node
- *				is closed.
- * @KDBUS_CMD_DOMAIN_MAKE:	Similar to KDBUS_CMD_BUS_MAKE, but it creates a
- *				new kdbus domain.
- * @KDBUS_CMD_EP_MAKE:		Creates a new named special endpoint to talk to
+ *				cleaned up when the opened file descriptor is
+ *				closed.
+ *
+ * KDBUS_CMD_ENDPOINT_MAKE:	Creates a new named special endpoint to talk to
  *				the bus. Such endpoints usually carry a more
  *				restrictive policy and grant restricted access
  *				to specific applications.
- * @KDBUS_CMD_HELLO:		By opening the bus device node a connection is
+ * KDBUS_CMD_ENDPOINT_UPDATE:	Update the properties of a custom enpoint. U=
sed
+ *				to update the policy.
+ *
+ * KDBUS_CMD_HELLO:		By opening the bus node, a connection is
  *				created. After a HELLO the opened connection
  *				becomes an active peer on the bus.
- * @KDBUS_CMD_BYEBYE:		Disconnect a connection. If the connection's
- *				message list is empty, the calls succeeds, and
- *				the handle is rendered unusable. Otherwise,
- *				-EAGAIN is returned without any further side-
- *				effects.
- * @KDBUS_CMD_MSG_SEND:		Send a message and pass data from userspace to
+ * KDBUS_CMD_UPDATE:		Update the properties of a connection. Used to
+ *				update the metadata subscription mask and
+ *				policy.
+ * KDBUS_CMD_BYEBYE:		Disconnect a connection. If there are no
+ *				messages queued up in the connection's pool,
+ *				the call succeeds, and the handle is rendered
+ *				unusable. Otherwise, -EBUSY is returned without
+ *				any further side-effects.
+ * KDBUS_CMD_FREE:		Release the allocated memory in the receiver's
+ *				pool.
+ * KDBUS_CMD_CONN_INFO:		Retrieve credentials and properties of the
+ *				initial creator of the connection. The data was
+ *				stored at registration time and does not
+ *				necessarily represent the connected process or
+ *				the actual state of the process.
+ * KDBUS_CMD_BUS_CREATOR_INFO:	Retrieve information of the creator of the =
bus
+ *				a connection is attached to.
+ *
+ * KDBUS_CMD_SEND:		Send a message and pass data from userspace to
  *				the kernel.
- * @KDBUS_CMD_MSG_RECV:		Receive a message from the kernel which is
+ * KDBUS_CMD_RECV:		Receive a message from the kernel which is
  *				placed in the receiver's pool.
- * @KDBUS_CMD_MSG_CANCEL:	Cancel a pending request of a message that
- *				blocks while waiting for a reply. The parameter
- *				denotes the cookie of the message in flight.
- * @KDBUS_CMD_FREE:		Release the allocated memory in the receiver's
- *				pool.
- * @KDBUS_CMD_NAME_ACQUIRE:	Request a well-known bus name to associate with
+ *
+ * KDBUS_CMD_NAME_ACQUIRE:	Request a well-known bus name to associate with
  *				the connection. Well-known names are used to
  *				address a peer on the bus.
- * @KDBUS_CMD_NAME_RELEASE:	Release a well-known name the connection
+ * KDBUS_CMD_NAME_RELEASE:	Release a well-known name the connection
  *				currently owns.
- * @KDBUS_CMD_NAME_LIST:	Retrieve the list of all currently registered
+ * KDBUS_CMD_LIST:		Retrieve the list of all currently registered
  *				well-known and unique names.
- * @KDBUS_CMD_CONN_INFO:	Retrieve credentials and properties of the
- *				initial creator of the connection. The data was
- *				stored at registration time and does not
- *				necessarily represent the connected process or
- *				the actual state of the process.
- * @KDBUS_CMD_CONN_UPDATE:	Update the properties of a connection. Used to
- *				update the metadata subscription mask and
- *				policy.
- * @KDBUS_CMD_EP_UPDATE:	Update the properties of a custom enpoint. Used
- *				to update the policy.
- * @KDBUS_CMD_MATCH_ADD:	Install a match which broadcast messages should
+ *
+ * KDBUS_CMD_MATCH_ADD:		Install a match which broadcast messages should
  *				be delivered to the connection.
- * @KDBUS_CMD_MATCH_REMOVE:	Remove a current match for broadcast messages.
- * @KDBUS_CMD_MEMFD_NEW:	Return a new file descriptor which provides an
- *				anonymous shared memory file and which can be
- *				used to pass around larger chunks of data.
- *				Kdbus memfd files can be sealed, which allows
- *				the receiver to trust the data it has received.
- *				Kdbus memfd files expose only very limited
- *				operations, they can be mmap()ed, seek()ed,
- *				(p)read(v)() and (p)write(v)(); most other
- *				common file operations are not implemented.
- *				Special caution needs to be taken with
- *				read(v)()/write(v)() on a shared file; the
- *				underlying file position is always shared
- *				between all users of the file and race against
- *				each other, pread(v)()/pwrite(v)() avoid these
- *				issues.
- * @KDBUS_CMD_MEMFD_SIZE_GET:	Return the size of the underlying file, which
- *				changes with write().
- * @KDBUS_CMD_MEMFD_SIZE_SET:	Truncate the underlying file to the specified
- *				size.
- * @KDBUS_CMD_MEMFD_SEAL_GET:	Return the state of the file sealing.
- * @KDBUS_CMD_MEMFD_SEAL_SET:	Seal or break a seal of the file. Only files
- *				which are not shared with other processes and
- *				which are currently not mapped can be sealed.
- *				The current process needs to be the one and
- *				single owner of the file, the sealing cannot
- *				be changed as long as the file is shared.
+ * KDBUS_CMD_MATCH_REMOVE:	Remove a current match for broadcast messages.
  */
 enum kdbus_ioctl_type {
+	/* bus owner (00-0f) */
 	KDBUS_CMD_BUS_MAKE =3D		_IOW(KDBUS_IOCTL_MAGIC, 0x00,
-					     struct kdbus_cmd_make),
-	KDBUS_CMD_DOMAIN_MAKE =3D		_IOW(KDBUS_IOCTL_MAGIC, 0x10,
-					     struct kdbus_cmd_make),
-	KDBUS_CMD_EP_MAKE =3D		_IOW(KDBUS_IOCTL_MAGIC, 0x20,
-					     struct kdbus_cmd_make),
+					     struct kdbus_cmd),
 =

-	KDBUS_CMD_HELLO =3D		_IOWR(KDBUS_IOCTL_MAGIC, 0x30,
+	/* endpoint owner (10-1f) */
+	KDBUS_CMD_ENDPOINT_MAKE =3D	_IOW(KDBUS_IOCTL_MAGIC, 0x10,
+					     struct kdbus_cmd),
+	KDBUS_CMD_ENDPOINT_UPDATE =3D	_IOW(KDBUS_IOCTL_MAGIC, 0x11,
+					     struct kdbus_cmd),
+
+	/* connection owner (80-ff) */
+	KDBUS_CMD_HELLO =3D		_IOWR(KDBUS_IOCTL_MAGIC, 0x80,
 					      struct kdbus_cmd_hello),
-	KDBUS_CMD_BYEBYE =3D		_IO(KDBUS_IOCTL_MAGIC, 0x31),
-
-	KDBUS_CMD_MSG_SEND =3D		_IOWR(KDBUS_IOCTL_MAGIC, 0x40,
-					      struct kdbus_msg),
-	KDBUS_CMD_MSG_RECV =3D		_IOWR(KDBUS_IOCTL_MAGIC, 0x41,
-					      struct kdbus_cmd_recv),
-	KDBUS_CMD_MSG_CANCEL =3D		_IOW(KDBUS_IOCTL_MAGIC, 0x42, __u64 *),
-	KDBUS_CMD_FREE =3D		_IOW(KDBUS_IOCTL_MAGIC, 0x43, __u64 *),
-
-	KDBUS_CMD_NAME_ACQUIRE =3D	_IOWR(KDBUS_IOCTL_MAGIC, 0x50,
-					      struct kdbus_cmd_name),
-	KDBUS_CMD_NAME_RELEASE =3D	_IOW(KDBUS_IOCTL_MAGIC, 0x51,
-					     struct kdbus_cmd_name),
-	KDBUS_CMD_NAME_LIST =3D		_IOWR(KDBUS_IOCTL_MAGIC, 0x52,
-					     struct kdbus_cmd_name_list),
-
-	KDBUS_CMD_CONN_INFO =3D		_IOWR(KDBUS_IOCTL_MAGIC, 0x60,
-					      struct kdbus_cmd_conn_info),
-	KDBUS_CMD_CONN_UPDATE =3D		_IOW(KDBUS_IOCTL_MAGIC, 0x61,
-					     struct kdbus_cmd_update),
-
-	KDBUS_CMD_EP_UPDATE =3D		_IOW(KDBUS_IOCTL_MAGIC, 0x71,
-					     struct kdbus_cmd_update),
-
-	KDBUS_CMD_MATCH_ADD =3D		_IOW(KDBUS_IOCTL_MAGIC, 0x80,
+	KDBUS_CMD_UPDATE =3D		_IOW(KDBUS_IOCTL_MAGIC, 0x81,
+					     struct kdbus_cmd),
+	KDBUS_CMD_BYEBYE =3D		_IOW(KDBUS_IOCTL_MAGIC, 0x82,
+					     struct kdbus_cmd),
+	KDBUS_CMD_FREE =3D		_IOW(KDBUS_IOCTL_MAGIC, 0x83,
+					     struct kdbus_cmd_free),
+	KDBUS_CMD_CONN_INFO =3D		_IOR(KDBUS_IOCTL_MAGIC, 0x84,
+					     struct kdbus_cmd_info),
+	KDBUS_CMD_BUS_CREATOR_INFO =3D	_IOR(KDBUS_IOCTL_MAGIC, 0x85,
+					     struct kdbus_cmd_info),
+	KDBUS_CMD_LIST =3D		_IOR(KDBUS_IOCTL_MAGIC, 0x86,
+					     struct kdbus_cmd_list),
+
+	KDBUS_CMD_SEND =3D		_IOW(KDBUS_IOCTL_MAGIC, 0x90,
+					     struct kdbus_cmd_send),
+	KDBUS_CMD_RECV =3D		_IOR(KDBUS_IOCTL_MAGIC, 0x91,
+					     struct kdbus_cmd_recv),
+
+	KDBUS_CMD_NAME_ACQUIRE =3D	_IOW(KDBUS_IOCTL_MAGIC, 0xa0,
+					     struct kdbus_cmd),
+	KDBUS_CMD_NAME_RELEASE =3D	_IOW(KDBUS_IOCTL_MAGIC, 0xa1,
+					     struct kdbus_cmd),
+
+	KDBUS_CMD_MATCH_ADD =3D		_IOW(KDBUS_IOCTL_MAGIC, 0xb0,
 					     struct kdbus_cmd_match),
-	KDBUS_CMD_MATCH_REMOVE =3D	_IOW(KDBUS_IOCTL_MAGIC, 0x81,
+	KDBUS_CMD_MATCH_REMOVE =3D	_IOW(KDBUS_IOCTL_MAGIC, 0xb1,
 					     struct kdbus_cmd_match),
-
-	KDBUS_CMD_MEMFD_NEW =3D		_IOWR(KDBUS_IOCTL_MAGIC, 0xc0,
-					      struct kdbus_cmd_memfd_make),
-	KDBUS_CMD_MEMFD_SIZE_GET =3D	_IOR(KDBUS_IOCTL_MAGIC, 0xc1, __u64 *),
-	KDBUS_CMD_MEMFD_SIZE_SET =3D	_IOW(KDBUS_IOCTL_MAGIC, 0xc2, __u64 *),
-	KDBUS_CMD_MEMFD_SEAL_GET =3D	_IOR(KDBUS_IOCTL_MAGIC, 0xc3, int *),
-	KDBUS_CMD_MEMFD_SEAL_SET =3D	_IO(KDBUS_IOCTL_MAGIC, 0xc4),
 };
 =

-/*
- * errno - api error codes
- * @E2BIG:		A message contains too many records or items.
- * @EADDRINUSE:		A well-known bus name is already taken by another
- *			connection.
- * @EADDRNOTAVAIL:	A message flagged not to activate a service, addressed
- *			a service which is not currently running.
- * @EAGAIN:		No messages are queued@the moment.
- * @EALREADY:		A requested name is already owned by the connection,
- *			a connection is already disconnected, memfd is already
- *			sealed or has the requested size.
- * @EBADF:		File descriptors passed with the message are not valid.
- * @EBADFD:		A bus connection is in a corrupted state.
- * @EBADMSG:		Passed data contains a combination of conflicting or
- *			inconsistent types.
- * @EBUSY:		The user tried to say BYEBYE to a connection, but the
- *			connection had a non-empty message list.
- * @ECANCELED:		A synchronous message sending was cancelled.
- * @ECONNRESET:		A connection is shut down, no further operations are
- *			possible.
- * @ECOMM:		A peer does not accept the file descriptors addressed
- *			to it.
- * @EDESTADDRREQ:	The well-known bus name is required but missing.
- * @EDOM:		The size of data does not match the expectations. Used
- *			for bloom bit field sizes.
- * @EEXIST:		A requested domain, bus or endpoint with the same
- *			name already exists.  A specific data type, which is
- *			only expected once, is provided multiple times.
- * @EFAULT:		The supplied memory could not be accessed, or the data
- *			is not properly aligned.
- * @EINVAL:		The provided data does not match its type or other
- *			expectations, like a string which is not NUL terminated,
- *			or a string length that points behind the first
- *			\0-byte in the string.
- * @EMEDIUMTYPE:	A file descriptor which is not a kdbus memfd was
- *			refused to send as KDBUS_MSG_PAYLOAD_MEMFD.
- * @EMFILE:		Too many file descriptors have been supplied with a
- *			message.
- *			Too many connections or buses are created for a given
- *			user.
- * @EMLINK:		Too many requests from this connection to other peers
- *			are queued and waiting for a reply
- * @EMSGSIZE:		The supplied data is larger than the allowed maximum
- *			size.
- * @ENAMETOOLONG:	The requested name is larger than the allowed maximum
- *			size.
- * @ENOBUFS:		There is no space left for the submitted data to fit
- *			into the receiver's pool.
- * @ENOENT:		The to be cancelled message was not found.
- * @ENOMEM:		Out of memory.
- * @ENOMSG:		The queue is not empty, but no message with a matching
- *			priority is currently queued.
- * @ENOSYS:		The requested functionality is not available.
- * @ENOTTY:		An unknown ioctl command was received.
- * @ENOTUNIQ:		A specific data type was addressed to a broadcast
- *			address, but only direct addresses support this kind of
- *			data.
- * @ENXIO:		A unique address does not exist, or an offset in the
- *			receiver's pool does not represent a queued message.
- * @EOPNOTSUPP:		The feature negotiation failed, a not supported feature
- *			was requested, or an unknown item type was received.
- * @EPERM:		The policy prevented an operation. The requested
- *			resource is owned by another entity.
- * @EPIPE:		When sending a message, a synchronous reply from the
- *			receiving connection was expected but the connection
- *			died before answering.
- * @ESHUTDOWN:		A domain, bus or endpoint is currently shutting down;
- *			no further operations will be possible.
- * @ESRCH:		A requested well-known bus name is not found.
- * @ETIMEDOUT:		A synchronous wait for a message reply did not arrive
- *			within the specified time frame.
- * @ETXTBSY:		A kdbus memfd file cannot be sealed or the seal removed,
- *			because it is shared with other processes or still
- *			mmap()ed.
- * @EXFULL:		The size limits in the pool are reached, no data of
- *			the size tried to submit can be queued.
- */
-#endif
+#endif /* _UAPI_KDBUS_H_ */
-- =

2.5.0


--===============5733727490087995327==--

