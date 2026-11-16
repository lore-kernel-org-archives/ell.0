Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=103.168.172.145
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794868093;
	b=yJe1K9nBwrjoB60LAkH10Owoy20Mw4t2Pox2goC6UGCexelgMl7IYIUshvBX+8Cm7+Dn
	 8RLCyhRifBLKxVUFsMPH4f8FcTKhWo0moiLBBGTczN467J3vtjpwYZpsJJ1cFSuXihGsY
	 LbEyQsHtk7I/zJKeCVu8CmP24ctn2JY7ZA1FX4HByEdsjnOun/G9uHecYzdy+2QjgRVfi
	 h5mEAQ/vctGVCL+F4TKVGPeWnGayYg29tImKLPuwLqSiaD+fXcOLdjR18xCDaYoaHxzy2
	 6KNI8CDKDvK3s5BptDBl02f8K9FnhO0i+n2YnqQgc1QBK6xHvdsna61srlX2OXhedPQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794868093;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:
	 References:MIME-Version:Content-Transfer-Encoding;
	bh=B05GxyvfPRn17XF2lyU4Az0qm2LAR/vxYWP3ub54Ejk=;
	b=nbLguEmk5vK6UnVDGHKR4xJOemj7VnEpXtcsCvOTjWbNm2k4UIjZdNM+oCKb2dvkOv8P
	 fbHISVet2Wi+i87p9HW72p9GwwmDZcuyR3ND3gxcBiNEVLZR7owCAv8ZeVo7+Xl5PKGdN
	 WZE2AYc5GecKqCnNOTYzA4NeKQ/1MX6jcSa/0TEj2SSMWwsGpcV5ngstKE5Ir95mw+Fd7
	 QK9cKRY4dWLEg4oJFntkGHWm9zFdKKG/GIrQyuyDXzLhY7k1OhNEZNMFt3pgdWTDhx2KT
	 fxHZYBJ5gyNWeZ/tUQYi8UismC3gwzUzWn+TuHBJNZgDhURtsKvzS5IXBQX6RdQKkPA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=testtoast.com;
	spf=pass smtp.mailfrom=testtoast.com;
	dkim=pass header.d=testtoast.com header.i=@testtoast.com header.a=rsa-sha256 header.s=fm3 header.b=rDpQDcQp;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b=RvLMkAgG;
	arc=none smtp.remote-ip=103.168.172.145
Received: from fout-a2-smtp.messagingengine.com (fout-a2-smtp.messagingengine.com [103.168.172.145])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 91A4E606A338
	for <ell@lists.linux.dev>; Mon, 16 Nov 2026 22:28:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 91A4E606A338
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=testtoast.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=testtoast.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=testtoast.com header.i=@testtoast.com header.a=rsa-sha256 header.s=fm3 header.b=rDpQDcQp;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b=RvLMkAgG
Received: from phl-compute-03.internal (phl-compute-03.internal [10.202.2.43])
	by mailfout.phl.internal (Postfix) with ESMTP id E7288EC0873
	for <ell@lists.linux.dev>; Mon, 16 Nov 2026 17:28:11 -0500 (EST)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-03.internal (MEProxy); Mon, 16 Nov 2026 17:28:11 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=testtoast.com;
	 h=cc:cc:content-transfer-encoding:content-type:date:date:from
	:from:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:subject:subject:to:to; s=fm3; t=1794868091; x=
	1794954491; bh=B05GxyvfPRn17XF2lyU4Az0qm2LAR/vxYWP3ub54Ejk=; b=r
	DpQDcQpJA0gxscsDWtKBqL/8fbAmQZTyPgzzWSB9JAkCtECPAZVW/lOeAJIfZpHU
	4jD6hO62sF6N5/yN8xiLZha6eeSn9k8uYa937gVlxS25HP/GPYs/lhZdB2+ftkDO
	oTzQCTd41ibQtK151ESwtHFjDb4cO/cdStOq8PBGWPPxBqwsesxCpScHlG9VMgrf
	jCRFqBgfzoNSnoauKHrK/owRpiOWoriOXI5xrvJckWHaujwOPYHhRVu2Q62P3Uka
	+LPlHQoz5roF3OVLmiJmsgEdYG+Cve6eF9DY1DRZLUFF3qymmI+v/DqMALaHIik9
	Fk8KJDGl9MKzPNV+O+BHQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1794868091; x=1794954491; bh=B
	05GxyvfPRn17XF2lyU4Az0qm2LAR/vxYWP3ub54Ejk=; b=RvLMkAgGIqQXZ8EeO
	NvCekR9IACVBUT1O2L5ELkolW3M3I6Y75/oD9xVg+bmfUFm9zawlbYn26jumbkss
	7uKTUagNFXwQDjz5tsNfGSeBLN3IhdGn29kI0HyIArBJIlVFZdh/l2TMJchtrDHo
	YSIX3bb7ubhVD7gmUDvvO3kBh7i9wpgSMnDizXywIEp7cyDYdiWF5WfKvaqZkRr4
	vLfN76BXHXPXRBqtz6mV+HPF783uS54udBMAY7f0xw596hKr9STpJ1niRn+m1N7/
	ghmmRxu2qthmo8+6VHOSScwWLNwcXrHe6wWoMggN5Lkrdm9Q/FXmO/lDvkRt2ELS
	aKKdw==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=sign d=testtoast.com a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1794868091; d=testtoast.com;
	mf=PHJ5YW5AdGVzdHRvYXN0LmNvbT4=;
	rt=PGVsbEBsaXN0cy5saW51eC5kZXY+;
	s=fm3:rsa-sha256:NZgALwh1o6RioujIdh4FWXLILFlhDRDrTLFE7DM1dWPTb9K
	Vy0hVLr+XS0DUTa3EAIZ69csRipG/3XEtPe4WHxWJORrU77+LxQbTWhDC9dv/Nbx
	blzj/q8bm3PQehK37ATCN6tSf+uAOIF+bIlk/cLZnE1GVIUgWfIyw6tNYHMhVFXN
	cY/oLI/KI27n5wQqLtIickXgtM4+4VgcFR7ZnrS36srLoSPYE8yfIRtQBDTcag2R
	03C/7kM7uu6eXsk9bulE8Dr7KBhO+8OCH29aQx5C3aT0VRJBKz0iuQC4hj+X8iY9
	IOeAJT1jQ5eV0KTeeVlR5vhtSvQ76SXyr5up/7A==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=mi-m=1; hc=11;
	hn=cc,content-transfer-encoding,date,feedback-id,from,
	in-reply-to,message-id,mime-version,references,subject,to;
