Content-Type: multipart/mixed; boundary="===============4847121611335096342=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 04/11] dbus: Handle the 'y' type in append_arguments
Date: Fri, 29 Apr 2016 05:32:01 +0200
Message-ID: <1461900728-20662-9-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1461900728-20662-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4847121611335096342==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

FD values can't be handled same as int32 values ('i' and 'u').
---
 ell/dbus-message.c | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index 8151c69..5f91360 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -1137,7 +1137,6 @@ static bool append_arguments(struct l_dbus_message *m=
essage,
 		}
 		case 'i':
 		case 'u':
-		case 'h':
 		{
 			uint32_t u =3D va_arg(args, uint32_t);
 =

@@ -1146,6 +1145,20 @@ static bool append_arguments(struct l_dbus_message *=
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
+					fd =3D fcntl(fd, F_DUPFD_CLOEXEC, 3);
+
+			break;
+		}
 		case 'x':
 		case 't':
 		{
-- =

2.5.0


--===============4847121611335096342==--

