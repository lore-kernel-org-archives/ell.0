Content-Type: multipart/mixed; boundary="===============2923816593061515953=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH v2 2/9] dhcp-private: add flag in lease to distinguish
 offered/active
Date: Mon, 23 Nov 2020 10:47:33 -0800
Message-ID: <20201123184740.4023017-2-prestwoj@gmail.com>
In-Reply-To: <20201123184740.4023017-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2923816593061515953==
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

--===============2923816593061515953==--

