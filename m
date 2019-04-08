Content-Type: multipart/mixed; boundary="===============3114181880651703345=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 2/2] unit: Fixed a test-dbus-message seg fault.
Date: Mon, 08 Apr 2019 13:12:35 -0700
Message-ID: <20190408201235.10846-3-ossama.othman@intel.com>
In-Reply-To: <20190408201235.10846-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3114181880651703345==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The parse_struct_3() test in unit/test-dbus-message.c exhibited a
segmentation fault, flagged as "bad memory permissions" in valgrind,
when built with the Clang C compiler.  The problem was caused by
attempts by the l_dbus_message_get_arguments() function to write to
read-only memory since pointers to constant integer array elements
were passed as the "out" arguments.  Remove the "const" from the
integer array declaration to permit writes to the array elements.
---
 unit/test-dbus-message.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/unit/test-dbus-message.c b/unit/test-dbus-message.c
index c2ca128..b809f0a 100644
--- a/unit/test-dbus-message.c
+++ b/unit/test-dbus-message.c
@@ -1820,7 +1820,7 @@ static void build_struct_2(const void *data)
 static void parse_struct_3(const void *data)
 {
 	struct l_dbus_message *msg =3D check_message(data);
-	const int num[32] =3D { 0 };
+	int num[32] =3D { 0 };
 	bool result;
 	int i;
 =

-- =

2.17.1


--===============3114181880651703345==--

