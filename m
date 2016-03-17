Content-Type: multipart/mixed; boundary="===============7250780816736393984=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH v3 5/5] unit: Add test-main check for self-removal
Date: Thu, 17 Mar 2016 11:15:42 -0700
Message-ID: <1458238542-11711-5-git-send-email-mathew.j.martineau@linux.intel.com>
In-Reply-To: <1458238542-11711-1-git-send-email-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7250780816736393984==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Call l_timeout_remove() within a handler for the same timeout.
---
 unit/test-main.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/unit/test-main.c b/unit/test-main.c
index 469d186..ee99a4b 100644
--- a/unit/test-main.c
+++ b/unit/test-main.c
@@ -74,12 +74,19 @@ static void race_handler(struct l_timeout *timeout, voi=
d *user_data)
 	*other_racer =3D NULL;
 }
 =

+static void remove_handler(struct l_timeout *timeout, void *user_data)
+{
+	l_timeout_remove(timeout);
+	l_info("Timer removed itself");
+}
+
 int main(int argc, char *argv[])
 {
 	struct l_timeout *timeout_quit;
 	struct l_timeout *race_delay;
 	struct l_timeout *race1;
 	struct l_timeout *race2;
+	struct l_timeout *remove_self;
 	struct l_signal *signal;
 	struct l_idle *idle;
 	sigset_t mask;
@@ -98,6 +105,8 @@ int main(int argc, char *argv[])
 	race2 =3D l_timeout_create_with_nanoseconds(1, 100000000, race_handler,
 						  &race1, NULL);
 =

+	remove_self =3D l_timeout_create(2, remove_handler, &remove_self, NULL);
+
 	idle =3D l_idle_create(idle_handler, NULL, NULL);
 =

 	l_log_set_stderr();
-- =

2.7.3


--===============7250780816736393984==--

