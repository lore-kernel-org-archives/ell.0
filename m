Content-Type: multipart/mixed; boundary="===============0657028511032069958=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 3/3] unit: free cli_addr at end of test
Date: Mon, 08 Feb 2021 11:27:56 -0800
Message-ID: <20210208192756.580521-3-prestwoj@gmail.com>
In-Reply-To: <20210208192756.580521-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0657028511032069958==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-dhcp.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/unit/test-dhcp.c b/unit/test-dhcp.c
index ad06c14..d67b1b5 100644
--- a/unit/test-dhcp.c
+++ b/unit/test-dhcp.c
@@ -1001,6 +1001,7 @@ static void test_expired_ip_reuse(const void *data)
 	assert(lease);
 	cli_addr =3D l_dhcp_lease_get_address(lease);
 	assert(!strcmp(cli_addr, "192.168.1.2"));
+	l_free(cli_addr);
 }
 =

 int main(int argc, char *argv[])
-- =

2.26.2

--===============0657028511032069958==--

