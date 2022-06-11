Content-Type: multipart/mixed; boundary="===============5648133505587242717=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 2/3] genl,netlink: Move extended ACK code to netlink-private
Date: Sat, 11 Jun 2022 03:45:44 +0200
Message-ID: <20220611014545.1466270-2-andrew.zaborowski@intel.com>
In-Reply-To: 20220611014545.1466270-1-andrew.zaborowski@intel.com

--===============5648133505587242717==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Since extended ACK parsing can be also useful for rtnl, move it from
genl.c to netlink.c and declare in netlink-private.h.
---
 ell/genl.c            | 61 ++++---------------------------------------
 ell/netlink-private.h | 15 +++++++++++
 ell/netlink.c         | 56 ++++++++++++++++++++++++++++++++++++++-
 3 files changed, 75 insertions(+), 57 deletions(-)

diff --git a/ell/genl.c b/ell/genl.c
index 61b7b3a..c6965db 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -33,9 +33,9 @@
 #include "log.h"
 #include "queue.h"
 #include "io.h"
+#include "private.h"
 #include "netlink-private.h"
 #include "genl.h"
-#include "private.h"
 =

 #define MAX_NESTING_LEVEL 4
 #define GENL_DEBUG(fmt, args...)	\
@@ -722,17 +722,6 @@ static bool match_request_hid(const void *a, const voi=
d *b)
 	return request->handle_id =3D=3D id;
 }
 =

-#define NLA_OK(nla,len)         ((len) >=3D (int) sizeof(struct nlattr) &&=
 \
-				(nla)->nla_len >=3D sizeof(struct nlattr) && \
-				(nla)->nla_len <=3D (len))
-#define NLA_NEXT(nla,attrlen)	((attrlen) -=3D NLMSG_ALIGN((nla)->nla_len),=
 \
-				(struct nlattr*)(((char*)(nla)) + \
-				NLMSG_ALIGN((nla)->nla_len)))
-
-#define NLA_LENGTH(len)		(NLMSG_ALIGN(sizeof(struct nlattr)) + (len))
-#define NLA_DATA(nla)		((void*)(((char*)(nla)) + NLA_LENGTH(0)))
-#define NLA_PAYLOAD(nla)	((int)((nla)->nla_len) - NLA_LENGTH(0))
-
 static struct l_genl_msg *msg_alloc(uint8_t cmd, uint8_t version, uint32_t=
 size)
 {
 	struct l_genl_msg *msg;
@@ -774,52 +763,13 @@ static bool msg_grow(struct l_genl_msg *msg, uint32_t=
 needed)
 static struct l_genl_msg *msg_create(const struct nlmsghdr *nlmsg)
 {
 	struct l_genl_msg *msg;
+	const char *error_msg =3D NULL;
 =

 	msg =3D l_new(struct l_genl_msg, 1);
 =

-	if (nlmsg->nlmsg_type =3D=3D NLMSG_ERROR) {
-		struct nlmsgerr *err =3D NLMSG_DATA(nlmsg);
-		unsigned int offset =3D 0;
-		struct nlattr *nla;
-		int len;
-
-		msg->error =3D err->error;
-
-		if (!(nlmsg->nlmsg_flags & NLM_F_ACK_TLVS))
-			goto done;
-
-		/*
-		 * If the message is capped, then err->msg.nlmsg_len contains
-		 * the length of the original message and thus can't be used
-		 * to calculate the offset
-		 */
-		if (!(nlmsg->nlmsg_flags & NLM_F_CAPPED))
-			offset =3D err->msg.nlmsg_len - sizeof(struct nlmsghdr);
-
-		/*
-		 * Attributes start past struct nlmsgerr.  The offset is 0
-		 * for NLM_F_CAPPED messages.  Otherwise the original message
-		 * is included, and thus the offset takes err->msg.nlmsg_len
-		 * into account
-		 */
-		nla =3D (void *)(err + 1) + offset;
-
-		/* Calculate bytes taken up by header + nlmsgerr contents */
-		offset +=3D sizeof(struct nlmsghdr) + sizeof(struct nlmsgerr);
-		if (nlmsg->nlmsg_len <=3D offset)
-			goto done;
-
-		len =3D nlmsg->nlmsg_len - offset;
-
-		for (; NLA_OK(nla, len); nla =3D NLA_NEXT(nla, len)) {
-			if ((nla->nla_type & NLA_TYPE_MASK) !=3D
-					NLMSGERR_ATTR_MSG)
-				continue;
-
-			msg->error_msg =3D l_strdup(NLA_DATA(nla));
-			goto done;
-		}
-	}
+	if (netlink_parse_ext_ack(nlmsg, &error_msg, NULL) &&
+			error_msg)
+		msg->error_msg =3D l_strdup(error_msg);
 =

 	msg->data =3D l_memdup(nlmsg, nlmsg->nlmsg_len);
 =

@@ -833,7 +783,6 @@ static struct l_genl_msg *msg_create(const struct nlmsg=
hdr *nlmsg)
 		msg->version =3D genlmsg->version;
 	}
 =

-done:
 	return l_genl_msg_ref(msg);
 }
 =

