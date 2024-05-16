Received: from www530.your-server.de (www530.your-server.de [188.40.30.78])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B8D394501A
	for <ell@lists.linux.dev>; Thu, 16 May 2024 08:16:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=188.40.30.78
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1715847387; cv=none; b=kgx/pM001xFnEAH93gIr5lTvPUNO/AkNctuCpvjW8OpsaAvUkbKGDVNeXmAbv3iwWeKq6kshZui8bHGWZFcDvh7yR4TE4FKn89UTUJPJKUu4x0JhHqzOERBgM+lpxlY8aVHnyvOnEjEAnlZo5582g68poUPAMa+HtOx1XznyQnc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1715847387; c=relaxed/simple;
	bh=AnD5hNY1TfnAx3UPanrFJ0CaALklYDDZ2owtGXMri6w=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=INAZbsYnEVrv+cRLRprpAJPeyrlxv43bDoUjW8othrkns3g9jvsFK5lipqfkyUdpLRJCiLRvRmgzCm0HEhvCer2wSKZrGDNs2lGkI1yA2ZMLxjXG2mgnoMz9KwD9cwy+FMlOKeRKpfYDsVKBgSclNeBPUo3GAyeI6is8/YGdksg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=geanix.com; spf=pass smtp.mailfrom=geanix.com; dkim=pass (2048-bit key) header.d=geanix.com header.i=@geanix.com header.b=UA1UIunT; arc=none smtp.client-ip=188.40.30.78
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=geanix.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=geanix.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=geanix.com header.i=@geanix.com header.b="UA1UIunT"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=geanix.com;
	s=default2211; h=MIME-Version:Content-Transfer-Encoding:Content-Type:
	References:In-Reply-To:Date:Cc:To:From:Subject:Message-ID:Sender:Reply-To:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID;
	bh=kxpqJckqWefZ2JbqoKRSy2SxoQsRdWBDU0pVe7BthIQ=; b=UA1UIunT4p8RpbHQ/dHELCLP9b
	ciJ/KcLZBY4H4izubTJ1LT51a2vBvrYSevhW3fKKHWzVw3wJby2AsbVfXoCQvbdAuyUPSFAzzsICc
	0rRF5E9qW/wZpa/bRDrT6VSvwclsDRx1TPPfX6lUmu5pmdddzauAEn8iRYbM+esxvEPBjp6GDK1No
	yu/CfUPIqm9HjXm5fUdxR06h4Kpxz1m67Y/v2JwQCXDgf41LlF+X/yanBKiPuEH8V34oHjLDm8TSn
	2MZzIQ5fR2UPtCerLR7ZWB75njLinA2/RSHrC87wX6CNhxoh/Eb4QJ8e2DBi8bGu29Y31W9jsPO8P
	f4qlXsvg==;
Received: from sslproxy03.your-server.de ([88.198.220.132])
	by www530.your-server.de with esmtpsa  (TLS1.3) tls TLS_AES_256_GCM_SHA384
	(Exim 4.94.2)
	(envelope-from <martin@geanix.com>)
	id 1s7WHe-000KEA-L2; Thu, 16 May 2024 10:16:14 +0200
Received: from [185.17.218.86] (helo=[192.168.64.76])
	by sslproxy03.your-server.de with esmtpsa  (TLS1.3) tls TLS_AES_256_GCM_SHA384
	(Exim 4.96)
	(envelope-from <martin@geanix.com>)
	id 1s7WHe-000HsX-0k;
	Thu, 16 May 2024 10:16:14 +0200
Message-ID: <5a388d3c220e13e7b61ae39d4d83611402283000.camel@geanix.com>
Subject: Re: [RFC PATCH v8] term: Added 'l_term_*' symbols.
From: Martin =?ISO-8859-1?Q?Hundeb=F8ll?= <martin@geanix.com>
To: Grant Erickson <gerickson@nuovations.com>, ell@lists.linux.dev
Cc: Marcel Holtmann <marcel@holtmann.org>
Date: Thu, 16 May 2024 10:16:13 +0200
In-Reply-To: <20240405003658.3490494-5-gerickson@nuovations.com>
References: <20240405003658.3490494-1-gerickson@nuovations.com>
	 <20240405003658.3490494-5-gerickson@nuovations.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.52.1 
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
X-Authenticated-Sender: martin@geanix.com
X-Virus-Scanned: Clear (ClamAV 0.103.10/27276/Wed May 15 10:26:29 2024)

Hi Grant,

On Thu, 2024-04-04 at 17:36 -0700, Grant Erickson wrote:
> ---
> =C2=A0ell/ell.sym | 21 +++++++++++++++++++++
> =C2=A01 file changed, 21 insertions(+)
>=20
> diff --git a/ell/ell.sym b/ell/ell.sym
> index 28b55d36719b..2767bf55e079 100644
> --- a/ell/ell.sym
> +++ b/ell/ell.sym
> @@ -623,6 +623,27 @@ global:
> =C2=A0	l_ecdh_generate_shared_secret;
> =C2=A0	/* time */
> =C2=A0	l_time_now;
> +	/* term */
> +	l_term_new;
> +	l_term_free;
> +	l_term_set_io_handler;
> +	l_term_set_input;
> +	l_term_set_input_stdin;
> +	l_term_set_output;
> +	l_term_set_output_stdout;
> +	l_term_set_key_handler;
> +	l_term_open;
> +	l_term_close;

Didn't you argue / say in the cover letter to v6 that these two
functions were renamed to l_term_{acquire,release} ?

// Martin

> +	l_term_io_callback;
> +	l_term_process;
> +	l_term_putnstr;
> +	l_term_putstr;
> +	l_term_putchar;
> +	l_term_print;
> +	l_term_vprint;
> +	l_term_set_bounds;
> +	l_term_get_rows;
> +	l_term_get_columns;
> =C2=A0	/* gpio */
> =C2=A0	l_gpio_chips_with_line_label;
> =C2=A0	l_gpio_chip_new;

