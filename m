Content-Type: multipart/mixed; boundary="===============1868496087313895737=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/9] checksum: Refactor to remove loops and string operations
Date: Tue, 22 Jan 2019 07:08:57 +0100
Message-ID: <20190122060905.27452-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1868496087313895737==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Various checksum methods, like is_supported, get_digest_length, would
look up the checksum data by building the algorithm name string and then
iterating over all checksum_info structs to find the matching name.
Change the checksum_info tables so that they're indexed by
l_checksum_type and the lookups are cheap and simple.  Also drop the
copies of the algorithm name from struct l_checksum.
---
I've also tried changing l_checksum_get_digest_length to take a pointer
to a checksum object instad of checksum type so it could be used equally
for the primary algorithms and the HMAC and CMAC algorithms but iwd has
one use case where it's convenient to have the digest size before
creating the checksum object.
---
 ell/checksum.c | 190 +++++++++++++++++++------------------------------
 1 file changed, 73 insertions(+), 117 deletions(-)

diff --git a/ell/checksum.c b/ell/checksum.c
index 0bb16fd..fec7a69 100644
--- a/ell/checksum.c
+++ b/ell/checksum.c
@@ -68,25 +68,42 @@ struct sockaddr_alg {
 #define SOL_ALG 279
 #endif
 =

-static struct {
+struct checksum_info {
+	enum l_checksum_type type;
 	const char *name;
 	uint8_t digest_len;
 	bool supported;
+};
+
+static struct checksum_info checksum_algs[] =3D {
+	[L_CHECKSUM_MD4] =3D { .name =3D "md4", .digest_len =3D 16 },
+	[L_CHECKSUM_MD5] =3D { .name =3D "md5", .digest_len =3D 16 },
+	[L_CHECKSUM_SHA1] =3D { .name =3D "sha1", .digest_len =3D 20 },
+	[L_CHECKSUM_SHA256] =3D { .name =3D "sha256", .digest_len =3D 32 },
+	[L_CHECKSUM_SHA384] =3D { .name =3D "sha384", .digest_len =3D 48 },
+	[L_CHECKSUM_SHA512] =3D { .name =3D "sha512", .digest_len =3D 64 },
+};
+
+static struct checksum_info checksum_cmac_aes_alg =3D
+	{ .name =3D "cmac(aes)", .digest_len =3D 16 };
+
+static struct checksum_info checksum_hmac_algs[] =3D {
+	[L_CHECKSUM_MD4] =3D { .name =3D "hmac(md4)", .digest_len =3D 16 },
+	[L_CHECKSUM_MD5] =3D { .name =3D "hmac(md5)", .digest_len =3D 16 },
+	[L_CHECKSUM_SHA1] =3D { .name =3D "hmac(sha1)", .digest_len =3D 20 },
+	[L_CHECKSUM_SHA256] =3D { .name =3D "hmac(sha256)", .digest_len =3D 32 },
+	[L_CHECKSUM_SHA384] =3D { .name =3D "hmac(sha384)", .digest_len =3D 48 },
+	[L_CHECKSUM_SHA512] =3D { .name =3D "hmac(sha512)", .digest_len =3D 64 },
+};
+
+static const struct {
+	struct checksum_info *list;
+	size_t n;
 } checksum_info_table[] =3D {
-	{ .name =3D "md4", .digest_len =3D 16 },
-	{ .name =3D "md5", .digest_len =3D 16 },
-	{ .name =3D "sha1", .digest_len =3D 20 },
-	{ .name =3D "sha256", .digest_len =3D 32 },
-	{ .name =3D "sha384", .digest_len =3D 48 },
-	{ .name =3D "sha512", .digest_len =3D 64 },
-	{ .name =3D "cmac(aes)", .digest_len =3D 16 },
-	{ .name =3D "hmac(md4)", .digest_len =3D 16 },
-	{ .name =3D "hmac(md5)", .digest_len =3D 16 },
-	{ .name =3D "hmac(sha1)", .digest_len =3D 20 },
-	{ .name =3D "hmac(sha256)", .digest_len =3D 32 },
-	{ .name =3D "hmac(sha384)", .digest_len =3D 48 },
-	{ .name =3D "hmac(sha512)", .digest_len =3D 64 },
-	{ .name =3D NULL, .digest_len =3D 0 },
+	{ checksum_algs, L_ARRAY_SIZE(checksum_algs) },
+	{ &checksum_cmac_aes_alg, 1 },
+	{ checksum_hmac_algs, L_ARRAY_SIZE(checksum_hmac_algs) },
+	{}
 };
 =

 /**
@@ -96,17 +113,16 @@ static struct {
  * Checksum handling
  */
 =

-#define is_valid_type(type)  ((type) > L_CHECKSUM_NONE && \
-					(type) <=3D L_CHECKSUM_SHA512)
+#define is_valid_index(array, i) ((i) >=3D 0 && (i) < L_ARRAY_SIZE(array))
 =

 /**
  * l_checksum:
  *
- * Opague object representing the checksum.
+ * Opaque object representing the checksum.
  */
 struct l_checksum {
 	int sk;
-	char alg_name[sizeof(((struct sockaddr_alg *) 0)->salg_name)];
+	const struct checksum_info *alg_info;
 };
 =

 static int create_alg(const char *alg)
@@ -131,30 +147,6 @@ static int create_alg(const char *alg)
 	return sk;
 }
 =

