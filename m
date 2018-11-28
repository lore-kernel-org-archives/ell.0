Content-Type: multipart/mixed; boundary="===============2997701568660103984=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 9/9] tools: Update certchain-verify to new l_certchain_verify
 params
Date: Wed, 28 Nov 2018 03:38:35 +0100
Message-ID: <20181128023835.2081-9-andrew.zaborowski@intel.com>
In-Reply-To: <20181128023835.2081-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2997701568660103984==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 tools/certchain-verify.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/tools/certchain-verify.c b/tools/certchain-verify.c
index 08eec90..1a1dab1 100644
--- a/tools/certchain-verify.c
+++ b/tools/certchain-verify.c
@@ -98,6 +98,7 @@ int main(int argc, char *argv[])
 	struct l_certchain *certchain;
 	struct l_queue *ca_certs;
 	int err;
+	const char *error_str;
 =

 	if (argc !=3D 3) {
 		usage(argv[0]);
@@ -122,8 +123,8 @@ int main(int argc, char *argv[])
 		goto free_certchain;
 	}
 =

-	if (!l_certchain_verify(certchain, ca_certs)) {
-		fprintf(stderr, "Verification failed\n");
+	if (!l_certchain_verify(certchain, ca_certs, &error_str)) {
+		fprintf(stderr, "Verification failed: %s\n", error_str);
 		goto free_cacert;
 	}
 =

-- =

2.19.1


--===============2997701568660103984==--

