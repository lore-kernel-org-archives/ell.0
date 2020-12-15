Content-Type: multipart/mixed; boundary="===============5065851957143246309=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/5] tls: Add l_tls_set_cert_dump_path
Date: Tue, 15 Dec 2020 23:53:43 +0100
Message-ID: <20201215225345.791738-3-andrew.zaborowski@intel.com>
In-Reply-To: <20201215225345.791738-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5065851957143246309==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

If this function is used to set a file path, l_tls will write the peer's
certificate chain received in the TLS Certificate message if it is used
(on the server side we may receive no client certificate).  This can be
used to diagnose 802.1x connection configurations for example.
---
 ell/ell.sym       |  1 +
 ell/tls-private.h |  1 +
 ell/tls.c         | 22 ++++++++++++++++++++++
 ell/tls.h         |  1 +
 4 files changed, 25 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index d94b585..c98bd8c 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -498,6 +498,7 @@ global:
 	l_tls_set_domain_mask;
 	l_tls_alert_to_str;
 	l_tls_set_debug;
+	l_tls_set_cert_dump_path;
 	/* uintset */
 	l_uintset_new_from_range;
 	l_uintset_new;
diff --git a/ell/tls-private.h b/ell/tls-private.h
index 908c622..8d0540a 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -205,6 +205,7 @@ struct l_tls {
 	l_tls_debug_cb_t debug_handler;
 	l_tls_destroy_cb_t debug_destroy;
 	void *debug_data;
+	char *cert_dump_path;
 	enum l_tls_version min_version;
 	enum l_tls_version max_version;
 =

diff --git a/ell/tls.c b/ell/tls.c
index 1452909..4eaa66d 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -37,6 +37,7 @@
 #include "random.h"
 #include "queue.h"
 #include "pem.h"
+#include "pem-private.h"
 #include "cert.h"
 #include "cert-private.h"
 #include "tls-private.h"
@@ -1942,6 +1943,19 @@ static void tls_handle_certificate(struct l_tls *tls,
 		goto done;
 	}
 =

+	if (tls->cert_dump_path) {
+		int r =3D pem_write_certificate_chain(certchain,
+							tls->cert_dump_path);
+
+		if (r < 0)
+			TLS_DEBUG("Error %i (%s) writing the peer certchain "
+					"to %s",
+					-r, strerror(-r), tls->cert_dump_path);
+		else
+			TLS_DEBUG("Peer certchain written to %s",
+					tls->cert_dump_path);
+	}
+
 	/*
 	 * Validate the certificate chain's consistency and validate it
 	 * against our CAs if we have any.
@@ -2614,6 +2628,7 @@ LIB_EXPORT void l_tls_free(struct l_tls *tls)
 	l_tls_set_cacert(tls, NULL);
 	l_tls_set_auth_data(tls, NULL, NULL);
 	l_tls_set_domain_mask(tls, NULL);
+	l_tls_set_cert_dump_path(tls, NULL);
 =

 	tls_reset_handshake(tls);
 	tls_cleanup_handshake(tls);
@@ -3104,3 +3119,10 @@ LIB_EXPORT bool l_tls_set_debug(struct l_tls *tls, l=
_tls_debug_cb_t function,
 =

 	return true;
 }
+
+LIB_EXPORT bool l_tls_set_cert_dump_path(struct l_tls *tls, const char *pa=
th)
+{
+	l_free(tls->cert_dump_path);
+	tls->cert_dump_path =3D path ? l_strdup(path) : NULL;
+	return true;
+}
diff --git a/ell/tls.h b/ell/tls.h
index b67492b..683c54c 100644
--- a/ell/tls.h
+++ b/ell/tls.h
@@ -133,6 +133,7 @@ bool l_tls_prf_get_bytes(struct l_tls *tls, bool use_ma=
ster_secret,
 =

 bool l_tls_set_debug(struct l_tls *tls, l_tls_debug_cb_t function,
 			void *user_data, l_tls_destroy_cb_t destroy);
+bool l_tls_set_cert_dump_path(struct l_tls *tls, const char *path);
 =

 #ifdef __cplusplus
 }
-- =

2.27.0

--===============5065851957143246309==--

