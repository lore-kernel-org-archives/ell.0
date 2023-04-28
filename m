Received: from mail-ej1-f42.google.com (mail-ej1-f42.google.com [209.85.218.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 12CD62F36
	for <ell@lists.linux.dev>; Fri, 28 Apr 2023 12:20:40 +0000 (UTC)
Received: by mail-ej1-f42.google.com with SMTP id a640c23a62f3a-94f109b1808so1872919366b.1
        for <ell@lists.linux.dev>; Fri, 28 Apr 2023 05:20:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20221208; t=1682684439; x=1685276439;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=LQUXiARMvnOUuHC9plPKthV0iTLFBCZlrDtaXkKdP5A=;
        b=UXOHNiIDtcfFaxKmdWhhlLocjQM3A47zqWSu8Z4bOz97b49Gn9pitgKC//YP+XV8P+
         Pgtwza+cTNWADFK32jzteIUs3qNBwWHPmHQPXadOOcEHE2wGigy5P06QaU8nXJYBIwCJ
         FkYQZIlgxLwIrxxjheiMgfJxmKLY9jIOeTi0mm8yDVnj7oNLR1xUDNouHn0+Q1G5TLeF
         UmW8Zsk1hRLAZZeLVkej2M9owsN+mM5QG9e+HI0i9C5zEUFUl5i7vy9DsukSKYIMfqS7
         ucSHyOWn7t4dxP+H4d6zPscFvmY3DHlnh+U2ZZiFBx+oSl9vtMYmifkholUSawHoAvKp
         5PXA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20221208; t=1682684439; x=1685276439;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=LQUXiARMvnOUuHC9plPKthV0iTLFBCZlrDtaXkKdP5A=;
        b=I//Oq7JKhH9I+1l5Hsek2hROkck+qgALBcvUrgGyLh0p8ybWmDUMpGE8dZBjrlSI70
         glCWY87s5pRXKDYv/G35AarSVQcsfswPtULnOv1waZEkcHUGgOuwk1PBb+LEBRJpdUI6
         qjQGwcnMhYTWVzYFb7bSwBqFD/RvM3TTZ9pGWKItuGyx87m4ufpzNzxkGkNF2w2rc0xh
         0ExwFTm1HhJaTWBm9shhkmHKQEAhPFz9Xcd/l2PoyzjyqK/c+DKYAqE2/EibJ3ivGGO4
         OjqMJ5CYNOHR8MFgz965jABm836tPSe1R96rJq1eHkh6N56n0KbQbCpbeCJB4hmOloou
         yizw==
X-Gm-Message-State: AC+VfDzYdoyMp0VEM7angUol85kswYxNLgUPlO/VcYBlAL+ADLTUt+UH
	R3ukb0GerketKhOPPAidSGg=
X-Google-Smtp-Source: ACHHUZ6KxhtVWbKrG5cnQk6arkQYXmrTzbLDr/gxsR4hcTFMpCys2o8nPWZEyiuVofRvTIVoL5cTOw==
X-Received: by 2002:a17:907:25cc:b0:961:b0:3e0e with SMTP id ae12-20020a17090725cc00b0096100b03e0emr917406ejc.30.1682684439048;
        Fri, 28 Apr 2023 05:20:39 -0700 (PDT)
Received: from localhost.localdomain ([129.0.174.85])
        by smtp.gmail.com with ESMTPSA id d9-20020a17090694c900b0095354acf666sm11203659ejy.92.2023.04.28.05.20.36
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 28 Apr 2023 05:20:38 -0700 (PDT)
From: Brandon Cheo Fusi <fusibrandon13@gmail.com>
To: marcel@holtmann.org
Cc: ell@lists.linux.dev,
	Brandon Cheo Fusi <fusibrandon13@gmail.com>
Subject: [PATCH] ell: Make public headers compilable with C++
Date: Fri, 28 Apr 2023 13:20:25 +0100
Message-Id: <20230428122025.117834-1-fusibrandon13@gmail.com>
X-Mailer: git-send-email 2.30.2
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

This patch allows ell/ell.h to be included in C++ code by removing
'only C' features. These comprise

i)  implicit casts from void* to other types which are now made
    explicit
ii) C99 Static array indices.
---
 ell/cert.h     |  4 ++--
 ell/cleanup.h  |  4 ++--
 ell/ecc.h      |  4 ++--
 ell/icmp6.h    |  2 +-
 ell/key.h      |  4 ++--
 ell/rtnl.h     |  6 +++---
 ell/settings.h |  2 +-
 ell/string.h   |  2 +-
 ell/strv.h     |  2 +-
 ell/uintset.h  |  2 +-
 ell/util.h     | 12 ++++++------
 11 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/ell/cert.h b/ell/cert.h
