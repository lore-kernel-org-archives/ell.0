Content-Type: multipart/mixed; boundary="===============2642183721788503947=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 3/6] dhcp-private: add flag in lease to distinguish
 offered/active
Date: Wed, 18 Nov 2020 11:00:53 -0800
Message-ID: <20201118190056.3584080-3-prestwoj@gmail.com>
In-Reply-To: <20201118190056.3584080-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2642183721788503947==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The DHCP server did not distinguish between a lease which has been
offered, and one that is active.
---
 ell/dhcp-private.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/ell/dhcp-private.h b/ell/dhcp-private.h
index 62abfca..17d0574 100644
--- a/ell/dhcp-private.h
+++ b/ell/dhcp-private.h
@@ -158,6 +158,9 @@ struct l_dhcp_lease {
 	char *domain_name;
 	/* for server */
 	uint8_t mac[6];
+
+	/* set for an offered lease, but not ACK'ed */
+	bool offering : 1;
 };
 =

 struct l_dhcp_lease *_dhcp_lease_new(void);
-- =

2.26.2

--===============2642183721788503947==--

