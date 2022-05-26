Content-Type: multipart/mixed; boundary="===============8575366668876575009=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau at linux.intel.com>
To: ell at lists.01.org
Subject: [PATCH] useful: Remove extra semicolons after DEFINE_CLEANUP_FUNC()
Date: Thu, 26 May 2022 14:19:30 -0700
Message-ID: <20220526211930.172542-1-mathew.j.martineau@linux.intel.com>

--===============8575366668876575009==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The DEFINE_CLEANUP_FUNC() macro substitutes an inline function
definition that ends with a '}'. All the users of the macro add a
semicolon after the macro, so to the C compiler it ends up looking like
there's an extra semicolon after the inline function.

When non-ELL source files include ELL headers and use '-pedantic' with
gcc, the compiler complains:

error: ISO C does not allow extra =E2=80=98;=E2=80=99 outside of a function=
 [-Werror=3Dpedantic]

The non-ELL files can work around this with pragmas, but it does make
sense for ELL headers to be compliant with the C standard.
---
 ell/cert.h     | 4 ++--
 ell/ecc.h      | 4 ++--
 ell/key.h      | 4 ++--
 ell/rtnl.h     | 4 ++--
 ell/settings.h | 2 +-
 ell/string.h   | 2 +-
 ell/strv.h     | 2 +-
 ell/uintset.h  | 2 +-
 ell/util.h     | 2 +-
 9 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/ell/cert.h b/ell/cert.h
index 605e427c3d05..aa8ed3bc928f 100644
--- a/ell/cert.h
+++ b/ell/cert.h
@@ -43,7 +43,7 @@ typedef bool (*l_cert_walk_cb_t)(struct l_cert *cert, voi=
d *user_data);
 =

 struct l_cert *l_cert_new_from_der(const uint8_t *buf, size_t buf_len);
 void l_cert_free(struct l_cert *cert);
-DEFINE_CLEANUP_FUNC(l_cert_free);
+DEFINE_CLEANUP_FUNC(l_cert_free)
 =

 const uint8_t *l_cert_get_der_data(struct l_cert *cert, size_t *out_len);
 const uint8_t *l_cert_get_dn(struct l_cert *cert, size_t *out_len);
@@ -51,7 +51,7 @@ enum l_cert_key_type l_cert_get_pubkey_type(struct l_cert=
 *cert);
 struct l_key *l_cert_get_pubkey(struct l_cert *cert);
 =

 void l_certchain_free(struct l_certchain *chain);
