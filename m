Content-Type: multipart/mixed; boundary="===============7675612830668294064=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/4] tls: Escape characters in the peer_identity string
Date: Sat, 17 Aug 2019 02:28:31 +0200
Message-ID: <20190817002834.15208-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7675612830668294064==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Escape the /, =3D and \ characters in the strings we take from the peer
certificate's Subject DN to build the peer_identity string passed to the
ell client's ready callback to enable it to be parsed unamiguously.
---
 ell/tls.c | 21 ++++++++++++++++++++-
 1 file changed, 20 insertions(+), 1 deletion(-)

diff --git a/ell/tls.c b/ell/tls.c
index 7405098..37f5b3f 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -2021,6 +2021,25 @@ static const struct dn_element_info dn_elements[] =
=3D {
 	{}
 };
 =

+static void tls_str_escape_append(struct l_string *out, char *str, size_t =
len)
+{
+	while (len--) {
+		switch (*str) {
+		case '\\':
+		case '/':
+		case '=3D':
+			l_string_append_c(out, '\\');
+			l_string_append_c(out, *str);
+			break;
+		default:
+			l_string_append_c(out, *str);
+			break;
+		}
+
+		str++;
+	}
+}
+
 static char *tls_get_peer_identity_str(struct l_cert *cert)
 {
 	const uint8_t *dn, *end;
@@ -2072,7 +2091,7 @@ static char *tls_get_peer_identity_str(struct l_cert =
*cert)
 		l_string_append_c(id_str, '/');
 		l_string_append(id_str, info->str);
 		l_string_append_c(id_str, '=3D');
-		l_string_append_fixed(id_str, (char *) name, name_len);
+		tls_str_escape_append(id_str, (char *) name, name_len);
 	}
 =

 	return l_string_unwrap(id_str);
-- =

2.20.1


--===============7675612830668294064==--

