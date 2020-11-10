Content-Type: multipart/mixed; boundary="===============6437123961882410978=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@gmail.com>
Subject: [PATCH 2/2] ell: Do not use C99 static array index in C++
Date: Mon, 09 Nov 2020 16:57:58 -0800
Message-ID: <20201110005758.55338-3-ossama.othman@intel.com>
In-Reply-To: <20201110005758.55338-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6437123961882410978==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Some function declarations that are in the public ELL API that have
an array parameter with a C99 static array size, e.g.
void foo(int a[static 4], result in compile-time errors when used in
C++ code since C++ does not support that syntax.  When using a C++
compiler, pass the array by reference to achieve a similar affect of
having the compiler detect an inappropriately sized array being passed
to the function in question.

Note: The use of a C++ reference to an array as a function parameter
is not strictly the same as the C99 feature where the array size in
the function parameter is declared static since the latter specifies a
minimum array size and the the former specifies an exact size.
However, that isn't a problem in the case of the changes in this patch
since arrays of the exact size specified in the declaration are
expected.
---
 ell/icmp6.h | 4 ++++
 ell/rtnl.h  | 4 ++++
 2 files changed, 8 insertions(+)

diff --git a/ell/icmp6.h b/ell/icmp6.h
index a6b1265..5a85755 100644
--- a/ell/icmp6.h
+++ b/ell/icmp6.h
@@ -59,7 +59,11 @@ bool l_icmp6_client_set_debug(struct l_icmp6_client *cli=
ent,
 				l_icmp6_debug_cb_t function,
 				void *user_data, l_icmp6_destroy_cb_t destroy);
 bool l_icmp6_client_set_address(struct l_icmp6_client *client,
+#ifdef __cplusplus
+					const uint8_t (&addr)[6]);
+#else
 					const uint8_t addr[static 6]);
+#endif
 bool l_icmp6_client_set_nodelay(struct l_icmp6_client *client, bool nodela=
y);
 bool l_icmp6_client_set_rtnl(struct l_icmp6_client *client,
 						struct l_netlink *rtnl);
diff --git a/ell/rtnl.h b/ell/rtnl.h
index 0d1664a..552f18e 100644
--- a/ell/rtnl.h
+++ b/ell/rtnl.h
@@ -79,7 +79,11 @@ uint32_t l_rtnl_set_linkmode_and_operstate(struct l_netl=
ink *rtnl, int ifindex,
 					l_netlink_destroy_func_t destroy);
 =

 uint32_t l_rtnl_set_mac(struct l_netlink *rtnl, int ifindex,
+#ifdef __cplusplus
+					const uint8_t (&addr)[6],
+#else
 					const uint8_t addr[static 6],
+#endif
 					bool power_up,
 					l_netlink_command_func_t cb,
 					void *user_data,
-- =

2.25.1

--===============6437123961882410978==--

