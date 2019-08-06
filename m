Content-Type: multipart/mixed; boundary="===============4017608574777573342=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/4] tls: Make l_tls_free reentrant
Date: Tue, 06 Aug 2019 15:45:13 +0200
Message-ID: <20190806134514.6340-3-andrew.zaborowski@intel.com>
In-Reply-To: <20190806134514.6340-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4017608574777573342==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Handle l_tls_free being called from inside user callbacks that our code
may have called.  Use flags because in this case it's not possible to
move all of the callbacks to the end of our functions.
---
 ell/tls-private.h |  3 +++
 ell/tls.c         | 19 +++++++++++++++++++
 2 files changed, 22 insertions(+)

diff --git a/ell/tls-private.h b/ell/tls-private.h
index bf9e2ec..c1de257 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -215,6 +215,9 @@ struct l_tls {
 =

 	struct tls_cipher_suite **cipher_suite_pref_list;
 =

+	bool in_callback;
+	bool pending_destroy;
+
 	/* Record layer */
 =

 	uint8_t *record_buf;
diff --git a/ell/tls.c b/ell/tls.c
index c3591a8..4b23076 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -2098,7 +2098,9 @@ static void tls_finished(struct l_tls *tls)
 	TLS_SET_STATE(TLS_HANDSHAKE_DONE);
 	tls->ready =3D true;
 =

+	tls->in_callback =3D true;
 	tls->ready_handle(peer_identity, tls->user_data);
+	tls->in_callback =3D false;
 	l_free(peer_identity);
 =

 	tls_cleanup_handshake(tls);
@@ -2389,6 +2391,11 @@ LIB_EXPORT void l_tls_free(struct l_tls *tls)
 	if (unlikely(!tls))
 		return;
 =

+	if (tls->in_callback) {
+		tls->pending_destroy =3D true;
+		return;
+	}
+
 	l_tls_set_cacert(tls, NULL);
 	l_tls_set_auth_data(tls, NULL, NULL, NULL);
 =

@@ -2537,6 +2544,11 @@ bool tls_handle_message(struct l_tls *tls, const uin=
t8_t *message,
 					message + TLS_HANDSHAKE_HEADER_SIZE,
 					len - TLS_HANDSHAKE_HEADER_SIZE);
 =

+		if (tls->pending_destroy) {
+			l_tls_free(tls);
+			return false;
+		}
+
 		return true;
 =

 	case TLS_CT_APPLICATION_DATA:
@@ -2551,7 +2563,14 @@ bool tls_handle_message(struct l_tls *tls, const uin=
t8_t *message,
 		if (!len)
 			return true;
 =

+		tls->in_callback =3D true;
 		tls->rx(message, len, tls->user_data);
+		tls->in_callback =3D false;
+
+		if (tls->pending_destroy) {
+			l_tls_free(tls);
+			return false;
+		}
 =

 		return true;
 	}
-- =

2.20.1


--===============4017608574777573342==--

