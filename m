Content-Type: multipart/mixed; boundary="===============1756293740560867595=="
MIME-Version: 1.0
From: Inga Stotland <inga.stotland@intel.com>
Subject: [PATCH] tester: Remove timeout if pre-setup failed
Date: Fri, 23 Apr 2021 11:26:56 -0700
Message-ID: <20210423182656.97424-1-inga.stotland@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1756293740560867595==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

If test pre setup stage fails, remove test run timeout.
Also, fix a stray call to free(): should be l_free().
---
 ell/tester.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/ell/tester.c b/ell/tester.c
index 54fbb4b..7625b93 100644
--- a/ell/tester.c
+++ b/ell/tester.c
@@ -279,6 +279,9 @@ LIB_EXPORT void l_tester_pre_setup_failed(struct l_test=
er *tester)
 =

 	print_progress(test->name, COLOR_RED, "pre setup failed");
 =

+	l_timeout_remove(test->run_timer);
+	test->run_timer =3D NULL;
+
 	l_idle_oneshot(done_callback, tester, NULL);
 }
 =

@@ -501,7 +504,7 @@ static void wait_callback(struct l_timeout *timer, void=
 *user_data)
 =

 	wait->func(wait->user_data);
 =

-	free(wait);
+	l_free(wait);
 =

 	l_timeout_remove(timer);
 }
-- =

2.26.3

--===============1756293740560867595==--

