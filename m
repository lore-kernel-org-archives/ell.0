Received: from mail.holtmann.org (coyote.holtmann.net [212.227.132.17])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id C5C825646E
	for <ell@lists.linux.dev>; Tue, 13 Feb 2024 14:05:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=212.227.132.17
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1707833126; cv=none; b=KCiTHwvm2fBcrufpynzZLkVi7MfqngIrfL04hwmykhsdO8tKdgTkm7z178TZz62sXr5Og3N0OD69+BPd6QXiVF/a5OBbjLkCClkoXKZi3bk0DH/n5BwPWfyucGgnaWaHOH5jRx5i0hAvLpZbRlUHApMPB7l33VysZheVGYgOAtk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1707833126; c=relaxed/simple;
	bh=vuBDJPfmQh+EUZWNTghNQ5CnXHpFJaLOB1GLYHicu/I=;
	h=Content-Type:Mime-Version:Subject:From:In-Reply-To:Date:Cc:
	 Message-Id:References:To; b=Vwd6nK2Yr9HXoP2rNU8zsolC8e7B5vht0SqG7xfzBTccjuABpWyrZ8ED31zRZNAOJFDz43znmjA631eoi1hE1CgtyDeaFq/+1K15fp+7wiGgR8Q9VQMmn/vN2v0Z7nGyjRPTsTd24qGchW7WBqFgmW783wcFjyOtaRKC14j74GA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org; spf=pass smtp.mailfrom=holtmann.org; arc=none smtp.client-ip=212.227.132.17
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=holtmann.org
Received: from smtpclient.apple (p4ff9fff9.dip0.t-ipconnect.de [79.249.255.249])
	by mail.holtmann.org (Postfix) with ESMTPSA id 49A76CECBE;
	Tue, 13 Feb 2024 15:05:22 +0100 (CET)
Content-Type: text/plain;
	charset=us-ascii
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3774.400.31\))
Subject: Re: [PATCH] log: add l_notice
From: Marcel Holtmann <marcel@holtmann.org>
In-Reply-To: <20240213131619.828613-1-prestwoj@gmail.com>
Date: Tue, 13 Feb 2024 15:05:11 +0100
Cc: ell@lists.linux.dev
Content-Transfer-Encoding: 7bit
Message-Id: <0D7EFC7E-C3D9-43E0-823E-6C06498C6B3D@holtmann.org>
References: <20240213131619.828613-1-prestwoj@gmail.com>
To: James Prestwood <prestwoj@gmail.com>
X-Mailer: Apple Mail (2.3774.400.31)

Hi James,

> Adds the ability to use a notice (5) log level.
> ---
> ell/log.h | 2 ++
> 1 file changed, 2 insertions(+)
> 
> diff --git a/ell/log.h b/ell/log.h
> index 72dbed3..7ddf663 100644
> --- a/ell/log.h
> +++ b/ell/log.h
> @@ -17,6 +17,7 @@ extern "C" {
> 
> #define L_LOG_ERR 3
> #define L_LOG_WARNING 4
> +#define L_LOG_NOTICE 5
> #define L_LOG_INFO 6
> #define L_LOG_DEBUG 7

for what? What is the difference to just use l_info?

Regards

Marcel

