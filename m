Content-Type: multipart/mixed; boundary="===============4883266154200976241=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH v3 5/9] gvariant: Fix empty struct encoding
Date: Fri, 15 Apr 2016 02:33:58 +0200
Message-ID: <1460680442-15201-5-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1460680442-15201-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4883266154200976241==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Empty structs are encoded as a single zero byte.
---
 ell/gvariant-util.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/ell/gvariant-util.c b/ell/gvariant-util.c
index 791fc41..d5d6772 100644
--- a/ell/gvariant-util.c
+++ b/ell/gvariant-util.c
@@ -1010,6 +1010,10 @@ static bool leave_struct_dict_common(struct dbus_bui=
lder *builder,
 		int alignment =3D _gvariant_get_alignment(container->signature);
 		grow_body(builder, 0, alignment);
 =

+		/* Empty struct or "unit type" is a encoded as a zero byte */
+		if (container->signature[0] =3D=3D '\0')
+			grow_body(builder, 1, 1);
+
 		parent->variable_is_last =3D false;
 	} else {
 		size_t offset;
-- =

2.5.0


--===============4883266154200976241==--

