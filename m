Content-Type: multipart/mixed; boundary="===============7750910614381893554=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 11/11] unit: 'h' type parsing and building tests.
Date: Fri, 29 Apr 2016 05:32:08 +0200
Message-ID: <1461900728-20662-16-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1461900728-20662-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7750910614381893554==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-dbus-message.c | 125 +++++++++++++++++++++++++++++++++++++++++++=
++++
 1 file changed, 125 insertions(+)

diff --git a/unit/test-dbus-message.c b/unit/test-dbus-message.c
index 20b09bc..52df9d8 100644
--- a/unit/test-dbus-message.c
+++ b/unit/test-dbus-message.c
@@ -26,6 +26,10 @@
 =

 #include <assert.h>
 #include <math.h>
+#include <sys/stat.h>
+#include <unistd.h>
+#include <fcntl.h>
+#include <errno.h>
 =

 #include <ell/ell.h>
 =

@@ -2578,6 +2582,124 @@ static void builder_rewind(const void *data)
 	compare_message(msg, data);
 }
 =

+static int count_fds(void)
+{
+	int fd;
+	int count =3D 0;
+
+	for (fd =3D 0; fd < FD_SETSIZE; fd++)
+		if (fcntl(fd, F_GETFL) !=3D -1 || errno !=3D EBADF)
+			count++;
+
+	return count;
+}
+
+static void compare_files(int a, int b)
+{
+	struct stat sa, sb;
+
+	assert(fstat(a, &sa) =3D=3D 0);
+	assert(fstat(b, &sb) =3D=3D 0);
+
+	assert(sa.st_dev =3D=3D sb.st_dev);
+	assert(sa.st_ino =3D=3D sb.st_ino);
+	assert(sa.st_rdev =3D=3D sb.st_rdev);
+}
+
+static const unsigned char message_binary_basic_h[] =3D {
+	0x6c, 0x01, 0x00, 0x01, 0x04, 0x00, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00, 0x6f, 0x00, 0x00, 0x00,
+	0x01, 0x01, 0x6f, 0x00, 0x13, 0x00, 0x00, 0x00,
+	0x2f, 0x63, 0x6f, 0x6d, 0x2f, 0x65, 0x78, 0x61,
+	0x6d, 0x70, 0x6c, 0x65, 0x2f, 0x6f, 0x62, 0x6a,
+	0x65, 0x63, 0x74, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x06, 0x01, 0x73, 0x00, 0x0b, 0x00, 0x00, 0x00,
+	0x63, 0x6f, 0x6d, 0x2e, 0x65, 0x78, 0x61, 0x6d,
+	0x70, 0x6c, 0x65, 0x00, 0x00, 0x00, 0x00, 0x00,
+	0x02, 0x01, 0x73, 0x00, 0x15, 0x00, 0x00, 0x00,
+	0x63, 0x6f, 0x6d, 0x2e, 0x65, 0x78, 0x61, 0x6d,
+	0x70, 0x6c, 0x65, 0x2e, 0x69, 0x6e, 0x74, 0x65,
+	0x72, 0x66, 0x61, 0x63, 0x65, 0x00, 0x00, 0x00,
+	0x03, 0x01, 0x73, 0x00, 0x06, 0x00, 0x00, 0x00,
+	0x6d, 0x65, 0x74, 0x68, 0x6f, 0x64, 0x00, 0x00,
+	0x08, 0x01, 0x67, 0x00, 0x01, 0x68, 0x00, 0x00,
+	0x00, 0x00, 0x00, 0x00,
+};
+
+static const struct message_data message_data_basic_h =3D {
+	.type		=3D "method_call",
+	.path		=3D "/com/example/object",
+	.interface	=3D "com.example.interface",
+	.member		=3D "method",
+	.destination	=3D "com.example",
+	.signature	=3D "h",
+	.serial		=3D 0,
+	.reply_serial	=3D 0,
+	.no_reply	=3D 0,
+	.auto_start	=3D 1,
+	.unix_fds	=3D 1,
+	.binary		=3D message_binary_basic_h,
+	.binary_len	=3D sizeof(message_binary_basic_h),
+};
+
+static void message_fds_parse(const void *data)
+{
+	struct message_data message_data =3D message_data_basic_h;
+	struct l_dbus_message *msg;
+	int fd0, fd1;
+	int open_fds;
+	bool result;
+
+	open_fds =3D count_fds();
+
+	fd0 =3D open("/dev/random", O_RDONLY);
+	assert(fd0 !=3D -1);
+
+	message_data.fds =3D &fd0;
+	msg =3D check_message(&message_data);
+
+	result =3D l_dbus_message_get_arguments(msg, "h", &fd1);
+	assert(result);
+	assert(fd1 !=3D -1 && fd0 !=3D fd1);
+
+	compare_files(fd0, fd1);
+
+	assert(count_fds() !=3D open_fds);
+
+	close(fd1);
+
+	assert(count_fds() !=3D open_fds);
+
+	l_dbus_message_unref(msg);
+
+	assert(count_fds() =3D=3D open_fds);
+}
+
+static void message_fds_build(const void *data)
+{
+	struct message_data message_data =3D message_data_basic_h;
+	struct l_dbus_message *msg;
+	int fd;
+	int open_fds;
+
+	open_fds =3D count_fds();
+
+	fd =3D open("/dev/random", O_RDONLY);
+	assert(fd !=3D -1);
+
+	msg =3D build_message(&message_data);
+
+	l_dbus_message_set_arguments(msg, "h", fd);
+
+	close(fd);
+
+	assert(count_fds() !=3D open_fds);
+
+	compare_message(msg, &message_data);
+
+	assert(count_fds() =3D=3D open_fds);
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
@@ -2674,5 +2796,8 @@ int main(int argc, char *argv[])
 	l_test_add("Message Builder Rewind Complex 1", builder_rewind,
 						&message_data_complex_1);
 =

+	l_test_add("FDs (parse)", message_fds_parse, NULL);
+	l_test_add("FDs (build)", message_fds_build, NULL);
+
 	return l_test_run();
 }
-- =

2.5.0


--===============7750910614381893554==--

