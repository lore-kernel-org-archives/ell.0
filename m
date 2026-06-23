Received: from mail-ed1-f44.google.com (mail-ed1-f44.google.com [209.85.208.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 065FD34E745
	for <ell@lists.linux.dev>; Tue, 23 Jun 2026 18:56:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.208.44
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782240990; cv=none; b=Y/BvycZCev0ffus1pw8BxyX1sjLQQTx8tSfrxA+X2tTZnNNMXEBsyOvK2QlTuDlvpSUiXjX26yOB13DG1JsnvkMK4QAtMBqs6flhtz9svoJZ3b4UHpCzt/u9ZEHPro6UMk1fKDQqagkzWgPXmMdAk+i4OzL2lH+wMOnWTTn9hXw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782240990; c=relaxed/simple;
	bh=24Dn8UqRZ1p8BQICezHYOo9NJl5h5GUSnVLscYJARrU=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=PqkN1iMxkck/PLPAr16MgnmPFH6NI5iu0Lr10jWJHwA026CFvZ2JYBdRiSuolbiw5sVLb0r0wfnDhqRKsN3qIHdJrVhnSUzCz8liwJMV7Hn6tgdzOXCuU0dbhgoFJeRIigDtIE3Mc6mV4Ir8zhHv1CszBdqbNN3iZPPNrCkXk4k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org; spf=pass smtp.mailfrom=linuxfoundation.org; dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b=B4FdDA7v; arc=none smtp.client-ip=209.85.208.44
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linuxfoundation.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="B4FdDA7v"
Received: by mail-ed1-f44.google.com with SMTP id 4fb4d7f45d1cf-696bf0e7c9cso389427a12.1
        for <ell@lists.linux.dev>; Tue, 23 Jun 2026 11:56:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google; t=1782240987; x=1782845787; darn=lists.linux.dev;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:from:to:cc:subject:date:message-id:reply-to;
        bh=sTYMiI8T7qy3LqZCJa3jMkJNbrBL8JjUNCpZXVETjNU=;
        b=B4FdDA7vbjN+B1fbSd7PNIMiH1LeqaJAudBrYZ33zgFArSewDAlxMU+pNFuU9bAl6Y
         qVLT78an6yuhRCvflqNZvEkubYSTGqs3SMzvSDaHV3rEXbpidfqZqmmcahjsxle0ugzu
         vTn3x9IhDG+EbrrMkwc0jprvth6R3NxHN/QCY=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1782240987; x=1782845787;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to;
        bh=sTYMiI8T7qy3LqZCJa3jMkJNbrBL8JjUNCpZXVETjNU=;
        b=bLp3r6AZ3McA3xlkbZEpN2/3iZ5s51Cg5aEuxpqguRSiha82HZeX9M/mFb6I57xW/y
         2YY4qah3ZIvYwvSJ73xmYFdPTA+s9sDmCZms8bwJaLIEItAgbYSXJqxyeZxCC4+/AbOH
         wL6NUPGUWh1EgVEVHKmOkFoI+SOd+Ju0B2ihSL1HHMqQ6onJR/fDlvhpsGN8P1tRBBBn
         6pIiAQ4s6QZdUqwyE1MFjR1vxiSb88uTtdGAE6rrhxu/3f+ZX4bLHxqADPuIArxoss33
         5/SVuCYkqcSnNPQGAYThbAL9wASlWj3ayTcikGCJpIywZB0lMpQv57YhTLUOTkTLzyDK
         dHjA==
X-Forwarded-Encrypted: i=1; AFNElJ9udle9oRMEHHXaaJmx/mHCESlFQqIh0TcMiHUfQpDbO2gYrTlJGXO1zNiBbfdX3Q7Gj7w=@lists.linux.dev
X-Gm-Message-State: AOJu0Yzjjg7iswm6s75vTQz6EMDOWzHN7o9o76hQQUDGDw3YY99f28TU
	CmXBo5lWD0dYr17HDStcpycqFz2nkHcmv3u9v3++KPfUMgPI1RKTbyqKk2XYRz7IqiAWzlGLXcl
	PIEhXH3U=
X-Gm-Gg: AfdE7cmZhGexrYmA8+Tiff2hnFMy/ikGfJ0BBQd0Tmipf6k+gfIK3MIr2Co4rbIRcky
	oi6C7dqlCqp3ltRqptPaMY5434qYgmQyiQaTAIqO4NiTbMVtOK0VSiDdNPhlEqZ3yvgMknGIVVy
	Ox5JRRYCCy9sWIOK0pccXcsf/vWFEvEOMMZNnrX6n3SV5BvD7g7lsIqY/nftcH6gtZyejLLozx9
	cg9OfokUno3mxCPq5vDbECZQJ9fe9RNkyb93ChoZBLQc1W/wB8OuxqlfYoQHgnW9TcK8bK0vMRK
	l+TZRiiPfQ6xQXKHJJFCrl7mKiMKMZ3cvxZrCsR7NelzRIJtzFM7ulQhEz0vE8a+bAz8hLbOFQS
	4oTRQ95jNkaTcAuQKf3eRjBbxAh4/1HIaCA3MCTXZCtrPoSP2nstsin0jUYCkG1FkGVItZO5l8i
	K5o0kymwY8RtZ3TmR43uAiG4CPF9y1Wa3RP+XxqcPfG7T6dOhjki8ia6DbHof8oeUQpubpLXVc
X-Received: by 2002:a05:6402:26c9:b0:697:96d4:dece with SMTP id 4fb4d7f45d1cf-697d42d3ec1mr2653639a12.2.1782240987245;
        Tue, 23 Jun 2026 11:56:27 -0700 (PDT)
Received: from mail-ej1-f43.google.com (mail-ej1-f43.google.com. [209.85.218.43])
        by smtp.gmail.com with ESMTPSA id 4fb4d7f45d1cf-6977be31ca1sm5106146a12.19.2026.06.23.11.56.26
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 23 Jun 2026 11:56:26 -0700 (PDT)
Received: by mail-ej1-f43.google.com with SMTP id a640c23a62f3a-c029505b389so230349466b.1
        for <ell@lists.linux.dev>; Tue, 23 Jun 2026 11:56:26 -0700 (PDT)
X-Forwarded-Encrypted: i=1; AFNElJ+2Rs3TnAoF6xJzsGpaLItmWfAbeOVoi09xowN7/xcQTfhDevF4JwbCOj2pvVPa4uDJnZk=@lists.linux.dev
X-Received: by 2002:a17:907:c207:b0:c11:8357:40f with SMTP id
 a640c23a62f3a-c11835704bfmr15229166b.2.1782240986490; Tue, 23 Jun 2026
 11:56:26 -0700 (PDT)
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <20260430011544.31823-1-ebiggers@kernel.org> <7d08a6df54279e9915f5df6bd4e5e5dde52b4fe1.camel@hadess.net>
 <20260623164932.GA1793@sol>
In-Reply-To: <20260623164932.GA1793@sol>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 23 Jun 2026 11:56:10 -0700
X-Gmail-Original-Message-ID: <CAHk-=wgNG=F3xO9PjL0RcKy3UWvq0Np9uZu+nFUQBAA8So9xdA@mail.gmail.com>
X-Gm-Features: AVVi8CdpFGqem5dP7mBI1VIDKVc8WIWTZWMdjSeug8fejnSzLkFpq4QaapJhuLo
Message-ID: <CAHk-=wgNG=F3xO9PjL0RcKy3UWvq0Np9uZu+nFUQBAA8So9xdA@mail.gmail.com>
Subject: Re: [PATCH] crypto: af_alg - Document the deprecation of AF_ALG
To: Eric Biggers <ebiggers@kernel.org>
Cc: Bastien Nocera <hadess@hadess.net>, linux-crypto@vger.kernel.org, 
	Herbert Xu <herbert@gondor.apana.org.au>, Marcel Holtmann <marcel@holtmann.org>, 
	Luiz Augusto von Dentz <luiz.dentz@gmail.com>, linux-doc@vger.kernel.org, linux-api@vger.kernel.org, 
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org, 
	linux-bluetooth@vger.kernel.org, ell@lists.linux.dev
Content-Type: text/plain; charset="UTF-8"

On Tue, 23 Jun 2026 at 09:51, Eric Biggers <ebiggers@kernel.org> wrote:
>
> We're aware of that and are taking it into account in the allowlist:

Note that if we can  just unconditionally make it depend on
CAP_NET_ADMIN, that would be good - independently of any allowlist.

Because if iwd and abluetoothd are the main two users, and both of
those already require CAP_NET_ADMIN anyway...

                Linus
