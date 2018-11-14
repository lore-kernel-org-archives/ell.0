Content-Type: multipart/mixed; boundary="===============8887419196074584513=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 04/12] tls: Fix functions that return error strings
Date: Wed, 14 Nov 2018 14:18:54 +0100
Message-ID: <20181114131902.1695-4-andrew.zaborowski@intel.com>
In-Reply-To: <20181114131902.1695-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8887419196074584513==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/tls.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/ell/tls.c b/ell/tls.c
index 4b37785..9dc97ff 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -204,7 +204,7 @@ static bool tls_change_cipher_spec(struct l_tls *tls, b=
ool txrx,
 	struct tls_bulk_encryption_algorithm *enc;
 	struct tls_mac_algorithm *mac;
 	int key_offset;
-	char error_buf[50];
+	static char error_buf[200];
 =

 	if (tls->cipher[txrx]) {
 		l_cipher_free(tls->cipher[txrx]);
@@ -533,7 +533,7 @@ enum tls_handshake_type {
 =

 static const char *tls_handshake_type_to_str(enum tls_handshake_type type)
 {
-	static char buf[40];
+	static char buf[100];
 =

 	switch (type) {
 	SWITCH_ENUM_TO_STR(TLS_HELLO_REQUEST)
@@ -2529,7 +2529,7 @@ LIB_EXPORT const char *l_tls_alert_to_str(enum l_tls_=
alert_desc desc)
 =

 const char *tls_handshake_state_to_str(enum tls_handshake_state state)
 {
-	static char buf[40];
+	static char buf[100];
 =

 	switch (state) {
 	SWITCH_ENUM_TO_STR(TLS_HANDSHAKE_WAIT_HELLO)
-- =

2.19.1


--===============8887419196074584513==--

