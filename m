Received: from mail.holtmann.org (coyote.holtmann.net [212.227.132.17])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 094EE2DF87
	for <ell@lists.linux.dev>; Sat, 25 Nov 2023 19:04:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; dkim=none
Received: from smtpclient.apple (p4fefc822.dip0.t-ipconnect.de [79.239.200.34])
	by mail.holtmann.org (Postfix) with ESMTPSA id 50AACCECD1
	for <ell@lists.linux.dev>; Sat, 25 Nov 2023 20:04:12 +0100 (CET)
From: Marcel Holtmann <marcel@holtmann.org>
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 7bit
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3774.200.91.1.1\))
Subject: Re: [PATCH] netlink: Add workaround for missing NLM_F_ACK_TLVS and
 NLM_F_CAPPED
Date: Sat, 25 Nov 2023 20:04:01 +0100
References: <20231121184836.197219-1-marcel@holtmann.org>
To: ell@lists.linux.dev
In-Reply-To: <20231121184836.197219-1-marcel@holtmann.org>
Message-Id: <94A43D71-2C25-4F9C-8F97-3DC5E32580F0@holtmann.org>
X-Mailer: Apple Mail (2.3774.200.91.1.1)

Hi,

> The feature for NETLINK_EXT_ACK also adds two additional flags. These
> are NLM_F_ACK_TLVS and NLM_F_CAPPED and need to be defined as well to
> be able to used the extended ACK feature.
> ---
> ell/netlink-private.h | 2 ++
> 1 file changed, 2 insertions(+)
> 
> diff --git a/ell/netlink-private.h b/ell/netlink-private.h
> index 0a1b016d8887..fdb584e62652 100644
> --- a/ell/netlink-private.h
> +++ b/ell/netlink-private.h
> @@ -27,6 +27,8 @@ enum nlmsgerr_attrs {
> NLMSGERR_ATTR_MSG,
> NLMSGERR_ATTR_OFFS,
> };
> +#define NLM_F_CAPPED   0x100
> +#define NLM_F_ACK_TLVS 0x200
> #endif

I applied this patch.

Regards

Marcel