index db116e0..22ff559 100644
--- a/ell/cert.h
+++ b/ell/cert.h
@@ -44,7 +44,7 @@ typedef bool (*l_cert_walk_cb_t)(struct l_cert *cert, void *user_data);
 
 struct l_cert *l_cert_new_from_der(const uint8_t *buf, size_t buf_len);
 void l_cert_free(struct l_cert *cert);
-DEFINE_CLEANUP_FUNC(l_cert_free);
+DEFINE_CLEANUP_FUNC(l_cert_free, struct l_cert *);
 
 const uint8_t *l_cert_get_der_data(struct l_cert *cert, size_t *out_len);
 const uint8_t *l_cert_get_dn(struct l_cert *cert, size_t *out_len);
@@ -54,7 +54,7 @@ enum l_cert_key_type l_cert_get_pubkey_type(struct l_cert *cert);
 struct l_key *l_cert_get_pubkey(struct l_cert *cert);
 
 void l_certchain_free(struct l_certchain *chain);
-DEFINE_CLEANUP_FUNC(l_certchain_free);
+DEFINE_CLEANUP_FUNC(l_certchain_free, struct l_certchain *);
 
 struct l_cert *l_certchain_get_leaf(struct l_certchain *chain);
 void l_certchain_walk_from_leaf(struct l_certchain *chain,
diff --git a/ell/cleanup.h b/ell/cleanup.h
index 89b1981..d2c9232 100644
--- a/ell/cleanup.h
+++ b/ell/cleanup.h
@@ -22,6 +22,6 @@
 
 #pragma once
 
-#define DEFINE_CLEANUP_FUNC(func)			\
+#define DEFINE_CLEANUP_FUNC(func, arg_type)			\
 	inline __attribute__((always_inline))		\
-	void func ## _cleanup(void *p) { func(*(void **) p); }
+	void func ## _cleanup(void *p) { func((arg_type)(*(void **) p)); }
diff --git a/ell/ecc.h b/ell/ecc.h
index 981bf95..c92450c 100644
--- a/ell/ecc.h
+++ b/ell/ecc.h
@@ -73,7 +73,7 @@ bool l_ecc_point_y_isodd(const struct l_ecc_point *p);
 
 ssize_t l_ecc_point_get_data(const struct l_ecc_point *p, void *buf, size_t len);
 void l_ecc_point_free(struct l_ecc_point *p);
-DEFINE_CLEANUP_FUNC(l_ecc_point_free);
+DEFINE_CLEANUP_FUNC(l_ecc_point_free, struct l_ecc_point *);
 
 struct l_ecc_scalar *l_ecc_scalar_new(const struct l_ecc_curve *curve,
 						const void *buf, size_t len);
@@ -87,7 +87,7 @@ struct l_ecc_scalar *l_ecc_scalar_new_reduced_1_to_n(
 ssize_t l_ecc_scalar_get_data(const struct l_ecc_scalar *c, void *buf,
 					size_t len);
 void l_ecc_scalar_free(struct l_ecc_scalar *c);
-DEFINE_CLEANUP_FUNC(l_ecc_scalar_free);
+DEFINE_CLEANUP_FUNC(l_ecc_scalar_free, struct l_ecc_scalar *);
 
 /* Constant operations */
 bool l_ecc_scalar_add(struct l_ecc_scalar *ret, const struct l_ecc_scalar *a,
diff --git a/ell/icmp6.h b/ell/icmp6.h
index ad3d661..1c1e147 100644
--- a/ell/icmp6.h
+++ b/ell/icmp6.h
@@ -59,7 +59,7 @@ bool l_icmp6_client_set_debug(struct l_icmp6_client *client,
 				l_icmp6_debug_cb_t function,
 				void *user_data, l_icmp6_destroy_cb_t destroy);
 bool l_icmp6_client_set_address(struct l_icmp6_client *client,
-					const uint8_t addr[static 6]);
+					const uint8_t addr[]);
 bool l_icmp6_client_set_nodelay(struct l_icmp6_client *client, bool nodelay);
 bool l_icmp6_client_set_rtnl(struct l_icmp6_client *client,
 						struct l_netlink *rtnl);
diff --git a/ell/key.h b/ell/key.h
index 6897105..dca8f86 100644
--- a/ell/key.h
+++ b/ell/key.h
@@ -111,9 +111,9 @@ bool l_keyring_restrict(struct l_keyring *keyring, enum l_keyring_restriction re
 			const struct l_keyring *trust);
 
 void l_keyring_free(struct l_keyring *keyring);
-DEFINE_CLEANUP_FUNC(l_keyring_free);
+DEFINE_CLEANUP_FUNC(l_keyring_free, struct l_keyring *);
 void l_keyring_free_norevoke(struct l_keyring *keyring);
-DEFINE_CLEANUP_FUNC(l_keyring_free_norevoke);
+DEFINE_CLEANUP_FUNC(l_keyring_free_norevoke, struct l_keyring *);
 
 bool l_keyring_link(struct l_keyring *keyring, const struct l_key *key);
 
diff --git a/ell/rtnl.h b/ell/rtnl.h
index 1e6b1fa..07f6292 100644
--- a/ell/rtnl.h
+++ b/ell/rtnl.h
@@ -41,7 +41,7 @@ typedef void (*l_rtnl_neighbor_get_cb_t) (int error, const uint8_t *hwaddr,
 struct l_rtnl_address *l_rtnl_address_new(const char *ip, uint8_t prefix_len);
 struct l_rtnl_address *l_rtnl_address_clone(const struct l_rtnl_address *orig);
 void l_rtnl_address_free(struct l_rtnl_address *addr);
-DEFINE_CLEANUP_FUNC(l_rtnl_address_free);
+DEFINE_CLEANUP_FUNC(l_rtnl_address_free, struct l_rtnl_address *);
 bool l_rtnl_address_get_address(const struct l_rtnl_address *addr,
 				char *out_buf);
 const void *l_rtnl_address_get_in_addr(const struct l_rtnl_address *addr);
@@ -75,7 +75,7 @@ struct l_rtnl_route *l_rtnl_route_new_prefix(const char *ip,
 struct l_rtnl_route *l_rtnl_route_new_static(const char *gw, const char *ip,
 							uint8_t prefix_len);
 void l_rtnl_route_free(struct l_rtnl_route *rt);
-DEFINE_CLEANUP_FUNC(l_rtnl_route_free);
+DEFINE_CLEANUP_FUNC(l_rtnl_route_free, struct l_rtnl_route *);
 uint8_t l_rtnl_route_get_family(const struct l_rtnl_route *rt);
 bool l_rtnl_route_get_gateway(const struct l_rtnl_route *rt, char *out_buf);
 const void *l_rtnl_route_get_gateway_in_addr(const struct l_rtnl_route *rt);
@@ -107,7 +107,7 @@ uint32_t l_rtnl_set_linkmode_and_operstate(struct l_netlink *rtnl, int ifindex,
 					l_netlink_destroy_func_t destroy);
 
 uint32_t l_rtnl_set_mac(struct l_netlink *rtnl, int ifindex,
-					const uint8_t addr[static 6],
+					const uint8_t addr[],
 					bool power_up,
 					l_netlink_command_func_t cb,
 					void *user_data,
diff --git a/ell/settings.h b/ell/settings.h
index 519014d..45a6b70 100644
--- a/ell/settings.h
+++ b/ell/settings.h
@@ -40,7 +40,7 @@ struct l_settings *l_settings_new(void);
 struct l_settings *l_settings_clone(const struct l_settings *settings);
 
 void l_settings_free(struct l_settings *settings);
-DEFINE_CLEANUP_FUNC(l_settings_free);
+DEFINE_CLEANUP_FUNC(l_settings_free, struct l_settings *);
 
 bool l_settings_load_from_data(struct l_settings *settings,
 						const char *data, size_t len);
diff --git a/ell/string.h b/ell/string.h
index e1faa7d..6f13ea6 100644
--- a/ell/string.h
+++ b/ell/string.h
@@ -34,7 +34,7 @@ struct l_string;
 
 struct l_string *l_string_new(size_t initial_length);
 void l_string_free(struct l_string *string);
-DEFINE_CLEANUP_FUNC(l_string_free);
+DEFINE_CLEANUP_FUNC(l_string_free, struct l_string *);
 char *l_string_unwrap(struct l_string *string);
 
 struct l_string *l_string_append(struct l_string *dest, const char *src);
diff --git a/ell/strv.h b/ell/strv.h
index 6de81db..42b7388 100644
--- a/ell/strv.h
+++ b/ell/strv.h
@@ -38,7 +38,7 @@ char *l_strjoinv(char **str_array, const char delim);
 
 char **l_strv_new(void);
 void l_strv_free(char **str_array);
-DEFINE_CLEANUP_FUNC(l_strv_free);
+DEFINE_CLEANUP_FUNC(l_strv_free, char **);
 unsigned int l_strv_length(char **str_array);
 bool l_strv_contains(char **str_array, const char *item);
 char **l_strv_append(char **str_array, const char *str);
diff --git a/ell/uintset.h b/ell/uintset.h
index 86ce8f7..2a928e7 100644
--- a/ell/uintset.h
+++ b/ell/uintset.h
@@ -39,7 +39,7 @@ struct l_uintset;
 struct l_uintset *l_uintset_new_from_range(uint32_t min, uint32_t max);
 struct l_uintset *l_uintset_new(unsigned int size);
 void l_uintset_free(struct l_uintset *set);
-DEFINE_CLEANUP_FUNC(l_uintset_free);
+DEFINE_CLEANUP_FUNC(l_uintset_free, struct l_uintset *);
 
 bool l_uintset_contains(struct l_uintset *set, uint32_t number);
 bool l_uintset_take(struct l_uintset *set, uint32_t number);
diff --git a/ell/util.h b/ell/util.h
index 1998720..06467e5 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -236,7 +236,7 @@ void *l_malloc(size_t size) __attribute__ ((warn_unused_result, malloc));
 void *l_memdup(const void *mem, size_t size)
 			__attribute__ ((warn_unused_result, malloc));
 void l_free(void *ptr);
-DEFINE_CLEANUP_FUNC(l_free);
+DEFINE_CLEANUP_FUNC(l_free, void *);
 
 void *l_realloc(void *mem, size_t size)
 			__attribute__ ((warn_unused_result, malloc));
@@ -365,8 +365,8 @@ const char *l_util_get_debugfs_path(void);
 static inline int l_secure_memcmp(const void *a, const void *b,
 					size_t size)
 {
-	const volatile uint8_t *aa = a;
-	const volatile uint8_t *bb = b;
+	const volatile uint8_t *aa = (const volatile uint8_t *)a;
+	const volatile uint8_t *bb = (const volatile uint8_t *)b;
 	int res = 0, diff, mask;
 
 	/*
@@ -417,9 +417,9 @@ static inline void l_secure_select(bool select_left,
 				const void *left, const void *right,
 				void *out, size_t len)
 {
-	const uint8_t *l = left;
-	const uint8_t *r = right;
-	uint8_t *o = out;
+	const uint8_t *l = (const uint8_t *)left;
+	const uint8_t *r = (const uint8_t *)right;
+	uint8_t *o = (uint8_t *)out;
 	uint8_t mask = -(!!select_left);
 	size_t i;
 
-- 
2.30.2

