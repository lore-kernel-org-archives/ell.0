Content-Type: multipart/mixed; boundary="===============2880043243622106122=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 02/11] unit: Update dbus tests to use new
 dbus_message_from_blob prototype
Date: Fri, 29 Apr 2016 05:31:59 +0200
Message-ID: <1461900728-20662-7-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1461900728-20662-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2880043243622106122==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-dbus-message.c     | 4 +++-
 unit/test-gvariant-message.c | 3 ++-
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/unit/test-dbus-message.c b/unit/test-dbus-message.c
index c8e2059..20b09bc 100644
--- a/unit/test-dbus-message.c
+++ b/unit/test-dbus-message.c
@@ -48,6 +48,7 @@ struct message_data {
 	uint32_t unix_fds;
 	const unsigned char *binary;
 	size_t binary_len;
+	int *fds;
 };
 =

 static const unsigned char message_binary_basic_1[] =3D {
@@ -1320,7 +1321,8 @@ static struct l_dbus_message *check_message(const str=
uct message_data *msg_data)
 {
 	struct l_dbus_message *msg;
 =

-	msg =3D dbus_message_from_blob(msg_data->binary, msg_data->binary_len);
+	msg =3D dbus_message_from_blob(msg_data->binary, msg_data->binary_len,
+					msg_data->fds, msg_data->unix_fds);
 	assert(msg);
 =

 	if (do_print)
diff --git a/unit/test-gvariant-message.c b/unit/test-gvariant-message.c
index 85326a6..8ded4cd 100644
--- a/unit/test-gvariant-message.c
+++ b/unit/test-gvariant-message.c
@@ -138,7 +138,8 @@ static struct l_dbus_message *check_message(const struc=
t message_data *msg_data)
 {
 	struct l_dbus_message *msg;
 =

-	msg =3D dbus_message_from_blob(msg_data->binary, msg_data->binary_len);
+	msg =3D dbus_message_from_blob(msg_data->binary, msg_data->binary_len,
+					NULL, 0);
 	assert(msg);
 =

 	if (msg_data->path) {
-- =

2.5.0


--===============2880043243622106122==--

