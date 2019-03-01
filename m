Content-Type: multipart/mixed; boundary="===============0664601348337334722=="
MIME-Version: 1.0
From: Tim Kourt <tim.a.kourt@linux.intel.com>
Subject: [PATCH v2 1/2] uintset: NULL-check before use
Date: Thu, 28 Feb 2019 17:01:17 -0800
Message-ID: <20190301010118.32494-1-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0664601348337334722==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Postpone the variable usage until after the set is NULL-checked.
---
 ell/uintset.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/ell/uintset.c b/ell/uintset.c
index 2b95ac2..1d96e68 100644
--- a/ell/uintset.c
+++ b/ell/uintset.c
@@ -202,11 +202,13 @@ LIB_EXPORT void l_uintset_free(struct l_uintset *set)
  **/
 LIB_EXPORT bool l_uintset_take(struct l_uintset *set, uint32_t number)
 {
-	uint32_t offset =3D (number - set->min) / BITS_PER_LONG;
+	uint32_t offset;
 =

 	if (unlikely(!set))
 		return false;
 =

+	offset =3D (number - set->min) / BITS_PER_LONG;
+
 	number -=3D set->min;
 =

 	if (number > set->size)
@@ -233,12 +235,13 @@ LIB_EXPORT bool l_uintset_take(struct l_uintset *set,=
 uint32_t number)
  **/
 LIB_EXPORT bool l_uintset_put(struct l_uintset *set, uint32_t number)
 {
-	uint32_t bit =3D number - set->min;
+	uint32_t bit;
 	uint32_t offset;
 =

 	if (unlikely(!set))
 		return false;
 =

+	bit =3D number - set->min;
 	if (bit >=3D set->size)
 		return false;
 =

@@ -257,12 +260,13 @@ LIB_EXPORT bool l_uintset_put(struct l_uintset *set, =
uint32_t number)
  **/
 LIB_EXPORT bool l_uintset_contains(struct l_uintset *set, uint32_t number)
 {
-	uint32_t bit =3D number - set->min;
+	uint32_t bit;
 	uint32_t offset;
 =

 	if (unlikely(!set))
 		return false;
 =

+	bit =3D number - set->min;
 	if (bit >=3D set->size)
 		return false;
 =

-- =

2.13.6


--===============0664601348337334722==--

