Content-Type: multipart/mixed; boundary="===============5857230361892730997=="
MIME-Version: 1.0
From: ell@ongy.net
Subject: [PATCH 4/4] tls-record: remove unnecessary null-pointer check
Date: Wed, 14 Dec 2016 23:51:21 +0100
Message-ID: <20161214225121.9439-5-ell@ongy.net>
In-Reply-To: <20161214225121.9439-1-ell@ongy.net>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5857230361892730997==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

From: Markus Ongyerth <ongy@ongy.net>

---
 ell/tls-record.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/ell/tls-record.c b/ell/tls-record.c
index 3033372..c0e5834 100644
--- a/ell/tls-record.c
+++ b/ell/tls-record.c
@@ -371,8 +371,8 @@ static bool tls_handle_ciphertext(struct l_tls *tls)
 		tls_write_mac(tls, compressed + 8, 5 + compressed_len,
 				mac_buf, false);
 =

-		if (tls->mac_length && memcmp(mac_buf, compressed + 13 +
-					compressed_len, tls->mac_length[0])) {
+		if (memcmp(mac_buf, compressed + 13 + compressed_len,
+							tls->mac_length[0])) {
 			tls_disconnect(tls, TLS_ALERT_BAD_RECORD_MAC, 0);
 			return false;
 		}
-- =

2.10.2


--===============5857230361892730997==--

