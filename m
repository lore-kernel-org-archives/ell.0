Content-Type: multipart/mixed; boundary="===============1629254867532790993=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/4] tls: Fix error check typo
Date: Thu, 17 Jan 2019 18:19:14 +0100
Message-ID: <20190117171916.27960-2-andrew.zaborowski@intel.com>
In-Reply-To: <20190117171916.27960-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1629254867532790993==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/tls-suites.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/tls-suites.c b/ell/tls-suites.c
index d99f08b..1c3976e 100644
--- a/ell/tls-suites.c
+++ b/ell/tls-suites.c
@@ -1063,7 +1063,7 @@ static void tls_handle_dhe_client_key_xchg(struct l_t=
ls *tls,
 	}
 =

 	params->public =3D l_key_new(L_KEY_RAW, buf, public_len);
-	if (!params->prime) {
+	if (!params->public) {
 		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0, "l_key_new failed");
 		return;
 	}
-- =

2.19.1


--===============1629254867532790993==--

