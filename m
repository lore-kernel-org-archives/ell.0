Content-Type: multipart/mixed; boundary="===============0288769682481318111=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/2] dbus: Add name_cache argument NULL checks
Date: Wed, 11 May 2016 11:36:07 +0200
Message-ID: <1462959370-30764-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0288769682481318111==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This is so that _dbus_name_cache_free and _dbus_name_cache_notify can be
called with a null pointer similar to l_free, _dbus_filter_free, etc.
---
 ell/dbus-name-cache.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/ell/dbus-name-cache.c b/ell/dbus-name-cache.c
index 24ca619..0c2e08e 100644
--- a/ell/dbus-name-cache.c
+++ b/ell/dbus-name-cache.c
@@ -100,6 +100,9 @@ static void name_cache_entry_destroy(void *data)
 =

 void _dbus_name_cache_free(struct _dbus_name_cache *cache)
 {
+	if (!cache)
+		return;
+
 	if (cache->watch_remove_work)
 		l_idle_remove(cache->watch_remove_work);
 =

@@ -172,6 +175,9 @@ void _dbus_name_cache_notify(struct _dbus_name_cache *c=
ache,
 	struct service_watch *watch;
 	bool prev_connected, connected;
 =

+	if (!cache)
+		return;
+
 	if (_dbus_parse_unique_name(name, NULL))
 		return;
 =

-- =

2.7.4


--===============0288769682481318111==--

