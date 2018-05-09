Content-Type: multipart/mixed; boundary="===============2966506205012325443=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] tls: Flush rx buffer on failure
Date: Wed, 09 May 2018 13:13:03 +0200
Message-ID: <20180509111303.7543-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2966506205012325443==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

When we send an Alert message to the peer (and our alerts are always
fatal) ignore any buffered messages we've received.  When the
certificate chain verification fails on a client we are usually
processing the third message in a sequence of five received from the
server.  We would then send an Alert and forget the negotiated state,
then process the two remaining messages which would result in two more
Alerts being sent, with the default TLS 1.0 version header.  There is
no need to process those remaining messages.
---
 ell/tls-private.h |  1 +
 ell/tls-record.c  | 10 ++++++++++
 2 files changed, 11 insertions(+)

diff --git a/ell/tls-private.h b/ell/tls-private.h
index d501651..8c068c6 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -147,6 +147,7 @@ struct l_tls {
 	uint8_t *record_buf;
 	int record_buf_len;
 	int record_buf_max_len;
+	bool record_flush;
 =

 	uint8_t *message_buf;
 	int message_buf_len;
diff --git a/ell/tls-record.c b/ell/tls-record.c
index c0e5834..0ad03ed 100644
--- a/ell/tls-record.c
+++ b/ell/tls-record.c
@@ -181,6 +181,9 @@ void tls_tx_record(struct l_tls *tls, enum tls_content_=
type type,
 	uint16_t fragment_len;
 	uint16_t version =3D tls->negotiated_version ?: TLS_MIN_VERSION;
 =

+	if (type =3D=3D TLS_CT_ALERT)
+		tls->record_flush =3D true;
+
 	while (len) {
 		fragment =3D buf + TX_RECORD_HEADROOM;
 		fragment_len =3D len < TX_RECORD_MAX_LEN ?
@@ -492,6 +495,8 @@ LIB_EXPORT void l_tls_handle_rx(struct l_tls *tls, cons=
t uint8_t *data,
 	int need_len;
 	int chunk_len;
 =

+	tls->record_flush =3D false;
+
 	/* Reassemble TLSCiphertext structures from the received chunks */
 =

 	while (1) {
@@ -506,6 +511,11 @@ LIB_EXPORT void l_tls_handle_rx(struct l_tls *tls, con=
st uint8_t *data,
 =

 				tls->record_buf_len =3D 0;
 				need_len =3D 5;
+
+				if (tls->record_flush) {
+					tls->record_flush =3D false;
+					break;
+				}
 			}
 =

 			if (!len)
-- =

2.14.1


--===============2966506205012325443==--

