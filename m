Received: from fallback16.i.mail.ru (fallback16.i.mail.ru [79.137.243.71])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6CA34339BE
	for <ell@lists.linux.dev>; Mon, 16 Oct 2023 19:16:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=aqsi.ru
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=aqsi.ru
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=aqsi.ru header.i=@aqsi.ru header.b="ZadAyx+S";
	dkim=pass (1024-bit key) header.d=aqsi.ru header.i=@aqsi.ru header.b="mvQhL7Uk"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=aqsi.ru; s=mailru;
	h=Content-Transfer-Encoding:MIME-Version:Content-Type:Date:To:From:Subject:Message-ID:From:Subject:Content-Type:Content-Transfer-Encoding:To:Cc; bh=ACDgdzdYyQhPeOuy4f4j79+BuL2jSHgskfrKdUejU6Q=;
	t=1697483791;x=1697573791; 
	b=ZadAyx+ScpFd+TuP7VG2+fF8q8Z7mxwkdlySlbG+gOJNBr01mbjDwUfnDZItloEULTrpS60Z80flT7w16n/+c0M9uQvWixicX0yB+p6h+jxZXJqwJFcabzCChaj1YxXveQOwH9RezxjbfIT2g36Egpdrq4w5UhkizAgJ1NhpDsw=;
Received: from [10.12.4.23] (port=43118 helo=smtp49.i.mail.ru)
	by fallback16.i.mail.ru with esmtp (envelope-from <m.lyubimov@aqsi.ru>)
	id 1qsSVv-006ehz-4K
	for ell@lists.linux.dev; Mon, 16 Oct 2023 21:40:27 +0300
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=aqsi.ru;
	s=mailru; h=Content-Transfer-Encoding:MIME-Version:Content-Type:Date:To:From:
	Subject:Message-ID:From:Sender:Reply-To:To:Cc:Content-Type:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:
	References:List-Id:List-Help:List-Unsubscribe:List-Subscribe:List-Post:
	List-Owner:List-Archive:X-Cloud-Ids:Disposition-Notification-To;
	bh=ACDgdzdYyQhPeOuy4f4j79+BuL2jSHgskfrKdUejU6Q=; t=1697481627; x=1697571627; 
	b=mvQhL7UkEfawmqglEo2o9VBvdZZUStARL8aEoa9XWn4CHDA+PgBliPCCtVqHXKI2Fpbiz7XoOh7
	ztVLyuTmfwZYMpaDUMYwloKaxUFcOEfPmQurhUiZgLUhxZw0kZhr9VZ4r5GTDyzm/Beprb8nL/iSx
	mJyhjxMMjHuneZPL2IM=;
Received: by smtp49.i.mail.ru with esmtpa (envelope-from <m.lyubimov@aqsi.ru>)
	id 1qsSVj-00Gsbi-3A
	for ell@lists.linux.dev; Mon, 16 Oct 2023 21:40:18 +0300
Message-ID: <4103d54928605fb3d2a573ba6890395b4a155138.camel@aqsi.ru>
Subject: [PATCH] genl: fix
 =?UTF-8?Q?=E2=80=98attr=5Fgrp=2Enext=5Flen=E2=80=99?= may be used
 uninitialized
