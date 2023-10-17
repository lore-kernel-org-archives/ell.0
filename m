Received: from fallback18.i.mail.ru (fallback18.i.mail.ru [79.137.243.73])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 207923FB14
	for <ell@lists.linux.dev>; Tue, 17 Oct 2023 17:10:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=aqsi.ru
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=aqsi.ru
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=aqsi.ru header.i=@aqsi.ru header.b="fzaeKCxc";
	dkim=pass (1024-bit key) header.d=aqsi.ru header.i=@aqsi.ru header.b="pGuR7DRU"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=aqsi.ru; s=mailru;
	h=Content-Transfer-Encoding:MIME-Version:Content-Type:References:In-Reply-To:Date:To:From:Subject:Message-ID:From:Subject:Content-Type:Content-Transfer-Encoding:To:Cc; bh=ROCByNyQIF33J+3ZWt/+kAoVJth52NuFJvy6zBRCEAk=;
	t=1697562619;x=1697652619; 
	b=fzaeKCxcIBXh5IlWi5zy57m8TfWhr5tR68TW5UdzT6X2fC0qBOfjHxAoSogXjq4EvVjvAujHrVfg7tu8SXxeZQnVh3oAXqgqa8MKb2/63XCyrZJyY0i0b/uYYkWZxDEWYuA4gwP84NcozPnYjUJKDozLvOl8nz0eKiuGa1Nlfdk=;
Received: from [10.12.4.14] (port=36552 helo=smtp39.i.mail.ru)
	by fallback18.i.mail.ru with esmtp (envelope-from <m.lyubimov@aqsi.ru>)
	id 1qsnA1-000Ow8-8q
	for ell@lists.linux.dev; Tue, 17 Oct 2023 19:43:13 +0300
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=aqsi.ru;
	s=mailru; h=Content-Transfer-Encoding:MIME-Version:Content-Type:References:
	In-Reply-To:Date:To:From:Subject:Message-ID:From:Sender:Reply-To:To:Cc:
	Content-Type:Content-Transfer-Encoding:Content-ID:Content-Description:
	Resent-Date:Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:
	List-Id:List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:
	List-Archive:X-Cloud-Ids:Disposition-Notification-To;
	bh=ROCByNyQIF33J+3ZWt/+kAoVJth52NuFJvy6zBRCEAk=; t=1697560993; x=1697650993; 
	b=pGuR7DRUycmqmDxKDR+dvj+eDa6vyMjxsp0D0/X8/0pyQoGeMb+eHCZn1Eu8UzLjh3qE2UkIW2I
	G7+sEPam9t1RDNX+KHTwBpuLY1fCveEmPFDTrO17dObScv5FQ3sjslXAQuoouJGB58aBVCi5vNjp+
	cMpPSwtVNLs9ih0hLF8=;
Received: by smtp39.i.mail.ru with esmtpa (envelope-from <m.lyubimov@aqsi.ru>)
	id 1qsn9r-007y2L-10; Tue, 17 Oct 2023 19:43:03 +0300
Message-ID: <fdfffd9b8fb3b9c7694177a8d5520112193c5cdb.camel@aqsi.ru>
Subject: Re: [PATCH] genl: fix
 =?UTF-8?Q?=E2=80=98attr=5Fgrp=2Enext=5Flen=E2=80=99?= may be used
 uninitialized
