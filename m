Content-Type: multipart/mixed; boundary="===============5598757605025550469=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 11/16] examples: Ensure SIGPIPE is ignore in https examples
Date: Wed, 21 Nov 2018 16:08:58 +0100
Message-ID: <20181121150903.24437-11-andrew.zaborowski@intel.com>
In-Reply-To: <20181121150903.24437-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5598757605025550469==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Potential SIGPIPEs on a write to a socket that's been shut down would
kill the example without letting it print any explanation to user.
---
 examples/https-client-test.c | 2 +-
 examples/https-server-test.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/examples/https-client-test.c b/examples/https-client-test.c
index 55709dc..9454a1d 100644
--- a/examples/https-client-test.c
+++ b/examples/https-client-test.c
@@ -86,7 +86,7 @@ static void https_tls_write(const uint8_t *data, size_t l=
en, void *user_data)
 	int r;
 =

 	while (len) {
-		r =3D write(l_io_get_fd(io), data, len);
+		r =3D send(l_io_get_fd(io), data, len, MSG_NOSIGNAL);
 		if (r < 0) {
 			l_main_quit();
 			break;
diff --git a/examples/https-server-test.c b/examples/https-server-test.c
index 73ea6ad..da44af8 100644
--- a/examples/https-server-test.c
+++ b/examples/https-server-test.c
@@ -89,7 +89,7 @@ static void https_tls_write(const uint8_t *data, size_t l=
en, void *user_data)
 	int r;
 =

 	while (len) {
-		r =3D write(l_io_get_fd(io), data, len);
+		r =3D send(l_io_get_fd(io), data, len, MSG_NOSIGNAL);
 		if (r < 0) {
 			l_main_quit();
 			break;
-- =

2.19.1


--===============5598757605025550469==--

