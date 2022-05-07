Received: from gregdf.com (gregdf.com [152.228.171.180])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A07EF3D9E
	for <ell@lists.linux.dev>; Sun,  8 May 2022 00:00:23 +0000 (UTC)
Received: from localhost.localdomain (unknown [37.167.202.147])
	by gregdf.com (Postfix) with ESMTPSA id 2E3F5796F3B
	for <ell@lists.linux.dev>; Sun,  8 May 2022 01:49:28 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gregdf.com; s=mail;
	t=1651967368; bh=kpom0PilfT+kjrrKROCUkxRkabwOUvqyjA/wRjvlV1w=;
	h=From:To:Subject:Date;
	b=UkR+cq0oawJE7r6e2VL6txyzu13YjhrjhQ7ZZCNzmXalbJnINETXa5FjYR0JeIfPA
	 fzENVCb2yz/2PfippAHNELy2g4/D80JSKgvx/f1CeMoGiyjrVEO/AaVUt9sVsrF5pi
	 /hKoDdp8+Y7m83escqsVlZhmWs/zxbYPZ4jHnZc0=
From: Greg Depoire--Ferrer <greg@gregdf.com>
To: ell@lists.linux.dev
Subject: Fix bug when stdin is closed
Date: Sun,  8 May 2022 01:54:31 +0200
Message-Id: <20220507235434.11693-1-greg@gregdf.com>
X-Mailer: git-send-email 2.35.1
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Running iwd with FD 0 (stdin) closed fails because ell considers epoll_fd of 0 to mean failure. The first commit fixes
that bug.

However, it still won't work because ell/dhcp6-transport.c has a bug where it closes a uninitialized FD (FD 0 on my
machine) and that would cause an infinite loop because the epoll_wait call was returning EBADF. The second commit fixes
that bug.

I noticed that ell/dhcp-transport.c is prone to the same mistake as the udp_fd field is not initialized on construction,
but I don't know if the close can actually be called before the udp_fd field is set. Just to be sure, the third commit
initializes it.


