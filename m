Received: from fallback25.i.mail.ru (fallback25.i.mail.ru [79.137.243.79])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0929042BEB
	for <ell@lists.linux.dev>; Tue, 17 Oct 2023 15:21:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=aqsi.ru
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=aqsi.ru
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=aqsi.ru header.i=@aqsi.ru header.b="Z+kuNF1g";
	dkim=pass (1024-bit key) header.d=aqsi.ru header.i=@aqsi.ru header.b="eZY++fRs"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=aqsi.ru; s=mailru;
	h=Content-Transfer-Encoding:MIME-Version:Content-Type:References:In-Reply-To:Date:To:From:Subject:Message-ID:From:Subject:Content-Type:Content-Transfer-Encoding:To:Cc; bh=/MarfbjFW5XIYV8HZfImCwW4u3qjPpsTyxSIZLnVbSE=;
	t=1697556108;x=1697646108; 
	b=Z+kuNF1g4JuPG5WTFRfnGKjIRttn0dsSp2Ja8wxPi7P9QE6A+aEztpZ0MwRBfplwzpJMd4ca59AxFmEblrHwQ4Q9e59S8fv7Wd+V7MIKEtsU8kgR8qIZBgnWONYzhJIBRwVsmOyZoz3jV7BKFBuxJVavyYSSLH1TPucS/SYcNQU=;
Received: from [10.12.4.22] (port=44792 helo=smtp41.i.mail.ru)
	by fallback25.i.mail.ru with esmtp (envelope-from <m.lyubimov@aqsi.ru>)
	id 1qsltB-002H6K-0B
	for ell@lists.linux.dev; Tue, 17 Oct 2023 18:21:45 +0300
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=aqsi.ru;
	s=mailru; h=Content-Transfer-Encoding:MIME-Version:Content-Type:References:
	In-Reply-To:Date:To:From:Subject:Message-ID:From:Sender:Reply-To:To:Cc:
	Content-Type:Content-Transfer-Encoding:Content-ID:Content-Description:
	Resent-Date:Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:
	List-Id:List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:
	List-Archive:X-Cloud-Ids:Disposition-Notification-To;
	bh=/MarfbjFW5XIYV8HZfImCwW4u3qjPpsTyxSIZLnVbSE=; t=1697556105; x=1697646105; 
	b=eZY++fRsz11+TR41AdarI15KyKUOOKXGZp9mbozblONhIy4LXgHnuLnzC9M03JQAq6ffVi9zTeE
	+awDxipifGOTvErWK0pq/UzCdIj7ekW5YnrDZQjI9CFQU7fV1e/QnOs/mNGIrAJdGweXlDtPFbHan
	6Wx5sJmC3F97ZFT9GVA=;
Received: by smtp41.i.mail.ru with esmtpa (envelope-from <m.lyubimov@aqsi.ru>)
	id 1qslt2-00D0xc-0C
	for ell@lists.linux.dev; Tue, 17 Oct 2023 18:21:36 +0300
Message-ID: <08b740ec5ea8936c49c4242b59e33aba475a6fe4.camel@aqsi.ru>
Subject: Re: [PATCH] genl: fix
 =?UTF-8?Q?=E2=80=98attr=5Fgrp=2Enext=5Flen=E2=80=99?= may be used
 uninitialized
