Content-Type: multipart/mixed; boundary="===============3429697319879366345=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 2/4] cipher: Check AAD length when setting up AEAD result reads
Date: Wed, 24 Jan 2018 13:51:27 -0800
Message-ID: <20180124215129.13337-2-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20180124215129.13337-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3429697319879366345==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Use read() instead of recvmsg() when AAD length is zero, instead of
checking the AAD data pointer to make the decision. The length is used
in the affected block of code and the pointer is not.
---
 ell/cipher.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/cipher.c b/ell/cipher.c
index bfbe5d4..8fe3610 100644
--- a/ell/cipher.c
+++ b/ell/cipher.c
@@ -357,7 +357,7 @@ static ssize_t operate_cipher(int sk, __u32 operation,
 	if (result < 0)
 		return -errno;
 =

-	if (ad) {
+	if (ad_len) {
 		/*
 		 * When AEAD additional data is passed to sendmsg() for
 		 * use in computing the tag, those bytes also appear at
-- =

2.16.1


--===============3429697319879366345==--

