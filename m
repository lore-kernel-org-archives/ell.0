Content-Type: multipart/mixed; boundary="===============0416727633680501463=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [PATCH 21/21] git: Ignoring the org.freedesktop.DBus.Properties
 interface test binary
Date: Thu, 13 Nov 2014 12:36:25 +0200
Message-ID: <1415874985-13034-22-git-send-email-tomasz.bursztyka@linux.intel.com>
In-Reply-To: <1415874985-13034-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0416727633680501463==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 .gitignore | 1 +
 1 file changed, 1 insertion(+)

diff --git a/.gitignore b/.gitignore
index 1047a87..9448673 100644
--- a/.gitignore
+++ b/.gitignore
@@ -35,6 +35,7 @@ unit/test-dbus
 unit/test-dbus-message
 unit/test-dbus-util
 unit/test-dbus-service
+unit/test-dbus-freedesktop
 unit/test-gvariant-util
 unit/test-gvariant-message
 unit/test-siphash
-- =

2.0.4


--===============0416727633680501463==--

