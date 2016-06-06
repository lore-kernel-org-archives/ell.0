Content-Type: multipart/mixed; boundary="===============0862409329911890231=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 02/11] main: Fix comment typo
Date: Mon, 06 Jun 2016 13:54:41 -0700
Message-ID: <20160606205450.23615-2-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20160606205450.23615-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0862409329911890231==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/main.c b/ell/main.c
index 46e929a..f53ed9e 100644
--- a/ell/main.c
+++ b/ell/main.c
@@ -444,7 +444,7 @@ static void signal_handler(struct l_signal *signal, uin=
t32_t signo,
  *
  * Run the main loop with signal handling for SIGINT and SIGTERM
  *
- * Returns: #EXIT_SCUCESS after successful execution or #EXIT_FAILURE in
+ * Returns: #EXIT_SUCCESS after successful execution or #EXIT_FAILURE in
  *          case of failure
  **/
 LIB_EXPORT
-- =

2.8.3


--===============0862409329911890231==--

