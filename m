Content-Type: multipart/mixed; boundary="===============5512234427662025315=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/3] pem: Add pem_write_certificate_chain
Date: Thu, 17 Dec 2020 22:40:43 +0100
Message-ID: <20201217214045.851919-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5512234427662025315==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/pem-private.h |  5 +++++
 ell/pem.c         | 45 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 50 insertions(+)

diff --git a/ell/pem-private.h b/ell/pem-private.h
index 6e9458d..10f918f 100644
--- a/ell/pem-private.h
+++ b/ell/pem-private.h
@@ -27,6 +27,8 @@
 #define _GNU_SOURCE
 #include <sys/types.h>
 =

+struct l_certchain;
+
 const char *pem_next(const void *buf, size_t buf_len, char **type_label,
 				size_t *base64_len,
 				const char **endp, bool strict);
@@ -37,3 +39,6 @@ struct l_key *pem_key_from_pkcs8_private_key_info(const u=
int8_t *der,
 struct l_key *pem_key_from_pkcs8_encrypted_private_key_info(const uint8_t =
*der,
 							size_t der_len,
 							const char *passphrase);
+
+int pem_write_certificate_chain(const struct l_certchain *cert,
+				const char *filename);
diff --git a/ell/pem.c b/ell/pem.c
index 1b995d5..fd25016 100644
--- a/ell/pem.c
+++ b/ell/pem.c
@@ -364,6 +364,51 @@ LIB_EXPORT struct l_certchain *l_pem_load_certificate_=
chain(
 	return pem_list_to_chain(list);
 }
 =

+static bool pem_write_one_cert(struct l_cert *cert, void *user_data)
+{
+	int *fd =3D user_data;
+	const uint8_t *der;
+	size_t der_len;
+	struct iovec iov[3];
+	ssize_t r;
+
+	der =3D l_cert_get_der_data(cert, &der_len);
+
+	iov[0].iov_base =3D "-----BEGIN CERTIFICATE-----\n";
+	iov[0].iov_len =3D strlen(iov[0].iov_base);
+	iov[1].iov_base =3D l_base64_encode(der, der_len, 64, &iov[1].iov_len);
+	iov[2].iov_base =3D "\n-----END CERTIFICATE-----\n";
+	iov[2].iov_len =3D strlen(iov[2].iov_base);
+	r =3D L_TFR(writev(*fd, iov, 3));
+	l_free(iov[1].iov_base);
+
+	if (r =3D=3D (ssize_t) (iov[0].iov_len + iov[1].iov_len + iov[2].iov_len))
+		return false;
+
+	if (r < 0)
+		*fd =3D -errno;
+	else
+		*fd =3D -EIO;
+
+	return true;
+}
+
+int pem_write_certificate_chain(const struct l_certchain *chain,
+				const char *filename)
+{
+	int fd =3D L_TFR(open(filename, O_CREAT | O_WRONLY | O_CLOEXEC, 0600));
+	int err =3D fd;
+
+	if (err < 0)
+		return -errno;
+
+	l_certchain_walk_from_leaf((struct l_certchain *) chain,
+					pem_write_one_cert, &err);
+	close(fd);
+
+	return err < 0 ? err : 0;
+}
+
 LIB_EXPORT struct l_queue *l_pem_load_certificate_list_from_data(
 						const void *buf, size_t len)
 {
-- =

2.27.0

--===============5512234427662025315==--

