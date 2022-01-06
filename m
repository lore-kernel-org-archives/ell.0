Content-Type: multipart/mixed; boundary="===============0234221603415868051=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 3/5] icmp6: Call debug user data destroy handler
Date: Thu, 06 Jan 2022 16:05:27 +0100
Message-ID: <20220106150529.458775-3-andrew.zaborowski@intel.com>
In-Reply-To: 20220106150529.458775-1-andrew.zaborowski@intel.com

--===============0234221603415868051==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/icmp6.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ell/icmp6.c b/ell/icmp6.c
index 87e46d1..6a2d705 100644
--- a/ell/icmp6.c
+++ b/ell/icmp6.c
@@ -473,6 +473,7 @@ LIB_EXPORT void l_icmp6_client_free(struct l_icmp6_clie=
nt *client)
 =

 	l_icmp6_client_stop(client);
 	l_queue_destroy(client->routes, NULL);
+	l_icmp6_client_set_debug(client, NULL, NULL, NULL);
 	l_queue_destroy(client->event_handlers, icmp6_event_handler_destroy);
 	l_free(client);
 }
-- =

2.32.0

--===============0234221603415868051==--

