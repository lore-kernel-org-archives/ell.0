Received: from mail.holtmann.org (coyote.holtmann.net [212.227.132.17])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 4109133F385
	for <ell@lists.linux.dev>; Fri, 13 Mar 2026 11:09:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=212.227.132.17
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1773400147; cv=none; b=jvOTSPPLf4goT8k+7YZninoRnQC/PABmbM0l4SmquAvQzAtzVLieXySGBlX0i6wyMMgm5sHs9rsiAr/uWPdI1bv7+rkn8MDO5cvMiPfxMmUVjzVZyx7VCxlVuFLU1qQFnE/CHgdjsmJf6ssZu2xXH4a0txuhw4dAY9ggzeRRQoU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1773400147; c=relaxed/simple;
	bh=Sd5obWuARvifItBALlDWAuP9ZvkXn61+lqgpfM737mA=;
	h=Content-Type:Mime-Version:Subject:From:In-Reply-To:Date:Cc:
	 Message-Id:References:To; b=kMcozHH6DBYUONSeaPrvLY6q9MlIyw0qyZl+2oBOSXiR2qWXvGYPrOH3dys4ETrdO+w7gjZ6fQfTdS1ACRDyNKPXvjYbRIW2DNW2ut3Up2Y6YFvAeWoiM2v2FCQCPtx6Qx1MqtKl6gKu3QX9XCXVsdvHDxZiiiygiXLYRY4f3Bo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org; spf=pass smtp.mailfrom=holtmann.org; arc=none smtp.client-ip=212.227.132.17
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=holtmann.org
Received: from smtpclient.apple (p5b3d242d.dip0.t-ipconnect.de [91.61.36.45])
	by mail.holtmann.org (Postfix) with ESMTPSA id 14DBACECB9;
	Fri, 13 Mar 2026 12:01:19 +0100 (CET)
Content-Type: text/plain;
	charset=us-ascii
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3864.400.21\))
Subject: Re: [PATCH] test: only flag parse tests as little-endian-only in
 test-gvariant-message
From: Marcel Holtmann <marcel@holtmann.org>
In-Reply-To: <20260310194837.3078283-1-git@amaanq.com>
Date: Fri, 13 Mar 2026 12:01:08 +0100
Cc: ell@lists.linux.dev
Content-Transfer-Encoding: quoted-printable
Message-Id: <B4F8D2FF-BBE9-4DE6-9971-70AC3535CF66@holtmann.org>
References: <20260310194837.3078283-1-git@amaanq.com>
To: Amaan Qureshi <git@amaanq.com>
X-Mailer: Apple Mail (2.3864.400.21)

Hi Amaan,

> The blanket `l_test_set_default_flags(L_TEST_FLAG_LITTLE_ENDIAN_ONLY)`
> marks all gvariant-message tests as little-endian-only, but the build
> and rewind tests work correctly on big-endian. This causes an XPASS
> (unexpected pass) on big-endian systems, which autotools treats as a
> test suite failure.
>=20
> This commit applies the flag only to the three parse tests that =
compare
> against hardcoded little-endian byte sequences.
> ---
> unit/test-gvariant-message.c | 14 +++++++-------
> 1 file changed, 7 insertions(+), 7 deletions(-)


this does not work.

  CC       unit/test-gvariant-message.o
  CCLD     unit/test-gvariant-message
SKIP: unit/test-gvariant-message 1 - Basic 1 (parse) # SKIP =
little-endian-only
FAIL: unit/test-gvariant-message 2 - Basic 1 (build)
SKIP: unit/test-gvariant-message 3 - Complex 1 (parse) # SKIP =
little-endian-only
PASS: unit/test-gvariant-message 4 - Complex 1 (build)
SKIP: unit/test-gvariant-message 5 - Empty signature (parse) # SKIP =
little-endian-only
PASS: unit/test-gvariant-message 6 - Empty signature (build)
PASS: unit/test-gvariant-message 7 - Message Builder Rewind Complex 1

Regards

Marcel

