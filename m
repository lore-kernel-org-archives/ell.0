Content-Type: multipart/mixed; boundary="===============9086523044294856313=="
MIME-Version: 1.0
From: Szymon Janc <szymon.janc@codecoup.pl>
Subject: [PATCH 4/4] uintset: Fix crash on NULL set
Date: Wed, 21 Oct 2015 23:13:15 +0200
Message-ID: <1445461995-22036-4-git-send-email-szymon.janc@codecoup.pl>
In-Reply-To: <1445461995-22036-1-git-send-email-szymon.janc@codecoup.pl>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9086523044294856313==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This fix NULL pointer dereferences in l_uintset_find_* functions.

With NULL set it is impossible to return l_uintset_get_max(set) + 1
without ambiguous return value. Return UINT_MAX for such cases.
---
 ell/uintset.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/ell/uintset.c b/ell/uintset.c
index 4547ac9..e3d7ede 100644
--- a/ell/uintset.c
+++ b/ell/uintset.c
@@ -314,14 +314,15 @@ LIB_EXPORT uint32_t l_uintset_get_max(struct l_uintse=
t *set)
  * @set: The set of numbers
  *
  * Returns: The minimum number that is not preset in the set.  If the set =
of
- * numbers is fully populated, returns l_uintset_get_max(set) + 1.
+ * numbers is fully populated, returns l_uintset_get_max(set) + 1. If @set=
 is
+ * NULL returns UINT_MAX.
  **/
 LIB_EXPORT uint32_t l_uintset_find_unused_min(struct l_uintset *set)
 {
 	unsigned int bit;
 =

 	if (unlikely(!set))
-		return set->max + 1;
+		return UINT_MAX;
 =

 	bit =3D find_first_zero_bit(set->bits, set->size);
 =

@@ -336,14 +337,14 @@ LIB_EXPORT uint32_t l_uintset_find_unused_min(struct =
l_uintset *set)
  * @set: The set of numbers
  *
  * Returns: The maximum number preset in the set.  If the set of numbers is
- * empty, or on error, returns l_uintset_get_max(set) + 1.
+ * empty returns l_uintset_get_max(set) + 1. If @set is NULL returns UINT_=
MAX.
  **/
 LIB_EXPORT uint32_t l_uintset_find_max(struct l_uintset *set)
 {
 	unsigned int bit;
 =

 	if (unlikely(!set))
-		return set->max + 1;
+		return UINT_MAX;
 =

 	bit =3D find_last_bit(set->bits, set->size);
 =

@@ -358,14 +359,14 @@ LIB_EXPORT uint32_t l_uintset_find_max(struct l_uints=
et *set)
  * @set: The set of numbers
  *
  * Returns: The minimum number preset in the set.  If the set of numbers is
- * empty, or on error, returns l_uintset_get_max(set) + 1.
+ * empty returns l_uintset_get_max(set) + 1. If @set is NULL returns UINT_=
MAX.
  **/
 LIB_EXPORT uint32_t l_uintset_find_min(struct l_uintset *set)
 {
 	unsigned int bit;
 =

 	if (unlikely(!set))
-		return set->max + 1;
+		return UINT_MAX;
 =

 	bit =3D find_first_bit(set->bits, set->size);
 =

-- =

2.6.2


--===============9086523044294856313==--

