Received: from mail5.g24.pair.com (mail5.g24.pair.com [66.39.139.36])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BD3DE14D439
	for <ell@lists.linux.dev>; Thu, 16 May 2024 15:35:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=66.39.139.36
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1715873761; cv=none; b=X6Jm+EuOGk9cc+C7/F7/i+4RLRL9mCAm0MlRf+iNFlOPuYUOkFLgzFNuYlbKtSiwWoIZaQ3pTMVv7pPHSsp7gmXn1MYcCVQNGvS2BrYhOLohkkY5K4ydfSDSI0hYQ92c85X+mwP85uSCKxsIr44iNWW6RRpf19JkknZHi3bIDG0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1715873761; c=relaxed/simple;
	bh=wWR9HcuLkLVw8y6Aj67AiY42id7fzow4nIQ8GgCh8Uo=;
	h=Content-Type:Mime-Version:Subject:From:In-Reply-To:Date:Cc:
	 Message-Id:References:To; b=RKzDN5tW+RinSm+Cv6N6G1j5lTq4A6LFnIiDp0CMkDdXqnwic7bfi2mV+W9CXnWe5H8Jw8RB4AERoRE2Mc7Yg30lYFOPvdJJ2X8i77H9Ud8CcOhBVpyVjPGxuxMY+9ssj29NV/nh6u6JGNvVNnWyXAX69TEkcanWBsK5zlfa53Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com; spf=pass smtp.mailfrom=nuovations.com; dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b=DlsLpPz1; arc=none smtp.client-ip=66.39.139.36
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=nuovations.com header.i=@nuovations.com header.b="DlsLpPz1"
Received: from mail5.g24.pair.com (localhost [127.0.0.1])
	by mail5.g24.pair.com (Postfix) with ESMTP id 4E005164A95;
	Thu, 16 May 2024 11:35:55 -0400 (EDT)
Received: from smtpclient.apple (c-24-6-12-99.hsd1.ca.comcast.net [24.6.12.99])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail5.g24.pair.com (Postfix) with ESMTPSA id CE330124EDD;
	Thu, 16 May 2024 11:35:54 -0400 (EDT)
Content-Type: text/plain;
	charset=utf-8
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3774.500.171.1.1\))
Subject: Re: [RFC PATCH v8] term: Added 'l_term_*' symbols.
From: Grant Erickson <gerickson@nuovations.com>
In-Reply-To: <5a388d3c220e13e7b61ae39d4d83611402283000.camel@geanix.com>
Date: Thu, 16 May 2024 08:35:43 -0700
Cc: ell@lists.linux.dev,
 Marcel Holtmann <marcel@holtmann.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <3CFE87AC-7E37-4669-8DE5-29E67FF753EC@nuovations.com>
References: <20240405003658.3490494-1-gerickson@nuovations.com>
 <20240405003658.3490494-5-gerickson@nuovations.com>
 <5a388d3c220e13e7b61ae39d4d83611402283000.camel@geanix.com>
To: =?utf-8?Q?Martin_Hundeb=C3=B8ll?= <martin@geanix.com>
X-Mailer: Apple Mail (2.3774.500.171.1.1)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nuovations.com; h=content-type:mime-version:subject:from:in-reply-to:date:cc:content-transfer-encoding:message-id:references:to; s=pair-202401062137; bh=QRV1yxwTboe5G634ia3SYnKJZKboXcAOzqaOyW8JvYY=; b=DlsLpPz1RTu4fyrFrW4tE2vS9LV74WNd4AgJGWtg1T8lQ8q1qCklIhcQG3uGqFqH6LYxYYSvuG+6NZKM5dmV0znenqDUUNlrXC+j7SN/LNX9buzV4SmLn6P5pceUDOzVlIHPICZO4i9hSg4FfuOeqV/b3/PTIVn0UQm+cI6HPeejZxxV00PAcTwQl4n9hjnNRV93+vxdSsjfBd98lhQEafyLK+3c0GdlAkeNjSmvLi/w3zbuGT43e87SGPwSvaol5JQMOY31eSGsJgLpHoyIP0Sdoe4RZb4Vz6Yi3PgeqED9v3vR9CjoY22t4BWB6cTIAvmd8MGbPI6XxvnsRu8BsA==
X-Scanned-By: mailmunge 3.10 on 66.39.139.36

On May 16, 2024, at 1:16=E2=80=AFAM, Martin Hundeb=C3=B8ll =
<martin@geanix.com> wrote:
> On Thu, 2024-04-04 at 17:36 -0700, Grant Erickson wrote:
>> ---
>>  ell/ell.sym | 21 +++++++++++++++++++++
>>  1 file changed, 21 insertions(+)
>>=20
>> diff --git a/ell/ell.sym b/ell/ell.sym
>> index 28b55d36719b..2767bf55e079 100644
>> --- a/ell/ell.sym
>> +++ b/ell/ell.sym
>> @@ -623,6 +623,27 @@ global:
>>   l_ecdh_generate_shared_secret;
>>   /* time */
>>   l_time_now;
>> + /* term */
>> + l_term_new;
>> + l_term_free;
>> + l_term_set_io_handler;
>> + l_term_set_input;
>> + l_term_set_input_stdin;
>> + l_term_set_output;
>> + l_term_set_output_stdout;
>> + l_term_set_key_handler;
>> + l_term_open;
>> + l_term_close;
>=20
> Didn't you argue / say in the cover letter to v6 that these two
> functions were renamed to l_term_{acquire,release} ?

Martin,

Confirmed, you may note "[RFC PATCH v8] ell/edit: Rename =
'l_term_{open,close}=E2=80=99.=E2=80=9D patch later in that series that =
performs the rename of those symbols.

I intentionally left the revision history intact in the patch set, =
rather than squashing them, so that it was clear where Marcel started =
and then the changes I made atop those.

Best,

Grant

--=20
Principal
Nuovations

gerickson@nuovations.com
https://www.nuovations.com/

