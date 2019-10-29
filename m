Content-Type: multipart/mixed; boundary="===============6338752141685983489=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/5] tls: Don't free cert on l_tls_set_auth_data failure
Date: Tue, 29 Oct 2019 01:24:41 +0100
Message-ID: <20191029002443.23574-3-andrew.zaborowski@intel.com>
In-Reply-To: <20191029002443.23574-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6338752141685983489==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Make sure we don't free the key/cert on error return from this
function to be consistent with l_tls_set_cacert and their new
comments.
---
 ell/tls.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/tls.c b/ell/tls.c
index 5efd928..52e7924 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -2847,7 +2847,7 @@ LIB_EXPORT bool l_tls_set_auth_data(struct l_tls *tls,
 					L_CHECKSUM_NONE, &tls->priv_key_size,
 					&is_public) || is_public) {
 			TLS_DEBUG("Not a private key or l_key_get_info failed");
-			l_key_free(tls->priv_key);
+			tls->cert =3D NULL;
 			tls->priv_key =3D NULL;
 			tls->priv_key_size =3D 0;
 			return false;
-- =

2.20.1

--===============6338752141685983489==--

