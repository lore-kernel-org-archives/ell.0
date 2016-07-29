Content-Type: multipart/mixed; boundary="===============2019819095471429824=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH v2 3/7] key: Rename l_key_get_payload_size to clarify its
 purpose
Date: Fri, 29 Jul 2016 11:11:57 -0700
Message-ID: <20160729181201.16446-3-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20160729181201.16446-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2019819095471429824==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The size returned is the number of bytes needed to store the payload.
---
 ell/key.c | 2 +-
 ell/key.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/ell/key.c b/ell/key.c
index a8d011a..8e7b398 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -216,7 +216,7 @@ LIB_EXPORT bool l_key_extract(struct l_key *key, void *=
payload, size_t *len)
 	return true;
 }
 =

-LIB_EXPORT ssize_t l_key_get_size(struct l_key *key)
+LIB_EXPORT ssize_t l_key_get_payload_size(struct l_key *key)
 {
 	return kernel_read_key(key->serial, NULL, 0);
 }
diff --git a/ell/key.h b/ell/key.h
index 5d981f1..4ec32a6 100644
--- a/ell/key.h
+++ b/ell/key.h
@@ -52,7 +52,7 @@ bool l_key_update(struct l_key *key, const void *payload,=
 size_t len);
 =

 bool l_key_extract(struct l_key *key, void *payload, size_t *len);
 =

-ssize_t l_key_get_size(struct l_key *key);
+ssize_t l_key_get_payload_size(struct l_key *key);
 =

 bool l_key_compute_dh_public(struct l_key *generator, struct l_key *privat=
e,
 			     struct l_key *prime, void *payload, size_t *len);
-- =

2.9.2


--===============2019819095471429824==--

