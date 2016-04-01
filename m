Content-Type: multipart/mixed; boundary="===============4797505316769891920=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] dbus: Set a 30s kdbus method call timeout
Date: Fri, 01 Apr 2016 04:41:05 +0200
Message-ID: <1459478466-6299-3-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1459478466-6299-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4797505316769891920==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus-kernel.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/dbus-kernel.c b/ell/dbus-kernel.c
index b31cfcc..f828657 100644
--- a/ell/dbus-kernel.c
+++ b/ell/dbus-kernel.c
@@ -393,7 +393,7 @@ int _dbus_kernel_send(int fd, size_t bloom_size, uint8_=
t bloom_n_hash,
 	}
 	case DBUS_MESSAGE_TYPE_METHOD_CALL:
 		if (!l_dbus_message_get_no_reply(message))
-			kmsg->timeout_ns =3D 30000 * 1000ULL;
+			kmsg->timeout_ns =3D 30000 * 1000000ULL;
 		break;
 	case DBUS_MESSAGE_TYPE_SIGNAL:
 		kmsg->flags |=3D KDBUS_MSG_SIGNAL;
-- =

2.5.0


--===============4797505316769891920==--

