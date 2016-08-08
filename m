Content-Type: multipart/mixed; boundary="===============5935825878696462366=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH v2 1/6] key: Add NULL check to l_key_get_info
Date: Mon, 08 Aug 2016 10:25:40 -0700
Message-ID: <20160808172545.6648-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5935825878696462366==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/key.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/ell/key.c b/ell/key.c
index 669d257..01489bb 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -378,6 +378,9 @@ bool l_key_get_info(struct l_key *key, enum l_asymmetri=
c_cipher_type cipher,
 			enum l_checksum_type hash, size_t *bits,
 			bool *public)
 {
+	if (unlikely(!key))
+		return false;
+
 	return !kernel_query_key(key->serial, lookup_cipher(cipher),
 					lookup_checksum(hash), bits, public);
 }
-- =

2.9.2


--===============5935825878696462366==--

