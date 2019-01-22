Content-Type: multipart/mixed; boundary="===============5323400117298996471=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/9] checksum: Make l_checksum_get_digest more high-level
Date: Tue, 22 Jan 2019 07:08:58 +0100
Message-ID: <20190122060905.27452-2-andrew.zaborowski@intel.com>
In-Reply-To: <20190122060905.27452-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5323400117298996471==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Check that the recv() in l_checksum_get_digest has received the expected
number of bytes and update the comment to remove the reference to "bytes
read" which implied this is a low-level wrapper for an fd read.  Now the
caller can pass a buffer longer than strictly needed for the hash, in
which case the first digest_len bytes are used and digest_len is
returned to inform the caller of the number of bytes written, or a
shorter buffer to receive the initial part of the digest.  The caller
then only needs to check if the result is not < 0 instead of checking
for short reads.

The normal usage now may be:

uint8_t a[64];
size_t a_len;

a_len =3D l_checksum_get_digest(checksum, a, sizeof@);
---
 ell/checksum.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/ell/checksum.c b/ell/checksum.c
index fec7a69..f6f5cb2 100644
--- a/ell/checksum.c
+++ b/ell/checksum.c
@@ -361,12 +361,14 @@ LIB_EXPORT bool l_checksum_updatev(struct l_checksum =
*checksum,
 /**
  * l_checksum_get_digest:
  * @checksum: checksum object
- * @digest: digest data pointer
- * @len: length of digest data
+ * @digest: output data buffer
+ * @len: length of output buffer
  *
- * Gets the digest from @checksum as raw binary data.
+ * Writes the digest from @checksum as raw binary data into the provided
+ * buffer or, if the buffer is shorter, the initial @len bytes of the dige=
st
+ * data.
  *
- * Returns: Number of bytes read, or negative value if an error occurred.
+ * Returns: Number of bytes written, or negative value if an error occurre=
d.
  **/
 LIB_EXPORT ssize_t l_checksum_get_digest(struct l_checksum *checksum,
 						void *digest, size_t len)
@@ -386,6 +388,9 @@ LIB_EXPORT ssize_t l_checksum_get_digest(struct l_check=
sum *checksum,
 	if (result < 0)
 		return -errno;
 =

+	if ((size_t) result < len && result < checksum->alg_info->digest_len)
+		return -EIO;
+
 	return result;
 }
 =

-- =

2.19.1


--===============5323400117298996471==--

