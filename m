Content-Type: multipart/mixed; boundary="===============5068909216861818888=="
MIME-Version: 1.0
From: Tim Kourt <tim.a.kourt@linux.intel.com>
Subject: [PATCH 1/3] tls: introduce more_tofollow flag into l_tls_write_cb_t
Date: Fri, 26 Jan 2018 09:57:40 -0800
Message-ID: <20180126175742.11881-1-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5068909216861818888==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

TLS is a stream-oriented protocol and assumes processing of
a TLS record as soon as it becomes available. Certain
applications of TLS such as: TTLS, PEAP, etc. require to deal
with the packets that span multiple TLS records and must be
handled as a single block of data. This change introduces
'more_tofollow' flag into l_tls_write_cb_t that indicates
whether we have processed all of the data submitted into
l_tls_write or l_tls_handle_rx functions.
---
 ell/tls-private.h |  3 ++-
 ell/tls-record.c  | 28 +++++++++++++++++-----------
 ell/tls.c         |  5 +++--
 ell/tls.h         |  2 +-
 4 files changed, 23 insertions(+), 15 deletions(-)

diff --git a/ell/tls-private.h b/ell/tls-private.h
index d501651..ace1293 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -218,7 +218,8 @@ void tls_disconnect(struct l_tls *tls, enum l_tls_alert=
_desc desc,
 void tls_tx_record(struct l_tls *tls, enum tls_content_type type,
 			const uint8_t *data, size_t len);
 bool tls_handle_message(struct l_tls *tls, const uint8_t *message,
-			int len, enum tls_content_type type, uint16_t version);
+			int len, enum tls_content_type type, uint16_t version,
+			bool more_tofollow);
 =

 /* X509 Certificates and Certificate Chains */
 =

diff --git a/ell/tls-record.c b/ell/tls-record.c
index c0e5834..9a05450 100644
--- a/ell/tls-record.c
+++ b/ell/tls-record.c
@@ -63,7 +63,8 @@ static void tls_write_mac(struct l_tls *tls, uint8_t *com=
pressed,
 =

 static void tls_tx_record_plaintext(struct l_tls *tls,
 					uint8_t *plaintext,
-					uint16_t plaintext_len)
+					uint16_t plaintext_len,
+					bool more_tofollow)
 {
 	uint8_t *compressed;
 	uint16_t compressed_len;
@@ -169,9 +170,9 @@ static void tls_tx_record_plaintext(struct l_tls *tls,
 	ciphertext[3] =3D ciphertext_len >> 8;
 	ciphertext[4] =3D ciphertext_len >> 0;
 =

-	tls->tx(ciphertext, ciphertext_len + 5, tls->user_data);
+	tls->tx(ciphertext, ciphertext_len + 5, more_tofollow, tls->user_data);
 }
-
+#include <stdio.h>
 void tls_tx_record(struct l_tls *tls, enum tls_content_type type,
 			const uint8_t *data, size_t len)
 {
@@ -195,15 +196,17 @@ void tls_tx_record(struct l_tls *tls, enum tls_conten=
t_type type,
 		plaintext[4] =3D fragment_len >> 0;
 		memcpy(plaintext + 5, data, fragment_len);
 =

-		tls_tx_record_plaintext(tls, plaintext, fragment_len + 5);
-
 		data +=3D fragment_len;
 		len -=3D fragment_len;
+
+		tls_tx_record_plaintext(tls, plaintext, fragment_len + 5,
+							len ? true : false);
 	}
 }
 =

 static bool tls_handle_plaintext(struct l_tls *tls, const uint8_t *plainte=
xt,
-					int len, uint8_t type, uint16_t version)
+					int len, uint8_t type, uint16_t version,
+					bool more_tofollow)
 {
 	int header_len, need_len;
 	int chunk_len;
@@ -218,7 +221,8 @@ static bool tls_handle_plaintext(struct l_tls *tls, con=
st uint8_t *plaintext,
 	switch (type) {
 	case TLS_CT_CHANGE_CIPHER_SPEC:
 	case TLS_CT_APPLICATION_DATA:
-		return tls_handle_message(tls, plaintext, len, type, version);
+		return tls_handle_message(tls, plaintext, len, type, version,
+								more_tofollow);
 =

 	/*
 	 * We need to perform input reassembly twice at different levels:
@@ -277,7 +281,8 @@ static bool tls_handle_plaintext(struct l_tls *tls, con=
st uint8_t *plaintext,
 			if (tls->message_buf_len =3D=3D need_len) {
 				if (!tls_handle_message(tls, tls->message_buf,
 							need_len, type,
-							version))
+							version,
+							len ? true : false))
 					return false;
 =

 				tls->message_buf_len =3D 0;
@@ -314,7 +319,7 @@ static bool tls_handle_plaintext(struct l_tls *tls, con=
st uint8_t *plaintext,
 	return true;
 }
 =

-static bool tls_handle_ciphertext(struct l_tls *tls)
+static bool tls_handle_ciphertext(struct l_tls *tls, bool more_tofollow)
 {
 	uint8_t type;
 	uint16_t version;
@@ -483,7 +488,7 @@ static bool tls_handle_ciphertext(struct l_tls *tls)
 	/* DEFLATE not supported so just pass on compressed / compressed_len */
 =

 	return tls_handle_plaintext(tls, compressed, compressed_len,
-					type, version);
+					type, version, more_tofollow);
 }
 =

 LIB_EXPORT void l_tls_handle_rx(struct l_tls *tls, const uint8_t *data,
@@ -501,7 +506,8 @@ LIB_EXPORT void l_tls_handle_rx(struct l_tls *tls, cons=
t uint8_t *data,
 =

 			/* Do we have a full structure? */
 			if (tls->record_buf_len =3D=3D need_len) {
-				if (!tls_handle_ciphertext(tls))
+				if (!tls_handle_ciphertext(tls, len ?
+								true : false))
 					return;
 =

 				tls->record_buf_len =3D 0;
diff --git a/ell/tls.c b/ell/tls.c
index d3b4809..8e5b927 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -2065,7 +2065,8 @@ LIB_EXPORT void l_tls_write(struct l_tls *tls, const =
uint8_t *data, size_t len)
 }
 =

 bool tls_handle_message(struct l_tls *tls, const uint8_t *message,
-			int len, enum tls_content_type type, uint16_t version)
+			int len, enum tls_content_type type, uint16_t version,
+			bool more_tofollow)
 {
 	enum handshake_hash_type hash;
 =

@@ -2178,7 +2179,7 @@ bool tls_handle_message(struct l_tls *tls, const uint=
8_t *message,
 		if (!len)
 			return true;
 =

-		tls->rx(message, len, tls->user_data);
+		tls->rx(message, len, more_tofollow, tls->user_data);
 =

 		return true;
 	}
diff --git a/ell/tls.h b/ell/tls.h
index 0a7c920..865792e 100644
--- a/ell/tls.h
+++ b/ell/tls.h
@@ -56,7 +56,7 @@ enum l_tls_alert_desc {
 };
 =

 typedef void (*l_tls_write_cb_t)(const uint8_t *data, size_t len,
-					void *user_data);
+					bool more_tofollow, void *user_data);
 typedef void (*l_tls_ready_cb_t)(const char *peer_identity, void *user_dat=
a);
 typedef void (*l_tls_disconnect_cb_t)(enum l_tls_alert_desc reason,
 					bool remote, void *user_data);
-- =

2.9.4


--===============5068909216861818888==--

