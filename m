Content-Type: multipart/mixed; boundary="===============7644261962773686738=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH] dhcp6: Fix uninitialized variable build warning
Date: Thu, 20 Aug 2020 12:38:01 -0700
Message-ID: <20200820193801.264181-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7644261962773686738==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Commit 17f79c855e61 added a variable 'r' to dhcp6_client_rx_message()
that holds either a new dhcp6_state or an error (negative value). 'r'
was not set in several client states, but it appears that the unit tests
only cover cases where it is set.

It appears that the new code at the end of dhcp6_client_rx_message() is
only intended for the cases where 'r' was set, so initialize 'r' to the
current client->state and rely on the existing state check to preserve
old behavior.
---

Denis, I don't have enough background knowledge about DHCPv6 to be 100%
sure this patch does the right thing. Is my guess correct about the
intended use of the new code at the end of dhcp6_client_rx_message()?


 ell/dhcp6.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/dhcp6.c b/ell/dhcp6.c
index d41cdde..b0c6438 100644
--- a/ell/dhcp6.c
+++ b/ell/dhcp6.c
@@ -1148,7 +1148,7 @@ static void dhcp6_client_rx_message(const void *data,=
 size_t len,
 {
 	struct l_dhcp6_client *client =3D userdata;
 	const struct dhcp6_message *message =3D data;
-	int r;
+	int r =3D client->state;
 =

 	CLIENT_DEBUG("");
 =

-- =

2.28.0

--===============7644261962773686738==--

