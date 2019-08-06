Content-Type: multipart/mixed; boundary="===============5474407607270945404=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH] dhcp-transport: fix out-of-bounds access
Date: Tue, 06 Aug 2019 16:08:49 -0400
Message-ID: <20190806200849.2988-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5474407607270945404==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

If len was odd the iovec was getting accessed out of bounds. 'j' needed
to be decremented after the for loop. In addition, the iov_len was not
being used to access the last byte of iov_base.
---
 ell/dhcp-transport.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/ell/dhcp-transport.c b/ell/dhcp-transport.c
index b43dfbd..56db9dd 100644
--- a/ell/dhcp-transport.c
+++ b/ell/dhcp-transport.c
@@ -78,9 +78,11 @@ uint16_t _dhcp_checksumv(const struct iovec *iov, size_t=
 iov_cnt)
 			sum +=3D check[i];
 	}
 =

+	j--;
+
 	if (len & 0x01) {
 		const uint8_t *odd =3D iov[j].iov_base;
-		sum +=3D odd[len - 1];
+		sum +=3D odd[iov[j].iov_len - 1];
 	}
 =

 	while (sum >> 16)
-- =

2.21.0


--===============5474407607270945404==--

