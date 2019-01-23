Content-Type: multipart/mixed; boundary="===============0866148251353244843=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH] queue: Correct l_queue_foreach_remove() doc.
Date: Wed, 23 Jan 2019 10:46:15 -0800
Message-ID: <20190123184615.27170-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0866148251353244843==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Removed non-existent "destroy" parameter from l_queue_foreach_remove()
documentation.
---
 ell/queue.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/ell/queue.c b/ell/queue.c
index 67f7093..0f6ed3e 100644
--- a/ell/queue.c
+++ b/ell/queue.c
@@ -495,7 +495,6 @@ LIB_EXPORT unsigned int l_queue_foreach_remove(struct l=
_queue *queue,
  * @queue: queue object
  * @function: callback function
  * @user_data: user data given to callback function
- * @destroy: Destructor function to call on removal
  *
  * Remove the first entry in the @queue where the function returns #true.
  *
-- =

2.17.1


--===============0866148251353244843==--

