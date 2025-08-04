Received: from relay9-d.mail.gandi.net (relay9-d.mail.gandi.net [217.70.183.199])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5A1392E36FA
	for <ell@lists.linux.dev>; Mon,  4 Aug 2025 10:47:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.183.199
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1754304479; cv=none; b=gL0OKlo4uffoIKOtpmarogmx7fKz2/rr3j7NELncRSFUNSZz6nVOftD8WFCqy2KOUFKOPcnSrX3iDwLt4fb7PPOwLwrNWL3TrjpJpgnULlaBsK85trLs0Yr4pDYHvX5VUPoT2QouYrfUPAuEwi+7N7iSMYBua2uozsmP/6ygKW0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1754304479; c=relaxed/simple;
	bh=nlvdhRvBsqkpkQg2F0L6rgWYbMIHzYUvykf3YJBShbQ=;
	h=Message-ID:Subject:From:To:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=AGlbtnx14PJSVr42DRiPVuhG8WzRmRa2jq6BRn766FqAUoTQFZxrHtqR96prO/BabtbQRupCFJ6EM/K50qT23rHovL8dSOudoAZ2N+qJUlKThI06GvEVQXmudV1il/j9IUe5nB3resZyElX4gdqk8CAst2D/pXB4UDmRty3RYMk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net; spf=pass smtp.mailfrom=hadess.net; arc=none smtp.client-ip=217.70.183.199
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hadess.net
Received: by mail.gandi.net (Postfix) with ESMTPSA id 2526A4397C
	for <ell@lists.linux.dev>; Mon,  4 Aug 2025 10:47:49 +0000 (UTC)
Message-ID: <802c7b6d3d623c31e8c891caaf10a514ad7bf46c.camel@hadess.net>
Subject: Re: [PATCH v2 0/1] build: Add meson build system
From: Bastien Nocera <hadess@hadess.net>
To: ell@lists.linux.dev
Date: Mon, 04 Aug 2025 12:47:49 +0200
In-Reply-To: <20250804104557.4061152-1-hadess@hadess.net>
References: <20250804104557.4061152-1-hadess@hadess.net>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.56.2 (3.56.2-1.fc42) 
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
X-GND-State: clean
X-GND-Score: 0
X-GND-Cause: gggruggvucftvghtrhhoucdtuddrgeeffedrtdefgdduuddvtdekucetufdoteggodetrfdotffvucfrrhhofhhilhgvmecuifetpfffkfdpucggtfgfnhhsuhgsshgtrhhisggvnecuuegrihhlohhuthemuceftddunecunecujfgurhepkffuhffvffgjfhgtgfgfggesthhqredttderjeenucfhrhhomhepuegrshhtihgvnhcupfhotggvrhgruceohhgruggvshhssehhrgguvghsshdrnhgvtheqnecuggftrfgrthhtvghrnhepueeviedvteekkefgfefffeethfejieekteffvdetjeehfeeileettddvueeludelnecukfhppedvrgdtudemvgefgeemvggtjeefmegtfhdvtdemjeduuggrmeefsggumedvtdgrleemudeffeenucevlhhushhtvghrufhiiigvpedtnecurfgrrhgrmhepihhnvghtpedvrgdtudemvgefgeemvggtjeefmegtfhdvtdemjeduuggrmeefsggumedvtdgrleemudeffedphhgvlhhopeglkffrvheimedvrgdtudemvgefgeemvggtjeefmegtfhdvtdemjeduuggrmeefsggumedvtdgrleemudeffegnpdhmrghilhhfrhhomhephhgruggvshhssehhrgguvghsshdrnhgvthdpnhgspghrtghpthhtohepuddprhgtphhtthhopegvlhhlsehlihhsthhsrdhlihhnuhigrdguvghv
X-GND-Sasl: hadess@hadess.net

Sorry about this orphan cover letter, git-send-email crashed in the
middle of sending the associated patch

On Mon, 2025-08-04 at 12:44 +0200, Bastien Nocera wrote:
> Changes since v1:
> - fix cert-ca.cnf path (should be a files(), not a string)
> - fix cert-ca-index.txt generation
