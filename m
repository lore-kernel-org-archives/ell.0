Content-Type: multipart/mixed; boundary="===============6868511449719469939=="
MIME-Version: 1.0
From: Inga Stotland <inga.stotland@intel.com>
Subject: [PATCH] main: Add handler for SIGSEGV signal
Date: Mon, 25 Jan 2021 14:31:55 -0800
Message-ID: <20210125223155.10508-1-inga.stotland@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6868511449719469939==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

When an ell main loop based process is spun off as a child
and the parent process dies due to a segfault, the child process
is still left running and needs to detect the segfault condition.
To address this need, add watch and signal handler for SIGSEGV.
---
 ell/main.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/ell/main.c b/ell/main.c
index a479b74..712cfb7 100644
--- a/ell/main.c
+++ b/ell/main.c
@@ -619,6 +619,14 @@ static void sigterm_handler(void *user_data)
 		data->callback(SIGTERM, data->user_data);
 }
 =

+static void sigsegv_handler(void *user_data)
+{
+	struct signal_data *data =3D user_data;
+
+	if (data->callback)
+		data->callback(SIGSEGV, data->user_data);
+}
+
 /**
  * l_main_run_with_signal:
  *
@@ -633,6 +641,7 @@ LIB_EXPORT int l_main_run_with_signal(l_main_signal_cb_=
t callback,
 	struct signal_data *data;
 	struct l_signal *sigint;
 	struct l_signal *sigterm;
+	struct l_signal *sigsegv;
 	int result;
 =

 	data =3D l_new(struct signal_data, 1);
@@ -642,11 +651,13 @@ LIB_EXPORT int l_main_run_with_signal(l_main_signal_c=
b_t callback,
 =

 	sigint =3D l_signal_create(SIGINT, sigint_handler, data, NULL);
 	sigterm =3D l_signal_create(SIGTERM, sigterm_handler, data, NULL);
+	sigsegv =3D l_signal_create(SIGSEGV, sigsegv_handler, data, NULL);
 =

 	result =3D l_main_run();
 =

 	l_signal_remove(sigint);
 	l_signal_remove(sigterm);
+	l_signal_remove(sigsegv);
 =

 	l_free(data);
 =

-- =

2.26.2

--===============6868511449719469939==--