From: MaxLyubimov <m.lyubimov@aqsi.ru>
To: ell@lists.linux.dev
Date: Mon, 16 Oct 2023 23:39:58 +0500
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
X-77F55803: 4F1203BC0FB41BD978AFEFB3096932CF13E7FB3349EB8EC0C23B91B6439F56BB182A05F5380850409D4AE8AB2D8C6EAA50A7FA489FE73EB30ACF92CB772A63620EFCB49EC799DCF6
X-7FA49CB5: FF5795518A3D127A4AD6D5ED66289B5278DA827A17800CE76D24A1449B9F25A2EA1F7E6F0F101C67BD4B6F7A4D31EC0BCC500DACC3FED6E28638F802B75D45FF8AA50765F79006375D54B99ECAFA2F678638F802B75D45FF36EB9D2243A4F8B5A6FCA7DBDB1FC311F39EFFDF887939037866D6147AF826D86213DC40ED72C9ED4CB7B0739303D2F1117882F4460429724CE54428C33FAD305F5C1EE8F4F765FCC908CD1B87A134A2A471835C12D1D9774AD6D5ED66289B52BA9C0B312567BB23117882F44604297287769387670735201E561CDFBCA1751F6FD1C55BDD38FC3FD2E47CDBA5A96583BA9C0B312567BB2376E601842F6C81A19E625A9149C048EE9647ADFADE5905B16B91AC3BD56FC247D8FC6C240DEA76429C9F4D5AE37F343AA9539A8B242431040A6AB1C7CE11FEE37812A6222701F2156E0066C2D8992A16C4224003CC836476E2F48590F00D11D6E2021AF6380DFAD1A18204E546F3947C6089696B24BB1D192E808ACE2090B5E1725E5C173C3A84C3C5EA940A35A165FF2DBA43225CD8A89FC39EEDDD9AFC687442539A7722CA490CB5C8C57E37DE458BEDA766A37F9254B7
X-C1DE0DAB: 0D63561A33F958A5C27066CD9A735B1B6C52C2CB66155D73935D602F1671D047F87CCE6106E1FC07E67D4AC08A07B9B0CE135D2742255B359C5DF10A05D560A950611B66E3DA6D700B0A020F03D25A092FFDA4F57982C5F4CB5012B2E24CD356
X-C8649E89: 1C3962B70DF3F0ADE00A9FD3E00BEEDF77DD89D51EBB7742D3581295AF09D3DF87807E0823442EA2ED31085941D9CD0AF7F820E7B07EA4CF9F190A3E7134D0DBFABA48A464CC842EB9F5F2FB98D73962AD33099529F3794D6141934554CE5B5FEBFDF7752E1FC3372BE8AB3DCC9EB4EA91769EC8BCE322A4CAACD699CDC6F98202C26D483E81D6BEF55150C44C58A03AE08F1021D1C6A886BF305B2E6CBEE040
X-D57D3AED: 3ZO7eAau8CL7WIMRKs4sN3D3tLDjz0dLbV79QFUyzQ2Ujvy7cMT6pYYqY16iZVKkSc3dCLJ7zSJH7+u4VD18S7Vl4ZUrpaVfd2+vE6kuoey4m4VkSEu530nj6fImhcD4MUrOEAnl0W826KZ9Q+tr5ycPtXkTV4k65bRjmOUUP8cvGozZ33TWg5HZplvhhXbhDGzqmQDTd6OAevLeAnq3Ra9uf7zvY2zzsIhlcp/Y7m53TZgf2aB4JOg4gkr2biojbL9S8ysBdXiwzr1JaGjqC3PIIxl6k4F/
X-Mailru-Sender: 0E9E14D9EC491FBAA6F07D099F7E1BA98F57426DF7FE3A7A0786E7CA46423A97EFA8DF153332B55A5D68521865CF3C5293AC9912533B2342953ADA4C1418A8160CF35AF5341388420FBD6B69799305375FEEDEB644C299C0ED14614B50AE0675
X-Mras: Ok
X-7564579A: 78E4E2B564C1792B
X-77F55803: 6242723A09DB00B4DEDBBC46D76EB2520ED4F58DABF9B695DC7C1EB81BDDBEA3049FFFDB7839CE9E80FBBB2CB63C9CB5E5E75DFF643C17B7E661AED0FF4DAA9E3A45632F74BE7322
X-D57D3AED: 3ZO7eAau8CL7WIMRKs4sN3D3tLDjz0dLbV79QFUyzQ2Ujvy7cMT6pYYqY16iZVKkSc3dCLJ7zSJH7+u4VD18S7Vl4ZUrpaVfd2+vE6kuoey4m4VkSEu530nj6fImhcD4MUrOEAnl0W826KZ9Q+tr5xhPKz0ZEsZ5k6NOOPWz5QAiZSCXKGQRq3/7KxbCLSB2ESzQkaOXqCBFZPLWFrEGlV1shfWe2EVcxl5toh0c/aCGOghz/frdRhzMe95NxDFdVi+mls5yutrCC4MMEXX7KA==
X-Mailru-MI: C000000000000800
X-Mras: Ok

make --no-print-directory all-am
  CC       ell/genl.lo
ell/genl.c: In function ‘parse_cmd_newfamily.part.0’:
ell/genl.c:1728:5: error: ‘attr_grp.next_len’ may be used uninitialized
in this function [-Werror=maybe-uninitialized]
 1728 |  if (!NLA_OK(nla, attr->next_len))
      |     ^
ell/genl.c:268:22: note: ‘attr_grp.next_len’ was declared here
  268 |   struct l_genl_attr attr_grp;
      |                      ^~~~~~~~
ell/genl.c:1732:14: error: ‘attr_grp.next_data’ may be used
uninitialized in this function [-Werror=maybe-uninitialized]
 1732 |   *type = nla->nla_type & NLA_TYPE_MASK;
      |           ~~~^~~~~~~~~~
ell/genl.c:268:22: note: ‘attr_grp.next_data’ was declared here
  268 |   struct l_genl_attr attr_grp;
      |                      ^~~~~~~~
ell/genl.c:1728:5: error: ‘attr_op.next_len’ may be used uninitialized
in this function [-Werror=maybe-uninitialized]
 1728 |  if (!NLA_OK(nla, attr->next_len))
      |     ^
ell/genl.c:240:22: note: ‘attr_op.next_len’ was declared here
  240 |   struct l_genl_attr attr_op;
      |                      ^~~~~~~
ell/genl.c:1732:14: error: ‘attr_op.next_data’ may be used
uninitialized in this function [-Werror=maybe-uninitialized]
 1732 |   *type = nla->nla_type & NLA_TYPE_MASK;
      |           ~~~^~~~~~~~~~
ell/genl.c:240:22: note: ‘attr_op.next_data’ was declared here
  240 |   struct l_genl_attr attr_op;
      |                      ^~~~~~~
cc1: all warnings being treated as errors
make[1]: *** [Makefile:4032: ell/genl.lo] Error 1
make: *** [Makefile:2348: all] Error 2
---
 ell/genl.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/ell/genl.c b/ell/genl.c
index def3790..33ecc4d 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -240,7 +240,8 @@ static void family_ops(struct l_genl_family_info
*info,
 		struct l_genl_attr attr_op;
 		uint32_t id = 0, flags = 0;
 
-		l_genl_attr_recurse(attr, &attr_op);
+		if (!l_genl_attr_recurse(attr, &attr_op))
+			continue;
 
 		while (l_genl_attr_next(&attr_op, &type, &len, &data))
{
 			switch (type) {
@@ -269,7 +270,8 @@ static void family_mcast_groups(struct
l_genl_family_info *info,
 		const char *name = NULL;
 		uint32_t id = 0;
 
-		l_genl_attr_recurse(attr, &attr_grp);
+		if (!l_genl_attr_recurse(attr, &attr_grp))
+			continue;
 
 		while (l_genl_attr_next(&attr_grp, &type, &len, &data))
{
 			switch (type) {

