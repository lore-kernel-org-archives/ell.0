Content-Type: multipart/mixed; boundary="===============5608650691261872332=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 1/2] unit: Remove unnecessary NULL pointer checks.
Date: Mon, 08 Apr 2019 13:12:34 -0700
Message-ID: <20190408201235.10846-2-ossama.othman@intel.com>
In-Reply-To: <20190408201235.10846-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5608650691261872332==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Several unnecessary NULL pointer checks existed in unit/test-dhcp.c.
The pointers in question were actually arrays visible to the compiler.
Remove those NULL pointer checks to address "always true" warnings
exhibited by the Clang C compiler.
---
 unit/test-dhcp.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/unit/test-dhcp.c b/unit/test-dhcp.c
index 28504fe..49fc9f3 100644
--- a/unit/test-dhcp.c
+++ b/unit/test-dhcp.c
@@ -177,13 +177,13 @@ static struct dhcp_message *create_message(const stru=
ct option_test *test,
 	opt[2] =3D 83;
 	opt[3] =3D 99;
 =

-	if (test->options && test->len)
+	if (test->len)
 		memcpy(&opt[4], test->options, test->len);
 =

-	if (test->file && test->filelen <=3D 128)
+	if (test->filelen <=3D 128)
 		memcpy(&message->file, test->file, test->filelen);
 =

-	if (test->sname && test->snamelen <=3D 64)
+	if (test->snamelen <=3D 64)
 		memcpy(&message->sname, test->sname, test->snamelen);
 =

 	if (out_len)
-- =

2.17.1


--===============5608650691261872332==--

