Content-Type: multipart/mixed; boundary="===============8325918431797289797=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 3/4] time: Use l_timespec_to_usecs() to avoid overflow.
Date: Mon, 02 Mar 2020 13:28:16 -0800
Message-ID: <20200302212817.15524-4-ossama.othman@intel.com>
In-Reply-To: <20200302212817.15524-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8325918431797289797==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/time.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/time.c b/ell/time.c
index becf985..3bf75e6 100644
--- a/ell/time.c
+++ b/ell/time.c
@@ -67,7 +67,7 @@ LIB_EXPORT uint64_t l_time_now(void)
 =

 	clock_gettime(CLOCK_BOOTTIME, &now);
 =

-	return now.tv_sec * 1000000 + now.tv_nsec / 1000;
+	return l_timespec_to_usecs(&now);
 }
 =

 /**
-- =

2.20.1

--===============8325918431797289797==--

