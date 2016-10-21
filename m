Content-Type: multipart/mixed; boundary="===============7154805085715163168=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 3/4] unit: New certificates for intermediate CA testing
Date: Fri, 21 Oct 2016 13:52:25 -0700
Message-ID: <20161021205226.419-3-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20161021205226.419-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7154805085715163168==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/cert-entity-int.pem | 25 +++++++++++++++++++++++++
 unit/cert-intca.pem      | 26 ++++++++++++++++++++++++++
 2 files changed, 51 insertions(+)
 create mode 100644 unit/cert-entity-int.pem
 create mode 100644 unit/cert-intca.pem

diff --git a/unit/cert-entity-int.pem b/unit/cert-entity-int.pem
new file mode 100644
index 0000000..20384ad
--- /dev/null
+++ b/unit/cert-entity-int.pem
@@ -0,0 +1,25 @@
+-----BEGIN CERTIFICATE-----
+MIIEPTCCAyWgAwIBAgIJAI7NK3vBJ/f2MA0GCSqGSIb3DQEBCwUAMHgxNTAzBgNV
+BAoMLEludGVybmF0aW9uYWwgVW5pb24gb2YgRXhhbXBsZSBPcmdhbml6YXRpb25z
+MR8wHQYDVQQDDBZDZXJ0aWZpY2F0ZSBpc3N1ZXIgZ3V5MR4wHAYJKoZIhvcNAQkB
+Fg9jYUBtYWlsLmV4YW1wbGUwHhcNMTYxMDIxMjAxMTMyWhcNNDQwMzA4MjAxMTMy
+WjBnMSEwHwYDVQQKDBhCYXogRXhhbXBsZSBPcmdhbml6YXRpb24xITAfBgNVBAMM
+GEJheiBFeGFtcGxlIE9yZ2FuaXphdGlvbjEfMB0GCSqGSIb3DQEJARYQYmF6QG1h
+aWwuZXhhbXBsZTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAL2bi0cR
+ppjr5lSqdu0aUFvCvl1JqDh2+lUGpvrDqqJ67bVNbx9L6wts8VPYdpyTe/kG+PPf
+Mjys4M8UzTzJWYqpZuXzcYdzllZpjHEC+ujv3qHKwrVEdi8r2xa9TLrakLHiI5v/
+QvbUhQUAFU3m3IWV9bCc6uais3RHMCvOfGpPrYxj5Q+iA830I6TEHklIz7SqrHfA
+i45izx8YSZg744EmS29FGMAgOFeXyi1n+wvjrKv4E7miyYxPDNtaGtuurvE4dHqV
+oq4n9JNKo6tkV0CEVpaxPXBj9CM4bJgort4GktCWuY9/Fzz4waZOKmL4hwoLA8Oh
+IG4fCTbofusIQgkCAwEAAaOB2jCB1zAJBgNVHRMEAjAAMB0GA1UdDgQWBBS8N7xQ
+LmUgt+W2cyJ8nLDwXS6hoDCBqgYDVR0jBIGiMIGfgBSC3aq471/QsqUr3Rys9bLD
+4TC4xaF8pHoweDE1MDMGA1UECgwsSW50ZXJuYXRpb25hbCBVbmlvbiBvZiBFeGFt
+cGxlIE9yZ2FuaXphdGlvbnMxHzAdBgNVBAMMFkNlcnRpZmljYXRlIGlzc3VlciBn
+dXkxHjAcBgkqhkiG9w0BCQEWD2NhQG1haWwuZXhhbXBsZYIJAIJ0sZ9yZ5EBMA0G
+CSqGSIb3DQEBCwUAA4IBAQAoBhPIAoX2UpT0Y9xoFI2Pv0jIZYhECzCtlrsrsaAn
+xqo7sWp00HwlDGVc2QbRowSaGHDmsVKvwvV1EskbvX7SjfSV2zSBn41iOkNYdjwu
+8q5Kbqx/wq/fYB6DXniSMy0/d8522A9sxO8acZLg0dyUUvIVZGB/6ymCHnyqUe+8
+sZytSzLKEjxK6y08SmhThKYtgWFnNiQHCuJw6rsPu+zzJbOoZ4zQdmNjWwvtD8Nj
+WnKTwcYS1+gz2UhW/bhzqxAldkjN20HACb3WzUq7pjri7ddAYL5MCKffklUVC5ic
+/eYl7Ti8l2RvSYymB0Yg7YAEmz43W7kmAn5Vml8SYotJ
+-----END CERTIFICATE-----
diff --git a/unit/cert-intca.pem b/unit/cert-intca.pem
new file mode 100644
index 0000000..7bd4d72
--- /dev/null
+++ b/unit/cert-intca.pem
@@ -0,0 +1,26 @@
+-----BEGIN CERTIFICATE-----
+MIIEUTCCAzmgAwIBAgIJAIJ0sZ9yZ5EBMA0GCSqGSIb3DQEBCwUAMHgxNTAzBgNV
+BAoMLEludGVybmF0aW9uYWwgVW5pb24gb2YgRXhhbXBsZSBPcmdhbml6YXRpb25z
+MR8wHQYDVQQDDBZDZXJ0aWZpY2F0ZSBpc3N1ZXIgZ3V5MR4wHAYJKoZIhvcNAQkB
+Fg9jYUBtYWlsLmV4YW1wbGUwHhcNMTYxMDIxMjAxMTMyWhcNNDQwMzA4MjAxMTMy
+WjB4MTUwMwYDVQQKDCxJbnRlcm5hdGlvbmFsIFVuaW9uIG9mIEV4YW1wbGUgT3Jn
+YW5pemF0aW9uczEfMB0GA1UEAwwWQ2VydGlmaWNhdGUgaXNzdWVyIGd1eTEeMBwG
+CSqGSIb3DQEJARYPY2FAbWFpbC5leGFtcGxlMIIBIjANBgkqhkiG9w0BAQEFAAOC
+AQ8AMIIBCgKCAQEAuUa9iIt7rgZSg3gjYLvH8+CyWV/ULDdjtgwEGfB2vHckL1fV
+gY7NBfXrgxXcjjWNxUnNWALsP7bcvJlMzZrlKffWSo2zkybv8yuajuZE++hsY2fT
+f4wnqkGJLSu1XJh+BwdslIA133nb5IbDayrRFArivI+LD/cIubmgSEnL6wr1XN3M
+h3M+NKF/LVXK2s6pB/Njaz4lAGzLpHfo4dauU7Xo+XPAdW7C2G34UEsZSr39watK
+e7Z8NkyrZ4zapz+LEmDFrKdNOVFgavlMvhXX8b4Pr8XlK3p2yvKgpjs9YP4vPjvL
+gKoWd8hx660kf2qwELQvuYkioi8DAjhfM7M9RQIDAQABo4HdMIHaMAwGA1UdEwQF
+MAMBAf8wHQYDVR0OBBYEFILdqrjvX9CypSvdHKz1ssPhMLjFMIGqBgNVHSMEgaIw
+gZ+AFO+M3tJAELTnseUqZyP4vl5X7SmUoXykejB4MTUwMwYDVQQKDCxJbnRlcm5h
+dGlvbmFsIFVuaW9uIG9mIEV4YW1wbGUgT3JnYW5pemF0aW9uczEfMB0GA1UEAwwW
+Q2VydGlmaWNhdGUgaXNzdWVyIGd1eTEeMBwGCSqGSIb3DQEJARYPY2FAbWFpbC5l
+eGFtcGxlggkAma3ZbsK60e8wDQYJKoZIhvcNAQELBQADggEBADCm6aMD9hZunlnx
+cWyRCMT37gamRdCDkQ1/jrixZLZpyl9I/O8zbBLLR+bfArdxmOkpO1CgX3l4Zbhk
+xetdelVXatmaFsSQXCQsrVuue2Q9aUAzVoztgg27qyuXaSafx7PvOPnpTJcn5pcQ
+TecYKQjIVZInGZ1t7Oe+U5AiE0CLEgGnTsdABD1pNjoUXnQZx1RkvLiUsSH+YNQN
+G7vC5GiCkNFDRGk/M0Qec7kaYIwHjag1a0uitIpUv1LaloL/GIePFPT/Hh6rVsf4
+kLaXK5f78Rc09W4X8Uf818sPZkgL1pinH/XmwcySM0PucP3nQbkIpnAZETTcIcBN
+03wfDNA=3D
+-----END CERTIFICATE-----
-- =

2.10.1


--===============7154805085715163168==--

