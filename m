Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=202.12.124.159
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793389714;
	b=j9d8YYSueM56/UjnhYljCa6HZ+JiiA6aqOjwrjRbB/Gg77CqhcyIFniF3RHDqs/5agZG
	 I+vdrnL9bjlUoooW9+H8lFoWY3DNVR51/lIZyfKWUKTHUpvP1/ozmzrswCZZfZPC5N39j
	 +terTd4UeLnRZFn/b8bA4peEC9PyozrodalNK+x49zNXScXmR5r/K26vwE2/GSXl+1hFR
	 GXVT3ZuCxUASkc28TjL3dU3MG4ZpmN7JNA1vRKr0JwQQf9emZWWbd4yOGjBAi9S1+vvM1
	 FJBwD4PVLuJQY0fs/+x8q8Id21AWs6EnxmZSJbIUmMbakbdRINPRnVgYdg3J3hOfrIw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793389714;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:
	 References:MIME-Version:Content-Transfer-Encoding;
	bh=etkPtqdN3KBEBbgfgkjBZeEWuzwEAGz4ihEmoZtbp0w=;
	b=wBXunot6ig8VlppQbntYyle7nSRDpfEqdjWNYdOs5H9AEli8eSZHPxxL5Rk6bOKH7/xl
	 TTUvv4p1r4zcuiTIQolh3uY1fgVKDzxJ76JZ7M+HKHHzIkXzrzFwhxtfQwO9+vhpOpShL
	 /QtZ6sUZSRHS3NK3pZLjZ9koYyhskWejfo7ahCUKLDfG+X433zo2NF8nlNRTF2Fzl+v/Z
	 m+Z+z5D9UbUtpA/2NyI5MSmKX3tO2TVjsJkSSuB9jfsuu5wZvlbaKd93BVmj4GfijPDd/
	 5wtTBJ3FNV00n/FVSEKU+uGvX99Y+PS3d1dw4s6KjjnmfOwBF5FNptVwLXY0CQigRrg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=cteubner.net;
	spf=pass smtp.mailfrom=cteubner.net;
	dkim=pass header.d=cteubner.net header.i=@cteubner.net header.a=rsa-sha256 header.s=fm1 header.b=DKZ6gWdf;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=lXnwKPSz;
	arc=none smtp.remote-ip=202.12.124.159
Received: from fhigh-b8-smtp.messagingengine.com (fhigh-b8-smtp.messagingengine.com [202.12.124.159])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 743A0606A32D
	for <ell@lists.linux.dev>; Fri, 30 Oct 2026 19:48:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 743A0606A32D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=cteubner.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=cteubner.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=cteubner.net header.i=@cteubner.net header.a=rsa-sha256 header.s=fm1 header.b=DKZ6gWdf;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=lXnwKPSz