diff --git a/ell/netlink-private.h b/ell/netlink-private.h
index fff30af..fab0ab9 100644
--- a/ell/netlink-private.h
+++ b/ell/netlink-private.h
@@ -23,3 +23,18 @@
 #ifndef SOL_NETLINK
 #define SOL_NETLINK 270
 #endif
+
+#define NLA_OK(nla,len)         ((len) >=3D (int) sizeof(struct nlattr) &&=
 \
+				(nla)->nla_len >=3D sizeof(struct nlattr) && \
+				(nla)->nla_len <=3D (len))
+#define NLA_NEXT(nla,attrlen)	((attrlen) -=3D NLMSG_ALIGN((nla)->nla_len),=
 \
+				(struct nlattr*)(((char*)(nla)) + \
+				NLMSG_ALIGN((nla)->nla_len)))
+
+#define NLA_LENGTH(len)		(NLMSG_ALIGN(sizeof(struct nlattr)) + (len))
+#define NLA_DATA(nla)		((void*)(((char*)(nla)) + NLA_LENGTH(0)))
+#define NLA_PAYLOAD(nla)	((int)((nla)->nla_len) - NLA_LENGTH(0))
+
+bool netlink_parse_ext_ack(const struct nlmsghdr *nlmsg,
+				const char **out_error_msg,
+				uint32_t *out_error_offset);
diff --git a/ell/netlink.c b/ell/netlink.c
index 4b6d800..32d021b 100644
--- a/ell/netlink.c
+++ b/ell/netlink.c
@@ -32,9 +32,9 @@
 #include "hashmap.h"
 #include "queue.h"
 #include "io.h"
+#include "private.h"
 #include "netlink-private.h"
 #include "netlink.h"
-#include "private.h"
 =

 struct command {
 	unsigned int id;
@@ -611,3 +611,57 @@ LIB_EXPORT bool l_netlink_set_debug(struct l_netlink *=
netlink,
 =

 	return true;
 }
+
+bool netlink_parse_ext_ack(const struct nlmsghdr *nlmsg,
+				const char **out_error_msg,
+				uint32_t *out_error_offset)
+{
+	const struct nlmsgerr *err;
+	unsigned int offset =3D 0;
+	struct nlattr *nla;
+	int len;
+
+	if (nlmsg->nlmsg_type !=3D NLMSG_ERROR ||
+			!(nlmsg->nlmsg_flags & NLM_F_ACK_TLVS))
+		return false;
+
+	err =3D NLMSG_DATA(nlmsg);
+
+	/*
+	 * If the message is capped, then err->msg.nlmsg_len contains the
+	 * length of the original message and thus can't be used to
+	 * calculate the offset.
+	 */
+	if (!(nlmsg->nlmsg_flags & NLM_F_CAPPED))
+		offset =3D err->msg.nlmsg_len - sizeof(struct nlmsghdr);
+
+	/*
+	 * Attributes start past struct nlmsgerr.  The offset is 0 for
+	 * NLM_F_CAPPED messages.  Otherwise the original message is
+	 * included, and thus the offset takes err->msg.nlmsg_len into
+	 * account.
+	 */
+	nla =3D (void *)(err + 1) + offset;
+
+	/* Calculate bytes taken up by header + nlmsgerr contents */
+	offset +=3D sizeof(struct nlmsghdr) + sizeof(struct nlmsgerr);
+	if (nlmsg->nlmsg_len <=3D offset)
+		return false;
+
+	len =3D nlmsg->nlmsg_len - offset;
+
+	for (; NLA_OK(nla, len); nla =3D NLA_NEXT(nla, len)) {
+		switch (nla->nla_type & NLA_TYPE_MASK) {
+		case NLMSGERR_ATTR_MSG:
+			if (out_error_msg)
+				*out_error_msg =3D NLA_DATA(nla);
+			break;
+		case NLMSGERR_ATTR_OFFS:
+			if (out_error_offset)
+				*out_error_offset =3D l_get_u32(NLA_DATA(nla));
+			break;
+		}
+	}
+
+	return true;
+}
-- =

2.34.1

--===============5648133505587242717==--

