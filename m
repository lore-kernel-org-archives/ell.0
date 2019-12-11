Content-Type: multipart/mixed; boundary="===============6095631094960673713=="
MIME-Version: 1.0
From: Tim Kourt <tim.a.kourt@linux.intel.com>
Subject: [PATCH 5/5] dhcp: Add debug message
Date: Wed, 11 Dec 2019 15:21:21 -0800
Message-ID: <20191211232121.23129-5-tim.a.kourt@linux.intel.com>
In-Reply-To: <20191211232121.23129-1-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6095631094960673713==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add debug message for failed parsing of DHCP options.
---
 ell/dhcp.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/ell/dhcp.c b/ell/dhcp.c
index a362b7f..f1e1595 100644
--- a/ell/dhcp.c
+++ b/ell/dhcp.c
@@ -858,8 +858,11 @@ static int dhcp_client_receive_ack(struct l_dhcp_clien=
t *client,
 		return -EINVAL;
 =

 	lease =3D _dhcp_lease_parse_options(&iter);
-	if (!lease)
+	if (!lease) {
+		CLIENT_DEBUG("Failed to parse DHCP options.");
+
 		return -ENOMSG;
+	}
 =

 	lease->address =3D ack->yiaddr;
 =

-- =

2.13.6

--===============6095631094960673713==--