Received: from phl-compute-01.internal (phl-compute-01.internal [10.202.2.41])
	by mailfhigh.stl.internal (Postfix) with ESMTP id E62227A00B3
	for <ell@lists.linux.dev>; Fri, 30 Oct 2026 15:48:32 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-01.internal (MEProxy); Fri, 30 Oct 2026 15:48:32 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=cteubner.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:subject:subject:to:to; s=fm1; t=1793389712; x=
	1793476112; bh=etkPtqdN3KBEBbgfgkjBZeEWuzwEAGz4ihEmoZtbp0w=; b=D
	KZ6gWdfPrCkke8lCDhTMzHI2EHrJYUYhhSAAD+v7/WPzSv3v/srBnIc0VQW1FjlS
	p11gI/C90k45kQwCk25uQ1IEuK3Ay/9ZPVJvA2nCMBmOz9iEBVIcKO894N68wTGr
	nDU7Bk5uyhDchqEP3X+fSoyRMTyjn+hxqUyxZCK1d5919p0U4unvUEukw6P4XwwZ
	JvkRJHcg0HJj8O4/PMvjtViKMZU3fYAGjOFHUhKFLgHIqnlsRho3kPKhYsq0o39f
	KjD6Vy/nF0JFmW4Bvy+2Ym/eZKdq5n5mKDpQv5iILGwGv8kPpOjDq3jB/rWLrO2q
	YsPSy3U/sdLh43SswsIMw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1793389712; x=1793476112; bh=e
	tkPtqdN3KBEBbgfgkjBZeEWuzwEAGz4ihEmoZtbp0w=; b=lXnwKPSzpdlvcPQQe
	Pve11Wwo3y5r+5kfgRCFc1cyYhX7TnFrOenXRZrOHYUW4odMfS7e2QONn8qh5n6m
	zIpxb/F83RTYMlGozcC6c9mxOhP25wRF4arG1p+hIydhcFtet4iho09CaXSgtY/l
	0RCewZSf+bKq8azjUStiFyOH34TwAhe0Zo7ZAy3mYOYmZD+zmLUSpdIfCHsdi4dp
	4Qhjl9QNExHFdf2EiHlqJ4lH1v5TI6HF0TV5uqTK6dX4ibZaLwodTmx1yyr58KxX
	K+JMqhzSc9K0vVAEepbF9oNIcb5YaHH0NhY2p1tGvesGmeqgj0ZL6c8gzyUp29ga
	PmjZg==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-08;
	repo=github.com/dkim2wg/interop; date=2026-10-28; sw=lmtpprox;
	action=sign d=cteubner.net a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1793389712; d=cteubner.net;
	mf=PGNhcmxvQGN0ZXVibmVyLm5ldD4=;
	rt=PGVsbEBsaXN0cy5saW51eC5kZXY+;
	s=fm1:rsa-sha256:Au1CgDCneyZFyrbVXHGXvMgDSn/VLUyDx6nXB48uo76zFEb
	R6b/kG74C7Vyq3R3dAc54GDC0mDPHoSVZl3awdL5TUDZjy6sYmKaFThNwXX9KT8p
	AN9RevzUidtbIvWGjMueLfmtNGOl0kHZQDJ2cVcvU8QG4Eq5vRyPaIfvGQ8AWgZQ
	/o2pEGODWSY/yoQj7sMt+slOO/bXum4yU/MPLn2h0hb5LsGOGoojC6A3755cfiqx
	whKE9RoWQ5zXHSTrtj1YvmebsiqAPeShleDVuJ7YXcdyglyNdKUGSmapK0q+0MMo
	FyQdDghWCr7wxMAZWcZDQ6w5vdVXfDa9AsNBNeQ==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-08;
	repo=github.com/dkim2wg/interop; date=2026-10-28; sw=lmtpprox;
	action=mi-m=1; hc=11;
	hn=cc,content-transfer-encoding,date,feedback-id,from,
	in-reply-to,message-id,mime-version,references,subject,to;
Message-Instance: m=1; h=sha256:aG6P4N85idUdDk9AX69y8/9QqfvgVi7rBbx25W2q9Eg=:tBOSIlhpb63UryCP17OBdgc6HUvdlTUPMa8xbRG+8H0=;
X-ME-Sender: <xms:kPTkanJ0WpQfAK7EWrgTgpWe9wSI8Ei66xQFkGa7H05CWfyCK5wZGQ>
    <xme:kPTkahKgzXze03-53vZ9ROu-xHXX7P_RHEZpH0SzpiRpcVUZsQ_W7AHj4ApCOI8zT
    uTS8Bv7LUpuSnvbOIh3S2aGkk9tstEItEcW8HskHJO45X-L0bhWTA>
