Content-Type: multipart/mixed; boundary="===============4077956877866279922=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH] dhcp6: change option code to uint16_t
Date: Mon, 28 Sep 2020 10:36:56 -0700
Message-ID: <20200928173656.194761-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4077956877866279922==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

GCC-10 appears to have gotten "smarter" (or pickier) and passing
unnamed enums as an argument expecting a named enum results in
an error. The internal APIs in dhcp6 have been changed to take a
uint16_t instead of enum l_dhcp6_option. This allows both public
and internal DHCP options to be passed to these builder APIs.
---
 ell/dhcp6.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/ell/dhcp6.c b/ell/dhcp6.c
index 31b07c1..894252e 100644
--- a/ell/dhcp6.c
+++ b/ell/dhcp6.c
@@ -226,8 +226,7 @@ static uint8_t *option_reserve(struct dhcp6_message_bui=
lder *builder,
 	return p;
 }
 =

-static void option_start(struct dhcp6_message_builder *builder,
-						enum l_dhcp6_option type)
+static void option_start(struct dhcp6_message_builder *builder, uint16_t t=
ype)
 {
 	builder->option_start =3D builder->options_pos;
 	l_put_be16(type, option_reserve(builder, OPTION_HEADER_LEN));
@@ -244,7 +243,7 @@ static void option_finalize(struct dhcp6_message_builde=
r *builder)
 }
 =

 static void option_append_uint16(struct dhcp6_message_builder *builder,
-					enum l_dhcp6_option type, uint16_t v)
+					uint16_t type, uint16_t v)
 {
 	uint8_t *p =3D option_reserve(builder, OPTION_HEADER_LEN + sizeof(v));
 =

@@ -254,8 +253,7 @@ static void option_append_uint16(struct dhcp6_message_b=
uilder *builder,
 }
 =

 static void option_append_bytes(struct dhcp6_message_builder *builder,
-				enum l_dhcp6_option type,
-				const void *bytes, uint16_t len)
+				uint16_t type, const void *bytes, uint16_t len)
 {
 	uint8_t *p =3D option_reserve(builder, OPTION_HEADER_LEN + len);
 =

@@ -453,7 +451,7 @@ static void option_append_option_request(struct dhcp6_m=
essage_builder *builder,
 =

 static int option_append_ia_common(struct l_dhcp6_client *client,
 				struct dhcp6_message_builder *builder,
-				enum l_dhcp6_option option)
+				uint16_t option)
 {
 	option_start(builder, option);
 =

-- =

2.26.2

--===============4077956877866279922==--

