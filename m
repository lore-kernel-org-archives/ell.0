Received: from relay7-d.mail.gandi.net (relay7-d.mail.gandi.net [217.70.183.200])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6D258322764
	for <ell@lists.linux.dev>; Wed, 20 Aug 2025 16:28:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.183.200
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1755707305; cv=none; b=V7MPlf6ASW7QV/uo2jHusDtyfguoJ/N9Ml4iyfLL+WW6i3zrJetagX+Qn4Y8Q/l1pqiw7OvzuuY+mYbqKdU+5QTUq17lclDhCjsL2r7rkbuuqpEsL2bcBdYc07yy3NEe34JOYB2UP9xcEbYuBxawD3vuB+Pu7FyCA8WNMBi82NQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1755707305; c=relaxed/simple;
	bh=hPnuR39961ejViyu17ETFfyoPLFFlTCrfkt2poRuf0w=;
	h=Message-ID:Subject:From:To:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=uTDzB6rq9UgHvoGeCaEm3yL7GOgrk+CD9j5+LDF7VVkTrkszHvUdAnSuVF6gczqWn6nhJkQ6c/Ym72QBz3pCXkyH9R8iCOkWY7u6ipp2+vzdG4QtKekd9YZrCf9x9tAXKEdHyuR0PPgv8IV+fSiV8dN/zFH9UUw8EgGblBeWZG4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net; spf=pass smtp.mailfrom=hadess.net; arc=none smtp.client-ip=217.70.183.200
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hadess.net
Received: by mail.gandi.net (Postfix) with ESMTPSA id 8619543991;
	Wed, 20 Aug 2025 16:28:19 +0000 (UTC)
Message-ID: <a137bd2597373a562a27d93e665705c3e0223ea4.camel@hadess.net>
Subject: Re: [PATCH v5 1/1] build: Add meson build system
From: Bastien Nocera <hadess@hadess.net>
To: Denis Kenzior <denkenz@gmail.com>, ell@lists.linux.dev
Date: Wed, 20 Aug 2025 18:28:19 +0200
In-Reply-To: <8cf523c2-fa78-4f1c-9e3f-48a529d1e280@gmail.com>
References: <20250807134859.930870-1-hadess@hadess.net>
	 <20250807134859.930870-2-hadess@hadess.net>
	 <5939828972792a22be2680c6b2bf377f1cd0d437.camel@hadess.net>
	 <bd05acb2cb6bb96ff13d1c82b0fb2d28c199a843.camel@hadess.net>
	 <8cf523c2-fa78-4f1c-9e3f-48a529d1e280@gmail.com>
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
X-GND-Score: -100
X-GND-Cause: gggruggvucftvghtrhhoucdtuddrgeeffedrtdefgdduheekkeehucetufdoteggodetrfdotffvucfrrhhofhhilhgvmecuifetpfffkfdpucggtfgfnhhsuhgsshgtrhhisggvnecuuegrihhlohhuthemuceftddunecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenucfjughrpefkuffhvfffjghftgfgfgggsehtqhertddtreejnecuhfhrohhmpeeurghsthhivghnucfpohgtvghrrgcuoehhrgguvghssheshhgruggvshhsrdhnvghtqeenucggtffrrghtthgvrhhnpeeuveeivdetkeekgfefffeftefhjeeikeetffdvteejheefieeltedtvdeuleduleenucfkphepvdgrtddumegvfeegmegvtgejfeemtghfvddtmeejudgurgemfegsugemvddtrgelmedufeefnecuvehluhhsthgvrhfuihiivgeptdenucfrrghrrghmpehinhgvthepvdgrtddumegvfeegmegvtgejfeemtghfvddtmeejudgurgemfegsugemvddtrgelmedufeefpdhhvghloheplgfkrfhvieemvdgrtddumegvfeegmegvtgejfeemtghfvddtmeejudgurgemfegsugemvddtrgelmedufeefngdpmhgrihhlfhhrohhmpehhrgguvghssheshhgruggvshhsrdhnvghtpdhnsggprhgtphhtthhopedvpdhrtghpthhtohepuggvnhhkvghniiesghhmrghilhdrtghomhdprhgtphhtthhopegvlhhlsehlihhsthhsrdhlihhnuhigrdguvghv
X-GND-Sasl: hadess@hadess.net

On Wed, 2025-08-20 at 11:17 -0500, Denis Kenzior wrote:
> Hi Bastien,
>=20
> On 8/20/25 4:02 AM, Bastien Nocera wrote:
> > Sorry to nag, I'd really appreciate if you could review and merge
> > this,
> > as it's blocking any further work on bluez.
>=20
> I personally have nothing against taking this in, but Marcel is the
> one=20
> maintaining the build system, so I'd need his ack first.

I just wanted to clarify that this doesn't touch the original build
system (autotools) at all, and that I'm happy doing follow-up bug fixes
as necessary.
