Received: from mail.holtmann.org (coyote.holtmann.net [212.227.132.17])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 6364C13698B
	for <ell@lists.linux.dev>; Thu, 31 Oct 2024 19:15:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=212.227.132.17
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1730402135; cv=none; b=h6eB2YxDy2zzSQAH/Nivu5dv6W5RWXQYTIMHpgAneYNeR6IMV32/Hra9vGoWUusKUy3ikyOjrd8FqmHxeI3qwhUpIYTrPxbbGfe2G2alEbUXMRrBQYQbeCX6sP5nsBqWwnYzhKOQ78PTYZCi05Dv17I7CQQHGZuHiCVZNUf5f28=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1730402135; c=relaxed/simple;
	bh=ullGOVrd9i5QtOtONe16YUC0ZJDp4n6M1+3UmxtXiOM=;
	h=Content-Type:Mime-Version:Subject:From:In-Reply-To:Date:Cc:
	 Message-Id:References:To; b=gGlxlt92EdKr4mtzdWzLokEoL/9G2f0VDJEGJXM8NzR+qyePBlYPd7gtLdLNK8hR5SAaB0sR78C/sjeKyWSb6UN+0NmKh+Mf2YYxJ7HHEWA0II8idaLfIUxuMGgPgCVs7zWT0GFgk+N3TpSQLdpjSk/ntPUmHCtnNSHK3C+EfVc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org; spf=pass smtp.mailfrom=holtmann.org; arc=none smtp.client-ip=212.227.132.17
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=holtmann.org
Received: from smtpclient.apple (p5b3d22a6.dip0.t-ipconnect.de [91.61.34.166])
	by mail.holtmann.org (Postfix) with ESMTPSA id 978E5CECDD;
	Thu, 31 Oct 2024 20:15:25 +0100 (CET)
Content-Type: text/plain;
	charset=us-ascii
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3826.200.121\))
Subject: Re: [PATCH v2 1/2] util: Add l_safe_memcpy
From: Marcel Holtmann <marcel@holtmann.org>
In-Reply-To: <20241031161928.1514776-1-denkenz@gmail.com>
Date: Thu, 31 Oct 2024 20:15:15 +0100
Cc: ell@lists.linux.dev
Content-Transfer-Encoding: 7bit
Message-Id: <79F5591E-3E4B-4947-8728-60BA46C1581E@holtmann.org>
References: <20241031161928.1514776-1-denkenz@gmail.com>
To: Denis Kenzior <denkenz@gmail.com>
X-Mailer: Apple Mail (2.3826.200.121)

Hi Denis,

> Some callers use memcpy without checking whether the size 'n' is greater
> than zero.  This is generally fine, but does cause sanitizers to
> complain.  Add a new l_safe_memcpy function to take care of this case.
> ---
> ell/util.h | 10 ++++++++++
> 1 file changed, 10 insertions(+)
> 
> diff --git a/ell/util.h b/ell/util.h
> index c56f182292fa..8a4e0950b41b 100644
> --- a/ell/util.h
> +++ b/ell/util.h
> @@ -243,6 +243,16 @@ static inline void l_put_be64(uint64_t val, void *ptr)
> void *l_malloc(size_t size) __attribute__ ((warn_unused_result, malloc));
> void *l_memdup(const void *mem, size_t size)
> __attribute__ ((warn_unused_result, malloc));
> +
> +static inline void * __attribute__((nonnull(1))) l_safe_memcpy(void *dest,
> + const void *src, size_t n)
> +{
> + if (!n)
> + return dest;
> +
> + return __builtin_memcpy(dest, src, n);
> +}
> +
> void l_free(void *ptr);
> DEFINE_CLEANUP_FUNC(l_free);

why not just l_memcpy?

Regards

Marcel

