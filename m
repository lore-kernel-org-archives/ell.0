Content-Type: multipart/mixed; boundary="===============3384404557481399687=="
MIME-Version: 1.0
From: Rosen Penev <rosenp@gmail.com>
Subject: [PATCH 3/4] ell: remove extra/unnecessary semicolons
Date: Wed, 01 Apr 2020 20:36:31 -0700
Message-ID: <20200402033632.961701-3-rosenp@gmail.com>
In-Reply-To: <20200402033632.961701-1-rosenp@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3384404557481399687==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Found with clang's -Wextra-semi-stmt
---
 ell/dbus-client.c | 2 +-
 ell/dbus.c        | 2 +-
 ell/dhcp.c        | 4 ++--
 ell/siphash.c     | 2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/ell/dbus-client.c b/ell/dbus-client.c
index f735f33..d98631a 100644
--- a/ell/dbus-client.c
+++ b/ell/dbus-client.c
@@ -414,7 +414,7 @@ static struct l_dbus_proxy *dbus_proxy_new(struct l_dbu=
s_client *client,
 	proxy->interface =3D l_strdup(interface);
 	proxy->path =3D l_strdup(path);
 	proxy->properties =3D l_queue_new();
-	proxy->pending_calls =3D l_queue_new();;
+	proxy->pending_calls =3D l_queue_new();
 =

 	l_queue_push_tail(client->proxies, proxy);
 =

diff --git a/ell/dbus.c b/ell/dbus.c
index 845ccb3..fb520e2 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -1496,7 +1496,7 @@ LIB_EXPORT bool l_dbus_register_object(struct l_dbus =
*dbus, const char *path,
 	va_list args;
 	const char *interface;
 	void *if_user_data;
-	bool r =3D true;;
+	bool r =3D true;
 =

 	if (unlikely(!dbus))
 		return false;
diff --git a/ell/dhcp.c b/ell/dhcp.c
index f1e1595..bc3994e 100644
--- a/ell/dhcp.c
+++ b/ell/dhcp.c
@@ -153,7 +153,7 @@ const char *_dhcp_option_to_string(uint8_t option)
 		return "End";
 	default:
 		return "unknown";
-	};
+	}
 }
 =

 bool _dhcp_message_iter_init(struct dhcp_message_iter *iter,
@@ -768,7 +768,7 @@ static void dhcp_client_timeout_resend(struct l_timeout=
 *timeout,
 	case DHCP_STATE_REBOOTING:
 	case DHCP_STATE_BOUND:
 		break;
-	};
+	}
 =

 	if (next_timeout)
 		l_timeout_modify_ms(timeout, dhcp_fuzz_secs(next_timeout));
diff --git a/ell/siphash.c b/ell/siphash.c
index a37d228..52542d4 100644
--- a/ell/siphash.c
+++ b/ell/siphash.c
@@ -134,5 +134,5 @@ void _siphash24(uint8_t out[8], const uint8_t *in, size=
_t inlen,
 	SIPROUND;
 	SIPROUND;
 	b =3D v0 ^ v1 ^ v2  ^ v3;
-	U64TO8_LE(out, b);
+	U64TO8_LE(out, b)
 }
-- =

2.25.1

--===============3384404557481399687==--