X-ME-Received: <xmr:kPTkatVJPkKumK-5joN87WLxHS7BftXFVmYaIsWNCu5Tge0bsS1bZQ>
X-ME-Proxy-Cause: dmFkZTGf0Cznyis8l85h8TWbzeIH1oC+xjY6M5Sp8tOoLGAeLowKDER93ScZdNis3riehv
    9C5JNQOwvxu4Vj/8xX5a+8yiVxpjI4+NdWDZvilppa60UYFFyssIIueNbIV9SGiokMAHRo
    mst1a59i3SeJ4dEL+E4/75rhfYjWYsVnKE6u/XkC3k0IcK5a0go0A/u/h19+zfB4AG1I1U
    Cs3136ZCUbIsPQq7n3pphwxF69bxKdCJwzpuCOIuf8pKsIJ/WTtdYNLDQHAsjnV0pzH5AW
    9STcnhfR3C3EnnGukNXTQXHQpIK6DTz/rgtivaVnMeYiT1T7b48eNgmz+6nwpNK4GG/nqc
    TKhzAWtTBSrevFDeXW/BQiTI3FK6cWlFI3sS9MBEpJJ/gXCSPgDRT2ry7NNoCZWNG73/KA
    Gk7SvisCl/0Uda2LLzPKpqonaYfN7HUf/mkfdZeoGXGnp25/l30F1BCHM4idfG5UGRwRN7
    tkkHfffInYqE6v6RUr0zBEzwOvMSXf/OrCapEasPSJxwKmPqjO9Ut+qXLUoTdGwtoczlr4
    TfeIkF70JOlHZBKplebh/neLlkTf61nt4ujcmvSlii48c9I+ZDXHDAV7WcLoBd+nEdV7WT
    zE1H5SVQ9SM9ImSVrSIf5yS/IkskmCks7tnu0rx8yi3XWom+cz3ERZp4PhhA
X-ME-Proxy: <xmx:kPTkargWERmjp5NgznJa3LA3oGM25NkLxDLGibSmDNgzM-_N4jYaPA>
    <xmx:kPTkag96FnKzbRM2NW8W5pOajMy4ZMoLZxPXU7GCO9HwAzzeWKcqXQ>
    <xmx:kPTkatBdp-oyHMT7J3to5PoVSxC6aCK6jRxPS-T8PPIQdyx-IY9WsA>
    <xmx:kPTkalKE4P4L9zni1Ky91Jy0a7WLClYBwTuAFC0filfXLLY9-fzBzA>
    <xmx:kPTkaqijjDp6lPmk8x7BLVr2eCqwnOOV7d80rz7Kg8sYXOqnnL_6sKKE>
Feedback-ID: i3cc944ce:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 30 Oct 2026 15:48:32 -0400 (EDT)
From: Carlo Teubner <carlo@cteubner.net>
To: ell@lists.linux.dev
Cc: Carlo Teubner <carlo@cteubner.net>
Subject: [PATCH 2/2] unit: Test DHCP lease domain name handling
Date: Fri, 30 Oct 2026 19:48:00 +0000
Message-ID: <179334935256.3.7554184553168312552@cteubner.net>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <179334935255.3.16564933583527517394@cteubner.net>
References: <528838ce-7599-4268-b7a1-0cc9d7d689bc@app.fastmail.com> <179334935255.3.16564933583527517394@cteubner.net>
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

Exercise lease parsing with root domain values, including a trailing NUL
and the empty root representation. Verify that the domain is omitted
while the server ID, lifetime, netmask, gateway and DNS server are
retained, including options following the domain name.

Also cover ordinary domain names with and without a trailing NUL, and
verify that localhost names, embedded NULs, invalid UTF-8 and
zero-length values are still rejected.

---
 unit/test-dhcp.c | 102 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 102 insertions(+)

diff --git a/unit/test-dhcp.c b/unit/test-dhcp.c
index 34faae4..a8971ec 100644
--- a/unit/test-dhcp.c
+++ b/unit/test-dhcp.c
@@ -403,6 +403,102 @@ static void test_option_set(const void *data)
 	}
 }
 
