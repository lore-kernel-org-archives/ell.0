Content-Type: multipart/mixed; boundary="===============2122750675567550314=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 10/17] unit: Add a certificate verification test.
Date: Fri, 24 Jul 2015 05:27:45 +0200
Message-ID: <1437708472-28124-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2122750675567550314==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Uses the included example certificate files and corresponding
private key files are included for use in future tests (for TLS).
This tests most of the cert.c functions and the RSA verify operation.
---
 .gitignore               |  1 +
 Makefile.am              |  7 ++++--
 unit/cert-ca-key.pem     | 27 +++++++++++++++++++++++
 unit/cert-ca.pem         | 26 ++++++++++++++++++++++
 unit/cert-client-key.pem | 27 +++++++++++++++++++++++
 unit/cert-client.pem     | 26 ++++++++++++++++++++++
 unit/cert-server-key.pem | 27 +++++++++++++++++++++++
 unit/cert-server.pem     | 26 ++++++++++++++++++++++
 unit/test-cert.c         | 57 ++++++++++++++++++++++++++++++++++++++++++++=
++++
 9 files changed, 222 insertions(+), 2 deletions(-)
 create mode 100644 unit/cert-ca-key.pem
 create mode 100644 unit/cert-ca.pem
 create mode 100644 unit/cert-client-key.pem
 create mode 100644 unit/cert-client.pem
 create mode 100644 unit/cert-server-key.pem
 create mode 100644 unit/cert-server.pem
 create mode 100644 unit/test-cert.c

diff --git a/.gitignore b/.gitignore
index 16f0103..b122511 100644
--- a/.gitignore
+++ b/.gitignore
@@ -46,6 +46,7 @@ unit/test-cipher
 unit/test-random
 unit/test-util
 unit/test-uintset
