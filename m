Content-Type: multipart/mixed; boundary="===============0472401762543436822=="
MIME-Version: 1.0
From: Tim Kourt <tim.a.kourt@linux.intel.com>
Subject: [PATCH] timeout: Clearified the ruturn behavior in comments
Date: Thu, 28 Apr 2016 11:21:06 -0700
Message-ID: <1461867666-37029-1-git-send-email-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0472401762543436822==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/timeout.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/ell/timeout.c b/ell/timeout.c
index 499c6d6..4ba4e6e 100644
--- a/ell/timeout.c
+++ b/ell/timeout.c
@@ -103,7 +103,8 @@ static inline int timeout_set(int fd, unsigned int seco=
nds, long nanoseconds)
  * The timeout will on fire once. The timeout handling needs to be rearmed
  * with l_timeout_modify() to trigger again.
  *
- * Returns: a newly allocated #l_timeout object
+ * Returns: a newly allocated #l_timeout object. On failure, the function
+ * returns NULL.
  **/
 LIB_EXPORT struct l_timeout *l_timeout_create(unsigned int seconds,
 			l_timeout_notify_cb_t callback,
@@ -126,7 +127,8 @@ LIB_EXPORT struct l_timeout *l_timeout_create(unsigned =
int seconds,
  * The timeout will on fire once. The timeout handling needs to be rearmed
  * with l_timeout_modify_with_nanoseconds() to trigger again.
  *
- * Returns: a newly allocated #l_timeout object
+ * Returns: a newly allocated #l_timeout object. On failure, the function
+ * returns NULL.
  **/
 LIB_EXPORT struct l_timeout *l_timeout_create_with_nanoseconds(unsigned in=
t seconds,
 			long nanoseconds, l_timeout_notify_cb_t callback,
-- =

2.5.0


--===============0472401762543436822==--

