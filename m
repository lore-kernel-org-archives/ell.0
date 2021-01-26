Content-Type: multipart/mixed; boundary="===============0644594710436934812=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH] dhcp-util: fix GCC 10 warning
Date: Tue, 26 Jan 2021 13:20:05 -0800
Message-ID: <20210126212005.885653-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0644594710436934812==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

LEN_CHECK was being fed a hardcoded '1' which was being
treated as an int. This led GCC 10.2.1 to emit a warning about
comparison between signed/unsigned integers because the
builder->max member is unsigned:

ell/dhcp-util.c: In function =E2=80=98_dhcp_message_builder_append=E2=80=99:
ell/dhcp-util.c:55:49: error: comparison of integer expressions of different
		signedness: =E2=80=98int=E2=80=99 and =E2=80=98unsigned int=E2=80=99 [-We=
rror=3Dsign-compare]
   55 |  if ((builder)->pos - (builder)->start + (next) > (builder)->max) \
      |                                                 ^
ell/dhcp-util.c:65:3: note: in expansion of macro =E2=80=98LEN_CHECK=E2=80=
=99
   65 |   LEN_CHECK(builder, 1);
      |   ^~~~~~~~~
cc1: all warnings being treated as errors

To fix this explicitly use '1U' so the compiler treats it
as unsigned.
---
 ell/dhcp-util.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/dhcp-util.c b/ell/dhcp-util.c
index 7809e52..af09856 100644
--- a/ell/dhcp-util.c
+++ b/ell/dhcp-util.c
@@ -62,7 +62,7 @@ bool _dhcp_message_builder_append(struct dhcp_message_bui=
lder *builder,
 	switch (code) {
 	case DHCP_OPTION_PAD:
 	case DHCP_OPTION_END:
-		LEN_CHECK(builder, 1);
+		LEN_CHECK(builder, 1U);
 =

 		builder->pos[0] =3D code;
 		builder->pos +=3D 1;
-- =

2.26.2

--===============0644594710436934812==--

