Content-Type: multipart/mixed; boundary="===============0943702343478728753=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 2/2] uintset: Do not exceed max offset in empty check
Date: Mon, 16 Sep 2019 13:36:10 -0700
Message-ID: <20190916203610.19722-3-ossama.othman@intel.com>
In-Reply-To: <20190916203610.19722-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0943702343478728753==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Do not exceed the maximum l_uintset bits offset when checking if the
set is empty.
---
 ell/uintset.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/ell/uintset.c b/ell/uintset.c
index 50119a0..b88e28e 100644
--- a/ell/uintset.c
+++ b/ell/uintset.c
@@ -516,11 +516,14 @@ LIB_EXPORT struct l_uintset *l_uintset_intersect(cons=
t struct l_uintset *set_a,
 LIB_EXPORT bool l_uintset_isempty(const struct l_uintset *set)
 {
 	uint16_t i;
+	uint32_t offset_max;
 =

 	if (unlikely(!set))
 		return true;
 =

-	for (i =3D 0; i < set->size; i++) {
+	offset_max =3D (set->size + BITS_PER_LONG - 1) / BITS_PER_LONG;
+
+	for (i =3D 0; i < offset_max; i++) {
 		if (set->bits[i])
 			return false;
 	}
-- =

2.20.1


--===============0943702343478728753==--

