Received: from mail-pj1-f47.google.com (mail-pj1-f47.google.com [209.85.216.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3B9222CAE
	for <ell@lists.linux.dev>; Sat, 18 Dec 2021 04:15:10 +0000 (UTC)
Received: by mail-pj1-f47.google.com with SMTP id c22-20020a17090a109600b001b101f02dd1so7446150pja.5
        for <ell@lists.linux.dev>; Fri, 17 Dec 2021 20:15:10 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=bAeKdw0mH7rnDXP3tO9iUA7fazJ5wgkv5c0rwgIscFY=;
        b=RrjOtmeoHepyQ+PiMFijddppPKoLKxRW3iBFnY5XXzno3bRdZkSUfjdqakqEsSEuVv
         SNfXy+6mNms0Q9TuXiQDgmOVhi2ufcTJ8I9w030oOVCw8MvADgl5N90DfVgAMMFr7Hq+
         BT3wZSTy5FD2UW47pXw6dOvu8yzFOKc0XPJ/kQVUUO0D2mwaBiZ6evRoRcZrRt6551YD
         ulNe+9om/BFJYqZzGPA9AKCIqVqNP1Aj0G7CGTlSKbzqB4FKStcZXRmxz1Orr36E6pv+
         PPYEesRbTu1sULubT3LVu+/pnE5a5++zdwI5EY7sH3p5HQUN+lfrsy+hOhshFMqLQBx6
         nBvg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=bAeKdw0mH7rnDXP3tO9iUA7fazJ5wgkv5c0rwgIscFY=;
        b=SVzoQOMFSJ1/ybfly7AY8F3gd6jeeSKZaJq5/apRUPQ0i7TntRdepLToK08/jzWC8x
         R/RB3tc0xWotO7GmZGEffZ8rlIbbHt8mAqWG0iWMmQvQL0nfS7+MBU0Li6B7B8UnQM2X
         AC4m3SW6Kl8XvK0gtiEk/rIzlYWQLl7AIBfur5CUsem0OYWyxluMCxh6kdEIL59//jxw
         4xHzEd9kPZ5l/Nuahy1BkTf/IcFtg39uitvm0C4NwFQEYeKiqI8N8hBr98Bnc4w1yWiH
         R59axEqm6nDn4C9kL0InVqUhXViQXyut8KRL9Y93Ccd0uBA3cuC1hDo+FN1ghfuNVMZz
         rozA==
X-Gm-Message-State: AOAM532gf+H06krQoaUpk8QOzmgcFDZg4ExX4+smahpXZ/NsAGos/9Vn
	HNhnpvTZJHPWz3RfFCZqirXW37eCQScliA==
X-Google-Smtp-Source: ABdhPJykPzNI1V4dyE0X+m5SZHIIQBgoYax3C6XrIKAV+QReiNNLA1dPD+7VTALtME87ZDp3qrM7VA==
X-Received: by 2002:a17:902:74c1:b0:148:b010:5391 with SMTP id f1-20020a17090274c100b00148b0105391mr6354075plt.155.1639800909301;
        Fri, 17 Dec 2021 20:15:09 -0800 (PST)
Received: from hydra.localdomain ([50.45.159.39])
        by smtp.gmail.com with ESMTPSA id qe2sm10194506pjb.42.2021.12.17.20.15.08
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 17 Dec 2021 20:15:08 -0800 (PST)
From: Ossama Othman <ossama.othman@gmail.com>
X-Google-Original-From: Ossama Othman <ossama.othman@intel.com>
To: ell@lists.linux.dev
Cc: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 0/3] Fix Valgrind errors
Date: Fri, 17 Dec 2021 20:14:28 -0800
Message-Id: <20211218041431.114737-1-ossama.othman@intel.com>
X-Mailer: git-send-email 2.32.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Running the ELL test suite through Valgrind triggers a few errors.
This set of patches addresses three of those errors.

Ossama Othman (3):
  dhcp-server: Fix memory leak.
  unit: Free l_uintset when done.
  unit: Initialize variables prior to use

 ell/dhcp-server.c   | 1 +
 unit/test-rtnl.c    | 2 +-
 unit/test-uintset.c | 2 ++
 3 files changed, 4 insertions(+), 1 deletion(-)

-- 
2.32.0

