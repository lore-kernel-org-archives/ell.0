Content-Type: multipart/mixed; boundary="===============3280050895589366464=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 5/5] unit: Remove C99 loop variable declaration.
Date: Mon, 04 Mar 2019 10:42:59 -0800
Message-ID: <20190304184259.22809-6-ossama.othman@intel.com>
In-Reply-To: <20190304184259.22809-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3280050895589366464==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-dbus-message.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/unit/test-dbus-message.c b/unit/test-dbus-message.c
index f392c0e..c2ca128 100644
--- a/unit/test-dbus-message.c
+++ b/unit/test-dbus-message.c
@@ -1822,6 +1822,7 @@ static void parse_struct_3(const void *data)
 	struct l_dbus_message *msg =3D check_message(data);
 	const int num[32] =3D { 0 };
 	bool result;
+	int i;
 =

 	result =3D l_dbus_message_get_arguments(msg, MESSAGE_SIGNATURE_STRUCT_3,
 		      &num[0], &num[1], &num[2], &num[3],
@@ -1835,7 +1836,7 @@ static void parse_struct_3(const void *data)
 =

 	assert(result);
 =

-	for (int i =3D 0; i < 32; i++) {
+	for (i =3D 0; i < 32; i++) {
 		assert(i =3D=3D num[i]);
 	}
 =

-- =

2.17.1


--===============3280050895589366464==--