From: Lyubimov Maxim <m.lyubimov@aqsi.ru>
To: ell@lists.linux.dev
Date: Tue, 17 Oct 2023 20:21:34 +0500
In-Reply-To: <a07bc07e-a2ae-4a3a-8698-190cd758955c@gmail.com>
References: <4103d54928605fb3d2a573ba6890395b4a155138.camel@aqsi.ru>
	 <a07bc07e-a2ae-4a3a-8698-190cd758955c@gmail.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.36.5-0ubuntu1 
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Mailru-Src: smtp
X-7564579A: 78E4E2B564C1792B
X-77F55803: 4F1203BC0FB41BD978AFEFB3096932CF9A0316BDAFAACF43AB8B2D609BB33468182A05F538085040525EC4DEE552CFD3E77AFA4D262F112CF64F6096B702B345FDA1B88046BD4DC2
X-7FA49CB5: FF5795518A3D127A4AD6D5ED66289B5278DA827A17800CE745229D52CF30560CEA1F7E6F0F101C67BD4B6F7A4D31EC0BCC500DACC3FED6E28638F802B75D45FF8AA50765F7900637174E2957C4CE0F938638F802B75D45FF36EB9D2243A4F8B5A6FCA7DBDB1FC311F39EFFDF887939037866D6147AF826D8DE0B3DC0AE3ECFF676377E271B2A2ACC117882F4460429724CE54428C33FAD305F5C1EE8F4F765FC1BE95B8C87527B4BA471835C12D1D9774AD6D5ED66289B52BA9C0B312567BB23117882F446042972877693876707352026055571C92BF10F2CC0D3CB04F14752D2E47CDBA5A96583BA9C0B312567BB2376E601842F6C81A19E625A9149C048EE9647ADFADE5905B128F6BDBBAB179F4ED8FC6C240DEA76429C9F4D5AE37F343AA9539A8B242431040A6AB1C7CE11FEE3F254576263B31EA9C0837EA9F3D19764C4224003CC836476E2F48590F00D11D6E2021AF6380DFAD1A18204E546F3947C5DBE5CE84B47B0E41DD303D21008E298D5E8D9A59859A8B6B372FE9A2E580EFC725E5C173C3A84C3CE5B583A975D522235872C767BF85DA2F004C90652538430E4A6367B16DE6309
X-C1DE0DAB: 0D63561A33F958A5A8418759231F491CCE260C91367F87D7096BB258E19250E2F87CCE6106E1FC07E67D4AC08A07B9B01DAA61796BF5227BCB5012B2E24CD356
X-C8649E89: 1C3962B70DF3F0ADE00A9FD3E00BEEDF77DD89D51EBB7742D3581295AF09D3DF87807E0823442EA2ED31085941D9CD0AF7F820E7B07EA4CF5CAAB78DA903E0F5D8A2480B8F2D950BEA48EDCBF2BD03608FDB63836C626F5E141C0AB2DA7D0DDAEBFDF7752E1FC337D6C883A2EDB01DB6A40CC71BE3C09735CAACD699CDC6F98202C26D483E81D6BEF55150C44C58A03AE08F1021D1C6A886BF305B2E6CBEE040
X-D57D3AED: 3ZO7eAau8CL7WIMRKs4sN3D3tLDjz0dLbV79QFUyzQ2Ujvy7cMT6pYYqY16iZVKkSc3dCLJ7zSJH7+u4VD18S7Vl4ZUrpaVfd2+vE6kuoey4m4VkSEu530nj6fImhcD4MUrOEAnl0W826KZ9Q+tr5ycPtXkTV4k65bRjmOUUP8cvGozZ33TWg5HZplvhhXbhDGzqmQDTd6OAevLeAnq3Ra9uf7zvY2zzsIhlcp/Y7m53TZgf2aB4JOg4gkr2biojfbpVM+RcTJDjYcpLqTwcyg==
X-Mailru-Sender: 0E9E14D9EC491FBAD2A03FC26A0EF7461F0C9373928CCEED947FDD86FCD49BCD1C93206F0F26F3DE5D68521865CF3C5293AC9912533B2342953ADA4C1418A8160CF35AF5341388420FBD6B69799305375FEEDEB644C299C0ED14614B50AE0675
X-Mras: Ok
X-7564579A: 646B95376F6C166E
X-77F55803: 6242723A09DB00B4DEDBBC46D76EB2520ED4F58DABF9B69518791C104F4FF5CF049FFFDB7839CE9E80FBBB2CB63C9CB5BCBD730F7650BBF4227751444D9B336F94A09F080AAA16B3
X-D57D3AED: 3ZO7eAau8CL7WIMRKs4sN3D3tLDjz0dLbV79QFUyzQ2Ujvy7cMT6pYYqY16iZVKkSc3dCLJ7zSJH7+u4VD18S7Vl4ZUrpaVfd2+vE6kuoey4m4VkSEu530nj6fImhcD4MUrOEAnl0W826KZ9Q+tr5xhPKz0ZEsZ5k6NOOPWz5QAiZSCXKGQRq3/7KxbCLSB2ESzQkaOXqCBFZPLWFrEGlV1shfWe2EVcxl5toh0c/aCGOghz/frdRhzMe95NxDFdVi+mls5yutqpvb51iclDtA==
X-Mailru-MI: C000000000000800
X-Mras: Ok

