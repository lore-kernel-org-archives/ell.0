Content-Type: multipart/mixed; boundary="===============1984601843255798963=="
MIME-Version: 1.0
From: Tim Kourt <tim.a.kourt@linux.intel.com>
Subject: [PATCH 2/3] examples: add more_tofollow flag into TLS examples
Date: Fri, 26 Jan 2018 09:57:41 -0800
Message-ID: <20180126175742.11881-2-tim.a.kourt@linux.intel.com>
In-Reply-To: <20180126175742.11881-1-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1984601843255798963==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 examples/https-client-test.c | 6 ++++--
 examples/https-server-test.c | 6 ++++--
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/examples/https-client-test.c b/examples/https-client-test.c
index 7135346..3fef679 100644
--- a/examples/https-client-test.c
+++ b/examples/https-client-test.c
@@ -66,7 +66,8 @@ static void https_tls_disconnected(enum l_tls_alert_desc =
reason, bool remote,
 	l_main_quit();
 }
 =

-static void https_new_data(const uint8_t *data, size_t len, void *user_dat=
a)
+static void https_new_data(const uint8_t *data, size_t len,
+					bool more_tofollow, void *user_data)
 {
 	int r;
 =

@@ -81,7 +82,8 @@ static void https_new_data(const uint8_t *data, size_t le=
n, void *user_data)
 	}
 }
 =

-static void https_tls_write(const uint8_t *data, size_t len, void *user_da=
ta)
+static void https_tls_write(const uint8_t *data, size_t len,
+					bool more_tofollow, void *user_data)
 {
 	int r;
 =

diff --git a/examples/https-server-test.c b/examples/https-server-test.c
index 2539277..f534078 100644
--- a/examples/https-server-test.c
+++ b/examples/https-server-test.c
@@ -68,7 +68,8 @@ static void https_tls_disconnected(enum l_tls_alert_desc =
reason, bool remote,
 	l_main_quit();
 }
 =

-static void https_new_data(const uint8_t *data, size_t len, void *user_dat=
a)
+static void https_new_data(const uint8_t *data, size_t len,
+					bool more_tofollow, void *user_data)
 {
 	char *reply =3D "HTTP/1.1 200 OK\r\n"
 		"Content-Type: text/plain\r\n"
@@ -84,7 +85,8 @@ static void https_new_data(const uint8_t *data, size_t le=
n, void *user_data)
 	}
 }
 =

-static void https_tls_write(const uint8_t *data, size_t len, void *user_da=
ta)
+static void https_tls_write(const uint8_t *data, size_t len,
+					bool more_tofollow, void *user_data)
 {
 	int r;
 =

-- =

2.9.4


--===============1984601843255798963==--

