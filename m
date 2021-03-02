Content-Type: multipart/mixed; boundary="===============3570847317642431047=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] queue: Be more specific in l_queue_insert comment
Date: Tue, 02 Mar 2021 22:54:53 +0100
Message-ID: <20210302215453.777869-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3570847317642431047==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Specify that entries for which the compare function returns a 0 come
before the new entry.
---
 ell/queue.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/ell/queue.c b/ell/queue.c
index 86c52ed..3ef892a 100644
--- a/ell/queue.c
+++ b/ell/queue.c
@@ -271,8 +271,9 @@ LIB_EXPORT void *l_queue_peek_tail(struct l_queue *queu=
e)
  * @user_data: user data given to compare function
  *
  * Inserts @data pointer at a position in the queue determined by the
- * compare @function.  @function should return > 0 if the @data (first
- * parameter) should be inserted after the current entry (second parameter=
).
+ * compare @function.  @function should return >=3D 0 if the @data (first
+ * parameter) should be inserted after the current entry (second parameter)
+ * and should return < 0 if before it.
  *
  * Returns: #true when data has been added and #false in case of failure
  **/
-- =

2.27.0

--===============3570847317642431047==--

