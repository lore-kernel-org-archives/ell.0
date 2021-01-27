Content-Type: multipart/mixed; boundary="===============5251470790741436300=="
MIME-Version: 1.0
From: Brian Gix <brian.gix@intel.com>
Subject: [PATCH] dhcp-util: Fix warning on signed pointer systems
Date: Wed, 27 Jan 2021 09:09:10 -0800
Message-ID: <20210127170910.1514394-1-brian.gix@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5251470790741436300==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Some systems treat pointers as signed values, causing the following
error:

ell/dhcp-util.c: In function =E2=80=98_dhcp_message_builder_append=E2=80=99:
ell/dhcp-util.c:55:49: error: comparison of integer expressions of differen=
t signedness: =E2=80=98int=E2=80=99 and =E2=80=98unsigned int=E2=80=99 [-We=
rror=3Dsign-compare]
   55 |  if ((builder)->pos - (builder)->start + (next) > (builder)->max) \
      |                                                 ^
ell/dhcp-util.c:65:3: note: in expansion of macro =E2=80=98LEN_CHECK=E2=80=
=99
   65 |   LEN_CHECK(builder, 1);
      |   ^~~~~~~~~
---
 ell/dhcp-util.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/ell/dhcp-util.c b/ell/dhcp-util.c
index 7809e52..feb1168 100644
--- a/ell/dhcp-util.c
+++ b/ell/dhcp-util.c
@@ -52,7 +52,8 @@ static void dhcp_init_header(struct dhcp_message *message=
, uint8_t type)
 }
 =

 #define LEN_CHECK(builder, next) \
-	if ((builder)->pos - (builder)->start + (next) > (builder)->max) \
+	if ((unsigned)((builder)->pos - (builder)->start + (next)) > \
+							(builder)->max) \
 		return false;
 =

 bool _dhcp_message_builder_append(struct dhcp_message_builder *builder,
-- =

2.25.4

--===============5251470790741436300==--

