Content-Type: multipart/mixed; boundary="===============1953709497007739690=="
MIME-Version: 1.0
From: Brian Gix <brian.gix@intel.com>
Subject: [PATCH v3] dbus: NULL check proxy on method calls
Date: Wed, 18 Dec 2019 07:12:35 -0800
Message-ID: <20191218151235.21355-1-brian.gix@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1953709497007739690==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

l_dbus_proxy_method_call() seg-faults when called with a NULL proxy
pointer.  This NULL check follows the pattern of NULL checks in the
other LIB_EXPORT methods in module.
---
 ell/dbus-client.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/ell/dbus-client.c b/ell/dbus-client.c
index 541f3e8..2d8120e 100644
--- a/ell/dbus-client.c
+++ b/ell/dbus-client.c
@@ -301,6 +301,9 @@ LIB_EXPORT uint32_t l_dbus_proxy_method_call(struct l_d=
bus_proxy *proxy,
 {
 	struct method_call_request *req;
 =

+	if (unlikely(!proxy))
+		return 0;
+
 	req =3D l_new(struct method_call_request, 1);
 	req->proxy =3D proxy;
 	req->setup =3D setup;
-- =

2.21.0

--===============1953709497007739690==--

