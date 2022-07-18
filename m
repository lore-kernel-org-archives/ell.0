Received: from mail-oa1-f45.google.com (mail-oa1-f45.google.com [209.85.160.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9BAD133CC
	for <ell@lists.linux.dev>; Mon, 18 Jul 2022 16:08:37 +0000 (UTC)
Received: by mail-oa1-f45.google.com with SMTP id 586e51a60fabf-10cf9f5b500so23783878fac.2
        for <ell@lists.linux.dev>; Mon, 18 Jul 2022 09:08:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=T0yZmzVZsIi01ezIp6odCr2lCTUSdgwxASWd9vC9+Kg=;
        b=RgAdP1hwL0xD3sX72A7N9rxD76M2Oc0SoYt4BuvAOY+5YqwPG7BYZRTUehmtRLb9JD
         VJQG+y4eC0ZUyuXZHC4spMuHnwKh+g9x4l/nmtRnM6X4hCuFUjE/LhRNqBCZeJSNpKMp
         MpX3+Mz5eS3rP5xSJu31XFY0G04S37dZ5UQN9dHQEOYA5nJSqMe4FoPERNHNc9jMl1ZF
         dY4wY01HdpIOTEbcqfIK2F1OzTMGlKFMgsycbt8UHvv8Kzh8Tn/1ZTDOQRiPnyNIk/oU
         VsPwdsFNZoXrTUDgL8fOH42yZXFjJ+gxciJ/L7GBFnjk2tQG/mLjyf4mUgG1VmLLkVyu
         g4tQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=T0yZmzVZsIi01ezIp6odCr2lCTUSdgwxASWd9vC9+Kg=;
        b=np4PM3Dld9fnG7BJjyPc7iQzES56wsH+aA1YhCE7BJfAhyAHVmEbSFNuvCkerpPX1a
         Bz/Rd+TZsZGna4dE+S3VvWwRaBwTwF2vOiH3EhrAmMMBCAVb/bQVyAw3p7NxJQ+hWenp
         56bcnJrtH55PpDdHJJS4u2tKTn59gWZH7YI9KWylEZyddfnTiGeIIjO0C3qsGCZDrN6r
         u/XxEjjG3XLfJASF+x7VCZR3QOEopdbLJv0ywqURSKlypCmJHIYaNR74GSC4Fdb5V2f0
         614dWJuT672tp02ZfRPatqukwTwHENC3wtqeVt/rWZtAeeBWnq9QpRtLF3ZYarRwnhJ9
         DFzg==
X-Gm-Message-State: AJIora88ALHzR9VDjpf0JYaBvdAXgk4Zb17aBsMoRo0Fl1Ajit+cOd61
	tYm697ZnNfVP/vEH+WlsWnVT2PKLw9U=
X-Google-Smtp-Source: AGRyM1sRoFojpfTwp7esFbu/EXvRhfW+jK/MuWBgT1FtnmKGQ6OETc3lmPYqyyXuwq9yc+OZBVSdrg==
X-Received: by 2002:aca:d9d5:0:b0:339:f84e:ff15 with SMTP id q204-20020acad9d5000000b00339f84eff15mr16661916oig.25.1658160516606;
        Mon, 18 Jul 2022 09:08:36 -0700 (PDT)
Received: from localhost.localdomain (216.106.68.145.reverse.socket.net. [216.106.68.145])
        by smtp.gmail.com with ESMTPSA id t19-20020a9d5913000000b0061cae832e5dsm297941oth.3.2022.07.18.09.08.36
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 18 Jul 2022 09:08:36 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 4/9] tls: Support peer certificates that use ECDSA
Date: Mon, 18 Jul 2022 11:02:17 -0500
Message-Id: <20220718160222.10634-4-denkenz@gmail.com>
X-Mailer: git-send-email 2.35.1
In-Reply-To: <20220718160222.10634-1-denkenz@gmail.com>
References: <20220718160222.10634-1-denkenz@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

---
 ell/tls.c | 22 +++++++++++++++++++---
 1 file changed, 19 insertions(+), 3 deletions(-)

diff --git a/ell/tls.c b/ell/tls.c
index b2f7411f3b36..75b9d45c6523 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -1899,6 +1899,8 @@ static void tls_handle_certificate(struct l_tls *tls,
 	bool dummy;
 	const char *error_str;
 	char *subject_str;
+	enum l_key_cipher_type format_type;
+	enum l_checksum_type checksum_type;
 
 	if (len < 3)
 		goto decode_error;
@@ -2028,9 +2030,23 @@ static void tls_handle_certificate(struct l_tls *tls,
 		return;
 	}
 
-	if (!l_key_get_info(tls->peer_pubkey, L_KEY_RSA_PKCS1_V1_5,
-					L_CHECKSUM_NONE, &tls->peer_pubkey_size,
-					&dummy)) {
+	switch (l_cert_get_pubkey_type(tls->peer_cert)) {
+	case L_CERT_KEY_RSA:
+		format_type = L_KEY_RSA_PKCS1_V1_5;
+		checksum_type = L_CHECKSUM_NONE;
+		break;
+	case L_CERT_KEY_ECC:
+		format_type = L_KEY_ECDSA_X962;
+		checksum_type = L_CHECKSUM_SHA1;
+		break;
+	case L_CERT_KEY_UNKNOWN:
+		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+				"Unknown public key type");
+		return;
+	}
+
+	if (!l_key_get_info(tls->peer_pubkey, format_type, checksum_type,
+				&tls->peer_pubkey_size, &dummy)) {
 		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
 				"Can't l_key_get_info for peer public key");
 
-- 
2.35.1

