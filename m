Content-Type: multipart/mixed; boundary="===============6288705720110158397=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 11/11] tls: Free cert memory after sending cert
Date: Mon, 06 Jun 2016 13:54:50 -0700
Message-ID: <20160606205450.23615-11-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20160606205450.23615-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6288705720110158397==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/tls.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/ell/tls.c b/ell/tls.c
index e1630c3..59fe0d0 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -727,6 +727,8 @@ static bool tls_send_certificate(struct l_tls *tls)
 	if (cert)
 		tls->cert_sent =3D true;
 =

+	l_free(cert);
+
 	return true;
 }
 =

-- =

2.8.3


--===============6288705720110158397==--