Hello Denis

On 17/10/2023 в 10:08 -0500, Denis Kenzior wrote:
> Hi Max,
> 
> On 10/16/23 13:39, MaxLyubimov wrote:
> > make --no-print-directory all-am
> >    CC       ell/genl.lo
> > ell/genl.c: In function ‘parse_cmd_newfamily.part.0’:
> > ell/genl.c:1728:5: error: ‘attr_grp.next_len’ may be used
> > uninitialized
> > in this function [-Werror=maybe-uninitialized]
> >   1728 |  if (!NLA_OK(nla, attr->next_len))
> >        |     ^
> > ell/genl.c:268:22: note: ‘attr_grp.next_len’ was declared here
> >    268 |   struct l_genl_attr attr_grp;
> >        |                      ^~~~~~~~
> > ell/genl.c:1732:14: error: ‘attr_grp.next_data’ may be used
> > uninitialized in this function [-Werror=maybe-uninitialized]
> >   1732 |   *type = nla->nla_type & NLA_TYPE_MASK;
> >        |           ~~~^~~~~~~~~~
> > ell/genl.c:268:22: note: ‘attr_grp.next_data’ was declared here
> >    268 |   struct l_genl_attr attr_grp;
> >        |                      ^~~~~~~~
> > ell/genl.c:1728:5: error: ‘attr_op.next_len’ may be used
> > uninitialized
> > in this function [-Werror=maybe-uninitialized]
> >   1728 |  if (!NLA_OK(nla, attr->next_len))
> >        |     ^
> > ell/genl.c:240:22: note: ‘attr_op.next_len’ was declared here
> >    240 |   struct l_genl_attr attr_op;
> >        |                      ^~~~~~~
> > ell/genl.c:1732:14: error: ‘attr_op.next_data’ may be used
> > uninitialized in this function [-Werror=maybe-uninitialized]
> >   1732 |   *type = nla->nla_type & NLA_TYPE_MASK;
> >        |           ~~~^~~~~~~~~~
> > ell/genl.c:240:22: note: ‘attr_op.next_data’ was declared here
> >    240 |   struct l_genl_attr attr_op;
> >        |                      ^~~~~~~
> > cc1: all warnings being treated as errors
> > make[1]: *** [Makefile:4032: ell/genl.lo] Error 1
> > make: *** [Makefile:2348: all] Error 2
> > ---
> >   ell/genl.c | 6 ++++--
> >   1 file changed, 4 insertions(+), 2 deletions(-)
> > 
> 
> I added a space between 'Max' and 'Lyubimov' in your author
> tag.  Tell me if 
> this was incorrect.  If it was correct, can you please fix your git
> config?

Lyubimov Maxim. Okay, I'll fix the config.

> > diff --git a/ell/genl.c b/ell/genl.c
> > index def3790..33ecc4d 100644
> > --- a/ell/genl.c
> > +++ b/ell/genl.c
> > @@ -240,7 +240,8 @@ static void family_ops(struct
> > l_genl_family_info
> > *info,
> >   		struct l_genl_attr attr_op;
> >   		uint32_t id = 0, flags = 0;
> >   
> > -		l_genl_attr_recurse(attr, &attr_op);
> > +		if (!l_genl_attr_recurse(attr, &attr_op))
> > +			continue;
> >   
> >   		while (l_genl_attr_next(&attr_op, &type, &len, &data))
> > {
> 
> Something in your mail server is messing with the text format.  I had
> to 
> manually edit the patch so it would apply properly (by e.g. removing
> the newline 
> before this '{').  Please fix that since I can't do this for more
> than the 
> simplest patches.

I wanted to ask what git-send-email configuration should be used to
send patches correctly?

> >   			switch (type) {
> > @@ -269,7 +270,8 @@ static void family_mcast_groups(struct
> > l_genl_family_info *info,
> >   		const char *name = NULL;
> >   		uint32_t id = 0;
> >   
> > -		l_genl_attr_recurse(attr, &attr_grp);
> > +		if (!l_genl_attr_recurse(attr, &attr_grp))
> > +			continue;
> >   
> >   		while (l_genl_attr_next(&attr_grp, &type, &len, &data))
> > {
> >   			switch (type) {
> > 
> > 
> 
> Applied, thanks.
> 
> Regards,
> -Denis

Best regards,
Lyubimov Maxim


