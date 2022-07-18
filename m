Received: from mail-ot1-f53.google.com (mail-ot1-f53.google.com [209.85.210.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2377333DE
	for <ell@lists.linux.dev>; Mon, 18 Jul 2022 18:07:13 +0000 (UTC)
Received: by mail-ot1-f53.google.com with SMTP id l9-20020a056830268900b006054381dd35so9827109otu.4
        for <ell@lists.linux.dev>; Mon, 18 Jul 2022 11:07:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=29oFm2MRd8WOXPiKgW+CwuARozgbB44LaPdvRkUKu2k=;
        b=l7sryX0ZlMkl2iJK86JxHzI4ge5ilQriuWFECNuAVTYFeOyy7GxraBujO5iwyiCnKe
         SPe1oZPp2wg4x7rTP97WoD6eSlfkbfOQPTJY+0GFosiARtN8f3KcMweMLTLFXWc78y/t
         nmSXGfWna4JkzVO5937yppeOQgEdFp0VjYnCP3tcK3eOtuNvaxq9i0MOlL6f5Ulnc6vv
         hfoFdGpmZHT83WCfV5Y5QaZKpcx/bDWVSnnZYM5BCx2jJEy6g+9VpODD8t29kRg12ujl
         BOCAKRDeZJGYcAtpnVS+yBYfhCdm624ipxEzHSN8cf/C78yrlrnT0yhVZxzNNP6HEjYq
         asmA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=29oFm2MRd8WOXPiKgW+CwuARozgbB44LaPdvRkUKu2k=;
        b=sUbv0UdCBdNhBrsKeIrdk7f04b+rkNY7K3ZRxgMIsKOavTcEV/H7JB/A88S04XlU9v
         qJzea9KD508+CIgvKSiTsETM6UdgU7uwTsu9iawU7BcQTAPNak8tZ6w1ZCF3KEYyu0qL
         Z8Fo4syL1acqT+iQbzVS+i1urWkEFZRYRDObTtDV/GFBWLohnrRhFL84MN31tnSkO0+a
         l7st5BPF1kuO/yn9u8zfPIBmXpHksgye1OV/mhR2dRt1/FrI1Mrcb3v+JPQVBlPTm1B+
         +tlQHdsv6474lbPe6Vi4hg5GDeWyJW8oG4fawPCZl+5drOweRtbM7A9aHT7wmX+js57b
         Fbqg==
X-Gm-Message-State: AJIora/IzBOgU4ZcGHNmL2F+xBoTqc5onwaj4Dn7NbWS6jDiqnu58iWr
	zJ5wsnuUBiJdOmNzYhoMn48qe5T2R0I=
X-Google-Smtp-Source: AGRyM1tS9MCz2Wed6zxwPtbiBXQ9LgGFGnABCljP/fhVMyIHOlehoOmQW4jgam9yUp22AquKnhStmA==
X-Received: by 2002:a05:6830:608d:b0:616:ecd7:de2 with SMTP id by13-20020a056830608d00b00616ecd70de2mr11390750otb.119.1658167632023;
        Mon, 18 Jul 2022 11:07:12 -0700 (PDT)
Received: from localhost.localdomain (216.106.68.145.reverse.socket.net. [216.106.68.145])
        by smtp.gmail.com with ESMTPSA id n23-20020a056870559700b0010c727a3c79sm6808467oao.26.2022.07.18.11.07.11
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 18 Jul 2022 11:07:11 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH v2 04/10] tls: Support peer certificates that use ECDSA
Date: Mon, 18 Jul 2022 13:00:39 -0500
Message-Id: <20220718180045.5845-4-denkenz@gmail.com>
X-Mailer: git-send-email 2.35.1
In-Reply-To: <20220718180045.5845-1-denkenz@gmail.com>
References: <20220718180045.5845-1-denkenz@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

---
v2 - Rework slightly to fix (false-positive) compiler warnings

 ell/tls.c | 24 +++++++++++++++++++-----
 1 file changed, 19 insertions(+), 5 deletions(-)

diff --git a/ell/tls.c b/ell/tls.c
index b2f7411f3b36..136aa8660c2a 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -2028,12 +2028,22 @@ static void tls_handle_certificate(struct l_tls *tls,
 		return;
 	}
 
-	if (!l_key_get_info(tls->peer_pubkey, L_KEY_RSA_PKCS1_V1_5,
-					L_CHECKSUM_NONE, &tls->peer_pubkey_size,
-					&dummy)) {
+	switch (l_cert_get_pubkey_type(tls->peer_cert)) {
+	case L_CERT_KEY_RSA:
+		if (!l_key_get_info(tls->peer_pubkey, L_KEY_RSA_PKCS1_V1_5,
+				L_CHECKSUM_NONE,
+				&tls->peer_pubkey_size, &dummy))
+			goto pubkey_unsupported;
+		break;
+	case L_CERT_KEY_ECC:
+		if (!l_key_get_info(tls->peer_pubkey, L_KEY_ECDSA_X962,
+				L_CHECKSUM_SHA1,
+				&tls->peer_pubkey_size, &dummy))
+			goto pubkey_unsupported;
+		break;
+	case L_CERT_KEY_UNKNOWN:
 		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
-				"Can't l_key_get_info for peer public key");
-
+				"Unknown public key type");
 		return;
 	}
 
@@ -2047,6 +2057,10 @@ static void tls_handle_certificate(struct l_tls *tls,
 
 	return;
 
+pubkey_unsupported:
+	TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+				"Can't l_key_get_info for peer public key");
+	return;
 decode_error:
 	TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
 			"TLS_CERTIFICATE decode error");
-- 
2.35.1

