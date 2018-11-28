Content-Type: multipart/mixed; boundary="===============6329626591488341878=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 5/9] unit: Validate the peer_identity in test-tls
Date: Wed, 28 Nov 2018 03:38:31 +0100
Message-ID: <20181128023835.2081-5-andrew.zaborowski@intel.com>
In-Reply-To: <20181128023835.2081-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6329626591488341878==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-tls.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/unit/test-tls.c b/unit/test-tls.c
index 5103bef..e8c18f0 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -397,6 +397,9 @@ static void tls_test_ready(const char *peer_identity, v=
oid *user_data)
 	struct tls_test_state *s =3D user_data;
 =

 	assert(!s->ready);
+	assert((!s->expect_peer && !peer_identity) ||
+			(s->expect_peer && peer_identity &&
+			 !strcmp(s->expect_peer, peer_identity)));
 	s->ready =3D true;
 =

 	l_tls_write(s->tls, (const uint8_t *) s->send_data,
-- =

2.19.1


--===============6329626591488341878==--

