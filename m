Content-Type: multipart/mixed; boundary="===============0245017808739960825=="
MIME-Version: 1.0
From: James Prestwood <prestwoj at gmail.com>
To: ell at lists.01.org
Subject: [PATCH v2 3/5] settings: add l_settings_remove_embedded_groups
Date: Fri, 04 Feb 2022 09:46:12 -0800
Message-ID: <20220204174614.261669-3-prestwoj@gmail.com>
In-Reply-To: 20220204174614.261669-1-prestwoj@gmail.com

--===============0245017808739960825==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This removes all embedded groups from a l_settings object
---
 ell/ell.sym    |  1 +
 ell/settings.c | 10 ++++++++++
 ell/settings.h |  1 +
 3 files changed, 12 insertions(+)

v2:
 * Use l_queue_clear(). Not sure how I didn't notice this API existed.

diff --git a/ell/ell.sym b/ell/ell.sym
index 827e68c..96b3a7d 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -490,6 +490,7 @@ global:
 	l_settings_has_embedded_group;
 	l_settings_get_embedded_groups;
 	l_settings_get_embedded_value;
+	l_settings_remove_embedded_groups;
 	/* signal */
 	l_signal_create;
 	l_signal_remove;
diff --git a/ell/settings.c b/ell/settings.c
index 31d23fe..ac4259c 100644
--- a/ell/settings.c
+++ b/ell/settings.c
@@ -1561,3 +1561,13 @@ LIB_EXPORT const char *l_settings_get_embedded_value(
 =

 	return group->data;
 }
+
+LIB_EXPORT bool l_settings_remove_embedded_groups(struct l_settings *setti=
ngs)
+{
+	if (unlikely(!settings))
+		return false;
+
+	l_queue_clear(settings->embedded_groups, embedded_group_destroy);
+
+	return true;
+}
diff --git a/ell/settings.h b/ell/settings.h
index f094ef5..519014d 100644
--- a/ell/settings.h
+++ b/ell/settings.h
@@ -137,6 +137,7 @@ bool l_settings_remove_key(struct l_settings *settings,=
 const char *group_name,
 bool l_settings_remove_group(struct l_settings *settings,
 				const char *group_name);
 =

+bool l_settings_remove_embedded_groups(struct l_settings *settings);
 char **l_settings_get_embedded_groups(struct l_settings *settings);
 bool l_settings_has_embedded_group(struct l_settings *settings,
 					const char *group);
-- =

2.31.1

--===============0245017808739960825==--

