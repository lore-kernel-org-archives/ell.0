Content-Type: multipart/mixed; boundary="===============8376884384589091717=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH] dhcp: Free the old transport when setting, not the new one
Date: Mon, 29 Oct 2018 15:16:12 -0700
Message-ID: <20181029221612.4455-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8376884384589091717==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

_dhcp_client_set_transport() would mistakenly free the new transport if
the client had an existing transport. This private function is only used
in a unit test, and only with a client that has an empty transport, so
it was a latent bug.
---
 ell/dhcp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/dhcp.c b/ell/dhcp.c
index 0d99f74..5b46b0e 100644
--- a/ell/dhcp.c
+++ b/ell/dhcp.c
@@ -935,7 +935,7 @@ bool _dhcp_client_set_transport(struct l_dhcp_client *c=
lient,
 		return false;
 =

 	if (client->transport)
-		_dhcp_transport_free(transport);
+		_dhcp_transport_free(client->transport);
 =

 	client->transport =3D transport;
 	return true;
-- =

2.19.1


--===============8376884384589091717==--

