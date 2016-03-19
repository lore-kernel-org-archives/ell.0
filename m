Content-Type: multipart/mixed; boundary="===============6332644024679314481=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] dbus: Fix returned body_size in _dbus1_builder_finish.
Date: Sat, 19 Mar 2016 07:00:45 +0100
Message-ID: <1458367247-14607-7-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1458367247-14607-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6332644024679314481==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Seems we missed this in the _mark and _rewind patch.
---
 ell/dbus-util.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/dbus-util.c b/ell/dbus-util.c
index 9d5b5af..ab0600a 100644
--- a/ell/dbus-util.c
+++ b/ell/dbus-util.c
@@ -1275,7 +1275,7 @@ char *_dbus1_builder_finish(struct dbus_builder *buil=
der,
 	builder->signature =3D NULL;
 =

 	*body =3D builder->body;
-	*body_size =3D builder->body_size;
+	*body_size =3D builder->body_pos;
 	builder->body =3D NULL;
 	builder->body_size =3D 0;
 =

-- =

2.5.0


--===============6332644024679314481==--