Message-Instance: m=1; h=sha256:nmgRC6vxPgawxRjRJIZC4mHzJrpGn8bscqnu6Cj9a2Q=:yvpL8mMx2ULQnK0ay1GDChnmaEeLIdn8yKTUEpN5kao=;
X-ME-Sender: <xms:e4P7avIvwh8PxDA8Nz7q2TCPY2PQvxRHaZS6aASTA4l8EnwrYrdfnw>
    <xme:e4P7apJ1beTvBiSsRm6y_zxHK0xom4dAZ3mkfUMx8wtJdJLqEGC_ZssWwrw7TbKaC
    GNHI5-IIkcEbEFrPcXsAZ8xHyMLq8Cc8wCbvFk72b03NlLIfBj8TRY>
X-ME-Received: <xmr:e4P7alUxHc3HhIgLSiKObNxlojvGydNUaEK6VU61CTV3hm-PQiZo5OiJrLL9i-Be9t-7NjdSOPwhsPqP8LijTi_25FY>
X-ME-Proxy-Cause: dmFkZTEEP0tiYnfrv8FOZ1/e/XcawF0bDm8Q8CNNJfgGlGTzEU72oaYms7G0oYWnigKsZE
    exrS0TVgC4VMYNKN9tMRgtVhq7JX7G70NYb4NbB47ABpcOBsnI+UAX9ECEsHZYX383LQyy
    wjQKVfFK2bpkd6rniJ8DOSwKdaPLImMl31mgaEv65z0wlqWyFbsp/dHW3X77DfVnwwqPNv
    1SqOHyMJSpQHvWu8qv7VH0cRxG668rltANRzGKzqCEgz4851QEQOtnKPL/T75QPzMDHUhs
    +Y/pz3rtL3AObiQR+ZIO9M5aqxxjYqNRTcgrkSSbw4+ednrGcDnf5OuY8cYq33vOIDigKu
    +hiZE26NGa/FDl+G7KNG1WS6/fgELTq31I28d/1yZDFNs8OmkVlBmZvBBkVlKUE45+zP63
    xp/pVnxPW9a144g+DqV0M+5vqHHMUtIO9bwBaWscXZqnFY0FooSIvBYdjDLHH5uXcXsisv
    ZovWUkFlD0m2W6XLByGCg/+o2oTABGr1XWwrwQAKq1JYZJLynxPERh9kMWobSg1voTRn2L
    apy9WuCD1aNxU2woWTpzmTVWUco9Qg36QzaKCnqo/63lnZlFwJjN52yOQtozTehhZGW8KL
    ZqCv/mxACGJVBbSxWO5TA4x9bJrOEbbHt7FiuNEd2catFnTuBfWcVGDNwpeQ
X-ME-Proxy: <xmx:e4P7ajio9uf3ow3r9lQMLL_ILSlF04A7KSK_JH4SIu8mNyRaBZ21hA>
    <xmx:e4P7ao9tjuwsbCKQwgvvUvL7hd68LAlneLlJsPjEOc4bx5aAYKTXVQ>
    <xmx:e4P7alALf042B2jxh8nSZdrSNHRDRKAKCfJzxJRMN7kaSuprvKCakw>
    <xmx:e4P7atJjljk3W2y1TTGhujKE-ltGcGaAMFd9XnrMAN8wrGKR1wk5KA>
    <xmx:e4P7aigf-Cla5VV1DUjagQNpaTZgJVXkSDav0mUhRc8-5qGUGupEF92k>
