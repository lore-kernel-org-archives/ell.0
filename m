Content-Type: multipart/mixed; boundary="===============7856587276584744577=="
MIME-Version: 1.0
From: Rosen Penev <rosenp@gmail.com>
Subject: [PATCH 3/3] ell: don't use else after return
Date: Tue, 21 Jul 2020 15:39:59 -0700
Message-ID: <20200721223959.87135-3-rosenp@gmail.com>
In-Reply-To: <20200721223959.87135-1-rosenp@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7856587276584744577==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Found with clang-tidy's readability-else-after-return

Signed-off-by: Rosen Penev <rosenp@gmail.com>
---
 ell/ecc-external.c   |  2 +-
 ell/ecc.c            |  5 ++---
 ell/gvariant-util.c  |  8 +++-----
 ell/key.c            | 15 +++++++--------
 ell/queue.c          |  6 +++---
 ell/tls-extensions.c |  3 ++-
 ell/tls.c            |  3 +--
 tools/gpio.c         | 11 +++++------
 8 files changed, 24 insertions(+), 29 deletions(-)

diff --git a/ell/ecc-external.c b/ell/ecc-external.c
index 1c118c2..13b55e6 100644
--- a/ell/ecc-external.c
+++ b/ell/ecc-external.c
@@ -85,7 +85,7 @@ int _vli_cmp(const uint64_t *left, const uint64_t *right,=
 unsigned int ndigits)
 	for (i =3D ndigits - 1; i >=3D 0; i--) {
 		if (left[i] > right[i])
 			return 1;
-		else if (left[i] < right[i])
+		if (left[i] < right[i])
 			return -1;
 	}
 =

diff --git a/ell/ecc.c b/ell/ecc.c
index d0c7393..250f7e8 100644
--- a/ell/ecc.c
+++ b/ell/ecc.c
@@ -442,10 +442,9 @@ int _vli_legendre(uint64_t *val, const uint64_t *p, un=
signed int ndigits)
 =

 	if (_vli_cmp(tmp, _1, ndigits) =3D=3D 0)
 		return 1;
-	else if (_vli_cmp(tmp, _0, ndigits) =3D=3D 0)
+	if (_vli_cmp(tmp, _0, ndigits) =3D=3D 0)
 		return 0;
-	else
-		return -1;
+	return -1;
 }
 =

 static bool vli_is_zero_or_one(const uint64_t *vli, unsigned int ndigits)
diff --git a/ell/gvariant-util.c b/ell/gvariant-util.c
index cf0161a..d6ebb64 100644
--- a/ell/gvariant-util.c
+++ b/ell/gvariant-util.c
@@ -307,8 +307,7 @@ static inline size_t offset_length(size_t size, size_t =
n_offsets)
 		return 2;
 	if (size + n_offsets * 4 <=3D 0xffffffff)
 		return 4;
-	else
-		return 8;
+	return 8;
 }
 =

 static inline size_t read_word_le(const void *p, size_t sz) {
@@ -325,10 +324,9 @@ static inline size_t read_word_le(const void *p, size_=
t sz) {
 =

 	if (sz =3D=3D 2)
 		return le16toh(x.u16);
-	else if (sz =3D=3D 4)
+	if (sz =3D=3D 4)
 		return le32toh(x.u32);
-	else
-		return le64toh(x.u64);
+	return le64toh(x.u64);
 }
 =

 static inline void write_word_le(void *p, size_t value, size_t sz) {
diff --git a/ell/key.c b/ell/key.c
index 2e4f3e6..62bd72a 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -500,9 +500,8 @@ static bool compute_common(struct l_key *base, struct l=
_key *private,
 	if (result_len > 0) {
 		*len =3D result_len;
 		return usable_payload;
-	} else {
-		return false;
 	}
+	return false;
 }
 =

 LIB_EXPORT bool l_key_compute_dh_public(struct l_key *generator,
@@ -532,13 +531,13 @@ static int be_bignum_compare(const uint8_t *a, size_t=
 a_len,
 				return 1;
 =

 		return memcmp(a + i, b, b_len);
-	} else {
-		for (i =3D 0; i < b_len - a_len; i++)
-			if (b[i])
-				return -1;
-
-		return memcmp(a, b + i, a_len);
 	}
+
+	for (i =3D 0; i < b_len - a_len; i++)
+		if (b[i])
+			return -1;
+
+	return memcmp(a, b + i, a_len);
 }
 =

 /*
diff --git a/ell/queue.c b/ell/queue.c
index 0f6ed3e..86c52ed 100644
--- a/ell/queue.c
+++ b/ell/queue.c
@@ -533,10 +533,10 @@ LIB_EXPORT void *l_queue_remove_if(struct l_queue *qu=
eue,
 			queue->entries--;
 =

 			return data;
-		} else {
-			prev =3D entry;
-			entry =3D entry->next;
 		}
+
+		prev =3D entry;
+		entry =3D entry->next;
 	}
 =

 	return NULL;
diff --git a/ell/tls-extensions.c b/ell/tls-extensions.c
index 2e2d9da..6154df0 100644
--- a/ell/tls-extensions.c
+++ b/ell/tls-extensions.c
@@ -742,7 +742,8 @@ ssize_t tls_parse_signature_algorithms(struct l_tls *tl=
s,
 				 tls->pending.cipher_suite->signature->id !=3D
 				 sig_alg_id))
 			continue;
-		else if (!tls->pending.cipher_suite &&
+
+		if (!tls->pending.cipher_suite &&
 				!memchr(sig_alg_ids, sig_alg_id, sig_alg_cnt))
 			continue;
 =

diff --git a/ell/tls.c b/ell/tls.c
index 6b47bea..5bf6573 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -134,8 +134,7 @@ static bool tls_prf_get_bytes(struct l_tls *tls,
 		return tls12_prf(tls->prf_hmac->l_id,
 					secret, secret_len, label,
 					seed, seed_len, buf, len);
-	else
-		return tls10_prf(secret, secret_len, label, seed, seed_len,
+	return tls10_prf(secret, secret_len, label, seed, seed_len,
 					buf, len);
 }
 =

diff --git a/tools/gpio.c b/tools/gpio.c
index 0fdb31e..0db596e 100644
--- a/tools/gpio.c
+++ b/tools/gpio.c
@@ -252,14 +252,13 @@ int main(int argc, char **argv)
 =

 	if (strcmp(cmd, "get") =3D=3D 0)
 		return get(argc, argv);
-	else if (strcmp(cmd, "set") =3D=3D 0)
+	if (strcmp(cmd, "set") =3D=3D 0)
 		return set(argc, argv);
-	else if (strcmp(cmd, "find") =3D=3D 0)
+	if (strcmp(cmd, "find") =3D=3D 0)
 		return find(argc, argv);
-	else if (strcmp(cmd, "chip") =3D=3D 0)
+	if (strcmp(cmd, "chip") =3D=3D 0)
 		return chip(argc, argv);
-	else if (strcmp(cmd, "line") =3D=3D 0)
+	if (strcmp(cmd, "line") =3D=3D 0)
 		return line(argc, argv);
-	else
-		return print_usage();
+	return print_usage();
 }
-- =

2.26.2

--===============7856587276584744577==--

