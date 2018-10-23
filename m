Content-Type: multipart/mixed; boundary="===============3979405509826188128=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH] Update Linux kernel documentation URLs.
Date: Tue, 23 Oct 2018 13:21:05 -0700
Message-ID: <20181023202105.31112-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3979405509826188128==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 HACKING              | 3 ++-
 doc/coding-style.txt | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/HACKING b/HACKING
index 7db7d66..22dc9a2 100644
--- a/HACKING
+++ b/HACKING
@@ -6,7 +6,8 @@ welcome! In order to ease the inclusion of your patch, it's=
 important to follow
 some rules, otherwise it will likely be rejected by maintainers.
 =

 ell rules for submitting patches follow most of the rules used by Linux ke=
rnel
-(https://www.kernel.org/doc/Documentation/SubmittingPatches) with some rem=
arks:
+(https://www.kernel.org/doc/html/latest/process/submitting-patches.html)
+with some remarks:
 =

 1) Do *not* add "Signed-off-by" lines in your commit messages. ell does not
 use them, so including them is actually an error.
diff --git a/doc/coding-style.txt b/doc/coding-style.txt
index 6b1c44a..3699052 100644
--- a/doc/coding-style.txt
+++ b/doc/coding-style.txt
@@ -9,7 +9,8 @@ to help your code survive under maintainer's fastidious eye=
s so that you
 can get a passport for your patch ASAP.
 =

 First of all, the Embedded Linux Library coding style must follow every ru=
le
-for the Linux kernel (http://www.kernel.org/doc/Documentation/CodingStyle).
+for the Linux kernel
+(https://www.kernel.org/doc/html/latest/process/coding-style.html).
 There also exists a tool named checkpatch.pl to help you check the complia=
nce
 with it. Just type "checkpatch.pl --no-tree --no-signoff patch_name" to ch=
eck
 your patch.
-- =

2.17.1


--===============3979405509826188128==--

