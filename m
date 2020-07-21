Content-Type: multipart/mixed; boundary="===============7666318986438732638=="
MIME-Version: 1.0
From: Rosen Penev <rosenp@gmail.com>
Subject: [PATCH 2/3] ell: match declaration names
Date: Tue, 21 Jul 2020 15:39:58 -0700
Message-ID: <20200721223959.87135-2-rosenp@gmail.com>
In-Reply-To: <20200721223959.87135-1-rosenp@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7666318986438732638==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Found with clang-tidy's
readability-inconsistent-declaration-parameter-name

Signed-off-by: Rosen Penev <rosenp@gmail.com>
---
 ell/cert-private.h | 2 +-
 ell/dbus-private.h | 2 +-
 ell/ecc-private.h  | 4 ++--
 ell/log.h          | 2 +-
 ell/rtnl.h         | 2 +-
 ell/utf8.h         | 2 +-
 6 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/ell/cert-private.h b/ell/cert-private.h
index ba9a513..929f88d 100644
--- a/ell/cert-private.h
+++ b/ell/cert-private.h
@@ -23,7 +23,7 @@
 struct asn1_oid;
 =

 struct l_certchain *certchain_new_from_leaf(struct l_cert *leaf);
-void certchain_link_issuer(struct l_certchain *chain, struct l_cert *issue=
r);
+void certchain_link_issuer(struct l_certchain *chain, struct l_cert *ca);
 =

 const uint8_t *cert_get_extension(struct l_cert *cert,
 					const struct asn1_oid *ext_id,
diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index d34a298..66a585e 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -179,7 +179,7 @@ void _dbus_property_introspection(struct _dbus_property=
 *info,
 void _dbus_interface_introspection(struct l_dbus_interface *interface,
 						struct l_string *buf);
 =

-struct l_dbus_interface *_dbus_interface_new(const char *interface);
+struct l_dbus_interface *_dbus_interface_new(const char *name);
 void _dbus_interface_free(struct l_dbus_interface *interface);
 =

 struct _dbus_method *_dbus_interface_find_method(struct l_dbus_interface *=
i,
diff --git a/ell/ecc-private.h b/ell/ecc-private.h
index 0e85d98..70d9607 100644
--- a/ell/ecc-private.h
+++ b/ell/ecc-private.h
@@ -59,10 +59,10 @@ void _vli_mod_inv(uint64_t *result, const uint64_t *inp=
ut, const uint64_t *mod,
 			unsigned int ndigits);
 =

 void _vli_mod_sub(uint64_t *result, const uint64_t *left, const uint64_t *=
right,
-		const uint64_t *curve_prime, unsigned int ndigits);
+		const uint64_t *mod, unsigned int ndigits);
 =

 void _vli_mod_add(uint64_t *result, const uint64_t *left, const uint64_t *=
right,
-			const uint64_t *curve_prime, unsigned int ndigits);
+			const uint64_t *mod, unsigned int ndigits);
 =

 void _vli_rshift1(uint64_t *vli, unsigned int ndigits);
 =

diff --git a/ell/log.h b/ell/log.h
index 19bf10b..924523b 100644
--- a/ell/log.h
+++ b/ell/log.h
@@ -74,7 +74,7 @@ struct l_debug_desc {
 =

 void l_debug_enable_full(const char *pattern,
 				struct l_debug_desc *start,
-				struct l_debug_desc *stop);
+				struct l_debug_desc *end);
 void l_debug_add_section(struct l_debug_desc *start,
 					struct l_debug_desc *end);
 =

diff --git a/ell/rtnl.h b/ell/rtnl.h
index 60b8db4..a0c06ed 100644
--- a/ell/rtnl.h
+++ b/ell/rtnl.h
@@ -83,7 +83,7 @@ uint32_t l_rtnl_route4_add_gateway(struct l_netlink *rtnl=
, int ifindex,
 					void *user_data,
 					l_netlink_destroy_func_t destroy);
 =

-void l_rtnl_ifaddr6_extract(const struct ifaddrmsg *ifa, int bytes,
+void l_rtnl_ifaddr6_extract(const struct ifaddrmsg *ifa, int len,
 								char **ip);
 uint32_t l_rtnl_ifaddr6_dump(struct l_netlink *rtnl,
 				l_netlink_command_func_t cb,
diff --git a/ell/utf8.h b/ell/utf8.h
index c92da60..d1b1811 100644
--- a/ell/utf8.h
+++ b/ell/utf8.h
@@ -102,7 +102,7 @@ static inline __attribute__ ((always_inline)) bool l_as=
cii_isascii(int c)
 }
 =

 bool l_utf8_validate(const char *src, size_t len, const char **end);
-size_t l_utf8_strlen(const char *src);
+size_t l_utf8_strlen(const char *str);
 =

 int l_utf8_get_codepoint(const char *str, size_t len, wchar_t *cp);
 size_t l_utf8_from_wchar(wchar_t c, char *out_buf);
-- =

2.26.2

--===============7666318986438732638==--

