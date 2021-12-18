Received: from mail-pg1-f182.google.com (mail-pg1-f182.google.com [209.85.215.182])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 61E7C168
	for <ell@lists.linux.dev>; Sat, 18 Dec 2021 04:16:06 +0000 (UTC)
Received: by mail-pg1-f182.google.com with SMTP id l10so4032764pgm.7
        for <ell@lists.linux.dev>; Fri, 17 Dec 2021 20:16:06 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=CInVyS5GPbTsBafIrpt5EV1BaqBYwhcCk2cljX17i0U=;
        b=WKBoa4vTfqAcsWO4e/qa4eH9vf6LLGX/oBdimRlPdAlWwtY0pVs4RYXqW8hzkakYoc
         mtF/6CTaMY1UV+7BBz5s2oKUgWtRPzTU4xmjiuMCwKhCAfw3MdJEVV8CI0P4J55wEud+
         q9RzuWPJ5WFPsBtJbFMGncfqr59fpPrs1VAwcNpz4C39TSuhWONBIrB35VzFkGKs9jzw
         czNSVtxtmRp4wOs0FEKU1zVRaJsFvg1ol6/LMqbPQbIP7EIp2gTNLsxNzd3xcO9SKIfO
         uewN0+H3+TFZIPH/au7FCJV1lYVCZ0MZhh02T0mZ8uD+IErLZyuiIXI0Rf0UWd8vWkac
         zhxA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=CInVyS5GPbTsBafIrpt5EV1BaqBYwhcCk2cljX17i0U=;
        b=waGr9i3xLSFXJpnyIM21u+oryZzhKJZTcy8xlFgKVCTNxbFDz7uMwzY5XK+9o2co4r
         v/6ChZhyz1CLPbAqnp/ug+vsg+ILD2wki2kNyjSAp7ScbfzuJst3mjQxWQPwm7V3ttwF
         C2rLNijtHdAP7uPtOfh62Fs8XG7u+U5MeiB24Nhrl73TQ4dN2lDPWb2sLVFKMgQmxPf2
         1KmGPULCz88GZynAH/NSf/BtA9wfkZ2OTpvaMqpXM+XvpW6xLUs2ouAy67H+pnBuGKOC
         JVdsJvkFGALScnmnkfsHo0jpqJDgly6mLzAOCqHKKNQyPSNQhdSOmomyb1M35qWa79gu
         RWXw==
X-Gm-Message-State: AOAM531BzUWEmXTNozmPpOEzp4K2AzDQNbs/Kvtqmw5eIgrsuHMTlTo0
	+zjrLzMCsZqOuRB1F7mnAMv+N5ZbgqjEZg==
X-Google-Smtp-Source: ABdhPJxvsJ5w2I40u7p5UmyB/IiDwfPsNscyxC1+6EkL+i8J2Tafq9NWQPObGNk+J9h+5oAIv6QKkA==
X-Received: by 2002:a65:5ccb:: with SMTP id b11mr5607211pgt.408.1639800965780;
        Fri, 17 Dec 2021 20:16:05 -0800 (PST)
Received: from hydra.localdomain ([50.45.159.39])
        by smtp.gmail.com with ESMTPSA id kk7sm15004153pjb.19.2021.12.17.20.16.05
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 17 Dec 2021 20:16:05 -0800 (PST)
From: Ossama Othman <ossama.othman@gmail.com>
X-Google-Original-From: Ossama Othman <ossama.othman@intel.com>
To: ell@lists.linux.dev
Cc: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH] configure: Update to support Autoconf >= 2.69
Date: Fri, 17 Dec 2021 20:15:42 -0800
Message-Id: <20211218041543.114845-1-ossama.othman@intel.com>
X-Mailer: git-send-email 2.32.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Bootstrapping ELL against Autoconf 2.71 triggers warnings about use of
the deprecated Autoconf macros.  Replace use of the deprecated
AC_HELP_STRING and AC_LANG_C macros with AS_HELP_STRING and
AC_LANG([C]), respectively.

Bump the Autoconf prerequisite, accordingly, to support the updated
macros, from 2.60 to 2.69.  Only require Autoconf 2.69 as a
prerequisite since many Linux distributions do not yet ship with
Autoconf 2.71.  Autoconf 2.69 is over nine years old whereas 2.71 is
less than a year old.
---
 configure.ac | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/configure.ac b/configure.ac
