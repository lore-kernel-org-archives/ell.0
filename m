Content-Type: multipart/mixed; boundary="===============3502079102077350078=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 1/2] plugin: Explicitly initialize descriptor fields.
Date: Tue, 23 Oct 2018 12:57:39 -0700
Message-ID: <20181023195740.30204-2-ossama.othman@intel.com>
In-Reply-To: <20181023195740.30204-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3502079102077350078==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The l_plugin_desc debug_start and debug_stop fields were implicitly
initialized in the L_PLUGIN_DEFINE macro.  While that is the expected
behavior, doing so may trigger a warning about missing field
initializers (e.g. when gcc's -Wmissing-field-initializers option is
enabled).  ELL explicitly disables that warning in maintainer mode
builds, but users cannot be expected to disable that warning to
silence warnings emanating from their own use of L_PLUGIN_DEFINE.
Explicitly initialize the debug_{start,stop} fields to prevent such
warnings from being triggered in ELL based user defined plugins.

Alternatively, allowing the two fields in question to be implicitly
initialized through designated initialization of the plugin descriptor
prevents the missing field initializer warning from being triggered,
but it was simpler to explicitly initialize them instead.
---
 ell/plugin.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/ell/plugin.h b/ell/plugin.h
index 7bbdb07..5ca95dc 100644
--- a/ell/plugin.h
+++ b/ell/plugin.h
@@ -48,7 +48,8 @@ struct l_plugin_desc {
 		extern struct l_plugin_desc symbol \
 				__attribute__ ((visibility("default"))); \
 		struct l_plugin_desc symbol =3D { \
-			#name, description, version, priority, init, exit \
+			#name, description, version, priority, init, exit, \
+			NULL, NULL \
 		};
 =

 #define L_PLUGIN_DEFINE_DEBUG(symbol, name, description, version, \
-- =

2.17.1


--===============3502079102077350078==--

