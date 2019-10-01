Content-Type: multipart/mixed; boundary="===============0195568051139465020=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 4/4] cert: allow l_certchain_free use in l_queue_destroy
Date: Tue, 01 Oct 2019 11:27:33 -0700
Message-ID: <20191001182733.16176-4-prestwoj@gmail.com>
In-Reply-To: <20191001182733.16176-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0195568051139465020==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

l_pem_load_certificate_list returns a queue of l_certchains and
cleaning up this queue requires l_certchain_free to be wrapped
in a queue destroy function.

This patch changes l_certchain_free to take a void * so it can
be used directly in l_queue_destroy.
---
 ell/cert.c | 4 +++-
 ell/cert.h | 2 +-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/ell/cert.c b/ell/cert.c
index 7d6ae3a..52be01d 100644
--- a/ell/cert.c
+++ b/ell/cert.c
@@ -304,8 +304,10 @@ static struct l_cert *certchain_pop_ca(struct l_certch=
ain *chain)
 	return ca;
 }
 =

-LIB_EXPORT void l_certchain_free(struct l_certchain *chain)
+LIB_EXPORT void l_certchain_free(void *data)
 {
+	struct l_certchain *chain =3D data;
+
 	while (chain && chain->ca)
 		l_cert_free(certchain_pop_ca(chain));
 =

diff --git a/ell/cert.h b/ell/cert.h
index 0dc86a2..8c1b8fb 100644
--- a/ell/cert.h
+++ b/ell/cert.h
@@ -48,7 +48,7 @@ const uint8_t *l_cert_get_dn(struct l_cert *cert, size_t =
*out_len);
 enum l_cert_key_type l_cert_get_pubkey_type(struct l_cert *cert);
 struct l_key *l_cert_get_pubkey(struct l_cert *cert);
 =

-void l_certchain_free(struct l_certchain *chain);
+void l_certchain_free(void *data);
 =

 struct l_cert *l_certchain_get_leaf(struct l_certchain *chain);
 void l_certchain_walk_from_leaf(struct l_certchain *chain,
-- =

2.17.1

--===============0195568051139465020==--