index 2c20c20..ca778e4 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1,5 +1,5 @@
-AC_PREREQ(2.60)
-AC_INIT(ell, 0.46)
+AC_PREREQ([2.69])
+AC_INIT([ell],[0.46])
 
 AC_CONFIG_HEADERS(config.h)
 AC_CONFIG_AUX_DIR(build-aux)
@@ -16,7 +16,7 @@ AC_PREFIX_DEFAULT(/usr/local)
 
 COMPILER_FLAGS
 
-AC_LANG_C
+AC_LANG([C])
 
 AC_PROG_CC
 AC_PROG_CC_PIE
@@ -31,14 +31,14 @@ AC_C_BIGENDIAN(little_endian=no, little_endian=yes, little_endian=no)
 LT_PREREQ(2.2)
 LT_INIT([disable-static])
 
-AC_ARG_ENABLE(optimization, AC_HELP_STRING([--disable-optimization],
+AC_ARG_ENABLE(optimization, AS_HELP_STRING([--disable-optimization],
 			[disable code optimization through compiler]), [
 	if (test "${enableval}" = "no"); then
 		CFLAGS="$CFLAGS -U_FORTIFY_SOURCE -O0"
 	fi
 ])
 
-AC_ARG_ENABLE(debug, AC_HELP_STRING([--enable-debug],
+AC_ARG_ENABLE(debug, AS_HELP_STRING([--enable-debug],
 			[enable compiling with debugging information]), [
 	if (test "${enableval}" = "yes" &&
 				test "${ac_cv_prog_cc_g}" = "yes"); then
@@ -46,7 +46,7 @@ AC_ARG_ENABLE(debug, AC_HELP_STRING([--enable-debug],
 	fi
 ])
 
-AC_ARG_ENABLE(pie, AC_HELP_STRING([--enable-pie],
+AC_ARG_ENABLE(pie, AS_HELP_STRING([--enable-pie],
 			[enable position independent executables flag]), [
 	if (test "${enableval}" = "yes" &&
 				test "${ac_cv_prog_cc_pie}" = "yes"); then
@@ -59,7 +59,7 @@ save_LIBS=$LIBS
 AC_CHECK_LIB(asan, _init)
 LIBS=$save_LIBS
 
-AC_ARG_ENABLE(asan, AC_HELP_STRING([--enable-asan],
+AC_ARG_ENABLE(asan, AS_HELP_STRING([--enable-asan],
 			[enable linking with address sanitizer]), [
 	if (test "${enableval}" = "yes" &&
 				test "${ac_cv_lib_asan__init}" = "yes" &&
@@ -73,7 +73,7 @@ save_LIBS=$LIBS
 AC_CHECK_LIB(lsan, _init)
 LIBS=$save_LIBS
 
-AC_ARG_ENABLE(lsan, AC_HELP_STRING([--enable-lsan],
+AC_ARG_ENABLE(lsan, AS_HELP_STRING([--enable-lsan],
 			[enable linking with leak sanitizer]), [
 	if (test "${enableval}" = "yes" &&
 				test "${ac_cv_lib_lsan__init}" = "yes" &&
@@ -87,7 +87,7 @@ save_LIBS=$LIBS
 AC_CHECK_LIB(ubsan, _init)
 LIBS=$save_LIBS
 
-AC_ARG_ENABLE(ubsan, AC_HELP_STRING([--enable-ubsan],
+AC_ARG_ENABLE(ubsan, AS_HELP_STRING([--enable-ubsan],
 			[enable linking with undefined behavior sanitizer]), [
 	if (test "${enableval}" = "yes" &&
 				test "${ac_cv_lib_ubsan__init}" = "yes" &&
@@ -111,7 +111,7 @@ AC_CHECK_FUNC(epoll_create, dummy=yes,
 
 AC_CHECK_HEADERS(linux/types.h linux/if_alg.h)
 
-AC_ARG_ENABLE(glib, AC_HELP_STRING([--enable-glib],
+AC_ARG_ENABLE(glib, AS_HELP_STRING([--enable-glib],
 				[enable ell/glib main loop example]),
 					[enable_glib=${enableval}])
 
-- 
2.32.0

