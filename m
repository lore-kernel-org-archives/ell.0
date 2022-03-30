Content-Type: multipart/mixed; boundary="===============2617029076536160319=="
MIME-Version: 1.0
From: James Prestwood <prestwoj at gmail.com>
To: ell at lists.01.org
Subject: [PATCH] rtnl: change l_rtnl_address expire times to uint64_t
Date: Wed, 30 Mar 2022 12:23:21 -0700
Message-ID: <20220330192321.1871376-1-prestwoj@gmail.com>

--===============2617029076536160319==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

These are calculated from uint64_t values so they also should be
uint64_t sizes.
---
 ell/rtnl.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/ell/rtnl.c b/ell/rtnl.c
index afbff9d..f7f36ab 100644
--- a/ell/rtnl.c
+++ b/ell/rtnl.c
@@ -54,8 +54,8 @@ struct l_rtnl_address {
 	char label[IFNAMSIZ];
 	uint32_t preferred_lifetime;
 	uint32_t valid_lifetime;
-	uint32_t preferred_expiry_time;
-	uint32_t valid_expiry_time;
+	uint64_t preferred_expiry_time;
+	uint64_t valid_expiry_time;
 	uint32_t flags;
 };
 =

-- =

2.34.1

--===============2617029076536160319==--

