Content-Type: multipart/mixed; boundary="===============8491033542405545097=="
MIME-Version: 1.0
From: Florian Klink <flokli@flokli.de>
Subject: [PATCH] unit/test-dbus: pick up dbus-daemon from $PATH
Date: Sun, 27 Dec 2020 13:16:20 +0100
Message-ID: <20201227121620.30667-1-flokli@flokli.de>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8491033542405545097==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This allows running the unit tests in environments where `dbus-daemon`
isn't in /usr/bin, but in $PATH.

Signed-off-by: Florian Klink <flokli@flokli.de>
---
 unit/test-dbus-message-fds.c | 4 ++--
 unit/test-dbus-properties.c  | 4 ++--
 unit/test-dbus.c             | 4 ++--
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/unit/test-dbus-message-fds.c b/unit/test-dbus-message-fds.c
index 6f68bae..4b5662e 100644
--- a/unit/test-dbus-message-fds.c
+++ b/unit/test-dbus-message-fds.c
@@ -51,7 +51,7 @@ static bool start_dbus_daemon(void)
 	char *prg_envp[1];
 	pid_t pid;
 =

-	prg_argv[0] =3D "/usr/bin/dbus-daemon";
+	prg_argv[0] =3D "dbus-daemon";
 	prg_argv[1] =3D "--nopidfile";
 	prg_argv[2] =3D "--nofork";
 	prg_argv[3] =3D "--config-file=3D" UNITDIR "dbus.conf";
@@ -68,7 +68,7 @@ static bool start_dbus_daemon(void)
 	}
 =

 	if (pid =3D=3D 0) {
-		execve(prg_argv[0], prg_argv, prg_envp);
+		execvpe(prg_argv[0], prg_argv, prg_envp);
 		exit(EXIT_SUCCESS);
 	}
 =

diff --git a/unit/test-dbus-properties.c b/unit/test-dbus-properties.c
index b435062..049f0f4 100644
--- a/unit/test-dbus-properties.c
+++ b/unit/test-dbus-properties.c
@@ -49,7 +49,7 @@ static bool start_dbus_daemon(void)
 	char *prg_envp[1];
 	pid_t pid;
 =

-	prg_argv[0] =3D "/usr/bin/dbus-daemon";
+	prg_argv[0] =3D "dbus-daemon";
 	prg_argv[1] =3D "--nopidfile";
 	prg_argv[2] =3D "--nofork";
 	prg_argv[3] =3D "--config-file=3D" UNITDIR "dbus.conf";
@@ -66,7 +66,7 @@ static bool start_dbus_daemon(void)
 	}
 =

 	if (pid =3D=3D 0) {
-		execve(prg_argv[0], prg_argv, prg_envp);
+		execvpe(prg_argv[0], prg_argv, prg_envp);
 		exit(EXIT_SUCCESS);
 	}
 =

diff --git a/unit/test-dbus.c b/unit/test-dbus.c
index 67f0a7b..582847e 100644
--- a/unit/test-dbus.c
+++ b/unit/test-dbus.c
@@ -45,7 +45,7 @@ static void start_dbus_daemon(void)
 	char *prg_envp[1];
 	pid_t pid;
 =

-	prg_argv[0] =3D "/usr/bin/dbus-daemon";
+	prg_argv[0] =3D "dbus-daemon";
 	prg_argv[1] =3D "--nopidfile";
 	prg_argv[2] =3D "--nofork";
 	prg_argv[3] =3D "--config-file=3D" UNITDIR "dbus.conf";
@@ -62,7 +62,7 @@ static void start_dbus_daemon(void)
 	}
 =

 	if (pid =3D=3D 0) {
-		execve(prg_argv[0], prg_argv, prg_envp);
+		execvpe(prg_argv[0], prg_argv, prg_envp);
 		exit(EXIT_SUCCESS);
 	}
 =

-- =

2.29.2

--===============8491033542405545097==--

