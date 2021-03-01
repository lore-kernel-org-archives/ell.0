Content-Type: multipart/mixed; boundary="===============3692730828306929653=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] queue: Fix an l_queue_insert corner case
Date: Mon, 01 Mar 2021 23:57:46 +0100
Message-ID: <20210301225746.742230-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3692730828306929653==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The comment doc for the function says:

 * Inserts @data pointer at a position in the queue determined by the
 * compare @function.  @function should return > 0 if the @data (first
 * parameter) should be inserted after the current entry (second parameter).

however the function would insert @data after entries for which
@function returned a >=3D 0 value.  Change the check to > 0 to align with
the docs.
---
 ell/queue.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/queue.c b/ell/queue.c
index 86c52ed..b28eecf 100644
--- a/ell/queue.c
+++ b/ell/queue.c
@@ -299,7 +299,7 @@ LIB_EXPORT bool l_queue_insert(struct l_queue *queue, v=
oid *data,
 	for (prev =3D NULL, cur =3D queue->head; cur; prev =3D cur, cur =3D cur->=
next) {
 		cmp =3D function(entry->data, cur->data, user_data);
 =

-		if (cmp >=3D 0)
+		if (cmp > 0)
 			continue;
 =

 		if (prev =3D=3D NULL) {
-- =

2.27.0

--===============3692730828306929653==--