From: Lyubimov Maxim <m.lyubimov@aqsi.ru>
To: Denis Kenzior <denkenz@gmail.com>, ell@lists.linux.dev
Date: Tue, 17 Oct 2023 21:43:01 +0500
In-Reply-To: <aeb71836-df9b-456d-8f0d-c782c3a70fc8@gmail.com>
References: <4103d54928605fb3d2a573ba6890395b4a155138.camel@aqsi.ru>
	 <a07bc07e-a2ae-4a3a-8698-190cd758955c@gmail.com>
	 <08b740ec5ea8936c49c4242b59e33aba475a6fe4.camel@aqsi.ru>
	 <aeb71836-df9b-456d-8f0d-c782c3a70fc8@gmail.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.36.5-0ubuntu1 
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Mailru-Src: smtp
X-7564579A: 646B95376F6C166E
X-77F55803: 4F1203BC0FB41BD978AFEFB3096932CFE894D0B694AE649AA7A71757303D0C60182A05F538085040240165EDC8A2D3A812F61F4C82F27C6E106F3A2A6F39B7116987202986CFA804
X-7FA49CB5: FF5795518A3D127A4AD6D5ED66289B5278DA827A17800CE732F68F8AF5E5BA59EA1F7E6F0F101C67BD4B6F7A4D31EC0BCC500DACC3FED6E28638F802B75D45FF8AA50765F790063757004B04402545C58638F802B75D45FF36EB9D2243A4F8B5A6FCA7DBDB1FC311F39EFFDF887939037866D6147AF826D8E07E3C9CDAB157873C520D4E4D631DA4117882F4460429724CE54428C33FAD305F5C1EE8F4F765FC1D8F55CB9E08B94CA471835C12D1D9774AD6D5ED66289B52BA9C0B312567BB23117882F4460429728776938767073520C24E1E72F37C03A0CB629EEF1311BF91D2E47CDBA5A96583BA9C0B312567BB2376E601842F6C81A19E625A9149C048EE9647ADFADE5905B128F6BDBBAB179F4ED8FC6C240DEA76429C9F4D5AE37F343AA9539A8B242431040A6AB1C7CE11FEE3F254576263B31EA9C0837EA9F3D19764C4224003CC836476E2F48590F00D11D6E2021AF6380DFAD1A18204E546F3947C17119E5299B287EE2E808ACE2090B5E1725E5C173C3A84C3ED8438A78DFE0A9E089D37D7C0E48F6C8AA50765F79006378271790605D4762CEFF80C71ABB335746BA297DBC24807EABDAD6C7F3747799A
X-C1DE0DAB: 0D63561A33F958A55EEDD59C63E5D2655FF5B5029C806F0839571FA064253909F87CCE6106E1FC07E67D4AC08A07B9B065B78C30F681404DCB5012B2E24CD356
X-C8649E89: 1C3962B70DF3F0ADBF74143AD284FC7177DD89D51EBB7742DC8270968E61249B1004E42C50DC4CA955A7F0CF078B5EC49A30900B95165D343F22CE0A71FDB37E3748E1745242253E011781DBD2F26D4C5A42DB02D10A38C4E514A92F5B259AA51D7E09C32AA3244C7B270BEF0A5EC451C364E305F0A964D2B038C9161EF167A13A1A83191EB2B8F05DA084F8E80FEBD38EDF88D74BAC437670101D478F77020B37E69C174A41D00C
X-D57D3AED: 3ZO7eAau8CL7WIMRKs4sN3D3tLDjz0dLbV79QFUyzQ2Ujvy7cMT6pYYqY16iZVKkSc3dCLJ7zSJH7+u4VD18S7Vl4ZUrpaVfd2+vE6kuoey4m4VkSEu530nj6fImhcD4MUrOEAnl0W826KZ9Q+tr5ycPtXkTV4k65bRjmOUUP8cvGozZ33TWg5HZplvhhXbhDGzqmQDTd6OAevLeAnq3Ra9uf7zvY2zzsIhlcp/Y7m53TZgf2aB4JOg4gkr2biojfbpVM+RcTJBKSHK4TLNXgg==
X-Mailru-Sender: 0E9E14D9EC491FBAD2A03FC26A0EF746020E4B3944D638DFA8E7122F1D4659A9B653BE8DE3F5727D5D68521865CF3C5293AC9912533B2342953ADA4C1418A8160CF35AF5341388420FBD6B69799305375FEEDEB644C299C0ED14614B50AE0675
X-Mras: Ok
X-7564579A: 646B95376F6C166E
X-77F55803: 6242723A09DB00B4DEDBBC46D76EB2520ED4F58DABF9B6959C78F57D1C82F16B049FFFDB7839CE9E80FBBB2CB63C9CB56680C00C4425FB22E4C75A2FCFC8C8687FDC4A304306DD24
X-D57D3AED: 3ZO7eAau8CL7WIMRKs4sN3D3tLDjz0dLbV79QFUyzQ2Ujvy7cMT6pYYqY16iZVKkSc3dCLJ7zSJH7+u4VD18S7Vl4ZUrpaVfd2+vE6kuoey4m4VkSEu530nj6fImhcD4MUrOEAnl0W826KZ9Q+tr5xhPKz0ZEsZ5k6NOOPWz5QAiZSCXKGQRq3/7KxbCLSB2ESzQkaOXqCBFZPLWFrEGlV1shfWe2EVcxl5toh0c/aCGOghz/frdRhzMe95NxDFdVi+mls5yutqorgacEGsLNg==
X-Mailru-MI: C000000000000800
X-Mras: Ok

> I'm not aware of any special git-send-email configuration.  Mine is
> simply:
> 
> [sendemail]
>         smtpencryption = tls
>         smtpserver = smtp.gmail.com
>         smtpuser = ***@gmail.com
>         smtpserverport = 587
> 
> It may be the outgoing mail server you're using is doing something
> 'smart'.
> 

Thanks, I have almost the same thing, only smtpencryption = ssl, the
problem was that this patch was sent via Evolution, I hope there are no
similar problems in the patches for ofono, I sent them via git-send-
email.