+unit/test-cert
 unit/*.log
 unit/*.trs
 examples/dbus-service
diff --git a/Makefile.am b/Makefile.am
index 576641f..4792544 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -125,7 +125,8 @@ unit_tests =3D unit/test-unit \
 			unit/test-cipher \
 			unit/test-random \
 			unit/test-util \
-			unit/test-uintset
+			unit/test-uintset \
+			unit/test-cert
 =

 if MAINTAINER_MODE
 noinst_PROGRAMS +=3D $(unit_tests)
@@ -187,6 +188,8 @@ unit_test_util_LDADD =3D ell/libell-private.la
 =

 unit_test_uintset_LDADD =3D ell/libell-private.la
 =

+unit_test_cert_LDADD =3D ell/libell-private.la
+
 if MAINTAINER_MODE
 noinst_LTLIBRARIES +=3D unit/example-plugin.la
 endif
@@ -194,7 +197,7 @@ endif
 unit_example_plugin_la_LDFLAGS =3D -no-undefined -module -avoid-version \
 							-rpath /dummy
 =

-unit_test_data_files =3D unit/settings.test
+unit_test_data_files =3D unit/settings.test unit/cert-ca.pem unit/cert-cli=
ent.pem unit/cert-server.pem unit/cert-client-key.pem unit/cert-server-key.=
pem
 =

 examples =3D examples/dbus-service
 =

diff --git a/unit/cert-ca-key.pem b/unit/cert-ca-key.pem
new file mode 100644
index 0000000..f121d73
--- /dev/null
+++ b/unit/cert-ca-key.pem
@@ -0,0 +1,27 @@
+-----BEGIN RSA PRIVATE KEY-----
+MIIEpQIBAAKCAQEAyz0GzVnm43TnX8Gl2aK1XknC4hhnw9MdJsEgOy3XJWYo8ijo
+9YxJTuxPIFc0bz8wJYj7JO/Z7GuRsybNt4pq80ILU0LB5VSnO/yZdpEv01gfgMUk
+2aCxIwZrnnQ3owHUq6x0+amlZD5NuWmPGE8TYUTXZILHRlLac6NP7fq1bHtT+CT4
+/HIivb9lgGg/tPuMac5nFxdXyal4coVAmoQa+s8kAlbiFDEVwSMlWkh7IXf/8acx
+31UOgD8XbNdo2HGrpN0TFkPX3qwLSq1CBApu4oX2PJ8/BemRbmsWZvAIxlHUyySa
+J5zg3bxQaX/nS9nre65SXXN1DEVmPMymMxb7yQIDAQABAoIBADAuopsychOAlo3U
+Ce6jrV3SHNqfMJJzTVjvtiVxg60BIDnwyvHTtVl5mnSvV+X70/1CEVA7cK2k/uC7
+FVArB5nuEWNG01L8E72b8AH0/6KaJLXRhx/1AamtDvx8zufdOj8M3pqFxokSYDjR
+trPro0uPF4Vjn7yjTdjWYc+ofTRfSFyOW25HviTztEFzWeZt4KVTbZ/a7Nc1mEDj
+m04noAPh2+24akeahCQUeNLzy197DDpoCLWnrtAwUQc9o4v2RwOakTdoPUT+n8H/
+oxhimB1sfZs3PS74iwf3Z2alFVarF6Surmt6cj7OqsT8GR1bcW5r4+zpaVq0MWs4
+dch7kgECgYEA7AOx/+pHbVzrPN3G+flYnLuCivwck6jUueMjBzJ6Q8mntnI9r2vp
+kHCmCV3sDgvust78jDj4oS8kQ/Q86wy28slZJbQv71XcUxbXCzDeRp/ZvGrAemHQ
+RzfLMsuGdirL9g5XaHpzOYa67Gd2JR6aK3MBOCE24jtm+Iwd6cYs34kCgYEA3HLQ
+dmZC9JJggTIM7Q72mqx3V8aLG54psO0B1O9QaG02yZe87YU4WY8GR729MGEK5VgQ
+AqqfP8slczRYeOzd+5tgyQTtSsPmIc75zXBdwrrpEv0kC+ZS06vAPlPYfqh/4kRq
+rXbGZulSIkmqOXHdnijqfUOc19GeJoUi6fOn6kECgYEArEPqOUvsBKQMw2lw4WYh
+So0GtKFdzl0tn9xs5cTvPulCc8Wgxpiyaw398tpOANauzHo7xbGTsDpzcvIjQMEQ
+C9fxLLb/QebeoPsLzQxHQS9Nwtv8T5dzaXgM5a9uHnQQWTGQlR7DWZrAdurxbhiP
+GOWhXzHHGIuZFhNXhhlzCVkCgYEArdBVL1V361BSiOtGp88Jf3EGdA3WdsMhCiAF
+NrguRPf/n7llPD2y7WJIyF4BAlkxdx0VGpUfFPR+pbQbIdVZPV4IVNbupemJ1RRV
+f7beJoCq7s7rEfrbSYv8+uevJkaC9ouNNRIWYuQKX4CHl92AqIiIQpYB32Smdqa4
+nZAA0EECgYEAoKA19JDFAJ28fAIPgxYmEvuO07P0O4QJrINzVNvXcQn+yUQ4jBcN
+eiAuqObZV1pGquOdPcnvDmOZZ+/gu1xJwXaPaZInuVJN1UCCRRcUcy40tXkZgW40
+kqb3e0GJPLMR31p5X1WdTpd7y4uh+IV0R9chuGVTc5dBwwoFNRMdWfk=3D
+-----END RSA PRIVATE KEY-----
diff --git a/unit/cert-ca.pem b/unit/cert-ca.pem
new file mode 100644
index 0000000..724f852
--- /dev/null
+++ b/unit/cert-ca.pem
@@ -0,0 +1,26 @@
+-----BEGIN CERTIFICATE-----
+MIIEVDCCAzygAwIBAgIJAIOyXTOJrYsaMA0GCSqGSIb3DQEBCwUAMHgxNTAzBgNV
+BAoTLEludGVybmF0aW9uYWwgVW5pb24gb2YgRXhhbXBsZSBPcmdhbml6YXRpb25z
+MR8wHQYDVQQDExZDZXJ0aWZpY2F0ZSBpc3N1ZXIgZ3V5MR4wHAYJKoZIhvcNAQkB
+Fg9jYUBtYWlsLmV4YW1wbGUwHhcNMTUwNzIxMjIzMDU4WhcNMTcwNzIwMjIzMDU4
+WjB4MTUwMwYDVQQKEyxJbnRlcm5hdGlvbmFsIFVuaW9uIG9mIEV4YW1wbGUgT3Jn
+YW5pemF0aW9uczEfMB0GA1UEAxMWQ2VydGlmaWNhdGUgaXNzdWVyIGd1eTEeMBwG
+CSqGSIb3DQEJARYPY2FAbWFpbC5leGFtcGxlMIIBIjANBgkqhkiG9w0BAQEFAAOC
+AQ8AMIIBCgKCAQEAyz0GzVnm43TnX8Gl2aK1XknC4hhnw9MdJsEgOy3XJWYo8ijo
+9YxJTuxPIFc0bz8wJYj7JO/Z7GuRsybNt4pq80ILU0LB5VSnO/yZdpEv01gfgMUk
+2aCxIwZrnnQ3owHUq6x0+amlZD5NuWmPGE8TYUTXZILHRlLac6NP7fq1bHtT+CT4
+/HIivb9lgGg/tPuMac5nFxdXyal4coVAmoQa+s8kAlbiFDEVwSMlWkh7IXf/8acx
+31UOgD8XbNdo2HGrpN0TFkPX3qwLSq1CBApu4oX2PJ8/BemRbmsWZvAIxlHUyySa
+J5zg3bxQaX/nS9nre65SXXN1DEVmPMymMxb7yQIDAQABo4HgMIHdMB0GA1UdDgQW
+BBQwJusAXVPeEDyctL5+1/gVROm4vTCBqgYDVR0jBIGiMIGfgBQwJusAXVPeEDyc
+tL5+1/gVROm4vaF8pHoweDE1MDMGA1UEChMsSW50ZXJuYXRpb25hbCBVbmlvbiBv
+ZiBFeGFtcGxlIE9yZ2FuaXphdGlvbnMxHzAdBgNVBAMTFkNlcnRpZmljYXRlIGlz
+c3VlciBndXkxHjAcBgkqhkiG9w0BCQEWD2NhQG1haWwuZXhhbXBsZYIJAIOyXTOJ
+rYsaMA8GA1UdEwEB/wQFMAMBAf8wDQYJKoZIhvcNAQELBQADggEBADKZwqldI8Il
+9ZgA4bhbEarcopiUUC3RMiH9cvy1rXDgYoSbC5RX2x6ptCIXDLfuAsTk+Qcl90KZ
+xno2zrKjjB7QUeb5kdZAwuZ0IoqgLWPxvdayVUDHT/7B/rNFH2ExmKR4Qz2k+gxb
+d5fUYQecRajfDQjOGhhoiDzJBq/GERXnJ2/WEOr3gFdOQ3QLFzTLjFRFlq+cxbm7
+OmBt+f2wTaX1l/EMGbxdvLfD96VbDihAl6yIsK2hNYNghW032nJjFDs7pOqneRue
+sCSbyRp2O8rBT8IPkn2e3QQl/zrdEv5FLnqrhSaB80bLJi/HGixkFkvvp+ZsWIBd
+NQZHpZyYJ+Y=3D
+-----END CERTIFICATE-----
diff --git a/unit/cert-client-key.pem b/unit/cert-client-key.pem
new file mode 100644
index 0000000..b8f88cf
--- /dev/null
+++ b/unit/cert-client-key.pem
@@ -0,0 +1,27 @@
+-----BEGIN RSA PRIVATE KEY-----
+MIIEowIBAAKCAQEApmgm9gy2iv2QqjzXom8XlT34Vp5XV0QWHwaWmIYuCAYpw5A2
+Y5cYNULg4M3BjsrjjmMVG9xncQ4WJHETkAs+l2d2cIqyvzmsRJ5EakeeQuxPbX+O
+E4XTVUWK7U8MtFbioynO7fy4FXYOvG0rG9BUAocuaMgBVJZC0TIQsD+LPQizMMwl
+gmkcK2dy0MAD7q4ouvIrWxdnn/JfcQernbl1s/ThLiFFxA+7s/QzP1zxm9nKaGSi
+ITteqrwKPkPiRjlQPM3Ia8i3nvskMlyZTVgEU4z0ZmoQ9T+odZ94vhR4VGib0Xr2
+7sn1Ejhlcl3+0Lt/v086hkhPSZ7nV5kjzOWy5wIDAQABAoIBACC03duEeihtWA6t
+sLBDZ3401OepbX9AaZylfdnynX+EPpcqdBY071QglfR5XG7FX95viQmV01r8Ksv0
+0aSBIUc+1Z+fEyzUmBBQjx/YfbmnmqDp7jHWHshmx7yGyfd0EE2DfSF3h3LoZlMQ
+neV0l957VVrQ3LoUYoOddHw/sQ1IpEDzjHKxcCXrBRVDp/Tcc9yrg+rWRMC8smmj
+bgf5bhUMIJLKaB1lhENLmwRYAALvo2hjUPMHhH9j1F+Q0js9MJGgBP772SEzDp4P
+34pUuxrg0zJeygULc2kJHBNJZ1DOO9hXIxiVtiGlvHC79+7N9OYlwd3kd9xWxvmc
+D7Fz9XECgYEA17VSI79KZaB2pSqP2nzHESHDMDZcfjLKa0GYMB6qbtUWbwexDxqv
+bLP7L0UsYdJbY1bNJGsof97wypz2uiC9s5X1AdXFe2zylmSjXZ6MVdqik1EpWU4I
+QDiU4lVPgIxGsu8v9owCGxo/9FV/jKME8u+C45KuVAxfmj1pxSeJRe8CgYEAxX1Z
+RB4RFR38m8yH3MyzL6nj54VGhD8eT9auJwXWKmBYa+5fntOOgMngruql0AWZs/Yr
+uexcX+ajNOj2yZVn+uERDBYLqNjQc92IoPAd6ZYIXjKHH8H6SO1GleylMmgW2MEp
+uS6YQh9S95y7S4wtcY/jtiLgKYe5JNRTjf77GokCgYAyvyuV0Vj1U6zV6o9xPU2v
+0BuVahSUc+p/FS1ylKRP8r2WXV7gSMzga+86DbIFSXHKiw8z9CnQ+2f2orrAyxcV
++r9rMRmGkfj4PLDaQ4SMZiU9NyjdI6h5Q1ZzcNKFUXsIeZD1FbchHSnSl5KsSWXO
+qV5Hn6h3iXmsVapegZCf7QKBgEzWv5OkSys3NqD7zGTZdGJ4LIdZMJ2l3UpdEfd2
+6uQkBmNAJQ4r7AcqBPSpsYglla8SeeLmFu7tUtT0S4kVS5auWS6lqTWx3jEmodFU
+e5711B2qdS6jD5muUEdnAsOBAlqllXFKss0PWP2kiq8TRF8qCARGv4cJGr08q6HU
+8qhZAoGBAJNvpqpB6pPy5Y0j0wGkc9gRFXFUy8Ulxk6bBA15GW0tiGiyEt1P1SbK
+/kwiWjwFryDn0eSATp4YRgqi1da0KG1oxdgzxbGNqNpVzZ9pDW4UcLyzzkBYDrjX
+YY+reFnomF8Wd3XaXmoI4wESHIWJMN3W2deXt75fkb48hxCf9kzX
+-----END RSA PRIVATE KEY-----
diff --git a/unit/cert-client.pem b/unit/cert-client.pem
new file mode 100644
index 0000000..6b0fccf
--- /dev/null
+++ b/unit/cert-client.pem
@@ -0,0 +1,26 @@
+-----BEGIN CERTIFICATE-----
+MIIEbzCCA1egAwIBAgIJAIOyXTOJrYsbMA0GCSqGSIb3DQEBBAUAMHgxNTAzBgNV
+BAoTLEludGVybmF0aW9uYWwgVW5pb24gb2YgRXhhbXBsZSBPcmdhbml6YXRpb25z
+MR8wHQYDVQQDExZDZXJ0aWZpY2F0ZSBpc3N1ZXIgZ3V5MR4wHAYJKoZIhvcNAQkB
+Fg9jYUBtYWlsLmV4YW1wbGUwIBcNMTUwNzIxMjIzMTE4WhgPMjExNTA2MjcyMjMx
+MThaMGcxITAfBgNVBAoTGEJhciBFeGFtcGxlIE9yZ2FuaXphdGlvbjEhMB8GA1UE
+AxMYQmFyIEV4YW1wbGUgT3JnYW5pemF0aW9uMR8wHQYJKoZIhvcNAQkBFhBiYXJA
+bWFpbC5leGFtcGxlMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApmgm
+9gy2iv2QqjzXom8XlT34Vp5XV0QWHwaWmIYuCAYpw5A2Y5cYNULg4M3BjsrjjmMV
+G9xncQ4WJHETkAs+l2d2cIqyvzmsRJ5EakeeQuxPbX+OE4XTVUWK7U8MtFbioynO
+7fy4FXYOvG0rG9BUAocuaMgBVJZC0TIQsD+LPQizMMwlgmkcK2dy0MAD7q4ouvIr
+Wxdnn/JfcQernbl1s/ThLiFFxA+7s/QzP1zxm9nKaGSiITteqrwKPkPiRjlQPM3I
+a8i3nvskMlyZTVgEU4z0ZmoQ9T+odZ94vhR4VGib0Xr27sn1Ejhlcl3+0Lt/v086
+hkhPSZ7nV5kjzOWy5wIDAQABo4IBCTCCAQUwCQYDVR0TBAIwADAsBglghkgBhvhC
+AQ0EHxYdT3BlblNTTCBHZW5lcmF0ZWQgQ2VydGlmaWNhdGUwHQYDVR0OBBYEFICx
+nSSUXhyrxVVOqUv/f3vZfTBoMIGqBgNVHSMEgaIwgZ+AFDAm6wBdU94QPJy0vn7X
++BVE6bi9oXykejB4MTUwMwYDVQQKEyxJbnRlcm5hdGlvbmFsIFVuaW9uIG9mIEV4
+YW1wbGUgT3JnYW5pemF0aW9uczEfMB0GA1UEAxMWQ2VydGlmaWNhdGUgaXNzdWVy
+IGd1eTEeMBwGCSqGSIb3DQEJARYPY2FAbWFpbC5leGFtcGxlggkAg7JdM4mtixow
+DQYJKoZIhvcNAQEEBQADggEBADqzKUMa7JZr9e7d8zmWj/kBP47XzXDl/3LZXHGT
+mbdhB/j73BICEK4+2WAF8d8uKLz3zYXOXgq72l6arcPPJjyA7Q8MKfXPCIkCe1Oy
+0oEUtTeiwrsT9cPGHXcbYInNZZ0GSw/w1nYoYTsmJeLV8dakY78bdvGjHjjYlUTU
+OWC7V4HuIBq2ablHJ/i54vS+k4iN4XIppLBwXytNEnu2l5QEz+29ZIEhTlvhhIR+
+D+DiPgNBxNGlPJH0m20qpErW6as/+UXKNQgadQbZ16gjmzCoZQJxUhT/WKqPhLhK
+ApzmXLQwarIjHW2qmy4I4VXUeqe5PFT2638qshylw+Qxeug=3D
+-----END CERTIFICATE-----
diff --git a/unit/cert-server-key.pem b/unit/cert-server-key.pem
new file mode 100644
index 0000000..efb3922
--- /dev/null
+++ b/unit/cert-server-key.pem
@@ -0,0 +1,27 @@
+-----BEGIN RSA PRIVATE KEY-----
+MIIEowIBAAKCAQEAw52fx0CLmdfz2JzBse6CfzTJqYljq3j6W4z3XsGz3qFtmi1e
+ZsPY9ZNj9jpA9+vvRNRG+VXfkF27OVIkyiwkdN6zeVtY7PdmAQjoSv1Akwr18Mrh
+2mnGeKcN2+27PBglARl0uS7IWIGcGdHEV4idin54ExtMm7d/OW2H8WvUeMJ/vE4t
+0BagPAMJosOtlIO0QzlfYsOuPfTxh2G4viRnw6vqD0My1jut68BqrwWJfO/h35Ok
+hYj7sdWmWni38v2j8sbs/6YH3mR7YkmWijfGLlVke/tkOjx2PlItT7PIjwDOkHxs
+Uu0yZCsEuh3w+wzuVv/ByzyW3K/0eAkF3ov6dQIDAQABAoIBAFWW6ykgabSHk68M
+b4et5zVHYJEohw6o4UobdMTmFhBsK2uRPEPUn2Jb+hnrRS/08Hz6MI+57hbZnCip
+c2VuSQlFw9tuh4sveFctkY32H0H3QsL30jhhnbB+z4aSDyFtIwvHGpZIDOsE0stN
+SA5QvTWyvlEF2dAsSqNS9G9CkfW/yE46UU1sWb9YHCpK6bQDKolRPb6HxHFY7KBn
+58MQd3mdripSjVUShEcXxuwq7aM/5hIPRVv/9SQyd450+STEKnA5iqjh3Wr1xvUN
+BuqEcTwhUhx9pp4vwft+0TIcwadGymTf4xsdb0Id3TrTSP9TtqdTIOvuVwm5bm9f
+DfHKFSUCgYEA7BXQEgqVWPU4vnlkrfZ21UMIh3tUYpwEKz+kqGapucdhdldb6EXp
+LgWLyuJqCy7wvwh/1uP0qKFNUOzSrSBnEAUfuteJWZoGM/VxUOkUimKIgYN5daPY
+JahRZl8Sehm24b6a2oh5v1oQhyLxYXuOCXrl8/fEsn5JU92LQE0HYJcCgYEA1B3i
+oQKHS0vzn79T8jVv+M5k+KcUa9esNeP+hQ/ZyjR9KbeX8gyxzIvm6v0BZSmxKw3P
+RV3A2GgJK67wzATdqrMB9I+mbC1lTkh7kVS5CFmViHkTmm/f6ppxHcebqEmqFCPh
+BCLP2NqwDV0s7+SoRhTWfxDeytOCauxhUQmRUtMCgYA7+K6KZrXZizGG8T9qEZnO
+QuD/yYx+IDPO6LPjM3EaCFPxw+9M6bV6Q15ng2x8usfdP0N6Sx3zWEZTsFU0NW74
+2tRcmjQB1uaMfGT0sMDPBoi2nbdU8vINXtyOrMf8zFtwrQKZUOHcgfyA15eJs+E4
+90dC2kXVMc9exoCBLRAasQKBgQCpiuWdKmc3oRKuigAwJdRE+7urH+jrtex4+q5y
+btP2knPEh3GUz97BjsVY6DdYQ7XPou8cE67TinxiBSeE+xKuoPwcHUG5T6OcqcTS
+yfRHn0stVRF9LJS+cQme8vAQ2ChwhqkRZD3bqBh15hbH/G0f7wHveG2Lkvm4Ow4h
+9tLIbwKBgDIN1MBmY5Fwf7KLaXwqnX2pstt+tHXUlA74emNZd5L405kiGkqK7fUG
+ezofIAm1mizAv4hcVOoxOllMPDjJadfhELoi9JMbkJxmpQ1ezW0d+cc6DgRsWEZ+
+T0mhkJKaKfjWvNxsXZhsLgakjAU8J0/kqUdC6VLOO2e/HprlpEv9
+-----END RSA PRIVATE KEY-----
diff --git a/unit/cert-server.pem b/unit/cert-server.pem
new file mode 100644
index 0000000..7f54b7a
--- /dev/null
+++ b/unit/cert-server.pem
@@ -0,0 +1,26 @@
+-----BEGIN CERTIFICATE-----
+MIIEbzCCA1egAwIBAgIJAIOyXTOJrYscMA0GCSqGSIb3DQEBBAUAMHgxNTAzBgNV
+BAoTLEludGVybmF0aW9uYWwgVW5pb24gb2YgRXhhbXBsZSBPcmdhbml6YXRpb25z
+MR8wHQYDVQQDExZDZXJ0aWZpY2F0ZSBpc3N1ZXIgZ3V5MR4wHAYJKoZIhvcNAQkB
+Fg9jYUBtYWlsLmV4YW1wbGUwIBcNMTUwNzIxMjIzMTUxWhgPMjExNTA2MjcyMjMx
+NTFaMGcxITAfBgNVBAoTGEZvbyBFeGFtcGxlIE9yZ2FuaXphdGlvbjEhMB8GA1UE
+AxMYRm9vIEV4YW1wbGUgT3JnYW5pemF0aW9uMR8wHQYJKoZIhvcNAQkBFhBmb29A
+bWFpbC5leGFtcGxlMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAw52f
+x0CLmdfz2JzBse6CfzTJqYljq3j6W4z3XsGz3qFtmi1eZsPY9ZNj9jpA9+vvRNRG
++VXfkF27OVIkyiwkdN6zeVtY7PdmAQjoSv1Akwr18Mrh2mnGeKcN2+27PBglARl0
+uS7IWIGcGdHEV4idin54ExtMm7d/OW2H8WvUeMJ/vE4t0BagPAMJosOtlIO0Qzlf
+YsOuPfTxh2G4viRnw6vqD0My1jut68BqrwWJfO/h35OkhYj7sdWmWni38v2j8sbs
+/6YH3mR7YkmWijfGLlVke/tkOjx2PlItT7PIjwDOkHxsUu0yZCsEuh3w+wzuVv/B
+yzyW3K/0eAkF3ov6dQIDAQABo4IBCTCCAQUwCQYDVR0TBAIwADAsBglghkgBhvhC
+AQ0EHxYdT3BlblNTTCBHZW5lcmF0ZWQgQ2VydGlmaWNhdGUwHQYDVR0OBBYEFL2v
+/nxaoNJQM65oOfksgwHMOgy2MIGqBgNVHSMEgaIwgZ+AFDAm6wBdU94QPJy0vn7X
++BVE6bi9oXykejB4MTUwMwYDVQQKEyxJbnRlcm5hdGlvbmFsIFVuaW9uIG9mIEV4
+YW1wbGUgT3JnYW5pemF0aW9uczEfMB0GA1UEAxMWQ2VydGlmaWNhdGUgaXNzdWVy
+IGd1eTEeMBwGCSqGSIb3DQEJARYPY2FAbWFpbC5leGFtcGxlggkAg7JdM4mtixow
+DQYJKoZIhvcNAQEEBQADggEBAECllH+Ph+sxeYlYR4Xn/QcvBNhMW5p8jtWt0KJ+
+drpnqGz428LojEm8E2i+ab6jIDcEEzDTnDZqcszpkIAKNhNhjJyREAoYpg0EXtW8
+1SQ6rLuZwE+mkG7yGUISRN/fn9RGKkDBdDCOeeKjEkklBLijejSwTJQiai1xdIsg
+KuQpqUX5iy++MS9gL/8BeFVGgqY5MJXWXNXryjnqy7gdhUc1YHwzJbG95rAFuo/v
+yP1NTqnduchiBXbFxLPTMenpe0cGfBdfDVR39hsFZSEMnCohc+WpYSF2PPxq58iw
+zdfAwPzGdSLU/F0knKRVxtAJ7/Paz6Mvv5bTYe8i8EfbLtU=3D
+-----END CERTIFICATE-----
diff --git a/unit/test-cert.c b/unit/test-cert.c
new file mode 100644
index 0000000..c217030
--- /dev/null
+++ b/unit/test-cert.c
@@ -0,0 +1,57 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2011-2014  Intel Corporation. All rights reserved.
+ *
+ *  This library is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU Lesser General Public
+ *  License as published by the Free Software Foundation; either
+ *  version 2.1 of the License, or (at your option) any later version.
+ *
+ *  This library is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ *  Lesser General Public License for more details.
+ *
+ *  You should have received a copy of the GNU Lesser General Public
+ *  License along with this library; if not, write to the Free Software
+ *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 =
 USA
+ *
+ */
+
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#include <assert.h>
+
+#include <ell/ell.h>
+
+static void test_cert_verify(const void *data)
+{
+	struct l_cert *cert;
+	struct l_cert *cacert;
+
+	cert =3D l_cert_load_file(TESTDATADIR "/cert-server.pem");
+	assert(cert);
+
+	cacert =3D l_cert_load_file(TESTDATADIR "/cert-ca.pem");
+	assert(cacert);
+
+	assert(l_cert_verify_certchain(cert, cacert));
+
+	assert(!l_cert_verify_certchain(cacert, cert));
+
+	l_free(cert);
+	l_free(cacert);
+}
+
+int main(int argc, char *argv[])
+{
+	l_test_init(&argc, &argv);
+
+	l_test_add("Certchain verify", test_cert_verify, NULL);
+
+	return l_test_run();
+}
-- =

2.1.4


--===============2122750675567550314==--

