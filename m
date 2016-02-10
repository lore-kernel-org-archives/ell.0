Content-Type: multipart/mixed; boundary="===============5079106009753909909=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 1/2] doc: Recommend "--no-signoff" when invoking checkpatch.pl
Date: Wed, 10 Feb 2016 15:48:41 -0800
Message-ID: <1455148122-20449-1-git-send-email-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5079106009753909909==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 doc/coding-style.txt | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/doc/coding-style.txt b/doc/coding-style.txt
index c362eef..6b1c44a 100644
--- a/doc/coding-style.txt
+++ b/doc/coding-style.txt
@@ -11,13 +11,13 @@ can get a passport for your patch ASAP.
 First of all, the Embedded Linux Library coding style must follow every ru=
le
 for the Linux kernel (http://www.kernel.org/doc/Documentation/CodingStyle).
 There also exists a tool named checkpatch.pl to help you check the complia=
nce
-with it. Just type "checkpatch.pl --no-tree patch_name" to check your patc=
h.
+with it. Just type "checkpatch.pl --no-tree --no-signoff patch_name" to ch=
eck
+your patch.
 =

-In theory, you need to clean up all the warnings and errors except this
-one: "ERROR: Missing Signed-off-by: line(s)".  ell does not used Signed-Off
-lines, so including them is actually an error.  In certain circumstances o=
ne
-can ignore the 80 character per line limit.  This is generally only allowe=
d if
-the alternative would make the code even less readable.
+In theory, you need to clean up all the warnings and errors.  In
+certain circumstances one can ignore the 80 character per line limit.
+This is generally only allowed if the alternative would make the code
+even less readable.
 =

 Besides the kernel coding style above, the ell has special
 flavors for its own. Some of them are mandatory (marked as 'M'), while
-- =

2.7.0


--===============5079106009753909909==--

