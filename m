Content-Type: multipart/mixed; boundary="===============3871684205706956149=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 09/14] dhcp: prepare for DHCP server
Date: Thu, 15 Oct 2020 10:17:26 -0700
Message-ID: <20201015171731.396538-9-prestwoj@gmail.com>
In-Reply-To: <20201015171731.396538-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3871684205706956149==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Some defines were moved out of dhcp.c and into dhcp-private.h
so server can utilize them.
---
 ell/dhcp-private.h | 14 ++++++++++++++
 ell/dhcp.c         | 14 --------------
 2 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/ell/dhcp-private.h b/ell/dhcp-private.h
index f6058fd..bca68d4 100644
--- a/ell/dhcp-private.h
+++ b/ell/dhcp-private.h
@@ -44,6 +44,8 @@ enum dhcp_op_code {
 	DHCP_OP_CODE_BOOTREPLY =3D 2,
 };
 =

+#define DHCP_MIN_OPTIONS_SIZE 312
+
 #define DHCP_MAGIC 0x63825363
 =

 /* RFC 2132, Section 9.6. DHCP Message Type */
@@ -51,6 +53,18 @@ enum dhcp_op_code {
 #define DHCP_OPTION_PAD 0 /* RFC 2132, Section 3.1 */
 #define DHCP_OPTION_END 255 /* RFC 2132, Section 3.2 */
 =

+/* RFC 2132, Section 9.3. Option Overload */
+#define DHCP_OPTION_OVERLOAD 52
+enum dhcp_option_overload {
+	DHCP_OVERLOAD_FILE =3D 1,
+	DHCP_OVERLOAD_SNAME =3D 2,
+	DHCP_OVERLOAD_BOTH =3D 3,
+};
+
+#define DHCP_OPTION_PARAMETER_REQUEST_LIST 55 /* Section 9.8 */
+#define DHCP_OPTION_MAXIMUM_MESSAGE_SIZE 57 /* Section 9.10 */
+#define DHCP_OPTION_CLIENT_IDENTIFIER 61 /* Section 9.14 */
+
 /* RFC 2131, Figure 1 */
 struct dhcp_message {
 	uint8_t op;
diff --git a/ell/dhcp.c b/ell/dhcp.c
index aa9fe0f..708c656 100644
--- a/ell/dhcp.c
+++ b/ell/dhcp.c
@@ -50,18 +50,6 @@
 =

 #define BITS_PER_LONG (sizeof(unsigned long) * 8)
 =

-/* RFC 2132, Section 9.3. Option Overload */
-#define DHCP_OPTION_OVERLOAD 52
-enum dhcp_option_overload {
-	DHCP_OVERLOAD_FILE =3D 1,
-	DHCP_OVERLOAD_SNAME =3D 2,
-	DHCP_OVERLOAD_BOTH =3D 3,
-};
-
-#define DHCP_OPTION_PARAMETER_REQUEST_LIST 55 /* Section 9.8 */
-#define DHCP_OPTION_MAXIMUM_MESSAGE_SIZE 57 /* Section 9.10 */
-#define DHCP_OPTION_CLIENT_IDENTIFIER 61 /* Section 9.14 */
-
 enum dhcp_state {
 	DHCP_STATE_INIT,
 	DHCP_STATE_SELECTING,
@@ -175,8 +163,6 @@ static inline int dhcp_message_optimize(struct dhcp_mes=
sage *message,
 	return len;
 }
 =

-#define DHCP_MIN_OPTIONS_SIZE 312
-
 struct l_dhcp_client {
 	enum dhcp_state state;
 	unsigned long request_options[256 / BITS_PER_LONG];
-- =

2.26.2

--===============3871684205706956149==--

