Content-Type: multipart/mixed; boundary="===============5145073765513335095=="
MIME-Version: 1.0
From: Tim Kourt <tim.a.kourt@linux.intel.com>
Subject: [PATCH 1/5] net: Add l_net_hostname_is_root
Date: Wed, 11 Dec 2019 15:21:17 -0800
Message-ID: <20191211232121.23129-1-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5145073765513335095==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The function identifies if the given hostname is root domain name.
---
 ell/net.c | 23 +++++++++++++++++++++++
 ell/net.h |  1 +
 2 files changed, 24 insertions(+)

diff --git a/ell/net.c b/ell/net.c
index b5b5f9d..3b6e0dc 100644
--- a/ell/net.c
+++ b/ell/net.c
@@ -110,3 +110,26 @@ LIB_EXPORT char *l_net_get_name(uint32_t ifindex)
 =

 	return l_strdup(ifr.ifr_name);
 }
+
+/**
+ * l_net_hostname_is_root:
+ * @hostname: Hostname to validate
+ *
+ * Identifies if the hostname given by @hostname is root domain name or
+ * not.
+ *
+ * Returns: #true if the given hostname is root and #false otherwise.
+ **/
+LIB_EXPORT bool l_net_hostname_is_root(const char *hostname)
+{
+	if (unlikely(!hostname))
+		return false;
+
+	if (!strcmp(hostname, ""))
+		return true;
+
+	if (!strcmp(hostname, "."))
+		return true;
+
+	return false;
+}
diff --git a/ell/net.h b/ell/net.h
index 25b1ca2..7afcf86 100644
--- a/ell/net.h
+++ b/ell/net.h
@@ -32,6 +32,7 @@ extern "C" {
 =

 bool l_net_get_mac_address(uint32_t ifindex, uint8_t *out_addr);
 char *l_net_get_name(uint32_t ifindex);
+bool l_net_hostname_is_root(const char *hostname);
 =

 #ifdef __cplusplus
 }
-- =

2.13.6

--===============5145073765513335095==--

