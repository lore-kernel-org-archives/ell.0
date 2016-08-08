Content-Type: multipart/mixed; boundary="===============0424350093200098856=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH v2 4/6] unit: Generate and use PKCS8 version of server key for
 TLS tests
Date: Mon, 08 Aug 2016 10:25:43 -0700
Message-ID: <20160808172545.6648-4-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20160808172545.6648-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0424350093200098856==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/cert-server-key-pkcs8.pem | 28 ++++++++++++++++++++++++++++
 unit/gencerts.sh               |  1 +
 unit/test-tls.c                | 16 ++++++++--------
 3 files changed, 37 insertions(+), 8 deletions(-)
 create mode 100644 unit/cert-server-key-pkcs8.pem

diff --git a/unit/cert-server-key-pkcs8.pem b/unit/cert-server-key-pkcs8.pem
new file mode 100644
index 0000000..85dd370
--- /dev/null
+++ b/unit/cert-server-key-pkcs8.pem
@@ -0,0 +1,28 @@
+-----BEGIN PRIVATE KEY-----
+MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDTAJBeptooxomx
+q/SJ606rbzgSbcPj0dlzbQVhpGx2gYHGc5DHYK/4uXprSKzO6WrjK53BwF03J4/Z
+RibDkUahBaddXN7MBjvAO+CpsT7+fIZqj7Oxgv9ZTsoDk14gIf2xJs48I+FY30ay
+kwxEwtF+I/42N3i3n2OpAnOXye7qsLjwYcG8kxgMGZHuf7xissqhb5nEuqTBmvVk
+e5cI/uuo34ZX2qH5KA4VT+zUzSMl4l5bbq7zeRS7HnYeXj3eNhwqf0T4ru7ZaFZJ
+aY0OgAhT71nMttUov6AkvjaREb1aquuUHJ4em+J6RpQ8S1YkHhJkIJXg8qqyD33a
+lytfLuu1AgMBAAECggEBAMxMjHyI80xtx16XTyPHCRnmixUU4ImSYwhms8Ix8K7h
+gCUFOlZBoMCj3gtIh8GjsdGZJps1xUuk65wFV30eCZPZJI66YCKNmobrswC61HKV
+YZSF5Qfn/ZOcPO8vXgCgyMEhAKisWQGy1gILbOKa+zo2YWpfVWv9UQKQlBmQ9NqY
+VbZZIZvq3BSdyAnXd7OMqvAN27sLrxdgvdRzCf0E/dSMtkxOkI3G1Z0hNzDFXKxa
+CS75Xb9WaiS8m6gynqPio5PjVe9mps1FMUZuVyJdUgsZS/LtfRabtsc8Da44uEVv
+Z6UvL4Ax5iv8UToGM05+gTLZPHz3kk83EYANnTUJ8TUCgYEA6StzqgpFiL4sa1gU
+AhPcyaL5CmOlojmY+rqVtH+EHDnfHi2p1BkJxkOsWUbuW+3lvkG7pTVQ5TXM5R/d
+yyTF07HyQgI7VJZrelQupYGl6ItwZmEzoJoUUXTsXKySUXUSvLmBeJuOIDWtMyXu
+n0xetWRl8ZuYHCqIT5qmEOt8/CMCgYEA56l4BO65Pqr2k42RQM4ibspDcAZMoYh0
+ysJLVL7PWMXhFbPX6GJCz1+Vm6//pwFqTyzbNpob/vNYNJFfD3syCQATx6ije0MS
+jcP9AdO//fMLfMfhoBKNk589POoqFbXWSqX0UKuAJcFwtkurn/gdq+3/Dxd8pmS6
+7zyXw/kP6kcCgYEA1nzQEzULrbQyrDQDg729tgYizPnJHaeaH9qPZ9B9OHHL2rjq
+pl657RXHbwCetxXp5tAUyu52kcKhzos3vW0ARbJFRY9EAJW2HHtfxYOzmGzcYnE7
+ypqx4hSKcN2WYzQsnkqO3OFLJjn6LzjPft4DqRzH4i7dB9vgNEnwRVQ6Tr0CgYA9
+UnrWs2qN0CudO2grw2UR9rCLQt+eEsT3tx7BvBCe6yJ94DFS7k/JHQA5SgleZ92A
+P9t3RKwMfNXodGK5cl74SvDxdQ5xXnvW0v5yMV8tFd0Alth+yup3HTvUmBezz4J+
+GBfoEr3FQMNZPgacPc186W8Oy6TPVvK0yVFTKuavmQKBgEH5359VsH6c/KHq8r4Z
+0lYaAp+tQz2iramOkCytvlSj8jyPnVS4u/rVgq7oLxxz210wF28Mm3LonrdTOtI7
+uoC4tpuTq46ie6XlhYNW9G1ph+kR+WdXRlKZ2+iGe1Al1tgjvghlFyPdn+Ggj4qO
+ebDb59kVMg21BvxJuAggvwLp
+-----END PRIVATE KEY-----
diff --git a/unit/gencerts.sh b/unit/gencerts.sh
index cfa6486..be186f1 100755
--- a/unit/gencerts.sh
+++ b/unit/gencerts.sh
@@ -6,6 +6,7 @@ openssl req -x509 -new -nodes -extensions ca_ext -config ./=
gencerts.cnf -subj '/
 =

 echo -e "\n*** Server Certificate ***"
 openssl genrsa -out cert-server-key.pem
