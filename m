Content-Type: multipart/mixed; boundary="===============7352607332045085265=="
MIME-Version: 1.0
From: Tim Kourt <tim.a.kourt@linux.intel.com>
Subject: [PATCH] dhcp-lease: Fix typo
Date: Thu, 12 Dec 2019 15:00:03 -0800
Message-ID: <20191212230003.25020-1-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7352607332045085265==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Replace logical AND with OR.
---
 ell/dhcp-lease.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/dhcp-lease.c b/ell/dhcp-lease.c
index 8f044fb..4d49190 100644
--- a/ell/dhcp-lease.c
+++ b/ell/dhcp-lease.c
@@ -104,7 +104,7 @@ struct l_dhcp_lease *_dhcp_lease_parse_options(struct d=
hcp_message_iter *iter)
 			}
 			break;
 		case L_DHCP_OPTION_DOMAIN_NAME:
-			if (l < 1 && l > 253)
+			if (l < 1 || l > 253)
 				goto error;
 =

 			/* Disallow embedded NUL bytes. */
-- =

2.13.6

--===============7352607332045085265==--

