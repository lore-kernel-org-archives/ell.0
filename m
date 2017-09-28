Content-Type: multipart/mixed; boundary="===============3924973930622309565=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 3/4] unit: Close files before exiting
Date: Wed, 27 Sep 2017 17:22:04 -0700
Message-ID: <20170928002205.17218-3-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20170928002205.17218-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3924973930622309565==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-dbus-message-fds.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/unit/test-dbus-message-fds.c b/unit/test-dbus-message-fds.c
index ff645ea..c31d0aa 100644
--- a/unit/test-dbus-message-fds.c
+++ b/unit/test-dbus-message-fds.c
@@ -277,12 +277,13 @@ static void get_random_return_callback(struct l_dbus_=
message *message,
 	test_assert(fd0 !=3D -1);
 =

 	compare_files(fd0, fd1);
-	if (compare_failed)
-		return;
 =

 	close(fd0);
 	close(fd1);
 =

+	if (compare_failed)
+		return;
+
 	test_assert(l_idle_oneshot(get_random_idle_callback, NULL, NULL));
 }
 =

-- =

2.14.1


--===============3924973930622309565==--

