Content-Type: multipart/mixed; boundary="===============6363641134217954967=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] tls: Refactor compression method ID check
Date: Fri, 12 Feb 2021 01:22:32 +0100
Message-ID: <20210212002232.300086-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6363641134217954967==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

When validating the Client Hello message we look up the compression
method IDs passed by the client in our look-up table.  After this is
done check that at least one ID was found in the table, rather than
use memchr() before that lookup to make sure it contains the only ID
that we support.  This should be less confusing to static analysis.
---
 ell/tls.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/ell/tls.c b/ell/tls.c
index 827c128..c65fd0d 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -1719,12 +1719,6 @@ static void tls_handle_client_hello(struct l_tls *tl=
s,
 	/* Select a compression method */
 =

 	/* CompressionMethod.null must be present in the vector */
-	if (!memchr(compression_methods, 0, compression_methods_size)) {
-		TLS_DISCONNECT(TLS_ALERT_HANDSHAKE_FAIL, 0,
-				"No common compression methods");
-		goto cleanup;
-	}
-
 	while (compression_methods_size) {
 		tls->pending.compression_method =3D
 			tls_find_compression_method(*compression_methods);
@@ -1736,6 +1730,12 @@ static void tls_handle_client_hello(struct l_tls *tl=
s,
 		compression_methods_size--;
 	}
 =

+	if (!compression_methods_size) {
+		TLS_DISCONNECT(TLS_ALERT_HANDSHAKE_FAIL, 0,
+				"No common compression methods");
+		goto cleanup;
+	}
+
 	TLS_DEBUG("Negotiated %s", tls->pending.compression_method->name);
 =

 	if (!tls_send_server_hello(tls, extensions_offered))
-- =

2.27.0

--===============6363641134217954967==--

