Content-Type: multipart/mixed; boundary="===============2788556023379422800=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 1/2] key: Avoid using C++ keywords as param names.
Date: Wed, 23 Jan 2019 11:06:09 -0800
Message-ID: <20190123190610.3787-2-ossama.othman@intel.com>
In-Reply-To: <20190123190610.3787-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2788556023379422800==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Rename the parameter names "public" and "private" to avoid conflicts
with the similarly named C++ keywords.  Addresses compile-time errors
in C++ code that includes <ell/key.h>.
---
 ell/key.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/ell/key.h b/ell/key.h
index 024afc6..0107b05 100644
--- a/ell/key.h
+++ b/ell/key.h
@@ -70,16 +70,16 @@ ssize_t l_key_get_payload_size(struct l_key *key);
 =

 bool l_key_get_info(struct l_key *key, enum l_key_cipher_type cipher,
 			enum l_checksum_type checksum, size_t *bits,
-			bool *public);
+			bool *_public);
 =

 struct l_key *l_key_generate_dh_private(const void *prime_buf,
 					size_t prime_len);
 =

-bool l_key_compute_dh_public(struct l_key *generator, struct l_key *privat=
e,
+bool l_key_compute_dh_public(struct l_key *generator, struct l_key *_priva=
te,
 				struct l_key *prime,
 				void *payload, size_t *len);
 =

-bool l_key_compute_dh_secret(struct l_key *other_public, struct l_key *pri=
vate,
+bool l_key_compute_dh_secret(struct l_key *other_public, struct l_key *_pr=
ivate,
 				struct l_key *prime,
 				void *payload, size_t *len);
 =

-- =

2.17.1


--===============2788556023379422800==--

