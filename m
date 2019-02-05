Content-Type: multipart/mixed; boundary="===============1726906533393535836=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/4] checksum: Drop unused field
Date: Tue, 05 Feb 2019 16:54:57 +0100
Message-ID: <20190205155500.24750-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1726906533393535836==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/checksum.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/ell/checksum.c b/ell/checksum.c
index f6f5cb2..729399e 100644
--- a/ell/checksum.c
+++ b/ell/checksum.c
@@ -69,7 +69,6 @@ struct sockaddr_alg {
 #endif
 =

 struct checksum_info {
-	enum l_checksum_type type;
 	const char *name;
 	uint8_t digest_len;
 	bool supported;
-- =

2.19.1


--===============1726906533393535836==--

