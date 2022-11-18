Received: from mail-pj1-f54.google.com (mail-pj1-f54.google.com [209.85.216.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B0FBEA486
	for <ell@lists.linux.dev>; Fri, 18 Nov 2022 21:16:39 +0000 (UTC)
Received: by mail-pj1-f54.google.com with SMTP id e7-20020a17090a77c700b00216928a3917so9389779pjs.4
        for <ell@lists.linux.dev>; Fri, 18 Nov 2022 13:16:39 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=iKzhesTFajQVvwTbLAvwUZNKcxRxw/E6jJUq8iKxE5E=;
        b=R7ToEBNNsXC+Lr4su+C7gBG9thb24sHxcODmeG8PTw/ekF9BAZ4crYTR7tsRZzY4iz
         y3oFzlnKtVDmcL2qOTsBfuJv3jSFZdq+fTuZrfkgr/xmtgsvLEbj1Y6GBSd1oWolFkkz
         flTWdbli7f0u2fcM+HVQG2NtqDHksZT+XAdkkJZuSNNutd2+WKFfD5VmnAtLmDdjySEq
         EpdoTUHCuKsaRbSaJLPnLCBQ1oWRyEA5lcaGuo4MIMk3GSzqzVxe/0GSkZyc2wXrrgNB
         UQd4ZU829YfC6H+U01iEc5+oIQB/qHrgvqMZ7l7kv5SUpFQsJbZ4/eOxEvd5T30noEhD
         UOdA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=iKzhesTFajQVvwTbLAvwUZNKcxRxw/E6jJUq8iKxE5E=;
        b=JqPN96wF2NUCDAxXDfp4h5Y5JC4Xp028GmsSoFf6VdAE/I7Mi22AKYQ2SGYgxK057f
         3mzzkT5N93NQIyhgZur/F2dDMlA7+5mIE5WT6EUfHhK+iqnPxh3RBwqkq7clwPp8A41+
         eJpkHq+3Mmq2R56oT2t6ugnNAAbS5T4Y4REwMuV7OS+ppnmgt1VKFWpwQxclT9m1WoE1
         awng65rnLmh/gpdVoL8QGHQr3RaOh8TtWlwOw2q+QbxA0+i4D3nKYiZ1OUutPAxQx3yJ
         C8M/cQ9eDeLHQivt5PcJixesFBb8H1H2hPlZl/yS9KkqYhui+noVUJA4MswHN/iq4JZ6
         SvIA==
X-Gm-Message-State: ANoB5pm/BM1jHeRrGZQUbhG9/KOMc+Ybc60F4nTQ6QEd0VwZx2l+a6JL
	BIN4gJcIwKtZhyH6LEk02V1nk0fh+4Y=
X-Google-Smtp-Source: AA0mqf7JzG2+QYeezdPTVJxntGwCmZdev5j+6kNie+X4aBDBLgdZ96WLOpPEZ8mPhYtPV/z4UXYiUQ==
X-Received: by 2002:a17:902:ccce:b0:185:4880:91cd with SMTP id z14-20020a170902ccce00b00185488091cdmr1203929ple.130.1668806198930;
        Fri, 18 Nov 2022 13:16:38 -0800 (PST)
Received: from jprestwo-xps.none ([50.39.160.234])
        by smtp.gmail.com with ESMTPSA id y12-20020aa79aec000000b0056ee49d6e95sm3630142pfp.86.2022.11.18.13.16.38
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 18 Nov 2022 13:16:38 -0800 (PST)
From: James Prestwood <prestwoj@gmail.com>
To: ell@lists.linux.dev
Cc: James Prestwood <prestwoj@gmail.com>
Subject: [RFC 0/8] Crypto operations by key ID
Date: Fri, 18 Nov 2022 13:16:16 -0800
Message-Id: <20221118211624.19298-1-prestwoj@gmail.com>
X-Mailer: git-send-email 2.34.3
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

This adds support for several key based crypto opterations but
instead of using a key directly it uses a key ID. This avoids
the need for ELL to ever hold a copy of the key assuming it
already exists in the kernel.

The motivation behind this is to enhance IWDs profile encryption.
Currently this uses a systemd feature but ultimately the secret
key is decrypted and put onto the file system for IWD to use.
This isn't desirable and it would be better if the key never hits
the FS, and even better if IWD never even sees it. This would
allow some external, trusted, entity (e.g. PAM/systemd-logind) to
set a secret key into the kernel upon user login (e.g. the users
password). This key ID could then be used by IWD to encrypt
profiles without ever seeing the actual key.

James Prestwood (8):
  key: add l_key_search
  unit: add key search test
  checksum: commonize checksum creation
  checksum: add l_checksum_new_hmac_from_key_id
  cert-crypto: refactor l_cert_pkcs5_pbkdf2
  cert: add l_cert_pkcs5_pbkdf2_from_key_id
  cert: add explicit length to l_cert_pkcs5_pbkdf2
  unit: update test-pbkdf2 with API change

 ell/cert-crypto.c  |  97 +++++++++++++++++++++++++++-----------
 ell/cert.h         |   7 ++-
 ell/checksum.c     | 114 ++++++++++++++++++++-------------------------
 ell/checksum.h     |   2 +
 ell/ell.sym        |   3 ++
 ell/key.c          |  46 ++++++++++++++++++
 ell/key.h          |   3 ++
 unit/test-key.c    |  26 +++++++++++
 unit/test-pbkdf2.c |   1 +
 9 files changed, 208 insertions(+), 91 deletions(-)

-- 
2.34.3