+openssl pkcs8 -topk8 -nocrypt -in cert-server-key.pem -out cert-server-key=
-pkcs8.pem
 openssl req -new -extensions cert_ext -config ./gencerts.cnf -subj '/O=3DF=
oo Example Organization/CN=3DFoo Example Organization/emailAddress=3Dfoo(a)=
mail.example' -key cert-server-key.pem -out cert-server.csr
 openssl x509 -req -extensions cert_ext -extfile ./gencerts.cnf -in cert-se=
rver.csr -CA cert-ca.pem -CAkey cert-ca-key.pem -CAcreateserial -sha256 -da=
ys 10000 -out cert-server.pem
 openssl verify -CAfile cert-ca.pem cert-server.pem
diff --git a/unit/test-tls.c b/unit/test-tls.c
index 1b896aa..9ddb80c 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -242,14 +242,14 @@ struct tls_conn_test {
 =

 static const struct tls_conn_test tls_conn_test_no_auth =3D {
 	.server_cert_path =3D TESTDATADIR "/cert-server.pem",
-	.server_key_path =3D TESTDATADIR "/cert-server-key.pem",
+	.server_key_path =3D TESTDATADIR "/cert-server-key-pkcs8.pem",
 	.server_expect_identity =3D NULL,
 	.client_expect_identity =3D NULL,
 };
 =

 static const struct tls_conn_test tls_conn_test_server_auth =3D {
 	.server_cert_path =3D TESTDATADIR "/cert-server.pem",
-	.server_key_path =3D TESTDATADIR "/cert-server-key.pem",
+	.server_key_path =3D TESTDATADIR "/cert-server-key-pkcs8.pem",
 	.server_expect_identity =3D NULL,
 	.client_ca_cert_path =3D TESTDATADIR "/cert-ca.pem",
 	.client_expect_identity =3D "Foo Example Organization",
@@ -257,7 +257,7 @@ static const struct tls_conn_test tls_conn_test_server_=
auth =3D {
 =

 static const struct tls_conn_test tls_conn_test_client_auth_attempt =3D {
 	.server_cert_path =3D TESTDATADIR "/cert-server.pem",
-	.server_key_path =3D TESTDATADIR "/cert-server-key.pem",
+	.server_key_path =3D TESTDATADIR "/cert-server-key-pkcs8.pem",
 	.server_ca_cert_path =3D TESTDATADIR "/cert-ca.pem",
 	.server_expect_identity =3D NULL,
 	.client_expect_identity =3D NULL,
@@ -265,17 +265,17 @@ static const struct tls_conn_test tls_conn_test_clien=
t_auth_attempt =3D {
 =

 static const struct tls_conn_test tls_conn_test_client_auth =3D {
 	.server_cert_path =3D TESTDATADIR "/cert-server.pem",
-	.server_key_path =3D TESTDATADIR "/cert-server-key.pem",
+	.server_key_path =3D TESTDATADIR "/cert-server-key-pkcs8.pem",
 	.server_ca_cert_path =3D TESTDATADIR "/cert-ca.pem",
 	.server_expect_identity =3D "Bar Example Organization",
 	.client_cert_path =3D TESTDATADIR "/cert-client.pem",
-	.client_key_path =3D TESTDATADIR "/cert-client-key.pem",
+	.client_key_path =3D TESTDATADIR "/cert-client-key-pkcs8.pem",
 	.client_expect_identity =3D NULL,
 };
 =

 static const struct tls_conn_test tls_conn_test_full_auth_attempt =3D {
 	.server_cert_path =3D TESTDATADIR "/cert-server.pem",
-	.server_key_path =3D TESTDATADIR "/cert-server-key.pem",
+	.server_key_path =3D TESTDATADIR "/cert-server-key-pkcs8.pem",
 	.server_ca_cert_path =3D TESTDATADIR "/cert-ca.pem",
 	.server_expect_identity =3D NULL,
 	.client_ca_cert_path =3D TESTDATADIR "/cert-ca.pem",
@@ -284,11 +284,11 @@ static const struct tls_conn_test tls_conn_test_full_=
auth_attempt =3D {
 =

 static const struct tls_conn_test tls_conn_test_full_auth =3D {
 	.server_cert_path =3D TESTDATADIR "/cert-server.pem",
-	.server_key_path =3D TESTDATADIR "/cert-server-key.pem",
+	.server_key_path =3D TESTDATADIR "/cert-server-key-pkcs8.pem",
 	.server_ca_cert_path =3D TESTDATADIR "/cert-ca.pem",
 	.server_expect_identity =3D "Bar Example Organization",
 	.client_cert_path =3D TESTDATADIR "/cert-client.pem",
-	.client_key_path =3D TESTDATADIR "/cert-client-key.pem",
+	.client_key_path =3D TESTDATADIR "/cert-client-key-pkcs8.pem",
 	.client_ca_cert_path =3D TESTDATADIR "/cert-ca.pem",
 	.client_expect_identity =3D "Foo Example Organization",
 };
-- =

2.9.2


--===============0424350093200098856==--

