Content-Type: multipart/mixed; boundary="===============2889948241961951567=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/3] tls: Reset .negotiated_ff_group on handshake reset
Date: Thu, 10 Jan 2019 23:25:36 +0100
Message-ID: <20190110222537.14492-2-andrew.zaborowski@intel.com>
In-Reply-To: <20190110222537.14492-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2889948241961951567==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/tls.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ell/tls.c b/ell/tls.c
index 0809a47..0e7928a 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -197,6 +197,7 @@ static void tls_reset_handshake(struct l_tls *tls)
 	tls->peer_pubkey =3D NULL;
 	tls->peer_pubkey_size =3D 0;
 	tls->negotiated_curve =3D NULL;
+	tls->negotiated_ff_group =3D NULL;
 =

 	for (hash =3D 0; hash < __HANDSHAKE_HASH_COUNT; hash++)
 		tls_drop_handshake_hash(tls, hash);
-- =

2.19.1


--===============2889948241961951567==--

