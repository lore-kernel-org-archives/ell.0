Content-Type: multipart/mixed; boundary="===============4727741841448521348=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 4/8] dhcp-lease: Check duplicate options in
 _dhcp_lease_parse_options
Date: Fri, 23 Jul 2021 20:23:27 +0200
Message-ID: <20210723182331.135123-4-andrew.zaborowski@intel.com>
In-Reply-To: <20210723182331.135123-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4727741841448521348==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Guard against leaks if some of the options are duplicated in the message
being parsed in _dhcp_lease_parse_options.
---
 ell/dhcp-lease.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/ell/dhcp-lease.c b/ell/dhcp-lease.c
index 94b67b4..ffed6d6 100644
--- a/ell/dhcp-lease.c
+++ b/ell/dhcp-lease.c
@@ -90,6 +90,9 @@ struct l_dhcp_lease *_dhcp_lease_parse_options(struct dhc=
p_message_iter *iter)
 				lease->broadcast =3D l_get_u32(v);
 			break;
 		case L_DHCP_OPTION_DOMAIN_NAME_SERVER:
+			if (lease->dns)
+				goto error;
+
 			if (l >=3D 4 && !(l % 4)) {
 				unsigned i =3D 0;
 =

@@ -105,7 +108,7 @@ struct l_dhcp_lease *_dhcp_lease_parse_options(struct d=
hcp_message_iter *iter)
 			}
 			break;
 		case L_DHCP_OPTION_DOMAIN_NAME:
-			if (l < 1 || l > 253)
+			if (l < 1 || l > 253 || lease->domain_name)
 				goto error;
 =

 			/* Disallow embedded NUL bytes. */
-- =

2.30.2

--===============4727741841448521348==--

