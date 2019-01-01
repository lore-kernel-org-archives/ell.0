Content-Type: multipart/mixed; boundary="===============6706263809674617674=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 05/17] tls: Implement the Supported Point Formats extension
Date: Tue, 01 Jan 2019 20:49:27 +0100
Message-ID: <20190101194939.5974-5-andrew.zaborowski@intel.com>
In-Reply-To: <20190101194939.5974-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6706263809674617674==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Defined in RFC 8422 5.1.2
---
 ell/tls-extensions.c | 42 ++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 42 insertions(+)

diff --git a/ell/tls-extensions.c b/ell/tls-extensions.c
index 749b8e6..3d75037 100644
--- a/ell/tls-extensions.c
+++ b/ell/tls-extensions.c
@@ -96,6 +96,40 @@ static bool tls_elliptic_curves_client_absent(struct l_t=
ls *tls)
 	return true;
 }
 =

+static bool tls_ec_point_formats_client_handle(struct l_tls *tls,
+						const uint8_t *buf, size_t len)
+{
+	if (len < 2)
+		return false;
+
+	if (buf[0] !=3D len - 1)
+		return false;
+
+	if (!memchr(buf + 1, 0, len - 1)) {
+		TLS_DEBUG("Uncompressed point format missing");
+		return false;
+	}
+
+	return true;
+}
+
+/*
+ * For compatibility with clients respond to a valid Client Hello Supported
+ * Point Formats extension with the hardcoded confirmation that we do
+ * support the single valid point format.  As a client we never send this
+ * extension so we never have to handle a server response to it either.
+ */
+static ssize_t tls_ec_point_formats_server_write(struct l_tls *tls,
+						uint8_t *buf, size_t len)
+{
+	if (len < 2)
+		return -ENOMEM;
+
+	buf[0] =3D 0x01;	/* ec_point_format_list length */
+	buf[1] =3D 0x00;	/* uncompressed */
+	return 2;
+}
+
 const struct tls_hello_extension tls_extensions[] =3D {
 	{
 		"Supported Elliptic Curves", "elliptic_curves", 10,
@@ -104,5 +138,13 @@ const struct tls_hello_extension tls_extensions[] =3D {
 		tls_elliptic_curves_client_absent,
 		NULL, NULL, NULL,
 	},
+	{
+		"Supported Point Formats", "ec_point_formats", 11,
+		NULL,
+		tls_ec_point_formats_client_handle,
+		NULL,
+		tls_ec_point_formats_server_write,
+		NULL, NULL,
+	},
 	{}
 };
-- =

2.19.1


--===============6706263809674617674==--

