Content-Type: multipart/mixed; boundary="===============0673410228121145775=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/7] ecc: Erase freed values in l_ecc_scalar_free
Date: Fri, 21 Dec 2018 23:03:21 +0100
Message-ID: <20181221220326.10112-2-andrew.zaborowski@intel.com>
In-Reply-To: <20181221220326.10112-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0673410228121145775==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Both the private key and the final shared secret in ECDH happen to be
scalars (the public key is a point).  We could have a separate function
to free sensitive scalars but it's probably ok to erase all scalars
perfomance wise.
---
 ell/ecc.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/ell/ecc.c b/ell/ecc.c
index 6b93e54..a59e8e4 100644
--- a/ell/ecc.c
+++ b/ell/ecc.c
@@ -427,5 +427,9 @@ LIB_EXPORT ssize_t l_ecc_scalar_get_data(const struct l=
_ecc_scalar *c,
 =

 LIB_EXPORT void l_ecc_scalar_free(struct l_ecc_scalar *c)
 {
+	if (unlikely(!c))
+		return;
+
+	memset(c->c, 0, c->curve->ndigits * 8);
 	l_free(c);
 }
-- =

2.19.1


--===============0673410228121145775==--

