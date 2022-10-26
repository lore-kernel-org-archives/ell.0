Received: from mail-wr1-f52.google.com (mail-wr1-f52.google.com [209.85.221.52])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2A096138F
	for <ell@lists.linux.dev>; Wed, 26 Oct 2022 13:16:19 +0000 (UTC)
Received: by mail-wr1-f52.google.com with SMTP id z14so12763142wrn.7
        for <ell@lists.linux.dev>; Wed, 26 Oct 2022 06:16:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=RTwfpyEyl2k3fJzkWZFbxgXBb+Ymb7S9/4wV0ao/68c=;
        b=dEBmaSTPKfi1/ChB9nL0Pmsng0C8oMRMKDHmnLyFPCQGE7HrcUAPMCoTdnHtsVk2Vb
         6ORPKoEVcIshT6ROO+nNA8r5TktTKCT6meEV3tmEtztenMx+zVsHtt/Tu3SMYGJFVO7R
         LTqsf2rscp2JRPcuhRzko2LIba1c8ZBkT3lLBgscARcVJBXNftS5amUcH2Um9xX8ZeTF
         aIZdwr5TMwXCZwf2aK3Yawv/XYpZ2qnrzQZc0sN60fHEM5WC962LFpiqvH/FzUWrUXwX
         o4eJALURcmYIZUx7JWVZDDMlcZ8w26Kd2unpq3JMeMo/y3agqp2wC0A6F2gP/NJZVjZI
         ijaQ==
X-Gm-Message-State: ACrzQf2MQa6WSnEALXMRygbgmHKcJ4ko/x62hFOZK+hhqGPvi1/MJ3uy
	Wrd9sJqMouWTLb4z0UEMF0fhI8nfMBA=
X-Google-Smtp-Source: AMsMyM5XzH57ZljALPRtUTptdO6hL9n2cksujrs/M/Nevqp8PyTF6I4AAlUY8r4qAyoeLrbpNBnNkQ==
X-Received: by 2002:a5d:58d9:0:b0:236:5b81:2c99 with SMTP id o25-20020a5d58d9000000b002365b812c99mr16542886wrf.494.1666790176537;
        Wed, 26 Oct 2022 06:16:16 -0700 (PDT)
Received: from localhost.localdomain ([82.213.230.158])
        by smtp.gmail.com with ESMTPSA id x23-20020a05600c21d700b003a83ca67f73sm1934771wmj.3.2022.10.26.06.16.15
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 26 Oct 2022 06:16:15 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 6/6] examples: Cache sessions in https-client-test
Date: Wed, 26 Oct 2022 15:15:58 +0200
Message-Id: <20221026131558.2393488-6-andrew.zaborowski@intel.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20221026131558.2393488-1-andrew.zaborowski@intel.com>
References: <20221026131558.2393488-1-andrew.zaborowski@intel.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

If the environment variable TLS_CACHE is set, use
l_tls_set_session_cache() to enable session resumption.
---
 examples/https-client-test.c | 48 ++++++++++++++++++++++++++++++++++++
 1 file changed, 48 insertions(+)

diff --git a/examples/https-client-test.c b/examples/https-client-test.c
index b0c24b4..2c6939a 100644
--- a/examples/https-client-test.c
+++ b/examples/https-client-test.c
@@ -32,13 +32,18 @@
 #include <unistd.h>
 #include <errno.h>
 #include <arpa/inet.h>
+#include <sys/stat.h>
+#include <fcntl.h>
 
 #include <ell/ell.h>
+#include <ell/useful.h>
 
 static struct l_io *io;
 static struct l_tls *tls;
 static const char *hostname;
 static bool ready;
+static struct l_settings *session_cache;
+static char *session_cache_path;
 
 static void https_io_disconnect(struct l_io *io, void *user_data)
 {
@@ -127,6 +132,27 @@ static void https_tls_debug_cb(const char *str, void *user_data)
 	printf("%s\n", str);
 }
 
+static void https_tls_session_cache_update_cb(void *user_data)
+{
+	size_t len;
+	char *data = l_settings_to_data(session_cache, &len);
+	_auto_(close) int fd = L_TFR(creat(session_cache_path, 0600));
+
+	if (!data) {
+		fprintf(stderr, "l_settings_to_data() failed\n");
+		return;
+	}
+
+	if (fd < 0) {
+		fprintf(stderr, "can't open %s: %s\n",
+			session_cache_path, strerror(errno));
+		return;
+	}
+
+	if (L_TFR(write(fd, data, len)) < (ssize_t) len)
+		fprintf(stderr, "short write to %s\n", session_cache_path);
+}
+
 int main(int argc, char *argv[])
 {
 	struct hostent *he;
@@ -200,6 +226,23 @@ int main(int argc, char *argv[])
 		l_free(str);
 	}
 
+	if (getenv("TLS_CACHE")) {
+		const char *homedir = getenv("HOME");
+
+		if (!homedir)
+			homedir = "/tmp";
+
+		session_cache_path =
+			l_strdup_printf("%s/.ell-https-client-test", homedir);
+		session_cache = l_settings_new();
+		l_settings_load_from_file(session_cache, session_cache_path);
+
+		l_tls_set_session_cache(tls, session_cache, hostname,
+					24 * 3600 * L_USEC_PER_SEC,
+					https_tls_session_cache_update_cb,
+					NULL);
+	}
+
 	if (argc >= 3) {
 		ca_cert = l_pem_load_certificate_list(argv[2]);
 		if (!ca_cert) {
@@ -244,6 +287,11 @@ int main(int argc, char *argv[])
 	l_io_destroy(io);
 	l_tls_free(tls);
 
+	if (session_cache) {
+		l_settings_free(session_cache);
+		l_free(session_cache_path);
+	}
+
 	l_main_exit();
 
 	return 0;
-- 
2.34.1

