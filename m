Content-Type: multipart/mixed; boundary="===============3423323435581878602=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 8/9] key: Use consistent checksum arg name for l_key_get_info()
Date: Fri, 23 Sep 2016 16:02:21 -0700
Message-ID: <20160923230222.27401-8-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20160923230222.27401-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3423323435581878602==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/key.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/ell/key.c b/ell/key.c
index 24c42a2..c7ee329 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -366,14 +366,15 @@ static const char *lookup_checksum(enum l_checksum_ty=
pe checksum)
 }
 =

 bool l_key_get_info(struct l_key *key, enum l_key_cipher_type cipher,
-			enum l_checksum_type hash, size_t *bits,
+			enum l_checksum_type checksum, size_t *bits,
 			bool *public)
 {
 	if (unlikely(!key))
 		return false;
 =

 	return !kernel_query_key(key->serial, lookup_cipher(cipher),
-					lookup_checksum(hash), bits, public);
+					lookup_checksum(checksum), bits,
+					public);
 }
 =

 static bool compute_common(struct l_key *base,
-- =

2.10.0


--===============3423323435581878602==--

