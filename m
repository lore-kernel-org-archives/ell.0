Content-Type: multipart/mixed; boundary="===============2582791318650824501=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 4/4] examples: POSIX spec requires zeroing sockaddr_in
Date: Wed, 27 Sep 2017 17:22:05 -0700
Message-ID: <20170928002205.17218-4-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20170928002205.17218-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2582791318650824501==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 examples/https-client-test.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/examples/https-client-test.c b/examples/https-client-test.c
index 7a9c2a8..7135346 100644
--- a/examples/https-client-test.c
+++ b/examples/https-client-test.c
@@ -152,6 +152,7 @@ int main(int argc, char *argv[])
 		return -1;
 	}
 =

+	memset(&addr, 0, sizeof(addr));
 	addr.sin_family =3D AF_INET;
 	addr.sin_port =3D htons(443);
 	memcpy(&addr.sin_addr, addr_list[0], sizeof(addr.sin_addr));
-- =

2.14.1


--===============2582791318650824501==--

