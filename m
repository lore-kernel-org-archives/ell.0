Content-Type: multipart/mixed; boundary="===============6772341690616902130=="
MIME-Version: 1.0
From: =?unknown-8bit?q?Micha=C5=82?= Lowas-Rzechonek <michal.lowas-rzechonek@silvair.com>
Subject: [PATCH v2] util: Make l_container_of macro public
Date: Tue, 02 Apr 2019 18:36:11 +0200
Message-ID: <20190402163611.14690-1-michal.lowas-rzechonek@silvair.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6772341690616902130==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The macro is useful when e.g. scheduling timeouts, where l_timeout
passed to l_timeout_notify_cb_t is a member of a larger object, and we
would like to access this object while passing something else as
user_data.
---
 ell/dbus.c             | 8 ++++----
 ell/dhcp-transport.c   | 6 +++---
 ell/private.h          | 4 ----
 ell/util.h             | 5 +++++
 unit/test-dbus-watch.c | 4 ++--
 5 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/ell/dbus.c b/ell/dbus.c
index 92be396..3a84c90 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -579,7 +579,7 @@ static void dbus_init(struct l_dbus *dbus, int fd)
 static void classic_free(struct l_dbus *dbus)
 {
 	struct l_dbus_classic *classic =3D
-		container_of(dbus, struct l_dbus_classic, super);
+		l_container_of(dbus, struct l_dbus_classic, super);
 	unsigned int i;
 =

 	for (i =3D 0; i < classic->num_fds; i++)
@@ -658,7 +658,7 @@ static bool classic_send_message(struct l_dbus *dbus,
 static struct l_dbus_message *classic_recv_message(struct l_dbus *dbus)
 {
 	struct l_dbus_classic *classic =3D
-		container_of(dbus, struct l_dbus_classic, super);
+		l_container_of(dbus, struct l_dbus_classic, super);
 	int fd =3D l_io_get_fd(dbus->io);
 	struct dbus_header hdr;
 	struct msghdr msg;
@@ -809,7 +809,7 @@ static bool classic_add_match(struct l_dbus *dbus, unsi=
gned int id,
 				int rule_len)
 {
 	struct l_dbus_classic *classic =3D
-		container_of(dbus, struct l_dbus_classic, super);
+		l_container_of(dbus, struct l_dbus_classic, super);
 	char *match_str;
 	struct l_dbus_message *message;
 =

@@ -833,7 +833,7 @@ static bool classic_add_match(struct l_dbus *dbus, unsi=
gned int id,
 static bool classic_remove_match(struct l_dbus *dbus, unsigned int id)
 {
 	struct l_dbus_classic *classic =3D
-		container_of(dbus, struct l_dbus_classic, super);
+		l_container_of(dbus, struct l_dbus_classic, super);
 	char *match_str =3D l_hashmap_remove(classic->match_strings,
 						L_UINT_TO_PTR(id));
 	struct l_dbus_message *message;
diff --git a/ell/dhcp-transport.c b/ell/dhcp-transport.c
index 1de190a..758af10 100644
--- a/ell/dhcp-transport.c
+++ b/ell/dhcp-transport.c
@@ -148,7 +148,7 @@ static int _dhcp_default_transport_open(struct dhcp_tra=
nsport *s,
 					uint32_t port)
 {
 	struct dhcp_default_transport *transport =3D
-		container_of(s, struct dhcp_default_transport, super);
+		l_container_of(s, struct dhcp_default_transport, super);
 	int fd;
 =

 	if (transport->io)
@@ -263,7 +263,7 @@ static int _dhcp_default_transport_send(struct dhcp_tra=
nsport *s,
 					const void *data, size_t len)
 {
 	struct dhcp_default_transport *transport =3D
-		container_of(s, struct dhcp_default_transport, super);
+		l_container_of(s, struct dhcp_default_transport, super);
 	int fd =3D l_io_get_fd(transport->io);
 	int err;
 =

@@ -279,7 +279,7 @@ static int _dhcp_default_transport_send(struct dhcp_tra=
nsport *s,
 static void _dhcp_default_transport_close(struct dhcp_transport *s)
 {
 	struct dhcp_default_transport *transport =3D
-		container_of(s, struct dhcp_default_transport, super);
+		l_container_of(s, struct dhcp_default_transport, super);
 =

 	l_io_destroy(transport->io);
 	transport->io =3D NULL;
diff --git a/ell/private.h b/ell/private.h
index f132577..b0ae43f 100644
--- a/ell/private.h
+++ b/ell/private.h
@@ -27,10 +27,6 @@
 =

 #define uninitialized_var(x) x =3D x
 =

-#define container_of(ptr, type, member) ({			\
-	const __typeof__( ((type *)0)->member ) *__mptr =3D (ptr);	\
-	(type *)( (char *)__mptr - offsetof(type,member) );})
-
 #define align_len(len, boundary) (((len)+(boundary)-1) & ~((boundary)-1))
 =

 #define LIB_EXPORT __attribute__ ((visibility("default")))
diff --git a/ell/util.h b/ell/util.h
index c4ba7f8..95503de 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -35,6 +35,11 @@
 extern "C" {
 #endif
 =

+#define l_container_of(ptr, type, member) ({					\
+		const typeof( ((type *)0)->member ) *__mptr =3D (ptr);	\
+		(type *)( (char *)__mptr - offsetof(type,member) );		\
+	})
+
 #define likely(x)   __builtin_expect(!!(x), 1)
 #define unlikely(x) __builtin_expect(!!(x), 0)
 =

diff --git a/unit/test-dbus-watch.c b/unit/test-dbus-watch.c
index c6e4a92..029d71c 100644
--- a/unit/test-dbus-watch.c
+++ b/unit/test-dbus-watch.c
@@ -108,7 +108,7 @@ static bool test_add_match(struct l_dbus *dbus, unsigne=
d int id,
 				int rule_len)
 {
 	struct filter_test_state *test =3D
-		container_of(dbus, struct filter_test_state, dbus);
+		l_container_of(dbus, struct filter_test_state, dbus);
 =

 	assert(test->expected_rule);
 =

@@ -124,7 +124,7 @@ static bool test_add_match(struct l_dbus *dbus, unsigne=
d int id,
 static bool test_remove_match(struct l_dbus *dbus, unsigned int id)
 {
 	struct filter_test_state *test =3D
-		container_of(dbus, struct filter_test_state, dbus);
+		l_container_of(dbus, struct filter_test_state, dbus);
 =

 	assert(test->expected_id =3D=3D id && id);
 =

-- =

2.20.1


--===============6772341690616902130==--

