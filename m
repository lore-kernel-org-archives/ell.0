Content-Type: multipart/mixed; boundary="===============0103093440220493936=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] gvariant: Reset container's variable_is_last for fixed-size
 structs.
Date: Sat, 19 Mar 2016 07:00:44 +0100
Message-ID: <1458367247-14607-6-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1458367247-14607-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0103093440220493936==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

We reset container->variable_is_last after basic fixed-size types but
not after structs and dicts.  This would probably produce incorrect
results for fixed-size structs that are the last element in a
variable-size struct, e.g. (s(u))
---
 ell/gvariant-util.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/ell/gvariant-util.c b/ell/gvariant-util.c
index 61e5b52..4601222 100644
--- a/ell/gvariant-util.c
+++ b/ell/gvariant-util.c
@@ -994,6 +994,8 @@ static bool leave_struct_dict_common(struct dbus_builde=
r *builder,
 	if (_gvariant_is_fixed_size(container->signature)) {
 		int alignment =3D _gvariant_get_alignment(container->signature);
 		grow_body(builder, 0, alignment);
+
+		parent->variable_is_last =3D false;
 	} else {
 		size_t offset;
 =

-- =

2.5.0


--===============0103093440220493936==--