-DEFINE_CLEANUP_FUNC(l_certchain_free);
+DEFINE_CLEANUP_FUNC(l_certchain_free)
 =

 struct l_cert *l_certchain_get_leaf(struct l_certchain *chain);
 void l_certchain_walk_from_leaf(struct l_certchain *chain,
diff --git a/ell/ecc.h b/ell/ecc.h
index 981bf95928b2..2f5f78182acf 100644
--- a/ell/ecc.h
+++ b/ell/ecc.h
@@ -73,7 +73,7 @@ bool l_ecc_point_y_isodd(const struct l_ecc_point *p);
 =

 ssize_t l_ecc_point_get_data(const struct l_ecc_point *p, void *buf, size_=
t len);
 void l_ecc_point_free(struct l_ecc_point *p);
-DEFINE_CLEANUP_FUNC(l_ecc_point_free);
+DEFINE_CLEANUP_FUNC(l_ecc_point_free)
 =

 struct l_ecc_scalar *l_ecc_scalar_new(const struct l_ecc_curve *curve,
 						const void *buf, size_t len);
@@ -87,7 +87,7 @@ struct l_ecc_scalar *l_ecc_scalar_new_reduced_1_to_n(
 ssize_t l_ecc_scalar_get_data(const struct l_ecc_scalar *c, void *buf,
 					size_t len);
 void l_ecc_scalar_free(struct l_ecc_scalar *c);
-DEFINE_CLEANUP_FUNC(l_ecc_scalar_free);
+DEFINE_CLEANUP_FUNC(l_ecc_scalar_free)
 =

 /* Constant operations */
 bool l_ecc_scalar_add(struct l_ecc_scalar *ret, const struct l_ecc_scalar =
*a,
diff --git a/ell/key.h b/ell/key.h
index d25d09385b6f..ff3d9abbda4c 100644
--- a/ell/key.h
+++ b/ell/key.h
@@ -109,9 +109,9 @@ bool l_keyring_restrict(struct l_keyring *keyring, enum=
 l_keyring_restriction re
 			const struct l_keyring *trust);
 =

 void l_keyring_free(struct l_keyring *keyring);
-DEFINE_CLEANUP_FUNC(l_keyring_free);
+DEFINE_CLEANUP_FUNC(l_keyring_free)
 void l_keyring_free_norevoke(struct l_keyring *keyring);
-DEFINE_CLEANUP_FUNC(l_keyring_free_norevoke);
+DEFINE_CLEANUP_FUNC(l_keyring_free_norevoke)
 =

 bool l_keyring_link(struct l_keyring *keyring, const struct l_key *key);
 =

diff --git a/ell/rtnl.h b/ell/rtnl.h
index 2617b1ca8f56..23d3dfc5cac5 100644
--- a/ell/rtnl.h
+++ b/ell/rtnl.h
@@ -41,7 +41,7 @@ typedef void (*l_rtnl_neighbor_get_cb_t) (int error, cons=
t uint8_t *hwaddr,
 struct l_rtnl_address *l_rtnl_address_new(const char *ip, uint8_t prefix_l=
en);
 struct l_rtnl_address *l_rtnl_address_clone(const struct l_rtnl_address *o=
rig);
 void l_rtnl_address_free(struct l_rtnl_address *addr);
-DEFINE_CLEANUP_FUNC(l_rtnl_address_free);
+DEFINE_CLEANUP_FUNC(l_rtnl_address_free)
 bool l_rtnl_address_get_address(const struct l_rtnl_address *addr,
 				char *out_buf);
 uint8_t l_rtnl_address_get_family(const struct l_rtnl_address *addr);
@@ -74,7 +74,7 @@ struct l_rtnl_route *l_rtnl_route_new_prefix(const char *=
ip,
 struct l_rtnl_route *l_rtnl_route_new_static(const char *gw, const char *i=
p,
 							uint8_t prefix_len);
 void l_rtnl_route_free(struct l_rtnl_route *rt);
-DEFINE_CLEANUP_FUNC(l_rtnl_route_free);
+DEFINE_CLEANUP_FUNC(l_rtnl_route_free)
 uint8_t l_rtnl_route_get_family(const struct l_rtnl_route *rt);
 bool l_rtnl_route_get_gateway(const struct l_rtnl_route *rt, char *out_buf=
);
 const void *l_rtnl_route_get_gateway_in_addr(const struct l_rtnl_route *rt=
);
diff --git a/ell/settings.h b/ell/settings.h
index 519014d55337..5c206a84097a 100644
--- a/ell/settings.h
+++ b/ell/settings.h
@@ -40,7 +40,7 @@ struct l_settings *l_settings_new(void);
 struct l_settings *l_settings_clone(const struct l_settings *settings);
 =

 void l_settings_free(struct l_settings *settings);
-DEFINE_CLEANUP_FUNC(l_settings_free);
+DEFINE_CLEANUP_FUNC(l_settings_free)
 =

 bool l_settings_load_from_data(struct l_settings *settings,
 						const char *data, size_t len);
diff --git a/ell/string.h b/ell/string.h
index e1faa7d77a47..793226760d4e 100644
--- a/ell/string.h
+++ b/ell/string.h
@@ -34,7 +34,7 @@ struct l_string;
 =

 struct l_string *l_string_new(size_t initial_length);
 void l_string_free(struct l_string *string);
-DEFINE_CLEANUP_FUNC(l_string_free);
+DEFINE_CLEANUP_FUNC(l_string_free)
 char *l_string_unwrap(struct l_string *string);
 =

 struct l_string *l_string_append(struct l_string *dest, const char *src);
diff --git a/ell/strv.h b/ell/strv.h
index 6de81db6bde5..51019480261a 100644
--- a/ell/strv.h
+++ b/ell/strv.h
@@ -38,7 +38,7 @@ char *l_strjoinv(char **str_array, const char delim);
 =

 char **l_strv_new(void);
 void l_strv_free(char **str_array);
-DEFINE_CLEANUP_FUNC(l_strv_free);
+DEFINE_CLEANUP_FUNC(l_strv_free)
 unsigned int l_strv_length(char **str_array);
 bool l_strv_contains(char **str_array, const char *item);
 char **l_strv_append(char **str_array, const char *str);
diff --git a/ell/uintset.h b/ell/uintset.h
index aa9de48d633c..ba9ac7259b68 100644
--- a/ell/uintset.h
+++ b/ell/uintset.h
@@ -39,7 +39,7 @@ struct l_uintset;
 struct l_uintset *l_uintset_new_from_range(uint32_t min, uint32_t max);
 struct l_uintset *l_uintset_new(unsigned int size);
 void l_uintset_free(struct l_uintset *set);
-DEFINE_CLEANUP_FUNC(l_uintset_free);
+DEFINE_CLEANUP_FUNC(l_uintset_free)
 =

 bool l_uintset_contains(struct l_uintset *set, uint32_t number);
 bool l_uintset_take(struct l_uintset *set, uint32_t number);
diff --git a/ell/util.h b/ell/util.h
index 3daf07657430..c7e79003b089 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -236,7 +236,7 @@ void *l_malloc(size_t size) __attribute__ ((warn_unused=
_result, malloc));
 void *l_memdup(const void *mem, size_t size)
 			__attribute__ ((warn_unused_result, malloc));
 void l_free(void *ptr);
-DEFINE_CLEANUP_FUNC(l_free);
+DEFINE_CLEANUP_FUNC(l_free)
 =

 void *l_realloc(void *mem, size_t size)
 			__attribute__ ((warn_unused_result, malloc));
-- =

2.36.1

--===============8575366668876575009==--

