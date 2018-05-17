Content-Type: multipart/mixed; boundary="===============0380359987901981354=="
MIME-Version: 1.0
From: Claudio Takahasi <ckt@cesar.org.br>
Subject: [PATCH] checksum: Fix undefined references
Date: Thu, 17 May 2018 13:26:18 -0300
Message-ID: <20180517162618.16655-1-ckt@cesar.org.br>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0380359987901981354==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/checksum.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/ell/checksum.c b/ell/checksum.c
index 1e6a4b5..56b337c 100644
--- a/ell/checksum.c
+++ b/ell/checksum.c
@@ -223,8 +223,8 @@ LIB_EXPORT struct l_checksum *l_checksum_new_cmac_aes(c=
onst void *key,
 	return checksum;
 }
 =

-struct l_checksum *l_checksum_new_hmac(enum l_checksum_type type,
-					const void *key, size_t key_len)
+LIB_EXPORT struct l_checksum *l_checksum_new_hmac(enum l_checksum_type typ=
e,
+					  const void *key, size_t key_len)
 {
 	struct l_checksum *checksum;
 	int fd;
@@ -309,7 +309,7 @@ LIB_EXPORT void l_checksum_free(struct l_checksum *chec=
ksum)
  *
  * Resets the internal state of @checksum.
  **/
-void l_checksum_reset(struct l_checksum *checksum)
+LIB_EXPORT void l_checksum_reset(struct l_checksum *checksum)
 {
 	if (unlikely(!checksum))
 		return;
@@ -353,7 +353,7 @@ LIB_EXPORT bool l_checksum_update(struct l_checksum *ch=
ecksum,
  *
  * Returns: true if the operation succeeded, false otherwise.
  **/
-bool l_checksum_updatev(struct l_checksum *checksum,
+LIB_EXPORT bool l_checksum_updatev(struct l_checksum *checksum,
 					const struct iovec *iov, size_t iov_len)
 {
 	struct msghdr msg;
-- =

2.17.0


--===============0380359987901981354==--

