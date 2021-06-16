Content-Type: multipart/mixed; boundary="===============1981713374273422690=="
MIME-Version: 1.0
From: Davide Caratti <davide.caratti@gmail.com>
Subject: [PATCH 2/2] examples: avoid using inet_ntoa()
Date: Wed, 16 Jun 2021 21:22:15 +0200
Message-ID: <fb5f207d58299b01ef358503897507be9cc21fe0.1623871292.git.davide.caratti@gmail.com>
In-Reply-To: <144affac0389b92896ae152643610b6ec497a398.1623871292.git.davide.caratti@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1981713374273422690==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 examples/https-server-test.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/examples/https-server-test.c b/examples/https-server-test.c
index 6362722..b626fd2 100644
--- a/examples/https-server-test.c
+++ b/examples/https-server-test.c
@@ -199,12 +199,13 @@ int main(int argc, char *argv[])
 			https_tls_ready, https_tls_disconnected, NULL);
 =

 	if (getenv("TLS_DEBUG")) {
+		char buf[INET_ADDRSTRLEN];
 		char *str;
 =

 		l_tls_set_debug(tls, https_tls_debug_cb, NULL, NULL);
 =

-		str =3D l_strdup_printf("/tmp/ell-certchain-%s.pem",
-					inet_ntoa(client_addr.sin_addr));
+		inet_ntop(AF_INET,&client_addr.sin_addr, buf, INET_ADDRSTRLEN);
+		str =3D l_strdup_printf("/tmp/ell-certchain-%s.pem", buf);
 		l_tls_set_cert_dump_path(tls, str);
 		l_free(str);
 	}
-- =

2.31.1

--===============1981713374273422690==--