+static const struct domain_name_test {
+	const char *name;
+	const char *value;
+	uint8_t len; /* Option payload length, including any trailing NUL. */
+	bool valid;
+	const char *expected;
+} domain_name_tests[] = {
+	{ "lease/domain", "example.org", 11, true, "example.org" },
+	{ "lease/domain-nul", "example.org", 12, true, "example.org" },
+	{ "lease/root-domain", ".", 1, true, NULL },
+	{ "lease/root-domain-nul", ".", 2, true, NULL },
+	/* A single NUL is normalized to the empty root name. */
+	{ "lease/empty-root-domain", "", 1, true, NULL },
+	{ "lease/localhost-domain", "localhost", 9, false, NULL },
+	{ "lease/embedded-nul-domain", "a\0b", 3, false, NULL },
+	{ "lease/invalid-utf8-domain", "\xff", 1, false, NULL },
+	{ "lease/zero-length-domain", "", 0, false, NULL },
+};
+
+static void test_domain_name(const void *data)
+{
+	const struct domain_name_test *test = data;
+	static const uint8_t server[] = { 10, 128, 255, 254 };
+	static const uint8_t netmask[] = { 255, 255, 0, 0 };
+	static const uint8_t gateway[] = { 10, 128, 255, 254 };
+	static const uint8_t dns[] = { 8, 8, 8, 8 };
+	uint32_t lifetime = L_CPU_TO_BE32(3600); /* One hour, in wire order. */
+	struct dhcp_message *message;
+	struct dhcp_message_builder builder;
+	struct dhcp_message_iter iter;
+	struct l_dhcp_lease *lease;
+	char *value;
+	char **dns_list;
+	size_t capacity = 512; /* Room for options and BOOTP padding. */
+	size_t len;
+
+	message = (struct dhcp_message *) l_new(uint8_t, capacity);
+	assert(_dhcp_message_builder_init(&builder, message, capacity,
+						DHCP_MESSAGE_TYPE_OFFER));
+	assert(_dhcp_message_builder_append(&builder,
+					L_DHCP_OPTION_SERVER_IDENTIFIER,
+					sizeof(server), server));
+	assert(_dhcp_message_builder_append(&builder,
+					L_DHCP_OPTION_IP_ADDRESS_LEASE_TIME,
+					sizeof(lifetime), &lifetime));
+	assert(_dhcp_message_builder_append(&builder, L_DHCP_OPTION_DOMAIN_NAME,
+						test->len, test->value));
+	assert(_dhcp_message_builder_append(&builder, L_DHCP_OPTION_SUBNET_MASK,
+						sizeof(netmask), netmask));
+	assert(_dhcp_message_builder_append(&builder, L_DHCP_OPTION_ROUTER,
+						sizeof(gateway), gateway));
+	assert(_dhcp_message_builder_append(&builder,
+					L_DHCP_OPTION_DOMAIN_NAME_SERVER,
+					sizeof(dns), dns));
+	_dhcp_message_builder_finalize(&builder, &len);
+
+	assert(_dhcp_message_iter_init(&iter, message, len));
+	lease = _dhcp_lease_parse_options(&iter);
+	l_free(message);
+
+	if (!test->valid) {
+		assert(!lease);
+		return;
+	}
+
+	assert(lease);
+	assert(l_dhcp_lease_get_lifetime(lease) == 3600);
+
+	value = l_dhcp_lease_get_server_id(lease);
+	assert(value && !strcmp(value, "10.128.255.254"));
+	l_free(value);
+
+	value = l_dhcp_lease_get_netmask(lease);
+	assert(value && !strcmp(value, "255.255.0.0"));
+	l_free(value);
+
+	value = l_dhcp_lease_get_gateway(lease);
+	assert(value && !strcmp(value, "10.128.255.254"));
+	l_free(value);
+
+	dns_list = l_dhcp_lease_get_dns(lease);
+	assert(dns_list && dns_list[0] && !dns_list[1]);
+	assert(!strcmp(dns_list[0], "8.8.8.8"));
+	l_strv_free(dns_list);
+
+	value = l_dhcp_lease_get_domain_name(lease);
+
+	if (test->expected)
+		assert(value && !strcmp(value, test->expected));
+	else
+		assert(!value);
+
+	l_free(value);
+	_dhcp_lease_free(lease);
+}
+
 static void test_checksum(const void *data)
 {
 	static const uint8_t buf[20] = {
@@ -1045,6 +1141,8 @@ static void test_expired_ip_reuse(const void *data)
 
 int main(int argc, char *argv[])
 {
+	unsigned int i;
+
 	l_test_init(&argc, &argv);
 
 	l_test_add("request-option", test_request_option, NULL);
@@ -1062,6 +1160,10 @@ int main(int argc, char *argv[])
 
 	l_test_add("option set", test_option_set, NULL);
 
+	for (i = 0; i < L_ARRAY_SIZE(domain_name_tests); i++)
+		l_test_add(domain_name_tests[i].name, test_domain_name,
+						&domain_name_tests[i]);
+
 	l_test_add("checksum", test_checksum, NULL);
 
 	l_test_add("discover", test_discover, NULL);
