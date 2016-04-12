Content-Type: multipart/mixed; boundary="===============7604064686603498514=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 4/3] README: Add note about Diffie-Hellman kernel option
Date: Tue, 12 Apr 2016 12:50:29 -0700
Message-ID: <1460490629-6915-1-git-send-email-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7604064686603498514==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 README | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/README b/README
index 0eb8b63..c1ac931 100644
--- a/README
+++ b/README
@@ -29,6 +29,9 @@ epoll and timerfd.
 For checksum usage you need if_alg (crypto user-space API) with MD5
 and SHA-1 algorithms enabled.
 =

+For Diffie-Hellman usage the KEYCTL_DH_COMPUTE command for the
+keyctl() syscall is required.
+
 Kernel configuration checklist:
 =

 	CONFIG_TIMERFD=3Dy
@@ -39,6 +42,8 @@ Kernel configuration checklist:
 	CONFIG_CRYPTO_MD5=3Dy
 	CONFIG_CRYPTO_SHA1=3Dy
 =

+	CONFIG_KEY_DH_OPERATIONS=3Dy
+
 For kernel D-Bus (kdbus) support, the appropriate kernel module is required
 and must be loaded. The development repositories can be found here:
 =

-- =

2.8.1


--===============7604064686603498514==--

