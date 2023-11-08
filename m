Received: from mail-oa1-f45.google.com (mail-oa1-f45.google.com [209.85.160.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 52660374E3
	for <ell@lists.linux.dev>; Wed,  8 Nov 2023 23:46:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TPFXGRwg"
Received: by mail-oa1-f45.google.com with SMTP id 586e51a60fabf-1f0f94a08a0so134119fac.2
        for <ell@lists.linux.dev>; Wed, 08 Nov 2023 15:46:37 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1699487195; x=1700091995; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=3ysg522WjRLjCaiB8xOVGVDlh6PFsLP8odaA3WKDiJc=;
        b=TPFXGRwgeSk+6ARmt7l/dPib0GpkV7rlmQNsr8pN5HOFVTMvZolRQhlkehZW1sut8P
         ira5Q0+q+UNK/I8FEf3ZVqk0cYGLAY9Dswatzb8nVDuBy6Si1ITK7d6eZKMGL1dHUf8u
         H9W7Zv9skZe1P0w+XxR8Kp3bonAk8CO8GStJ5+Z2XJb6ZPm88YNb4w/F6af3J0lpac6w
         0ukz2GBpv80GkKmMMn9ZrnGlRmOwFm0hxS3nRIE6VQ53ckK1CoWlp/BY64etoCocGK+r
         Og5p6uU8jS5gYOZcDU3hwBpjVLGZf/3VljvxH/G6fR/i/5p+Cn/qEFDc7C4uHdDSR5kf
         HgAw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1699487195; x=1700091995;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=3ysg522WjRLjCaiB8xOVGVDlh6PFsLP8odaA3WKDiJc=;
        b=uPlPc2Fd/uFDlq/KuzVJr0OdUz+l/hno3HuMi9IAFXYzJiNEVjkwvM6kBreAcvwZlC
         bw1qb3Ahzg22b1WFMCxHOMGSCQ87E5Uvtzszq+dNU6hsCYElXmK0a5ATxWlLsSicEEOr
         /zj6pF9Jm6gtLwG4LQf4FF9B7lkJOvy5J2Lhc+5L4xjoYlyVbw/VkWnOya4ELNQNa3RC
         1UDzjyWjjt9HSoSpo8Thdck2dWlx8+Tw6UpB74hsW8h7HqbcvMz4foKAnDM+2mMZDyBd
         DTvdIs6RXzL9aOaClaB6ZLFgCiHApFmy416IbCOpgwA+qXG/NZhEZ2hOCbvyD5S1d+En
         SAXg==
X-Gm-Message-State: AOJu0Yxx6l0XhLPBJV1cEQbMDFmu9A3MdiulDcy4QTRC718ON3+7wfbl
	hMxkO/r27iKRldZ1nJ2m/v8i/PH7ABc=
X-Google-Smtp-Source: AGHT+IHckRtM01KJvYG4MzxlJmwc4mexIwiEtqPRbnMCH/0zexox3efFOV/YRhoM0MsY386ZXwLr8g==
X-Received: by 2002:a05:6870:93cc:b0:1f0:3fdc:5995 with SMTP id c12-20020a05687093cc00b001f03fdc5995mr3442120oal.50.1699487195512;
        Wed, 08 Nov 2023 15:46:35 -0800 (PST)
Received: from localhost.localdomain (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id h5-20020a056870a3c500b001e5c7cc54d3sm491116oak.55.2023.11.08.15.46.34
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 08 Nov 2023 15:46:34 -0800 (PST)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 2/4] netlink: Fix compilation on really old platforms
Date: Wed,  8 Nov 2023 17:45:21 -0600
Message-ID: <20231108234544.1050199-2-denkenz@gmail.com>
X-Mailer: git-send-email 2.42.0
In-Reply-To: <20231108234544.1050199-1-denkenz@gmail.com>
References: <20231108234544.1050199-1-denkenz@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

Some platforms lack definitions of new netlink features.  Fix this
by including a local copy of the most up to date netlink.h header.

  CC       ell/netlink.lo
ell/netlink.c: In function ‘l_netlink_set_debug’:
ell/netlink.c:629:56: error: ‘NETLINK_EXT_ACK’ undeclared (first use in this function)
  if (setsockopt(l_io_get_fd(netlink->io), SOL_NETLINK, NETLINK_EXT_ACK,
                                                        ^
ell/netlink.c:629:56: note: each undeclared identifier is reported only once for each function it appears in
ell/netlink.c: In function ‘netlink_parse_ext_ack_error’:
ell/netlink.c:649:29: error: ‘NLM_F_ACK_TLVS’ undeclared (first use in this function)
  if (!(nlmsg->nlmsg_flags & NLM_F_ACK_TLVS))
                             ^
ell/netlink.c:657:29: error: ‘NLM_F_CAPPED’ undeclared (first use in this function)
  if (!(nlmsg->nlmsg_flags & NLM_F_CAPPED))
                             ^
ell/netlink.c:677:8: error: ‘NLMSGERR_ATTR_MSG’ undeclared (first use in this function)
   case NLMSGERR_ATTR_MSG:
        ^
ell/netlink.c:681:8: error: ‘NLMSGERR_ATTR_OFFS’ undeclared (first use in this function)
   case NLMSGERR_ATTR_OFFS:
        ^
---
 Makefile.am     |   2 +-
 linux/netlink.h | 383 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 384 insertions(+), 1 deletion(-)
 create mode 100644 linux/netlink.h

diff --git a/Makefile.am b/Makefile.am
index 6c86e94e963e..ec75bb46ed44 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -12,7 +12,7 @@ ELL_CURRENT = 0
 ELL_REVISION = 2
 ELL_AGE = 0
 
-linux_headers = linux/gpio.h
+linux_headers = linux/gpio.h linux/netlink.h
 
 pkginclude_HEADERS = ell/ell.h \
 			ell/util.h \
diff --git a/linux/netlink.h b/linux/netlink.h
new file mode 100644
index 000000000000..f87aaf28a649
--- /dev/null
+++ b/linux/netlink.h
@@ -0,0 +1,383 @@
+/* SPDX-License-Identifier: GPL-2.0 WITH Linux-syscall-note */
+#ifndef _UAPI__LINUX_NETLINK_H
+#define _UAPI__LINUX_NETLINK_H
+
+#include <linux/const.h>
+#include <linux/socket.h> /* for __kernel_sa_family_t */
+#include <linux/types.h>
+
+#define NETLINK_ROUTE		0	/* Routing/device hook				*/
+#define NETLINK_UNUSED		1	/* Unused number				*/
+#define NETLINK_USERSOCK	2	/* Reserved for user mode socket protocols 	*/
+#define NETLINK_FIREWALL	3	/* Unused number, formerly ip_queue		*/
+#define NETLINK_SOCK_DIAG	4	/* socket monitoring				*/
+#define NETLINK_NFLOG		5	/* netfilter/iptables ULOG */
+#define NETLINK_XFRM		6	/* ipsec */
+#define NETLINK_SELINUX		7	/* SELinux event notifications */
+#define NETLINK_ISCSI		8	/* Open-iSCSI */
+#define NETLINK_AUDIT		9	/* auditing */
+#define NETLINK_FIB_LOOKUP	10	
+#define NETLINK_CONNECTOR	11
+#define NETLINK_NETFILTER	12	/* netfilter subsystem */
+#define NETLINK_IP6_FW		13
+#define NETLINK_DNRTMSG		14	/* DECnet routing messages (obsolete) */
+#define NETLINK_KOBJECT_UEVENT	15	/* Kernel messages to userspace */
+#define NETLINK_GENERIC		16
+/* leave room for NETLINK_DM (DM Events) */
+#define NETLINK_SCSITRANSPORT	18	/* SCSI Transports */
+#define NETLINK_ECRYPTFS	19
+#define NETLINK_RDMA		20
+#define NETLINK_CRYPTO		21	/* Crypto layer */
+#define NETLINK_SMC		22	/* SMC monitoring */
+
+#define NETLINK_INET_DIAG	NETLINK_SOCK_DIAG
+
+#define MAX_LINKS 32		
+
+struct sockaddr_nl {
+	__kernel_sa_family_t	nl_family;	/* AF_NETLINK	*/
+	unsigned short	nl_pad;		/* zero		*/
+	__u32		nl_pid;		/* port ID	*/
+       	__u32		nl_groups;	/* multicast groups mask */
+};
+
+/**
+ * struct nlmsghdr - fixed format metadata header of Netlink messages
+ * @nlmsg_len:   Length of message including header
+ * @nlmsg_type:  Message content type
+ * @nlmsg_flags: Additional flags
+ * @nlmsg_seq:   Sequence number
+ * @nlmsg_pid:   Sending process port ID
+ */
+struct nlmsghdr {
+	__u32		nlmsg_len;
+	__u16		nlmsg_type;
+	__u16		nlmsg_flags;
+	__u32		nlmsg_seq;
+	__u32		nlmsg_pid;
+};
+
+/* Flags values */
+
+#define NLM_F_REQUEST		0x01	/* It is request message. 	*/
+#define NLM_F_MULTI		0x02	/* Multipart message, terminated by NLMSG_DONE */
+#define NLM_F_ACK		0x04	/* Reply with ack, with zero or error code */
+#define NLM_F_ECHO		0x08	/* Receive resulting notifications */
+#define NLM_F_DUMP_INTR		0x10	/* Dump was inconsistent due to sequence change */
+#define NLM_F_DUMP_FILTERED	0x20	/* Dump was filtered as requested */
+
+/* Modifiers to GET request */
+#define NLM_F_ROOT	0x100	/* specify tree	root	*/
+#define NLM_F_MATCH	0x200	/* return all matching	*/
+#define NLM_F_ATOMIC	0x400	/* atomic GET		*/
+#define NLM_F_DUMP	(NLM_F_ROOT|NLM_F_MATCH)
+
+/* Modifiers to NEW request */
+#define NLM_F_REPLACE	0x100	/* Override existing		*/
+#define NLM_F_EXCL	0x200	/* Do not touch, if it exists	*/
+#define NLM_F_CREATE	0x400	/* Create, if it does not exist	*/
+#define NLM_F_APPEND	0x800	/* Add to end of list		*/
+
+/* Modifiers to DELETE request */
+#define NLM_F_NONREC	0x100	/* Do not delete recursively	*/
+#define NLM_F_BULK	0x200	/* Delete multiple objects	*/
+
+/* Flags for ACK message */
+#define NLM_F_CAPPED	0x100	/* request was capped */
+#define NLM_F_ACK_TLVS	0x200	/* extended ACK TVLs were included */
+
+/*
+   4.4BSD ADD		NLM_F_CREATE|NLM_F_EXCL
+   4.4BSD CHANGE	NLM_F_REPLACE
+
+   True CHANGE		NLM_F_CREATE|NLM_F_REPLACE
+   Append		NLM_F_CREATE
+   Check		NLM_F_EXCL
+ */
+
+#define NLMSG_ALIGNTO	4U
+#define NLMSG_ALIGN(len) ( ((len)+NLMSG_ALIGNTO-1) & ~(NLMSG_ALIGNTO-1) )
+#define NLMSG_HDRLEN	 ((int) NLMSG_ALIGN(sizeof(struct nlmsghdr)))
+#define NLMSG_LENGTH(len) ((len) + NLMSG_HDRLEN)
+#define NLMSG_SPACE(len) NLMSG_ALIGN(NLMSG_LENGTH(len))
+#define NLMSG_DATA(nlh)  ((void *)(((char *)nlh) + NLMSG_HDRLEN))
+#define NLMSG_NEXT(nlh,len)	 ((len) -= NLMSG_ALIGN((nlh)->nlmsg_len), \
+				  (struct nlmsghdr *)(((char *)(nlh)) + \
+				  NLMSG_ALIGN((nlh)->nlmsg_len)))
+#define NLMSG_OK(nlh,len) ((len) >= (int)sizeof(struct nlmsghdr) && \
+			   (nlh)->nlmsg_len >= sizeof(struct nlmsghdr) && \
+			   (nlh)->nlmsg_len <= (len))
+#define NLMSG_PAYLOAD(nlh,len) ((nlh)->nlmsg_len - NLMSG_SPACE((len)))
+
+#define NLMSG_NOOP		0x1	/* Nothing.		*/
+#define NLMSG_ERROR		0x2	/* Error		*/
+#define NLMSG_DONE		0x3	/* End of a dump	*/
+#define NLMSG_OVERRUN		0x4	/* Data lost		*/
+
+#define NLMSG_MIN_TYPE		0x10	/* < 0x10: reserved control messages */
+
+struct nlmsgerr {
+	int		error;
+	struct nlmsghdr msg;
+	/*
+	 * followed by the message contents unless NETLINK_CAP_ACK was set
+	 * or the ACK indicates success (error == 0)
+	 * message length is aligned with NLMSG_ALIGN()
+	 */
+	/*
+	 * followed by TLVs defined in enum nlmsgerr_attrs
+	 * if NETLINK_EXT_ACK was set
+	 */
+};
+
+/**
+ * enum nlmsgerr_attrs - nlmsgerr attributes
+ * @NLMSGERR_ATTR_UNUSED: unused
+ * @NLMSGERR_ATTR_MSG: error message string (string)
+ * @NLMSGERR_ATTR_OFFS: offset of the invalid attribute in the original
+ *	 message, counting from the beginning of the header (u32)
+ * @NLMSGERR_ATTR_COOKIE: arbitrary subsystem specific cookie to
+ *	be used - in the success case - to identify a created
+ *	object or operation or similar (binary)
+ * @NLMSGERR_ATTR_POLICY: policy for a rejected attribute
+ * @NLMSGERR_ATTR_MISS_TYPE: type of a missing required attribute,
+ *	%NLMSGERR_ATTR_MISS_NEST will not be present if the attribute was
+ *	missing at the message level
+ * @NLMSGERR_ATTR_MISS_NEST: offset of the nest where attribute was missing
+ * @__NLMSGERR_ATTR_MAX: number of attributes
+ * @NLMSGERR_ATTR_MAX: highest attribute number
+ */
+enum nlmsgerr_attrs {
+	NLMSGERR_ATTR_UNUSED,
+	NLMSGERR_ATTR_MSG,
+	NLMSGERR_ATTR_OFFS,
+	NLMSGERR_ATTR_COOKIE,
+	NLMSGERR_ATTR_POLICY,
+	NLMSGERR_ATTR_MISS_TYPE,
+	NLMSGERR_ATTR_MISS_NEST,
+
+	__NLMSGERR_ATTR_MAX,
+	NLMSGERR_ATTR_MAX = __NLMSGERR_ATTR_MAX - 1
+};
+
+#define NETLINK_ADD_MEMBERSHIP		1
+#define NETLINK_DROP_MEMBERSHIP		2
+#define NETLINK_PKTINFO			3
+#define NETLINK_BROADCAST_ERROR		4
+#define NETLINK_NO_ENOBUFS		5
+#ifndef __KERNEL__
+#define NETLINK_RX_RING			6
+#define NETLINK_TX_RING			7
+#endif
+#define NETLINK_LISTEN_ALL_NSID		8
+#define NETLINK_LIST_MEMBERSHIPS	9
+#define NETLINK_CAP_ACK			10
+#define NETLINK_EXT_ACK			11
+#define NETLINK_GET_STRICT_CHK		12
+
+struct nl_pktinfo {
+	__u32	group;
+};
+
+struct nl_mmap_req {
+	unsigned int	nm_block_size;
+	unsigned int	nm_block_nr;
+	unsigned int	nm_frame_size;
+	unsigned int	nm_frame_nr;
+};
+
+struct nl_mmap_hdr {
+	unsigned int	nm_status;
+	unsigned int	nm_len;
+	__u32		nm_group;
+	/* credentials */
+	__u32		nm_pid;
+	__u32		nm_uid;
+	__u32		nm_gid;
+};
+
+#ifndef __KERNEL__
+enum nl_mmap_status {
+	NL_MMAP_STATUS_UNUSED,
+	NL_MMAP_STATUS_RESERVED,
+	NL_MMAP_STATUS_VALID,
+	NL_MMAP_STATUS_COPY,
+	NL_MMAP_STATUS_SKIP,
+};
+
+#define NL_MMAP_MSG_ALIGNMENT		NLMSG_ALIGNTO
+#define NL_MMAP_MSG_ALIGN(sz)		__ALIGN_KERNEL(sz, NL_MMAP_MSG_ALIGNMENT)
+#define NL_MMAP_HDRLEN			NL_MMAP_MSG_ALIGN(sizeof(struct nl_mmap_hdr))
+#endif
+
+#define NET_MAJOR 36		/* Major 36 is reserved for networking 						*/
+
+enum {
+	NETLINK_UNCONNECTED = 0,
+	NETLINK_CONNECTED,
+};
+
+/*
+ *  <------- NLA_HDRLEN ------> <-- NLA_ALIGN(payload)-->
+ * +---------------------+- - -+- - - - - - - - - -+- - -+
+ * |        Header       | Pad |     Payload       | Pad |
+ * |   (struct nlattr)   | ing |                   | ing |
+ * +---------------------+- - -+- - - - - - - - - -+- - -+
+ *  <-------------- nlattr->nla_len -------------->
+ */
+
+struct nlattr {
+	__u16           nla_len;
+	__u16           nla_type;
+};
+
+/*
+ * nla_type (16 bits)
+ * +---+---+-------------------------------+
+ * | N | O | Attribute Type                |
+ * +---+---+-------------------------------+
+ * N := Carries nested attributes
+ * O := Payload stored in network byte order
+ *
+ * Note: The N and O flag are mutually exclusive.
+ */
+#define NLA_F_NESTED		(1 << 15)
+#define NLA_F_NET_BYTEORDER	(1 << 14)
+#define NLA_TYPE_MASK		~(NLA_F_NESTED | NLA_F_NET_BYTEORDER)
+
+#define NLA_ALIGNTO		4
+#define NLA_ALIGN(len)		(((len) + NLA_ALIGNTO - 1) & ~(NLA_ALIGNTO - 1))
+#define NLA_HDRLEN		((int) NLA_ALIGN(sizeof(struct nlattr)))
+
+/* Generic 32 bitflags attribute content sent to the kernel.
+ *
+ * The value is a bitmap that defines the values being set
+ * The selector is a bitmask that defines which value is legit
+ *
+ * Examples:
+ *  value = 0x0, and selector = 0x1
+ *  implies we are selecting bit 1 and we want to set its value to 0.
+ *
+ *  value = 0x2, and selector = 0x2
+ *  implies we are selecting bit 2 and we want to set its value to 1.
+ *
+ */
+struct nla_bitfield32 {
+	__u32 value;
+	__u32 selector;
+};
+
+/*
+ * policy descriptions - it's specific to each family how this is used
+ * Normally, it should be retrieved via a dump inside another attribute
+ * specifying where it applies.
+ */
+
+/**
+ * enum netlink_attribute_type - type of an attribute
+ * @NL_ATTR_TYPE_INVALID: unused
+ * @NL_ATTR_TYPE_FLAG: flag attribute (present/not present)
+ * @NL_ATTR_TYPE_U8: 8-bit unsigned attribute
+ * @NL_ATTR_TYPE_U16: 16-bit unsigned attribute
+ * @NL_ATTR_TYPE_U32: 32-bit unsigned attribute
+ * @NL_ATTR_TYPE_U64: 64-bit unsigned attribute
+ * @NL_ATTR_TYPE_S8: 8-bit signed attribute
+ * @NL_ATTR_TYPE_S16: 16-bit signed attribute
+ * @NL_ATTR_TYPE_S32: 32-bit signed attribute
+ * @NL_ATTR_TYPE_S64: 64-bit signed attribute
+ * @NL_ATTR_TYPE_BINARY: binary data, min/max length may be specified
+ * @NL_ATTR_TYPE_STRING: string, min/max length may be specified
+ * @NL_ATTR_TYPE_NUL_STRING: NUL-terminated string,
+ *	min/max length may be specified
+ * @NL_ATTR_TYPE_NESTED: nested, i.e. the content of this attribute
+ *	consists of sub-attributes. The nested policy and maxtype
+ *	inside may be specified.
+ * @NL_ATTR_TYPE_NESTED_ARRAY: nested array, i.e. the content of this
+ *	attribute contains sub-attributes whose type is irrelevant
+ *	(just used to separate the array entries) and each such array
+ *	entry has attributes again, the policy for those inner ones
+ *	and the corresponding maxtype may be specified.
+ * @NL_ATTR_TYPE_BITFIELD32: &struct nla_bitfield32 attribute
+ * @NL_ATTR_TYPE_SINT: 32-bit or 64-bit signed attribute, aligned to 4B
+ * @NL_ATTR_TYPE_UINT: 32-bit or 64-bit unsigned attribute, aligned to 4B
+ */
+enum netlink_attribute_type {
+	NL_ATTR_TYPE_INVALID,
+
+	NL_ATTR_TYPE_FLAG,
+
+	NL_ATTR_TYPE_U8,
+	NL_ATTR_TYPE_U16,
+	NL_ATTR_TYPE_U32,
+	NL_ATTR_TYPE_U64,
+
+	NL_ATTR_TYPE_S8,
+	NL_ATTR_TYPE_S16,
+	NL_ATTR_TYPE_S32,
+	NL_ATTR_TYPE_S64,
+
+	NL_ATTR_TYPE_BINARY,
+	NL_ATTR_TYPE_STRING,
+	NL_ATTR_TYPE_NUL_STRING,
+
+	NL_ATTR_TYPE_NESTED,
+	NL_ATTR_TYPE_NESTED_ARRAY,
+
+	NL_ATTR_TYPE_BITFIELD32,
+
+	NL_ATTR_TYPE_SINT,
+	NL_ATTR_TYPE_UINT,
+};
+
+/**
+ * enum netlink_policy_type_attr - policy type attributes
+ * @NL_POLICY_TYPE_ATTR_UNSPEC: unused
+ * @NL_POLICY_TYPE_ATTR_TYPE: type of the attribute,
+ *	&enum netlink_attribute_type (U32)
+ * @NL_POLICY_TYPE_ATTR_MIN_VALUE_S: minimum value for signed
+ *	integers (S64)
+ * @NL_POLICY_TYPE_ATTR_MAX_VALUE_S: maximum value for signed
+ *	integers (S64)
+ * @NL_POLICY_TYPE_ATTR_MIN_VALUE_U: minimum value for unsigned
+ *	integers (U64)
+ * @NL_POLICY_TYPE_ATTR_MAX_VALUE_U: maximum value for unsigned
+ *	integers (U64)
+ * @NL_POLICY_TYPE_ATTR_MIN_LENGTH: minimum length for binary
+ *	attributes, no minimum if not given (U32)
+ * @NL_POLICY_TYPE_ATTR_MAX_LENGTH: maximum length for binary
+ *	attributes, no maximum if not given (U32)
+ * @NL_POLICY_TYPE_ATTR_POLICY_IDX: sub policy for nested and
+ *	nested array types (U32)
+ * @NL_POLICY_TYPE_ATTR_POLICY_MAXTYPE: maximum sub policy
+ *	attribute for nested and nested array types, this can
+ *	in theory be < the size of the policy pointed to by
+ *	the index, if limited inside the nesting (U32)
+ * @NL_POLICY_TYPE_ATTR_BITFIELD32_MASK: valid mask for the
+ *	bitfield32 type (U32)
+ * @NL_POLICY_TYPE_ATTR_MASK: mask of valid bits for unsigned integers (U64)
+ * @NL_POLICY_TYPE_ATTR_PAD: pad attribute for 64-bit alignment
+ *
+ * @__NL_POLICY_TYPE_ATTR_MAX: number of attributes
+ * @NL_POLICY_TYPE_ATTR_MAX: highest attribute number
+ */
+enum netlink_policy_type_attr {
+	NL_POLICY_TYPE_ATTR_UNSPEC,
+	NL_POLICY_TYPE_ATTR_TYPE,
+	NL_POLICY_TYPE_ATTR_MIN_VALUE_S,
+	NL_POLICY_TYPE_ATTR_MAX_VALUE_S,
+	NL_POLICY_TYPE_ATTR_MIN_VALUE_U,
+	NL_POLICY_TYPE_ATTR_MAX_VALUE_U,
+	NL_POLICY_TYPE_ATTR_MIN_LENGTH,
+	NL_POLICY_TYPE_ATTR_MAX_LENGTH,
+	NL_POLICY_TYPE_ATTR_POLICY_IDX,
+	NL_POLICY_TYPE_ATTR_POLICY_MAXTYPE,
+	NL_POLICY_TYPE_ATTR_BITFIELD32_MASK,
+	NL_POLICY_TYPE_ATTR_PAD,
+	NL_POLICY_TYPE_ATTR_MASK,
+
+	/* keep last */
+	__NL_POLICY_TYPE_ATTR_MAX,
+	NL_POLICY_TYPE_ATTR_MAX = __NL_POLICY_TYPE_ATTR_MAX - 1
+};
+
+#endif /* _UAPI__LINUX_NETLINK_H */
-- 
2.42.0

