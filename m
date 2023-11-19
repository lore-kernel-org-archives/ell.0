Received: from mail.holtmann.org (coyote.holtmann.net [212.227.132.17])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 8957313FEA
	for <ell@lists.linux.dev>; Sun, 19 Nov 2023 16:49:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; dkim=none
Received: from smtpclient.apple (p4fefc822.dip0.t-ipconnect.de [79.239.200.34])
	by mail.holtmann.org (Postfix) with ESMTPSA id E2EFFCECD0
	for <ell@lists.linux.dev>; Sun, 19 Nov 2023 17:49:39 +0100 (CET)
From: Marcel Holtmann <marcel@holtmann.org>
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3774.200.91.1.1\))
Subject: Re: [RFC PATCH 1/2] netlink: Workaround missing NETLINK_EXT_ACK
 define
Date: Sun, 19 Nov 2023 17:49:29 +0100
References: <20231111180753.51488-1-marcel@holtmann.org>
To: ell@lists.linux.dev
In-Reply-To: <20231111180753.51488-1-marcel@holtmann.org>
Message-Id: <4BD6ECAA-A00D-4973-8341-AF88810539DC@holtmann.org>
X-Mailer: Apple Mail (2.3774.200.91.1.1)

Hi,

> This works around the missing NETLINK_EXT_ACK define of really really
> old kernel version and defines the missing enum nlmsgerr_attrs.
> ---
> ell/netlink-private.h | 9 +++++++++
> 1 file changed, 9 insertions(+)

I applied this patch since it is simple and removes one compile obstacle =
for older systems.

Regards

Marcel

