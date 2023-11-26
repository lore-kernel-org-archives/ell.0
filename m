Received: from mohas.pair.com (mohas.pair.com [209.68.5.112])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 044248C13
	for <ell@lists.linux.dev>; Sun, 26 Nov 2023 18:24:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; dkim=none
Received: from mohas.pair.com (localhost [127.0.0.1])
	by mohas.pair.com (Postfix) with ESMTP id 2365B730CA;
	Sun, 26 Nov 2023 13:24:18 -0500 (EST)
Received: from [IPv6:2601:647:5a00:15c1:5990:5683:21b8:9188] (unknown [IPv6:2601:647:5a00:15c1:5990:5683:21b8:9188])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mohas.pair.com (Postfix) with ESMTPSA id CA621730F2;
	Sun, 26 Nov 2023 13:24:17 -0500 (EST)
Content-Type: text/plain;
	charset=utf-8
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
Mime-Version: 1.0 (Mac OS X Mail 13.4 \(3608.120.23.2.4\))
Subject: Re: [PATCH] netlink: Add workaround for missing NLM_F_ACK_TLVS and
 NLM_F_CAPPED
From: Grant Erickson <gerickson@nuovations.com>
In-Reply-To: <20231121184836.197219-1-marcel@holtmann.org>
Date: Sun, 26 Nov 2023 10:24:16 -0800
Cc: ell@lists.linux.dev
Content-Transfer-Encoding: quoted-printable
Message-Id: <3239B07D-3CBB-42D0-997F-2A52797EA71E@nuovations.com>
References: <20231121184836.197219-1-marcel@holtmann.org>
To: Marcel Holtmann <marcel@holtmann.org>
X-Mailer: Apple Mail (2.3608.120.23.2.4)
X-Scanned-By: mailmunge 3.11 on 209.68.5.112

On Nov 21, 2023, at 10:48 AM, Marcel Holtmann <marcel@holtmann.org> =
wrote:
> The feature for NETLINK_EXT_ACK also adds two additional flags. These
> are NLM_F_ACK_TLVS and NLM_F_CAPPED and need to be defined as well to
> be able to used the extended ACK feature.
> =E2=80=94

Marcel,

I can confirm that ell-0.61 builds with this final patch against my =
linux-4.9.212 / glibc-2.32 configuration.

Thank you!

Best,

Grant

--=20
Principal
Nuovations

gerickson@nuovations.com
http://www.nuovations.com/

