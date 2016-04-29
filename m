Content-Type: multipart/mixed; boundary="===============7602118345083931064=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/5] dbus: Handle the 'h' type in append_arguments
Date: Sat, 30 Apr 2016 00:43:58 +0200
Message-ID: <1461969842-11704-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7602118345083931064==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

FD values can't be handled same as int32 values ('i' and 'u').
---
 ell/dbus-message.c | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index 6089295..038d44d 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -1140,7 +1140,6 @@ static bool append_arguments(struct l_dbus_message *m=
essage,
 		}
 		case 'i':
 		case 'u':
-		case 'h':
 		{
 			uint32_t u =3D va_arg(args, uint32_t);
 =

@@ -1149,6 +1148,20 @@ static bool append_arguments(struct l_dbus_message *=
message,
 =

 			break;
 		}
+		case 'h':
+		{
+			int fd =3D va_arg(args, int);
+
+			if (!driver->append_basic(builder, *s,
+							&message->num_fds))
+				goto error;
+
+			if (message->num_fds < L_ARRAY_SIZE(message->fds))
+				message->fds[message->num_fds++] =3D
+					fcntl(fd, F_DUPFD_CLOEXEC, 3);
+
+			break;
+		}
 		case 'x':
 		case 't':
 		{
-- =

2.5.0


--===============7602118345083931064==--

