Content-Type: multipart/mixed; boundary="===============2512407711121808335=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/2] unit: Make fswatch test pass with new event type
Date: Thu, 09 Aug 2018 16:28:52 +0200
Message-ID: <20180809142852.17764-2-andrew.zaborowski@intel.com>
In-Reply-To: <20180809142852.17764-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2512407711121808335==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Ignore the L_FSWATCH_EVENT_ATTRIB event seen for files being unlinked
that precedes the L_FSWATCH_EVENT_DELETE.
---
 unit/test-fswatch.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/unit/test-fswatch.c b/unit/test-fswatch.c
index d8b5f7b..a616495 100644
--- a/unit/test-fswatch.c
+++ b/unit/test-fswatch.c
@@ -140,9 +140,13 @@ static void file_watch_cb(struct l_fswatch *watch, con=
st char *filename,
 		test_file_modify_check();
 		break;
 	case TEST_FILE_REMOVE:
-		assert(event =3D=3D L_FSWATCH_EVENT_DELETE);
+		assert(event =3D=3D L_FSWATCH_EVENT_DELETE ||
+				event =3D=3D L_FSWATCH_EVENT_ATTRIB);
 		assert(!(substate & TEST_FILE_REMOVE_FILE_EVENT));
 =

+		if (event =3D=3D L_FSWATCH_EVENT_ATTRIB)
+			break;
+
 		substate |=3D TEST_FILE_REMOVE_FILE_EVENT;
 =

 		test_file_remove_check();
-- =

2.14.1


--===============2512407711121808335==--

