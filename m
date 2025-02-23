Received: from sonic306-2.consmr.mail.bf2.yahoo.com (sonic306-2.consmr.mail.bf2.yahoo.com [74.6.132.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DC6027082F
	for <ell@lists.linux.dev>; Sun, 23 Feb 2025 18:04:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.6.132.41
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1740333855; cv=none; b=E6gtMqjUi+kxVnFu1BkA1VTcRVF/YW3XrSBO6b4Q2Zf3UiL9q+ivW7Pw2dllPZ0pIUfqVfB0KJYnucGGy0d6a6flAXd/uopcn2z/nVCbYTYLWzyoXn+VfGWga8oiaZfRYszNjqKXq++rFuV0vwIOe2LxiC62UcijbugyPAyPJsM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1740333855; c=relaxed/simple;
	bh=+gF9Q0ZOft0WQBr8n6UulbH7BP4gTjPv9IDrRLnSaVs=;
	h=Message-ID:Date:MIME-Version:To:From:Subject:Content-Type:
	 References; b=ZW50x/2n59FJReHRkslt8VUS1pAlI1zCVDYLzTrx5nK+UOjzCrrX8Pug4fa6eZz/N4zKmZU8phGRG511NMT7nycQg0fT2eRKEHC56FEV6gtdZ2Qp42tZt84dQm1w0Z1tb9YgTvLdgXmZVBkOacV8WqWmLa7EinlGdhHj391AEbE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=yahoo.com; spf=pass smtp.mailfrom=yahoo.com; dkim=pass (2048-bit key) header.d=yahoo.com header.i=@yahoo.com header.b=IlKXbaH6; arc=none smtp.client-ip=74.6.132.41
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=yahoo.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=yahoo.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=yahoo.com header.i=@yahoo.com header.b="IlKXbaH6"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yahoo.com; s=s2048; t=1740333852; bh=hTtVXkirVZGlZIIHrmCc+okHMEwuViiInAnLmACYCHE=; h=Date:To:From:Subject:References:From:Subject:Reply-To; b=IlKXbaH6lsCX/GncWrZJYMiTKxJmkZpaIW4zVzMC7HnZlcGeu4NV2WW4lZv7Qgb3fB14QakTtt3NncDwguot8qhf4Y7TrqNgQS7vmxArQL82Pf0Lb5wTb51KkbFbtfQ3Ua6qIw8Ls03ZSJDcBsraExWoXw6M0DSofwPyGuNvwjJul/zRqP9Rzzs91B4w95c3Gd1dLX/JycKLtJU/2lNYI6E/83hfFWUNbrx5rceuNCvd75zY+b03J3k/rdzmzpeYmKBAnZt3ap7VIOe/SsnMg2Dp6xlyXIXwbmfD4aDyeYWP+lDOOFLt7P0vjbgfOHObJhfOaUV8YCGNoH+tKlohWg==
X-SONIC-DKIM-SIGN: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yahoo.com; s=s2048; t=1740333852; bh=DTr7KiP95LYYIka0xjF3xyX6IfcavmOBZmL6aRwMIVG=; h=X-Sonic-MF:Date:To:From:Subject:From:Subject; b=dmIAGPwKxg2uvEPy3Go4DANau/V4hKc54cPe69x5ZKwfXghddx/EuR38n8fmsM7q8bbcFWjg1uCGDpleZozH9YE8pJMJZ9fWEjjg3qlLbU75v+sUkNyg0ATFqMWg6OkGZ6OwsnKRjkJp5C8Tjt0ygxwr+YsmejaEFUYeQASxuyBhBhOjWUiZSWV7bnKHea7Ai7WTRqkHQOoRszIfoEjdOX8uC9JAhkGVfJbw3BRoUYE4L32qTs7mds+hs/yAFyjudK1xEUVRgCldkkalK1rpnXYNY3Wy2CPjJ64ThwIUZT2nHUzGp1U4mQMKkxiJOEiDxsrL/+XwuOFEy6vM1tx2WA==
X-YMail-OSG: QsOb4xYVM1n4lMLKWhmmDG1zCTG7RH3dlab.NvRWbXpiN4rejw0GKbkgm4fY6hr
 zBTva_g87EUjhdlo5yfPQ3W_UQ2oXudM0EyrWRJ8DfZXZ_tRyCPd.Z_EAEopyY7L42KulW_qJGkY
 cbmVK1PHEUnAwAPYSovVhJnm_Q2_SiG1rfUjfiOdluYraDtkVlopH3dQvdcvkHZM1iDB4Y.vxqyI
 p7RpO0K7FRlkZc6DPqogO5ntZ4y_Kd3BJD4hbjY7y6dZTBTfVdxx48mWtAqrGGzpP.BknPNpWVO1
 TsKrQArHG6nWqxa1S3PiPN0.Mwcm53VU31icOQmJfnwzlkcQ6IGL7LHGmUgZMd9toW9L5EPwRGeN
 RKLgrXWGYIzhZZWqR.RyNjk5IV_3tdRzu59z8F0WHUTgyh3ZpGXR4ZZLgtg5HDkqfFufrH80TdTo
 CkJdfMYp1QyBlTMN_SP8TCaWbYiPRLTi8mpa0AycSK3JJ9Wv0FJ7Ghu9MxnxdGrK0ummUIlYC_8a
 ZueATH8c3eqRj5PJ9zXxZDV1TSfN32Mw79doo37303D771PMlJlLbDuP8_sW0Nic_0zpzrOaUa2H
 _O_waDHaF5Qep2.we0m4m_9UmDE6qHuB3rY7Yav_PLbMcMZFWFNbfOoBGnSwPtSh1pcPZp0YE_k7
 5DLSe_yNf8rroyhBIux4iLSAucoOGpH_baJGhuoFfslwTrTRTsCO.NZ58iN6pw_D0katn_49celu
 zuh.3wVr8N7Aj1WBTWJMGCoo7qeZwpDBw9upRsDvLbl9ZakXOclqtCn_yffce2Fq3Y.y4n12ZLmc
 G61mVePc7Zr0v_3WvYG0vsOK9Ce7l7oqka6wun3aTmyi7bqhKFMMK0II1A6qrZdg9jWoKzhxZlBF
 VX20ItvNF0tcWo8SFB0mrBB19i6K0MVRhcnUzn9W40WC919x0PzmOkMMSCRcUp6d2CGYErjBFrjI
 9wSLH3eReB9XAm6NZ.vKfeBOxafHz99K283rvVe36gHoxt5x0v2uJ_KMNp3Ii.fCkV_Qeg3Wnpqm
 eGrEm5Dnl88Zcl8jI87BVnZ5nWRj2ED3ESpZgPrH.ERCr2qOEWnkN9jFS14wCzUfi9kt.cORkkHE
 YKpMiDpWdNptD6yc1U_T4DV3tS3R5aKa0OsROvgbmK9lj1Ds5YNJ8tC8x_Pe_.uADjHqv68Y1SnH
 8VHDors9h1exVL9HB_68SI8NoKlr4xeY22RgrDdlP3ZM14II5moKMMupf7WVxJfv7P5RPzhqmU2z
 1GOKYnciukKl_C7psyVBOeTLs04K1I9lK48GhaG2anfMCao4QS1Ocqjz3XjB.DkBg4mrkW93P4sX
 _np7z94ABKJS0VrnjLYuEvl1CjA_h48JMvNR03xCddAIVJ_eSwW7h9PujwsoUEY2ARMlbaROHTq4
 LJDJNmMRjG4dhsKlfDLQXNV8mMvs0POE6Pcsf8nRz.j8yhmYIM9FiFuNrC9ny1NmmDw9dHLGNF_Y
 kbiF.4_1FAXBk91TzrfKGBvhQTHPC7VHtnE8pnklJzhpVRQ4wFTN9.H_LM9DYKubb.lqobld_Erx
 EvmwuBm5IXVABMFe31634qv.ZAp42BfIRWqcU7ExQIxhenEKGoJA9Nb7FdHJx_VzShc9LCGLuIlA
 W4gSCpiOE5gDGpjzTQZ3aIMXmcJL95DtMkAI4NdIO9vW7X67CESdqWVIe8CoATfR8qi5WAiTrpBD
 yg0685QRBobwi.SezNP0pzjEwZiteL1SQgG7FvRusQrRl96bUNo7YcKS3B6TuyP4ozmJpekNmog5
 7XJNquufKYsGYEN3xI8IttlII_GO4J3IH7_nHoZbpLtTe0X16Yr2SgAO34VT4ZjTPuR_DJ1f85RX
 1cH2uTqOOIT7Ggv9Nth_1fCmDq8nUp4u.A.3UOov99leE.w8oxQgIy5VrQ_pyvZyA0eey5HAxY6a
 .GejtteKyQ3ho3lh3RNrZVCg6nsEZMjMow6d8g5_utFmYrAMUk9JVd8m88lLTgnQ1wjesFTqZE70
 O1Uj5__MbbZ9nyTgYB7iiVIIbo17c4E44warX7tVUBbTEecIKm0pFf8O.VjKHZ_ecdY26rCgbFwA
 zNyuPFWOB8Tlc3Tp.b1mKUZj2pO.moiZUccrUpe5Z9mRQNxzw3WK7np3ytM_OtQznotbRfoV6IcV
 exINMEnV3ImJMxuSfN.odAj1hXqeKktmuHh43JiWG8RyblAn9KtFiX80XKvJp335wzTkf.SE7kxw
 qC77xFYYkyknPi1aCG44TfF_TA2j6oceHDvHURg--
X-Sonic-MF: <jy6x2b32pie9@yahoo.com>
X-Sonic-ID: 928fac0a-1291-4244-8200-73aa4fa1d11e
Received: from sonic.gate.mail.ne1.yahoo.com by sonic306.consmr.mail.bf2.yahoo.com with HTTP; Sun, 23 Feb 2025 18:04:12 +0000
Received: by hermes--production-ir2-c694d79d9-f7l2b (Yahoo Inc. Hermes SMTP Server) with ESMTPA ID ca88de1b3b5903511dd9484aef8bea4b;
          Sun, 23 Feb 2025 16:43:14 +0000 (UTC)
Message-ID: <647ff8e8-caa7-4b26-8780-1e8308e19e5b@yahoo.com>
Date: Sun, 23 Feb 2025 20:43:11 +0400
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Content-Language: en-US
To: ell@lists.linux.dev
From: NHO <jy6x2b32pie9@yahoo.com>
Subject: Missing basename in util/test-path.c on musl-based systems
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
References: <647ff8e8-caa7-4b26-8780-1e8308e19e5b.ref@yahoo.com>
X-Mailer: WebService/1.1.23369 mail.backend.jedi.jws.acl:role.jedi.acl.token.atz.jws.hermes.yahoo

In systems using musl as libc, eg. certain Gentoo profiles, tests of ell 
fail to build, with error:
clang -DHAVE_CONFIG_H -I.    -fvisibility=hidden -DUNITDIR=\""./unit/"\" 
-DCERTDIR=\""./unit/"\" -O2 -pipe -fsigned-char 
-Wno-unknown-warning-option -Wno-unknown-pragmas -c -o unit/test-path.o 
unit/test-path.c
unit/test-path.c:65:9: error: call to undeclared function 'basename'; 
ISO C99 and later do not support implicit function declarations 
[-Wimplicit-function-declaration]
    65 |         base = basename(tmp_path);
       |                ^
unit/test-path.c:65:9: note: did you mean 'l_basename'?
./ell/path.h:20:13: note: 'l_basename' declared here
    20 | const char *l_basename(const char *path);
       |             ^
unit/test-path.c:65:7: error: incompatible integer to pointer conversion 
assigning to 'char *' from 'int' [-Wint-conversion]
    65 |         base = basename(tmp_path);
       |              ^ ~~~~~~~~~~~~~~~~~~
2 errors generated.

Musl doesn't have GNU basename() in the string.h, only POSIX in libgen.h
See also: Gentoo bug https://bugs.gentoo.org/942788
second error appears to be a false positive.

