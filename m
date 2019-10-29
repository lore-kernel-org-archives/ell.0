Content-Type: multipart/mixed; boundary="===============6517791998183147491=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/5] tls: Update the docs for l_tls_set_cacert and _auth_data
Date: Tue, 29 Oct 2019 01:24:40 +0100
Message-ID: <20191029002443.23574-2-andrew.zaborowski@intel.com>
In-Reply-To: <20191029002443.23574-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6517791998183147491==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Explicitly state when these functions take ownership of the parameters
and make the semantics the same for both functions.  Drop a no-longer
applicable TODO comment.  (this is independent of the comments needing
to be moved to tls.c in doxygen format)
---
 ell/tls.h | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/ell/tls.h b/ell/tls.h
index 0ca6def..b67492b 100644
--- a/ell/tls.h
+++ b/ell/tls.h
@@ -98,19 +98,21 @@ void l_tls_write(struct l_tls *tls, const uint8_t *data=
, size_t len);
 /* Submit TLS payload from underlying transport to be decrypted */
 void l_tls_handle_rx(struct l_tls *tls, const uint8_t *data, size_t len);
 =

-/* If peer is to be authenticated, supply the CA certificates */
+/*
+ * If peer is to be authenticated, supply the CA certificates.  On success
+ * the l_tls object takes ownership of the queue and the individual l_cert
+ * objects and they should not be freed by the caller afterwards.
+ */
 bool l_tls_set_cacert(struct l_tls *tls, struct l_queue *ca_certs);
 =

 /*
- * If we are to be authenticated, supply our certificate and private key. =
On the
- * client this is optional.
- * TODO: allow NULL private key if certificate file contains the key.
+ * If we are to be authenticated, supply our certificate and private key.
+ * On the client this is optional.  On success, the l_tls object takes
+ * ownership of the certchain and the key objects and they should not be
+ * freed by the caller afterwards.
  * TODO: it may also be useful for the caller to be able to supply one
  * certificate of each type so they can be used depending on which is comp=
atible
  * with the negotiated parameters.
- *
- * Note: Providing certchain and priv_key will move memory ownership into =
the
- *       tls object. These objects should not be freed by the caller.
  */
 bool l_tls_set_auth_data(struct l_tls *tls,
 				struct l_certchain *certchain,
-- =

2.20.1

--===============6517791998183147491==--

