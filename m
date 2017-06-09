Content-Type: multipart/mixed; boundary="===============8054860594303186277=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH] unit: Add DH test case where results have leading zeros
Date: Fri, 09 Jun 2017 15:25:29 -0700
Message-ID: <20170609222529.12727-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8054860594303186277==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-key.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/unit/test-key.c b/unit/test-key.c
index 067f016..7513b38 100644
--- a/unit/test-key.c
+++ b/unit/test-key.c
@@ -210,6 +210,24 @@ static const struct dh_test_vector dh_valid2 =3D {
 	"d6aab69ab7f1992a9164b93aca29a8348a1ef883a3045f00f9b9ce0e05647502",
 };
 =

+static const struct dh_test_vector dh_degenerate =3D {
+	.prime =3D
+	"dc53dfa73a49a384f603173c93c17a59baa4c18bf0305e587ded5c8c56f6e44c"
+	"645ba8a2eb26c87a9e2be8b28d407eb7a82be004bfbe4ff097ba97b2b4dc980f"
+	"349b75540c71120b49c279be3a610414ae984a781382ded04e64cd26dca3cb4e"
+	"cf8866db23af4c12db308148f281bbe0953165e0fe58fd6c806ace0152190018"
+	"6d0c0b4a3d636bb834bab9218441fb3117814621d5bf4558dfcca4cb8e1e680b"
+	"df525760a2cf79352114cd913c64d1b56836be86b2059aca3d4fc18818dab52c"
+	"f0031bab41b75f2b27519cc39fd557ba88f6765cd380ace9e7f2ceb9077b6b51"
+	"09ce7d4deffb0767717e9a475a5a7ef313daf79dd4026c114df248660de436c7",
+	.generator =3D "01",
+	.priv1 =3D "01",
+	.pub1 =3D "01",
+	.priv2 =3D "01",
+	.pub2 =3D "01",
+	.secret =3D "01",
+};
+
 struct testkey {
 	struct l_key *key;
 	uint8_t *bytes;
@@ -661,6 +679,7 @@ int main(int argc, char *argv[])
 =

 	l_test_add("Diffie-Hellman 1", test_dh, &dh_valid1);
 	l_test_add("Diffie-Hellman 2", test_dh, &dh_valid2);
+	l_test_add("Diffie-Hellman 3", test_dh, &dh_degenerate);
 =

 	l_test_add("simple keyring", test_simple_keyring, NULL);
 	l_test_add("trusted keyring", test_trusted_keyring, NULL);
-- =

2.13.1


--===============8054860594303186277==--

