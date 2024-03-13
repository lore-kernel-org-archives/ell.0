Received: from mail-yb1-f181.google.com (mail-yb1-f181.google.com [209.85.219.181])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6C77C52F7A
	for <ell@lists.linux.dev>; Wed, 13 Mar 2024 16:44:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.219.181
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1710348272; cv=none; b=RaKzHNCqgCR5Kkt8zY5wvuX0q03mIrmVqCTBdW7+AueLG90dQRmm2/P5N1yZOkqO+q48gIvE5j1JVokzuVQ0lk+KxPzATulDzUOHZ7u0xeXsn9jTWFJtJwNgBaYgWSt40lqWWlZxKiAvfhz4eq4X4Uk98oD2zdDTvBRktUzis9Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1710348272; c=relaxed/simple;
	bh=uT41nuH94BvBe/EKw0UGjjBDyVrQlfXiYOj3zqHpoMA=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=BD/kLB42/77e93lYnTLu4H+PeV33t/XB8j08HE4kHuFZtSY7iRwgQmv7p/1Uon0z5bT9V2RApm94IOi4D64Ekiqy2jIp4iWVKy37mOax47UquG3S8dT1t/h6x0iVHVrfW5YR6thhfzf+LP0yvErt7Warf/hypcb5IU1Xnlugt2w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=HPhSXpvH; arc=none smtp.client-ip=209.85.219.181
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HPhSXpvH"
Received: by mail-yb1-f181.google.com with SMTP id 3f1490d57ef6-dcbcea9c261so5590484276.3
        for <ell@lists.linux.dev>; Wed, 13 Mar 2024 09:44:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1710348270; x=1710953070; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=nmgZQtJiItRxkAkmjC0R21uUgcdvd2A7lw4k+RinDMY=;
        b=HPhSXpvHeHyTLVbncFUwFxKF2ttP7omjpZjPPfucCx/4P7dUrAAaPh9kGa2Ow+mwCt
         Z8Lnp8BX4g/v1ax9+C3RoOl42xl8pdRwLRriPE17k60oluZXvApYYlHdzGLb72XgkKMY
         iCMOJfxkoDvq/LdUwPt7LspG5KMsOvy5Vgxw45QVXEy6aa6Jrk9jwJPVzK36Er3GIrRR
         GWzfx8p+P+KnD1aSyON0tFq/ykwdbza2IrSTgVYvvulUOgQNtAquqSksIiYalVpPTvID
         mFEpi+XawMXCE4VVqdn4v0+h8PevkTEYFgTbv0Dh8s/dK/qae9QbUrrU4jtMZ8Pcg8gU
         cOMg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1710348270; x=1710953070;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=nmgZQtJiItRxkAkmjC0R21uUgcdvd2A7lw4k+RinDMY=;
        b=buR5zN28P2Vkp08Q9PFt5+Fi8P3v74+TE9tcSXN4fHWxRgs0IVemrjn2AjmCVDpxQS
         axPTpBqyvg4ygoioKLgaDf3ACpPIABLfMJwLH1acNiEOExEs7PABuWJbG2vGUa1QN3C/
         Y16BUmtfAhSoNB3G3NHT3aRViOdLcuWwFu5DKt8w7PR6dPUhtYEMX50eb80TowexI++0
         55GYiKVWdoc80iNRkK78mHQkDf1NlJLRV3p3J12rJcgNJTcWJ4bOv4Cujc9022IkvfaF
         YYQkQ4H6nDyyGyVoNBFU/izdzToVkw45G8uMtB+QLGlAoOnhchY+3zd0DueloX3/uLEf
         ID/w==
X-Gm-Message-State: AOJu0Yy+4c5gIFqErza5nb9EAXF0bsGMnZiYtmz7oLDFVOuXue5/XZIa
	WR/U0ZvR0emavw45ZXEvQXGCZk6re9xR2qVYhsNCDPmxFSJw0Oej4gOa+CGc
X-Google-Smtp-Source: AGHT+IEcRgT8cfOCxkT56tlP1zmD7D1hSpyPH3gSaFejsfgYbon20YN0e7r/EEej0buISPFqqDcxlg==
X-Received: by 2002:a25:9b42:0:b0:dcc:52dc:deb5 with SMTP id u2-20020a259b42000000b00dcc52dcdeb5mr2752680ybo.20.1710348270095;
        Wed, 13 Mar 2024 09:44:30 -0700 (PDT)
Received: from LOCLAP699.rst-01.locus ([208.195.13.130])
        by smtp.gmail.com with ESMTPSA id g1-20020a25db01000000b00dc6c58ae000sm2332549ybf.16.2024.03.13.09.44.29
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 13 Mar 2024 09:44:29 -0700 (PDT)
From: James Prestwood <prestwoj@gmail.com>
To: ell@lists.linux.dev
Cc: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 1/2] ecc: add l_ecc_scalar_clone
Date: Wed, 13 Mar 2024 09:44:24 -0700
Message-Id: <20240313164425.690572-1-prestwoj@gmail.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

---
 ell/ecc.c   | 8 ++++++++
 ell/ecc.h   | 1 +
 ell/ell.sym | 1 +
 3 files changed, 10 insertions(+)

diff --git a/ell/ecc.c b/ell/ecc.c
index 8302347..d8d9c1f 100644
--- a/ell/ecc.c
+++ b/ell/ecc.c
@@ -806,6 +806,14 @@ LIB_EXPORT struct l_ecc_scalar *l_ecc_scalar_new(
 	return NULL;
 }
 
+LIB_EXPORT struct l_ecc_scalar *l_ecc_scalar_clone(const struct l_ecc_scalar *s)
+{
+	if (!s)
+		return NULL;
+
+	return l_memdup(s, sizeof(*s));
+}
+
 /*
  * Build a scalar = value modulo p where p is the prime number for a given
  * curve.  bytes can contain a number with up to 2x number of digits as the
diff --git a/ell/ecc.h b/ell/ecc.h
index 5a8cf03..3502b98 100644
--- a/ell/ecc.h
+++ b/ell/ecc.h
@@ -62,6 +62,7 @@ DEFINE_CLEANUP_FUNC(l_ecc_point_free);
 
 struct l_ecc_scalar *l_ecc_scalar_new(const struct l_ecc_curve *curve,
 						const void *buf, size_t len);
+struct l_ecc_scalar *l_ecc_scalar_clone(const struct l_ecc_scalar *s);
 struct l_ecc_scalar *l_ecc_scalar_new_random(
 					const struct l_ecc_curve *curve);
 struct l_ecc_scalar *l_ecc_scalar_new_modp(const struct l_ecc_curve *curve,
diff --git a/ell/ell.sym b/ell/ell.sym
index 2c207d6..28b55d3 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -611,6 +611,7 @@ global:
 	l_ecc_scalar_legendre;
 	l_ecc_scalar_multiply;
 	l_ecc_scalar_new;
+	l_ecc_scalar_clone;
 	l_ecc_scalar_new_random;
 	l_ecc_scalar_new_modp;
 	l_ecc_scalar_new_modn;
-- 
2.34.1

