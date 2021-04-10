Content-Type: multipart/mixed; boundary="===============5756727600314261738=="
MIME-Version: 1.0
From: Inga Stotland <inga.stotland@intel.com>
Subject: [PATCH] tester: Fix test timeout data
Date: Fri, 09 Apr 2021 20:26:55 -0700
Message-ID: <20210410032655.57982-1-inga.stotland@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5756727600314261738==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

When advancing to a next test case, create test timeout with the tester
instance as user data.

Also, remove stray debug printfs.
---
 ell/tester.c | 9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

diff --git a/ell/tester.c b/ell/tester.c
index eedd66b..54fbb4b 100644
--- a/ell/tester.c
+++ b/ell/tester.c
@@ -131,18 +131,11 @@ static void teardown_callback(void *user_data)
 	struct l_tester *tester =3D user_data;
 	struct test_case *test;
 =

-	printf("teardown %p\n", tester->test_entry);
-
 	test =3D tester->test_entry->data;
-	printf("teardown data %p\n", tester->test_entry->data);
 	test->stage =3D L_TESTER_STAGE_TEARDOWN;
 	test->teardown =3D false;
 =

-	printf("Test name %p\n", test->name);
-	printf("Test name %s\n", test->name);
 	print_progress(test->name, COLOR_MAGENTA, "teardown");
-	printf("teardown\n");
-
 =

 	if (test->teardown_func)
 		test->teardown_func(test->test_data);
@@ -189,7 +182,7 @@ static void next_test_case(struct l_tester *tester)
 =

 	if (test->timeout > 0)
 		test->run_timer =3D l_timeout_create(test->timeout, test_timeout,
-								test, NULL);
+								tester, NULL);
 =

 	test->stage =3D L_TESTER_STAGE_PRE_SETUP;
 =

-- =

2.26.3

--===============5756727600314261738==--