Feedback-ID: idc0145fc:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 16 Nov 2026 17:28:10 -0500 (EST)
From: Ryan Walklin <ryan@testtoast.com>
To: ell@lists.linux.dev
Cc: Ryan Walklin <ryan@testtoast.com>
Subject: [PATCH 5/6] netconfig: Skip duplicate DNS servers and domains
Date: Tue, 17 Nov 2026 11:27:51 +1300
Message-ID: <20261116222756.2921577-6-ryan@testtoast.com>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20261116222756.2921577-1-ryan@testtoast.com>
References: <20261116222756.2921577-1-ryan@testtoast.com>
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Post: <mailto:ell@lists.linux.dev>
List-Help: <mailto:ell+help@lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
List-Owner: <mailto:ell+owner@lists.linux.dev>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

A network that hands out the same DNS server in DHCPv6 and in the RA's
RDNSS option, or the same search domain over more than one of DHCPv4,
DHCPv6 and the RA's DNSSL option, gets it listed twice by
l_netconfig_get_dns_list() or l_netconfig_get_domain_names(), and then
twice in resolv.conf.  Skip strings that are already in the list.

Fixes: abeb8590791b ("netconfig: Handle DNS data from l_icmp6_router")
---
 ell/netconfig.c | 51 ++++++++++++++++++++++++++++++++-----------------
 1 file changed, 34 insertions(+), 17 deletions(-)

diff --git a/ell/netconfig.c b/ell/netconfig.c
index 2eb9cae..fb18ec3 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -2376,27 +2376,38 @@ LIB_EXPORT const struct l_queue_entry *l_netconfig_get_routes(
 	return l_queue_get_entries(netconfig->routes.current);
 }
 
+/*
+ * Append the strings from @src that aren't in @dest yet, e.g. a DNS server
+ * that's both in the DHCPv6 lease and the RA.  Takes ownership of @src if
+ * @free is true.
+ */
 static void netconfig_strv_cat(char ***dest, char **src, bool free)
 {
 	unsigned int dest_len;
-	unsigned int src_len;
+	char **i;
 
 	if (!src)
 		return;
 
-	if (!free)
-		src = l_strv_copy(src);
+	dest_len = l_strv_length(*dest);
+	*dest = l_realloc(*dest, sizeof(char *) *
+				(dest_len + l_strv_length(src) + 1));
+	(*dest)[dest_len] = NULL;
 
-	if (!*dest) {
-		*dest = src;
-		return;
+	for (i = src; *i; i++) {
+		if (l_strv_contains(*dest, *i)) {
+			if (free)
+				l_free(*i);
+
+			continue;
+		}
+
+		(*dest)[dest_len++] = free ? *i : l_strdup(*i);
+		(*dest)[dest_len] = NULL;
 	}
 
-	dest_len = l_strv_length(*dest);
-	src_len = l_strv_length(src);
-	*dest = l_realloc(*dest, sizeof(char *) * (dest_len + src_len + 1));
-	memcpy(*dest + dest_len, src, sizeof(char *) * (src_len + 1));
-	l_free(src);
+	if (free)
+		l_free(src);
 }
 
 /* Returns a new strv array to be freed by the caller */
@@ -2438,17 +2449,19 @@ append_v6:
 
 		ret = l_realloc(ret, sizeof(char *) * (dest_len + src_len + 1));
 		i = ret + dest_len;
+		*i = NULL;
 
 		for (entry = l_queue_get_entries(netconfig->slaac_dnses);
 				entry; entry = entry->next) {
 			char addr_str[INET6_ADDRSTRLEN];
 
 			if (inet_ntop(AF_INET6, entry->data, addr_str,
-					sizeof(addr_str)))
+					sizeof(addr_str)) &&
+					!l_strv_contains(ret, addr_str)) {
 				*i++ = l_strdup(addr_str);
+				*i = NULL;
+			}
 		}
-
-		*i = NULL;
 	}
 
 done:
@@ -2501,12 +2514,16 @@ append_v6:
 
 		ret = l_realloc(ret, sizeof(char *) * (dest_len + src_len + 1));
 		i = ret + dest_len;
+		*i = NULL;
 
 		for (entry = l_queue_get_entries(netconfig->slaac_domains);
-				entry; entry = entry->next)
-			*i++ = l_strdup(entry->data);
+				entry; entry = entry->next) {
+			if (l_strv_contains(ret, entry->data))
+				continue;
 
-		*i = NULL;
+			*i++ = l_strdup(entry->data);
+			*i = NULL;
+		}
 	}
 
 done:
-- 
2.55.0

