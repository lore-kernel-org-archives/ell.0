Content-Type: multipart/mixed; boundary="===============8456600297220583934=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] genl: Handle empty data in l_genl_msg_append_attr
Date: Tue, 15 Jan 2019 07:21:25 +0100
Message-ID: <20190115062125.5202-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8456600297220583934==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Make sure l_genl_msg_append_attr can be called with a NULL @data (when
@len is 0) for attributes like nl80211 flags, without triggering an asan
warning about the memcpy parameter being NULL.
---
 ell/genl.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/ell/genl.c b/ell/genl.c
index 32f54bc..2905a5e 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -790,7 +790,9 @@ LIB_EXPORT bool l_genl_msg_append_attr(struct l_genl_ms=
g *msg, uint16_t type,
 	nla->nla_len =3D NLA_HDRLEN + len;
 	nla->nla_type =3D type;
 =

-	memcpy(msg->data + msg->len + NLA_HDRLEN, data, len);
+	if (len)
+		memcpy(msg->data + msg->len + NLA_HDRLEN, data, len);
+
 	msg->len +=3D NLA_HDRLEN + NLA_ALIGN(len);
 =

 	return true;
-- =

2.19.1


--===============8456600297220583934==--

