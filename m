Content-Type: multipart/mixed; boundary="===============0172207460943811914=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 4/5] unit: Switch from nanosecond timer to millisecond timer
Date: Wed, 02 Nov 2016 14:50:47 -0700
Message-ID: <20161102215048.19166-4-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20161102215048.19166-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0172207460943811914==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-main.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/unit/test-main.c b/unit/test-main.c
index 1f4bb31..bd68599 100644
--- a/unit/test-main.c
+++ b/unit/test-main.c
@@ -103,10 +103,8 @@ int main(int argc, char *argv[])
 	timeout_quit =3D l_timeout_create(3, timeout_quit_handler, NULL, NULL);
 =

 	race_delay =3D l_timeout_create(1, race_delay_handler, NULL, NULL);
-	race1 =3D l_timeout_create_with_nanoseconds(1, 100000000, race_handler,
-						  &race2, NULL);
-	race2 =3D l_timeout_create_with_nanoseconds(1, 100000000, race_handler,
-						  &race1, NULL);
+	race1 =3D l_timeout_create_ms(1100, race_handler, &race2, NULL);
+	race2 =3D l_timeout_create_ms(1100, race_handler, &race1, NULL);
 =

 	remove_self =3D l_timeout_create(2, remove_handler, &remove_self, NULL);
 =

-- =

2.10.2


--===============0172207460943811914==--

