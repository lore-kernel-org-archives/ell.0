Content-Type: multipart/mixed; boundary="===============6884295656315843857=="
MIME-Version: 1.0
From: Inga Stotland <inga.stotland@intel.com>
Subject: [PATCH] build: Fix exported symbols (tester)
Date: Tue, 06 Apr 2021 15:53:33 -0700
Message-ID: <20210406225333.250597-1-inga.stotland@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6884295656315843857==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/ell.sym | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/ell/ell.sym b/ell/ell.sym
index 606513c..229a2a6 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -670,9 +670,9 @@ global:
 	l_tester_destroy;
 	l_tester_start;
 	l_tester_summarize;
-	l_tester_test_add;
-	l_tester_test_add_full;
-	l_tester_test_get_stage;
+	l_tester_add;
+	l_tester_add_full;
+	l_tester_get_stage;
 	l_tester_get_data;
 	l_tester_pre_setup_complete;
 	l_tester_pre_setup_failed;
-- =

2.26.3

--===============6884295656315843857==--

