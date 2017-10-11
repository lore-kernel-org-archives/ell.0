Content-Type: multipart/mixed; boundary="===============7477653053168649507=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 1/2] genl: Make iovec parameter const
Date: Wed, 11 Oct 2017 15:12:38 -0700
Message-ID: <20171011221239.8656-2-ossama.othman@intel.com>
In-Reply-To: <20171011221239.8656-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7477653053168649507==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Make the iovec parameter of l_genl_msg_append_attrv() const since it
isn't modified by the function.  This allows a pointer to a const
struct iovec to be passed as an argument without casting away the
const.
---
 ell/genl.c | 3 ++-
 ell/genl.h | 2 +-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/ell/genl.c b/ell/genl.c
index aa6266f..c04a47f 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -797,7 +797,8 @@ LIB_EXPORT bool l_genl_msg_append_attr(struct l_genl_ms=
g *msg, uint16_t type,
 }
 =

 LIB_EXPORT bool l_genl_msg_append_attrv(struct l_genl_msg *msg, uint16_t t=
ype,
-					struct iovec *iov, size_t iov_len)
+					const struct iovec *iov,
+					size_t iov_len)
 {
 	struct nlattr *nla;
 	size_t len =3D 0;
diff --git a/ell/genl.h b/ell/genl.h
index 8597c8f..bddf1d4 100644
--- a/ell/genl.h
+++ b/ell/genl.h
@@ -72,7 +72,7 @@ int l_genl_msg_get_error(struct l_genl_msg *msg);
 bool l_genl_msg_append_attr(struct l_genl_msg *msg, uint16_t type,
 					uint16_t len, const void *data);
 bool l_genl_msg_append_attrv(struct l_genl_msg *msg, uint16_t type,
-					struct iovec *iov, size_t iov_len);
+				const struct iovec *iov, size_t iov_len);
 bool l_genl_msg_enter_nested(struct l_genl_msg *msg, uint16_t type);
 bool l_genl_msg_leave_nested(struct l_genl_msg *msg);
 =

-- =

2.11.0


--===============7477653053168649507==--

