Content-Type: multipart/mixed; boundary="===============8961581006926412078=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/9] tls: Don't send Client Hello in l_tls_new
Date: Thu, 13 Dec 2018 20:57:38 +0100
Message-ID: <20181213195746.32144-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8961581006926412078==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Give the user time to set up the tls instance's optional parameters --
those that can not be passed as parameters of l_tls_new, before sending
the Client Hello message in client mode.  We now send the message from
l_tls_start which has to be called after the optional setup is done,
e.g. set_cacert, set_auth_data, set_debug are called.  This way Client
Hello can avoid proposing cipher suites that would not have worked if
they were negotiated, due to bad certificate type.  It also allows us to
output debug messages in the Client Hello sending code, and will allow
to add methods to define security profiles.
---
 ell/ell.sym       |  1 +
 ell/tls-private.h |  1 +
 ell/tls.c         | 48 ++++++++++++++++++++++++++++-------------------
 ell/tls.h         |  3 +++
 4 files changed, 34 insertions(+), 19 deletions(-)

diff --git a/ell/ell.sym b/ell/ell.sym
index 841bc49..7d7a5e4 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -413,6 +413,7 @@ global:
 	l_tls_new;
 	l_tls_free;
 	l_tls_write;
+	l_tls_start;
 	l_tls_close;
 	l_tls_set_cacert;
 	l_tls_set_auth_data;
diff --git a/ell/tls-private.h b/ell/tls-private.h
index f2b6b14..b6d1461 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -98,6 +98,7 @@ struct tls_compression_method {
 };
 =

 enum tls_handshake_state {
+	TLS_HANDSHAKE_WAIT_START,
 	TLS_HANDSHAKE_WAIT_HELLO,
 	TLS_HANDSHAKE_WAIT_CERTIFICATE,
 	TLS_HANDSHAKE_WAIT_KEY_EXCHANGE,
diff --git a/ell/tls.c b/ell/tls.c
index f27f35c..d05ae8d 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -195,7 +195,7 @@ static void tls_reset_handshake(struct l_tls *tls)
 	for (hash =3D 0; hash < __HANDSHAKE_HASH_COUNT; hash++)
 		tls_drop_handshake_hash(tls, hash);
 =

-	TLS_SET_STATE(TLS_HANDSHAKE_WAIT_HELLO);
+	TLS_SET_STATE(TLS_HANDSHAKE_WAIT_START);
 	tls->cert_requested =3D 0;
 	tls->cert_sent =3D 0;
 }
@@ -826,13 +826,6 @@ static bool tls_send_client_hello(struct l_tls *tls)
 =

 	*ptr++ =3D 0; /* No SessionID */
 =

-	/*
-	 * FIXME: We do need to filter the cipher suites by key exchange
-	 * mechanism compatibility with the certificate but we don't normally
-	 * have the certificate at this point because we're called from
-	 * l_tls_new.  We also don't know the TLS version that's going to
-	 * be negotiated yet.
-	 */
 	len_ptr =3D ptr;
 	ptr +=3D 2;
 =

@@ -2463,17 +2456,11 @@ LIB_EXPORT struct l_tls *l_tls_new(bool server,
 =

 	tls->signature_hash =3D HANDSHAKE_HASH_SHA256;
 =

-	/* If we're the client, start the handshake right away */
-	if (!tls->server) {
-		if (!tls_init_handshake_hash(tls) ||
-				!tls_send_client_hello(tls)) {
-			l_free(tls);
-
-			return NULL;
-		}
-	}
-
-	TLS_SET_STATE(TLS_HANDSHAKE_WAIT_HELLO);
+	/* If we're the server wait for the Client Hello already */
+	if (tls->server)
+		TLS_SET_STATE(TLS_HANDSHAKE_WAIT_HELLO);
+	else
+		TLS_SET_STATE(TLS_HANDSHAKE_WAIT_START);
 =

 	return tls;
 }
@@ -2652,6 +2639,28 @@ bool tls_handle_message(struct l_tls *tls, const uin=
t8_t *message,
 	return false;
 }
 =

+LIB_EXPORT bool l_tls_start(struct l_tls *tls)
+{
+	/* This is a nop in server mode */
+	if (tls->server)
+		return true;
+
+	if (tls->state !=3D TLS_HANDSHAKE_WAIT_START) {
+		TLS_DEBUG("Call invalid in state %s",
+				tls_handshake_state_to_str(tls->state));
+		return false;
+	}
+
+	if (!tls_init_handshake_hash(tls))
+		return false;
+
+	if (!tls_send_client_hello(tls))
+		return false;
+
+	TLS_SET_STATE(TLS_HANDSHAKE_WAIT_HELLO);
+	return true;
+}
+
 LIB_EXPORT void l_tls_close(struct l_tls *tls)
 {
 	TLS_DISCONNECT(TLS_ALERT_CLOSE_NOTIFY, 0, "Closing session");
@@ -2800,6 +2809,7 @@ const char *tls_handshake_state_to_str(enum tls_hands=
hake_state state)
 	static char buf[100];
 =

 	switch (state) {
+	SWITCH_ENUM_TO_STR(TLS_HANDSHAKE_WAIT_START)
 	SWITCH_ENUM_TO_STR(TLS_HANDSHAKE_WAIT_HELLO)
 	SWITCH_ENUM_TO_STR(TLS_HANDSHAKE_WAIT_CERTIFICATE)
 	SWITCH_ENUM_TO_STR(TLS_HANDSHAKE_WAIT_KEY_EXCHANGE)
diff --git a/ell/tls.h b/ell/tls.h
index 505f0e0..fb33404 100644
--- a/ell/tls.h
+++ b/ell/tls.h
@@ -77,6 +77,9 @@ struct l_tls *l_tls_new(bool server, l_tls_write_cb_t app=
_data_handler,
 =

 void l_tls_free(struct l_tls *tls);
 =

+/* Begin sending connection setup messages to the server */
+bool l_tls_start(struct l_tls *tls);
+
 /* Properly disconnect a connected session */
 void l_tls_close(struct l_tls *tls);
 =

-- =

2.19.1


--===============8961581006926412078==--

