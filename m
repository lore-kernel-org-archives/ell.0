Received: from mail-qt1-f182.google.com (mail-qt1-f182.google.com [209.85.160.182])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6EFBB3FF7
	for <ell@lists.linux.dev>; Wed, 15 Sep 2021 18:25:48 +0000 (UTC)
Received: by mail-qt1-f182.google.com with SMTP id w17so3171175qta.9
        for <ell@lists.linux.dev>; Wed, 15 Sep 2021 11:25:48 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linuxfoundation.org; s=google;
        h=date:from:to:subject:message-id:mime-version:content-disposition;
        bh=PcSZ6JE3kihObY1mhYPtT2/CptLZpy/2COSkLEUaGPY=;
        b=CcuXPqsNzkX4/RHBeAQyEF9vZQQI2nasK6sGpjIWfh+tMaeYA8LN2Quwvcru/kGZVr
         c6fn7qR6QjMVMhfHKET0B5L6eDZEkXxK3mpUXhh4HqZ3DG/xqsSOwZ0rYPAeAr74uoFG
         1NY7G6H38bLA2jHSoX/vWswL56l13KqRbpfIA=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:date:from:to:subject:message-id:mime-version
         :content-disposition;
        bh=PcSZ6JE3kihObY1mhYPtT2/CptLZpy/2COSkLEUaGPY=;
        b=BAXrQLrPidueUhDQjH9/TJq9a/mx5ykN0nmjB5mhVzp0gEx4LSb7/mRbSQvU9ehOpc
         jhovJzSIf5JW+6codP8YdGCSltOUsUL/4zxpGwfgiWdu+xysBmaIg9V7oRY+vXQ0O/WR
         j+aMY1Ls4BzfXzXWZfnBNHtOb3fdJQ/OUj7wrjBlZhzgFigAlY768zVsYLmdnAvtugjz
         /8lnzwjFlJNEl1jiZLJTMNG9ZeSQaj4EAVkPCqYgVNz3CxLerRUtnUAGELJAjfgLRbE+
         jmMH3uJcRqAIFXghKlMK86Rm5HDrEhsRt54K+KQWKUBT23AcyXH2DhStTwKua295yGT7
         d1mg==
X-Gm-Message-State: AOAM5305Pe0+T48ssE/xWiPz4f0EJZ+UBkCuSBWE447vR3tJeC0lFc72
	2fGo55KRQ7bdu7sHVVAp3LpymysdgaXDtQ==
X-Google-Smtp-Source: ABdhPJy3JDQqpx4y+UyCU/AmL5dR+FYxfjNrZa8DQ/ccpaXfQO5h8S4zIluHQEg1F4sOGqL/Y1adig==
X-Received: by 2002:ac8:668e:: with SMTP id d14mr1247696qtp.342.1631730347184;
        Wed, 15 Sep 2021 11:25:47 -0700 (PDT)
Received: from meerkat.local (bras-base-mtrlpq5031w-grc-32-216-209-220-181.dsl.bell.ca. [216.209.220.181])
        by smtp.gmail.com with ESMTPSA id d129sm542308qkf.136.2021.09.15.11.25.46
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 15 Sep 2021 11:25:46 -0700 (PDT)
Date: Wed, 15 Sep 2021 14:25:45 -0400
From: Konstantin Ryabitsev <konstantin@linuxfoundation.org>
To: ell@lists.linux.dev
Subject: Test delivery to ell@lists.linux.dev
Message-ID: <20210915182545.2jx777b37qf7p44q@meerkat.local>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

Testing list archival, please ignore.

-K
