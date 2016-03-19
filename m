Content-Type: multipart/mixed; boundary="===============2732778228801779614=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] dbus: Replace copy_params/size_params with macros.
Date: Sat, 19 Mar 2016 07:00:40 +0100
Message-ID: <1458367247-14607-2-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1458367247-14607-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2732778228801779614==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Passing va_list to functions this way doesn't work on i386 gcc, va_list
seems to be a simple pointer as recommended by stdarg(3).  Passing a
pointer to va_list seems to fix this, but stdarg(3) also says:

   If ap is passed to a function that uses va_arg(ap,type), then the value
   of ap is undefined after the return of that function.

so it's better to just use a macro.
---
 ell/dbus-service.c | 98 ++++++++++++++++++++++----------------------------=
----
 1 file changed, 40 insertions(+), 58 deletions(-)

diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index c1ed9ec..e11a6d0 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -259,39 +259,34 @@ void _dbus_interface_introspection(struct l_dbus_inte=
rface *interface,
 	l_string_append(buf, "\t</interface>\n");
 }
 =

-static char *copy_params(char *dest, const char *signature, va_list args)
-{
-	const char *pname;
-	const char *sig;
-
-	for (sig =3D signature; *sig; sig++) {
-		sig =3D _dbus_signature_end(sig);
-		if (!sig)
-			return NULL;
-
-		pname =3D va_arg(args, const char *);
-		dest =3D stpcpy(dest, pname) + 1;
-	}
-
-	return dest;
-}
-
-static bool size_params(const char *signature, va_list args, unsigned int =
*len)
-{
-	const char *pname;
-	const char *sig;
-
-	for (sig =3D signature; *sig; sig++) {
-		sig =3D _dbus_signature_end(sig);
-		if (!sig)
-			return false;
-
-		pname =3D va_arg(args, const char *);
-		*len +=3D strlen(pname) + 1;
-	}
-
-	return true;
-}
+#define COPY_PARAMS(dest, signature, args)	\
+	do {	\
+		const char *pname;	\
+		const char *sig;	\
+		dest =3D stpcpy(dest, signature) + 1;	\
+		for (sig =3D signature; *sig; sig++) {	\
+			sig =3D _dbus_signature_end(sig);	\
+			pname =3D va_arg(args, const char *);	\
+			dest =3D stpcpy(dest, pname) + 1;	\
+		}	\
+	} while(0)
+
+#define SIZE_PARAMS(signature, args)	\
+	({	\
+		unsigned int len =3D strlen(signature) + 1;	\
+		const char *pname;	\
+		const char *sig;	\
+		for (sig =3D signature; *sig; sig++) {	\
+			sig =3D _dbus_signature_end(sig);	\
+			if (!sig) {	\
+				len =3D 0;	\
+				break;	\
+			}	\
+			pname =3D va_arg(args, const char *);	\
+			len +=3D strlen(pname) + 1;	\
+		}	\
+		len;	\
+	})
 =

 LIB_EXPORT bool l_dbus_interface_method(struct l_dbus_interface *interface,
 					const char *name, uint32_t flags,
@@ -318,19 +313,16 @@ LIB_EXPORT bool l_dbus_interface_method(struct l_dbus=
_interface *interface,
 		return false;
 =

 	/* Pre-calculate the needed meta-info length */
-	return_info_len =3D strlen(return_sig) + 1;
-	param_info_len =3D strlen(param_sig) + 1;
-
 	va_start(args, param_sig);
 =

-	if (!size_params(return_sig, args, &return_info_len))
-		goto error;
-
-	if (!size_params(param_sig, args, &param_info_len))
-		goto error;
+	return_info_len =3D SIZE_PARAMS(return_sig, args);
+	param_info_len =3D SIZE_PARAMS(param_sig, args);
 =

 	va_end(args);
 =

+	if (!return_info_len || !param_info_len)
+		return false;
+
 	info =3D l_malloc(sizeof(*info) + return_info_len +
 					param_info_len + strlen(name) + 1);
 	info->cb =3D cb;
@@ -345,22 +337,16 @@ LIB_EXPORT bool l_dbus_interface_method(struct l_dbus=
_interface *interface,
 	 * lookups during the message dispatch procedures.
 	 */
 	p =3D info->metainfo + info->name_len + param_info_len + 1;
-	p =3D stpcpy(p, return_sig) + 1;
-	p =3D copy_params(p, return_sig, args);
+	COPY_PARAMS(p, return_sig, args);
 =

 	p =3D info->metainfo + info->name_len + 1;
-	p =3D stpcpy(p, param_sig) + 1;
-	p =3D copy_params(p, param_sig, args);
+	COPY_PARAMS(p, param_sig, args);
 =

 	va_end(args);
 =

 	l_queue_push_tail(interface->methods, info);
 =

 	return true;
-
-error:
-	va_end(args);
-	return false;
 }
 =

 LIB_EXPORT bool l_dbus_interface_signal(struct l_dbus_interface *interface,
@@ -382,17 +368,14 @@ LIB_EXPORT bool l_dbus_interface_signal(struct l_dbus=
_interface *interface,
 		return false;
 =

 	/* Pre-calculate the needed meta-info length */
-	metainfo_len =3D strlen(name) + 1;
-	metainfo_len +=3D strlen(signature) + 1;
-
 	va_start(args, signature);
+	metainfo_len =3D SIZE_PARAMS(signature, args);
+	va_end(args);
 =

-	if (!size_params(signature, args, &metainfo_len)) {
-		va_end(args);
+	if (!metainfo_len)
 		return false;
-	}
 =

-	va_end(args);
+	metainfo_len +=3D strlen(name) + 1;
 =

 	info =3D l_malloc(sizeof(*info) + metainfo_len);
 	info->flags =3D flags;
@@ -401,8 +384,7 @@ LIB_EXPORT bool l_dbus_interface_signal(struct l_dbus_i=
nterface *interface,
 	p =3D stpcpy(info->metainfo, name) + 1;
 =

 	va_start(args, signature);
-	p =3D stpcpy(p, signature) + 1;
-	p =3D copy_params(p, signature, args);
+	COPY_PARAMS(p, signature, args);
 	va_end(args);
 =

 	l_queue_push_tail(interface->signals, info);
-- =

2.5.0


--===============2732778228801779614==--

