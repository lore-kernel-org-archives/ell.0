Received: from mail.holtmann.org (coyote.holtmann.net [212.227.132.17])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id A5C5D1E514
	for <ell@lists.linux.dev>; Thu,  9 Nov 2023 14:50:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; dkim=none
Received: from smtpclient.apple (p4fefc822.dip0.t-ipconnect.de [79.239.200.34])
	by mail.holtmann.org (Postfix) with ESMTPSA id 4DEE5CECE3;
	Thu,  9 Nov 2023 15:50:52 +0100 (CET)
Content-Type: text/plain;
	charset=us-ascii
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3774.200.91.1.1\))
Subject: Re: [PATCH 1/4] rtnl: Fixup rtnetlink includes
From: Marcel Holtmann <marcel@holtmann.org>
In-Reply-To: <20231108234544.1050199-1-denkenz@gmail.com>
Date: Thu, 9 Nov 2023 15:50:41 +0100
Cc: ell@lists.linux.dev
Content-Transfer-Encoding: 7bit
Message-Id: <BA542D73-DC1F-4090-9C20-767FBD9A4587@holtmann.org>
References: <20231108234544.1050199-1-denkenz@gmail.com>
To: Denis Kenzior <denkenz@gmail.com>
X-Mailer: Apple Mail (2.3774.200.91.1.1)

Hi Denis,

> man 7 rtnetlink suggests the 4 includes listed should be used.  Also,
> remove rtnetlink.h inclusion from rtnl.h and move it into the individual
> code files.
> ---
> ell/netconfig.c  | 4 ++++
> ell/rtnl.c       | 5 ++++-
> ell/rtnl.h       | 3 ++-
> unit/test-rtnl.c | 4 ++++
> 4 files changed, 14 insertions(+), 2 deletions(-)

I applied patch 1 and patch 4 since they are simple fixes.

Regards

Marcel

