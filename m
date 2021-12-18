Received: from mail-pl1-f177.google.com (mail-pl1-f177.google.com [209.85.214.177])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8F267168
	for <ell@lists.linux.dev>; Sat, 18 Dec 2021 04:15:10 +0000 (UTC)
Received: by mail-pl1-f177.google.com with SMTP id o14so3494416plg.5
        for <ell@lists.linux.dev>; Fri, 17 Dec 2021 20:15:10 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=NWdhmEVlrC/IVbGMZw59p+MArMj1X7+e5eFB3pCZ5D4=;
        b=jiwN5+AUqXGGrPRx93zRTpeqomR/SS294/6uiR+KyXzAuETW44QYVwTPn6sK9TCQsx
         wadOP3QgiEXjhJaOGC2IC0QZj8gwLIoL6w8lCch2E/t4AtwQzI/WsZEF7VEMrmxm3Ft4
         5oFHg8EoK1Tkl1FOTVJHqQaTAOO7ZZUyhrXdeVG1t3dLoBnyxOiAW2dj6qUiHrmwr0Cs
         aCmbWkmS9WaHGCV9TkoDtsBmjn2gX9/GALQk2JaDwXHaC3VBPtvJZAjcWzzN0Qvrpwcy
         YwZCHbiH9oxD/SE4fsQCa7hzbQZNM2IJLoCDqXF95kGAOlavVEWqI0t2SPvzIhiLmGUx
         +V+Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=NWdhmEVlrC/IVbGMZw59p+MArMj1X7+e5eFB3pCZ5D4=;
        b=cvdhE4xdzSirpY4TasgrXiF7nGcmhJsm+sF6QukWrwKu8tODChp+1LDb1Ai6XLlzOv
         RzKCFYme6H5jrrMJHjAp5YBz3Yr7XASfA03jz/TPutnPMHotbjzKxrX+760cZbcLOX92
         33Mj2LyCD0jqMzxpT5UDt9Wd3q/afqx4SKOG5eeCw0MHui+GMz4vremGe05xNWKRvK0g
         dZwM7lO/Wpu6dXDWKJUZEa8bixU7D7nZtedSpoRvVNIbqBEUVSaaB7RliD5NGTeJX9Gx
         elSjDLABQmmI4UwwrVbCj3DiMarVFXdddpS3mIe0QfdffSsHSNQWCc93HjMV1+FxCNz0
         bCvQ==
X-Gm-Message-State: AOAM532QuCXOlW2qdj3rccl0Fv8SFwtgAk1SXQ76e+PzO+XkAwlEB0KV
	lu4jXePCeBPeS0ObMocCcxTlnFrbv+TNJQ==
X-Google-Smtp-Source: ABdhPJxdk0hCZ4izc/5KzPz0MrASposdawvnCaBh34E1hjhRlBJgdCpBB0JDhs6E12DD/hCDLtw6SA==
X-Received: by 2002:a17:902:bd94:b0:148:8b76:71e3 with SMTP id q20-20020a170902bd9400b001488b7671e3mr6254262pls.56.1639800909958;
        Fri, 17 Dec 2021 20:15:09 -0800 (PST)
Received: from hydra.localdomain ([50.45.159.39])
        by smtp.gmail.com with ESMTPSA id qe2sm10194506pjb.42.2021.12.17.20.15.09
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 17 Dec 2021 20:15:09 -0800 (PST)
From: Ossama Othman <ossama.othman@gmail.com>
X-Google-Original-From: Ossama Othman <ossama.othman@intel.com>
To: ell@lists.linux.dev
Cc: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 1/3] dhcp-server: Fix memory leak.
Date: Fri, 17 Dec 2021 20:14:29 -0800
Message-Id: <20211218041431.114737-2-ossama.othman@intel.com>
X-Mailer: git-send-email 2.32.0
In-Reply-To: <20211218041431.114737-1-ossama.othman@intel.com>
References: <20211218041431.114737-1-ossama.othman@intel.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

When adding a lease, free the dns field of a l_dhcp_lease instance
prior to updating it.  This addresses a memory leak found when running
the test-dhcp unit test through the Valgrind memcheck tool.
---
 ell/dhcp-server.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index c8b06a6..ff0784f 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -308,6 +308,7 @@ static struct l_dhcp_lease *add_lease(struct l_dhcp_server *server,
 	if (ret != 0)
 		return NULL;
 
+	l_free(lease->dns);
 	l_free(lease->client_id);
 	memset(lease, 0, sizeof(*lease));
 
-- 
2.32.0

