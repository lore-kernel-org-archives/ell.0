Content-Type: multipart/mixed; boundary="===============4470661311539035782=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 08/14] dhcp-lease: change _dhcp_lease_free to take void*
Date: Thu, 15 Oct 2020 10:17:25 -0700
Message-ID: <20201015171731.396538-8-prestwoj@gmail.com>
In-Reply-To: <20201015171731.396538-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4470661311539035782==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This allows _dhcp_lease_free to be used with l_queue_destroy
directly without a wrapper function.
---
 ell/dhcp-lease.c   | 4 +++-
 ell/dhcp-private.h | 2 +-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/ell/dhcp-lease.c b/ell/dhcp-lease.c
index 59de3e3..f9545b5 100644
--- a/ell/dhcp-lease.c
+++ b/ell/dhcp-lease.c
@@ -41,8 +41,10 @@ struct l_dhcp_lease *_dhcp_lease_new(void)
 	return ret;
 }
 =

-void _dhcp_lease_free(struct l_dhcp_lease *lease)
+void _dhcp_lease_free(void *data)
 {
+	struct l_dhcp_lease *lease =3D data;
+
 	if (!lease)
 		return;
 =

diff --git a/ell/dhcp-private.h b/ell/dhcp-private.h
index 6038354..f6058fd 100644
--- a/ell/dhcp-private.h
+++ b/ell/dhcp-private.h
@@ -149,7 +149,7 @@ struct l_dhcp_lease {
 };
 =

 struct l_dhcp_lease *_dhcp_lease_new(void);
-void _dhcp_lease_free(struct l_dhcp_lease *lease);
+void _dhcp_lease_free(void *data);
 struct l_dhcp_lease *_dhcp_lease_parse_options(struct dhcp_message_iter *i=
ter);
 =

 struct dhcp_message_builder {
-- =

2.26.2

--===============4470661311539035782==--