-static const char *checksum_type_to_name(enum l_checksum_type type)
-{
-	switch (type) {
-	case L_CHECKSUM_NONE:
-		return NULL;
-	case L_CHECKSUM_MD4:
-		return "md4";
-	case L_CHECKSUM_MD5:
-		return "md5";
-	case L_CHECKSUM_SHA1:
-		return "sha1";
-	case L_CHECKSUM_SHA224:
-		return "sha224";
-	case L_CHECKSUM_SHA256:
-		return "sha256";
-	case L_CHECKSUM_SHA384:
-		return "sha384";
-	case L_CHECKSUM_SHA512:
-		return "sha512";
-	}
-
-	return NULL;
-}
-
 /**
  * l_checksum_new:
  * @type: checksum type
@@ -166,17 +158,15 @@ static const char *checksum_type_to_name(enum l_check=
sum_type type)
 LIB_EXPORT struct l_checksum *l_checksum_new(enum l_checksum_type type)
 {
 	struct l_checksum *checksum;
-	const char *name;
 	int fd;
 =

-	if (!is_valid_type(type))
+	if (!is_valid_index(checksum_algs, type) || !checksum_algs[type].name)
 		return NULL;
 =

 	checksum =3D l_new(struct l_checksum, 1);
+	checksum->alg_info =3D &checksum_algs[type];
 =

-	name =3D checksum_type_to_name(type);
-
-	fd =3D create_alg(name);
+	fd =3D create_alg(checksum->alg_info->name);
 	if (fd < 0)
 		goto error;
 =

@@ -186,8 +176,6 @@ LIB_EXPORT struct l_checksum *l_checksum_new(enum l_che=
cksum_type type)
 	if (checksum->sk < 0)
 		goto error;
 =

-	strcpy(checksum->alg_name, name);
-
 	return checksum;
 =

 error:
@@ -219,7 +207,7 @@ LIB_EXPORT struct l_checksum *l_checksum_new_cmac_aes(c=
onst void *key,
 		return NULL;
 	}
 =

-	strcpy(checksum->alg_name, "cmac(aes)");
+	checksum->alg_info =3D &checksum_cmac_aes_alg;
 	return checksum;
 }
 =

@@ -228,18 +216,12 @@ LIB_EXPORT struct l_checksum *l_checksum_new_hmac(enu=
m l_checksum_type type,
 {
 	struct l_checksum *checksum;
 	int fd;
-	char name[sizeof(((struct sockaddr_alg *)0)->salg_name)];
-	unsigned int r;
-
-	if (!is_valid_type(type))
-		return NULL;
 =

-	r =3D snprintf(name, sizeof(name), "hmac(%s)",
-					checksum_type_to_name(type));
-	if (r >=3D sizeof(name))
+	if (!is_valid_index(checksum_hmac_algs, type) ||
+			!checksum_hmac_algs[type].name)
 		return NULL;
 =

-	fd =3D create_alg(name);
+	fd =3D create_alg(checksum_hmac_algs[type].name);
 	if (fd < 0)
 		return NULL;
 =

@@ -257,7 +239,7 @@ LIB_EXPORT struct l_checksum *l_checksum_new_hmac(enum =
l_checksum_type type,
 		return NULL;
 	}
 =

-	strcpy(checksum->alg_name, name);
+	checksum->alg_info =3D &checksum_hmac_algs[type];
 	return checksum;
 }
 =

@@ -284,7 +266,7 @@ LIB_EXPORT struct l_checksum *l_checksum_clone(struct l=
_checksum *checksum)
 		return NULL;
 	}
 =

-	strcpy(clone->alg_name, checksum->alg_name);
+	clone->alg_info =3D checksum->alg_info;
 	return clone;
 }
 =

@@ -418,22 +400,13 @@ LIB_EXPORT ssize_t l_checksum_get_digest(struct l_che=
cksum *checksum,
 LIB_EXPORT char *l_checksum_get_string(struct l_checksum *checksum)
 {
 	unsigned char digest[64];
-	unsigned int i;
 =

 	if (unlikely(!checksum))
 		return NULL;
 =

 	l_checksum_get_digest(checksum, digest, sizeof(digest));
 =

-	for (i =3D 0; checksum_info_table[i].name; i++) {
-		if (strcmp(checksum_info_table[i].name, checksum->alg_name))
-			continue;
-
-		return l_util_hexstring(digest,
-					checksum_info_table[i].digest_len);
-	}
-
-	return NULL;
+	return l_util_hexstring(digest, checksum->alg_info->digest_len);
 }
 =

 static void init_supported()
@@ -441,7 +414,7 @@ static void init_supported()
 	static bool initialized =3D false;
 	struct sockaddr_alg salg;
 	int sk;
-	int i;
+	unsigned int i, j;
 =

 	if (likely(initialized))
 		return;
@@ -456,74 +429,57 @@ static void init_supported()
 	salg.salg_family =3D AF_ALG;
 	strcpy((char *) salg.salg_type, "hash");
 =

-	for (i =3D 0; checksum_info_table[i].name; i++) {
-		strcpy((char *) salg.salg_name, checksum_info_table[i].name);
-
-		if (bind(sk, (struct sockaddr *) &salg, sizeof(salg)) < 0)
-			continue;
-
-		checksum_info_table[i].supported =3D true;
-	}
+	for (i =3D 0; checksum_info_table[i].list; i++)
+		for (j =3D 0; j < checksum_info_table[i].n; j++) {
+			struct checksum_info *info;
 =

-	close(sk);
-}
+			info =3D &checksum_info_table[i].list[j];
+			if (!info->name)
+				continue;
 =

-static inline bool is_supported(const char *alg)
-{
-	int i;
+			strcpy((char *) salg.salg_name, info->name);
 =

-	for (i =3D 0; checksum_info_table[i].name; i++) {
-		if (strcmp(checksum_info_table[i].name, alg))
-			continue;
+			if (bind(sk, (struct sockaddr *) &salg,
+						sizeof(salg)) < 0)
+				continue;
 =

-		return checksum_info_table[i].supported;
-	}
+			info->supported =3D true;
+		}
 =

-	return false;
+	close(sk);
 }
 =

 LIB_EXPORT bool l_checksum_is_supported(enum l_checksum_type type,
 							bool check_hmac)
 {
-	const char *name;
-	char hmac[sizeof(((struct sockaddr_alg *)0)->salg_name)];
+	const struct checksum_info *list;
 =

 	init_supported();
 =

-	name =3D checksum_type_to_name(type);
-	if (!name)
-		return false;
+	if (!check_hmac) {
+		if (!is_valid_index(checksum_algs, type))
+			return false;
 =

-	if (!is_supported(name))
-		return false;
+		list =3D checksum_algs;
+	} else {
+		if (!is_valid_index(checksum_hmac_algs, type))
+			return false;
 =

-	if (!check_hmac)
-		return true;
+		list =3D checksum_hmac_algs;
+	}
 =

-	snprintf(hmac, sizeof(hmac) - 1, "hmac(%s)", name);
-	return is_supported(hmac);
+	return list[type].supported;
 }
 =

 LIB_EXPORT bool l_checksum_cmac_aes_supported()
 {
 	init_supported();
 =

-	return is_supported("cmac(aes)");
+	return checksum_cmac_aes_alg.supported;
 }
 =

 LIB_EXPORT ssize_t l_checksum_digest_length(enum l_checksum_type type)
 {
-	const char *name;
-	int i;
-
-	name =3D checksum_type_to_name(type);
-	if (!name)
-		return -EINVAL;
-
-	for (i =3D 0; checksum_info_table[i].name; i++) {
-		if (!strcmp(checksum_info_table[i].name, name))
-			return checksum_info_table[i].digest_len;
-	}
-
-	return 0;
+	return is_valid_index(checksum_algs, type) ?
+		checksum_algs[type].digest_len : 0;
 }
-- =

2.19.1


--===============1868496087313895737==--

