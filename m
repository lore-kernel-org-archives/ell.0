Content-Type: multipart/mixed; boundary="===============6376832057460555487=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 10/16] tls: Flush remaining decoded messages on Alert
Date: Wed, 21 Nov 2018 16:08:57 +0100
Message-ID: <20181121150903.24437-10-andrew.zaborowski@intel.com>
In-Reply-To: <20181121150903.24437-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6376832057460555487==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

We previously started flushing the received raw records that we still
had queued when one of the records being decoded generates an Alert
message.  But if there were multiple plaintext messages within one
record, they'd still be processed after one message had generated an
error, so also flush these too.  This caused further Alert messages to
be sent if the TLS state machine couldn't make sense of the new messages
after it had reset its state due to the initial Alert.

Also simplify the record_flush logic in l_tls_handle_rx slightly.
---
 ell/tls-record.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/ell/tls-record.c b/ell/tls-record.c
index 73be1a4..bffa413 100644
--- a/ell/tls-record.c
+++ b/ell/tls-record.c
@@ -334,6 +334,9 @@ static bool tls_handle_plaintext(struct l_tls *tls, con=
st uint8_t *plaintext,
 =

 				tls->message_buf_len =3D 0;
 =

+				if (tls->record_flush)
+					break;
+
 				continue;
 			}
 =

@@ -609,10 +612,8 @@ LIB_EXPORT void l_tls_handle_rx(struct l_tls *tls, con=
st uint8_t *data,
 				tls->record_buf_len =3D 0;
 				need_len =3D 5;
 =

-				if (tls->record_flush) {
-					tls->record_flush =3D false;
+				if (tls->record_flush)
 					break;
-				}
 			}
 =

 			if (!len)
-- =

2.19.1


--===============6376832057460555487==--

