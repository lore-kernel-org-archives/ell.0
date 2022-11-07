Received: from mail-ej1-f42.google.com (mail-ej1-f42.google.com [209.85.218.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DA90C33EE
	for <ell@lists.linux.dev>; Mon,  7 Nov 2022 11:30:22 +0000 (UTC)
Received: by mail-ej1-f42.google.com with SMTP id y14so29207449ejd.9
        for <ell@lists.linux.dev>; Mon, 07 Nov 2022 03:30:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=00ucuP6atKf0+P2hkGhqHz41HN6Oz1trC/Xfe2PNjEU=;
        b=1n3q2n4UjyNb0N9dK1jej1mMKfPM/LBk83X9BW0dmVahG/f00Wqzsl6zIRe2Qp9mgM
         NQYVCnRBkU63OMF1jIgGTxTxBs9OL2Nuxn8WVfyU2uBQWjAvmB1rFNk4vt1iZ8OfA1WZ
         Ern61vkc87cKnh7gpK6bjAiFJRAEbrtcUZDKBmp7IAPTBMVpoEqzQxj/UhPN3POtrn0E
         KS2u/vvoNO1z0WYdIvkSUSukKsiiYYsUd+E1kcr/9vot5NPzNPSCXj7xVh9m/G947kke
         0dB1rUwvjFqxBkbnS44HL6OucBazULTpT/0WtbhLDE+FbXt9aHOLhpQR8VTVy0mHDbMI
         1HVg==
X-Gm-Message-State: ACrzQf34BD24OJGYogheKOVWfRgshTANqo2GvqZdlhak/Ufejr1QpQKI
	u/1Rs4ev2nxtz2ZAvJWGvGpaY5abm9M=
X-Google-Smtp-Source: AMsMyM4YdeP3Dq9S5aIFs7fvXBgTKYpbt/IF/7K3p8Hx8t/woWPzobU4Pqg9kk47jhODmNGcpWyMew==
X-Received: by 2002:a17:907:2672:b0:781:dc01:6c5a with SMTP id ci18-20020a170907267200b00781dc016c5amr48242949ejc.191.1667820620218;
        Mon, 07 Nov 2022 03:30:20 -0800 (PST)
Received: from iss.ger.corp.intel.com ([82.213.230.158])
        by smtp.gmail.com with ESMTPSA id x16-20020a170906135000b007ae32daf4b9sm3259769ejb.106.2022.11.07.03.30.19
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 07 Nov 2022 03:30:19 -0800 (PST)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 3/3] examples: Update https example code
Date: Mon,  7 Nov 2022 12:30:12 +0100
Message-Id: <20221107113012.328918-3-andrew.zaborowski@intel.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20221107113012.328918-1-andrew.zaborowski@intel.com>
References: <20221107113012.328918-1-andrew.zaborowski@intel.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Update the l_tls_set_session_cache call signature in https-client-test
and add similar session caching support in https-server-test.
---
 examples/https-client-test.c |  2 +-
 examples/https-server-test.c | 43 ++++++++++++++++++++++++++++++++++++
 2 files changed, 44 insertions(+), 1 deletion(-)

diff --git a/examples/https-client-test.c b/examples/https-client-test.c
index 2c6939a..6b12f77 100644
--- a/examples/https-client-test.c
+++ b/examples/https-client-test.c
@@ -238,7 +238,7 @@ int main(int argc, char *argv[])
 		l_settings_load_from_file(session_cache, session_cache_path);
 
 		l_tls_set_session_cache(tls, session_cache, hostname,
-					24 * 3600 * L_USEC_PER_SEC,
+					24 * 3600 * L_USEC_PER_SEC, 0,
 					https_tls_session_cache_update_cb,
 					NULL);
 	}
diff --git a/examples/https-server-test.c b/examples/https-server-test.c
index b626fd2..5e861d5 100644
--- a/examples/https-server-test.c
+++ b/examples/https-server-test.c
@@ -32,12 +32,17 @@
 #include <unistd.h>
 #include <errno.h>
 #include <arpa/inet.h>
+#include <sys/stat.h>
+#include <fcntl.h>
 
 #include <ell/ell.h>
+#include <ell/useful.h>
 
 static struct l_io *io;
 static struct l_tls *tls;
 bool served;
+static struct l_settings *session_cache;
+static char *session_cache_path;
 
 static void https_io_disconnect(struct l_io *io, void *user_data)
 {
@@ -115,6 +120,27 @@ static void https_tls_debug_cb(const char *str, void *user_data)
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
 	struct sockaddr_in addr = {};
@@ -210,6 +236,23 @@ int main(int argc, char *argv[])
 		l_free(str);
 	}
 
+	if (getenv("TLS_CACHE")) {
+		const char *homedir = getenv("HOME");
+
+		if (!homedir)
+			homedir = "/tmp";
+
+		session_cache_path =
+			l_strdup_printf("%s/.ell-https-server-test", homedir);
+		session_cache = l_settings_new();
+		l_settings_load_from_file(session_cache, session_cache_path);
+
+		l_tls_set_session_cache(tls, session_cache, "tls-session",
+					24 * 3600 * L_USEC_PER_SEC, 10,
+					https_tls_session_cache_update_cb,
+					NULL);
+	}
+
 	auth_ok = l_tls_set_auth_data(tls, cert, priv_key) &&
 		(argc <= 4 || l_tls_set_cacert(tls, ca_cert)) &&
 		l_tls_start(tls);
-- 
2.34.1

