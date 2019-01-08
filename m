Content-Type: multipart/mixed; boundary="===============1264707657674943373=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/8] tls: Tolerate unsolicited extensions in Server Hello
Date: Tue, 08 Jan 2019 05:29:45 +0100
Message-ID: <20190108042951.21914-2-andrew.zaborowski@intel.com>
In-Reply-To: <20190108042951.21914-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1264707657674943373==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

There are apparently servers that include a "Supported Point Formats"
extension in the Server Hello even if the Client Hello has not asked for
one, not conditionted by the presence of the Supported Elliptic Curves
extension.  Don't fail when we see an extra extensions, only add a log
line about it.  It it rare among the servers I tested though.
---
 ell/tls.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/ell/tls.c b/ell/tls.c
index e94dde3..de62e83 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -1327,12 +1327,15 @@ static bool tls_handle_hello_extensions(struct l_tl=
s *tls,
 		 * extension type in ServerHello that it did not request in
 		 * the associated ClientHello, it MUST abort the handshake
 		 * with an unsupported_extension fatal alert."
+		 * There are however servers that include an unsolicited
+		 * Supported Point Format extension where the handshake
+		 * still completes fine if the extension is ignored so we
+		 * do this instead.
 		 */
 		if (!client_hello && !handler) {
-			TLS_DISCONNECT(TLS_ALERT_UNSUPPORTED_EXTENSION, 0,
-					"%s extension not expected in "
+			TLS_DEBUG("non-fatal: %s extension not expected in "
 					"a ServerHello", extension->name);
-			return false;
+			goto next;
 		}
 =

 		if (!handler(tls, buf, ext_len)) {
-- =

2.19.1


--===============1264707657674943373==--

