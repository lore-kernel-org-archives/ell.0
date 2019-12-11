Content-Type: multipart/mixed; boundary="===============4384398887332817995=="
MIME-Version: 1.0
From: Tim Kourt <tim.a.kourt@linux.intel.com>
Subject: [PATCH 2/5] net: Add l_net_hostname_is_localhost
Date: Wed, 11 Dec 2019 15:21:18 -0800
Message-ID: <20191211232121.23129-2-tim.a.kourt@linux.intel.com>
In-Reply-To: <20191211232121.23129-1-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4384398887332817995==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Identifies if the given hostname is localhost.
---
 ell/net.c | 45 +++++++++++++++++++++++++++++++++++++++++++++
 ell/net.h |  1 +
 2 files changed, 46 insertions(+)

diff --git a/ell/net.c b/ell/net.c
index 3b6e0dc..350340a 100644
--- a/ell/net.c
+++ b/ell/net.c
@@ -133,3 +133,48 @@ LIB_EXPORT bool l_net_hostname_is_root(const char *hos=
tname)
 =

 	return false;
 }
+
+static bool str_has_suffix(const char *str, const char *suffix)
+{
+	size_t str_len;
+	size_t suffix_len;
+	size_t len_diff;
+
+	str_len =3D strlen(str);
+	suffix_len =3D strlen(suffix);
+
+	if (str_len < suffix_len)
+		return false;
+
+	len_diff =3D str_len - suffix_len;
+
+	return !strcasecmp(&str[len_diff], suffix);
+}
+
+/**
+ * l_net_hostname_is_localhost:
+ * @hostname: Hostname to validate
+ *
+ * Identifies if the hostname given by @hostname is localhost or not.
+ *
+ * Returns: #true if the given hostname is localhost and #false otherwise.
+ **/
+LIB_EXPORT bool l_net_hostname_is_localhost(const char *hostname)
+{
+	if (unlikely(!hostname))
+		return false;
+
+	if (!strcasecmp(hostname, "localhost") ||
+			!strcasecmp(hostname, "localhost.") ||
+			!strcasecmp(hostname, "localhost.localdomain") ||
+			!strcasecmp(hostname, "localhost.localdomain."))
+		return true;
+
+	if (str_has_suffix(hostname, ".localhost") ||
+			str_has_suffix(hostname, ".localhost.") ||
+			str_has_suffix(hostname, ".localhost.localdomain") ||
+			str_has_suffix(hostname, ".localhost.localdomain."))
+		return true;
+
+	return false;
+}
diff --git a/ell/net.h b/ell/net.h
index 7afcf86..6808e07 100644
--- a/ell/net.h
+++ b/ell/net.h
@@ -33,6 +33,7 @@ extern "C" {
 bool l_net_get_mac_address(uint32_t ifindex, uint8_t *out_addr);
 char *l_net_get_name(uint32_t ifindex);
 bool l_net_hostname_is_root(const char *hostname);
+bool l_net_hostname_is_localhost(const char *hostname);
 =

 #ifdef __cplusplus
 }
-- =

2.13.6

--===============4384398887332817995==--

