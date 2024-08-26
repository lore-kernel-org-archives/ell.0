Received: from mail-pf1-f175.google.com (mail-pf1-f175.google.com [209.85.210.175])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A951F1547E2
	for <ell@lists.linux.dev>; Mon, 26 Aug 2024 18:14:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.175
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1724696061; cv=none; b=CHUuAfAKCLQGbOXxH8h2J4M5JqkJGsBz0JmeQpMDYJDHf60LzQotIW7vPDYRN7FFCORrcIbSnEtWPmTPY2R7POtBnC88fhbdXO2fpAzP4ti/oGnuItxkgB6O8fqdlJkCO/2vcvnx4c/2pHH0hDtqM071BKuWT6YlgmyMJNiuFcs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1724696061; c=relaxed/simple;
	bh=u/0K0KPptO00eJ3mLkENCE2xmzcbQIWuf7BVkgyJnjU=;
	h=Message-ID:Date:MIME-Version:To:From:Subject:Content-Type; b=cRJHbQMwtlBKdyXDWWehe+04p+r3EaD+vX+YGuWLs1dCfsJk2XkXKKTp4R1JeRQo+1nMUjJruLfAMgW8Grm6ZHqroHC0DQZKJyBoGHmFPaQDT0UF0WyPscoI7OVnIumMvENZDIdIow4H7ix/IltQUqz6T2HPJBnTgelOX3noHFs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=ENhlxipm; arc=none smtp.client-ip=209.85.210.175
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ENhlxipm"
Received: by mail-pf1-f175.google.com with SMTP id d2e1a72fcca58-715abede256so925853b3a.3
        for <ell@lists.linux.dev>; Mon, 26 Aug 2024 11:14:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1724696059; x=1725300859; darn=lists.linux.dev;
        h=autocrypt:subject:from:content-language:to:user-agent:mime-version
         :date:message-id:from:to:cc:subject:date:message-id:reply-to;
        bh=u/0K0KPptO00eJ3mLkENCE2xmzcbQIWuf7BVkgyJnjU=;
        b=ENhlxipm1tRB3ktkW03Ua9pIkDmMEfpk4MoTVHd0ORJ+FWewUgpl+XpFmnx8I9ePQW
         LeGPm3h0mi9BCABlik/I2d8dv7ZnP5Xz+io6/e3Cps4RhkiDOhHR7yOAFbGUhDq6VTHf
         rRNtgY9/g3SZ19/Nsz1FGS2Lxq8fbgGvjOjoM7z4OAtrQ/70yIatd/IeY1jvhtwKG/WS
         zpUw9vE8rvUs9wKpyCxOwnL30P3MVVxrCmGDnWru3nHOSE2/NskYtY6+Ybr9wTyMf8Zc
         kNgKz5RfQxeefXanGkhzbbEYnZjCVu2fu5EhkWswolV7eCOmPwoIMcZQQL195i+MvikN
         Ws+A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1724696059; x=1725300859;
        h=autocrypt:subject:from:content-language:to:user-agent:mime-version
         :date:message-id:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to;
        bh=u/0K0KPptO00eJ3mLkENCE2xmzcbQIWuf7BVkgyJnjU=;
        b=YdT4VxxRk3ivIGj4KH2NopXiaoNl5HvgQawJZ5f6CWBhwBytaJDw03efPA4xisf8gm
         FrvnAyZYjakdS5eoDUdRMJ3OO9tVeRdB3HUC7pUO3iR+voaf/ydixTdv8rS+oy0L26KA
         5g8HRbmNbM51iPDMYwi1A+OEB/IWKyCP65fttQI1VU1FYBZTyzkErRqDPfw4CFlJzXas
         if2EIdMGYb472/ceJ3rTmo4mafQSgk39AVlImOm0cI5s9CYVzV6zv7pAE6+tu1glm1KN
         urxLUTeuXaAbc9yey+Mhh6+0VZ99wpYeHUdAmi0yj7Rw4Gpt1oA8/4e8s7XtzQ110nGF
         7hFQ==
X-Gm-Message-State: AOJu0YxlkoJ0yau+hT1E9InGA2NvXLMlK6wwnMPJ6h9PbB9OqBunSr1t
	eo2IkUXnpsxOdKFAl3GSD4zIiGfQpBFNiRSxovVxiEaUs8jqVef6BqU19BxD
X-Google-Smtp-Source: AGHT+IGYfWTHMIxUHBUrmYUbPfIUb1EGyunApDvkZV6xwZqhc2sfnNSlt/PCbEHs8uVSURZKINWsHQ==
X-Received: by 2002:a05:6a00:1990:b0:710:7efe:a870 with SMTP id d2e1a72fcca58-71445dfe700mr10394865b3a.19.1724696058436;
        Mon, 26 Aug 2024 11:14:18 -0700 (PDT)
Received: from ?IPV6:2409:40e1:1144:7fc1:e60d:36ff:fe7f:7763? ([2409:40e1:1144:7fc1:e60d:36ff:fe7f:7763])
        by smtp.gmail.com with ESMTPSA id d2e1a72fcca58-71434338884sm7267684b3a.210.2024.08.26.11.14.17
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 26 Aug 2024 11:14:18 -0700 (PDT)
Message-ID: <d16d043c-aa5c-4fb8-8df6-8c109c6239bf@gmail.com>
Date: Mon, 26 Aug 2024 23:44:13 +0530
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
To: ell@lists.linux.dev
Content-Language: en-US
From: Rajdeep Malakar <rajdeepm.dev@gmail.com>
Subject: Segmentation Fault in iwd with ell 0.68 Due to l_netlink_send()
Autocrypt: addr=rajdeepm.dev@gmail.com; keydata=
 xjMEZcjGsRYJKwYBBAHaRw8BAQdAFsHHQM5yuUKpk2zn4THdaG8ksYhWtxJLNCWByeI7TM3N
 KFJhamRlZXAgTWFsYWthciA8cmFqZGVlcG0uZGV2QGdtYWlsLmNvbT7CkwQTFgoAOxYhBJmH
 hd9oeyQWbbGxsmg7rWbjxUxHBQJlyMaxAhsDBQsJCAcCAiICBhUKCQgLAgQWAgMBAh4HAheA
 AAoJEGg7rWbjxUxHmLoA/RpBa2fiVQlIrqsoFly8azNBvU7sI4nrbQ2KSXYbd+mxAQCbzGxN
 zoS1zJ4+kvzo99jcjg9lHNj6jy3DwAsmLXDRDM44BGXIxrESCisGAQQBl1UBBQEBB0CS16zl
 ts9v9wjePBnusFUxAdhQES84wRxNQdWAbxEeIAMBCAfCeAQYFgoAIBYhBJmHhd9oeyQWbbGx
 smg7rWbjxUxHBQJlyMaxAhsMAAoJEGg7rWbjxUxHR4UA/1Y0V+zoQzjgIcFbS6XLM2GPVzSo
 qrMzhTDwuydE62XUAQD1p0mO6aEZmD5UPGOApCj76fnqZPicxtsVVgIbbBBqDw==
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="------------a6uBH1t16g02NqyDwWnWQl8s"

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--------------a6uBH1t16g02NqyDwWnWQl8s
Content-Type: multipart/mixed; boundary="------------20JOc0vO0fIFxvu0lb1xY1Yq";
 protected-headers="v1"
From: Rajdeep Malakar <rajdeepm.dev@gmail.com>
To: ell@lists.linux.dev
Message-ID: <d16d043c-aa5c-4fb8-8df6-8c109c6239bf@gmail.com>
Subject: Segmentation Fault in iwd with ell 0.68 Due to l_netlink_send()

--------------20JOc0vO0fIFxvu0lb1xY1Yq
Content-Type: multipart/mixed; boundary="------------vBxUmRG8XgpB4yHCdE3tRMWY"

--------------vBxUmRG8XgpB4yHCdE3tRMWY
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: base64

SGksDQoNCknigJltIGVuY291bnRlcmluZyBhIHNlZ21lbnRhdGlvbiBmYXVsdCBpbiBpd2Qg
YWZ0ZXIgdXBncmFkaW5nIHRoZSBlbGwgDQpsaWJyYXJ5IGZyb20gdmVyc2lvbiAwLjY3IHRv
IDAuNjguIFRoZSBpc3N1ZSBzZWVtcyB0byBiZSByZWxhdGVkIHRvIHRoZSANCmxfbmV0bGlu
a19zZW5kKCkgZnVuY3Rpb24gaW4gdGhlIGVsbCBsaWJyYXJ5Lg0KDQpJc3N1ZSBEZXRhaWxz
Og0KDQotIEZ1bmN0aW9uIENhdXNpbmcgU2VnZmF1bHQ6IGxfbmV0bGlua19zZW5kKCkNCi0g
RXJyb3I6IFNJR1NFR1YgKFNlZ21lbnRhdGlvbiBGYXVsdCkNCi0gTGlicmFyeSBQYXRoOiAv
dXNyL2xpYi9saWJlbGwuc28uMA0KLSBTeXN0ZW06IEFyY2ggTGludXggeDg2LTY0DQoNClJl
cHJvZHVjdGlvbiBTdGVwczoNCg0KMS4gVXBncmFkZSBlbGwgZnJvbSB2ZXJzaW9uIDAuNjcg
dG8gMC42OC4NCjIuIFN0YXJ0IGl3ZC4NCjMuIE9ic2VydmUgdGhlIHNlZ21lbnRhdGlvbiBm
YXVsdC4NCg0KSSBjb25maXJtZWQgdGhpcyBpc3N1ZSB1c2luZyBnZGIsIHdoaWNoIGluZGlj
YXRlcyB0aGF0IGxfbmV0bGlua19zZW5kKCkgDQppbiB0aGUgZWxsIGxpYnJhcnkgaXMgY2F1
c2luZyB0aGUgc2VnbWVudGF0aW9uIGZhdWx0Lg0KDQpSZXZlcnRpbmcgdG8gZWxsIHZlcnNp
b24gMC42NyByZXNvbHZlcyB0aGUgaXNzdWUgd2l0aG91dCBjYXVzaW5nIGEgDQpzZWdtZW50
YXRpb24gZmF1bHQuDQoNClNpbmNlIHRoZXJlIGhhdmUgYmVlbiBubyB1cGRhdGVzIG9yIGNv
bW1pdHMgaW4gdGhlIHJlcG9zaXRvcnkgc2luY2UgdGhlIA0KcmVsZWFzZSwgSSB3YW50ZWQg
dG8gYnJpbmcgdGhpcyB0byB5b3VyIGF0dGVudGlvbi4gVGhpcyBtaWdodCBiZSBhIA0Kc3Bl
Y2lmaWMgcHJvYmxlbSB3aXRoIHRoZSByZWNlbnQgdmVyc2lvbiwgYW5kIGFueSBpbnNpZ2h0
cyBvciBzb2x1dGlvbnMgDQp3b3VsZCBiZSBncmVhdGx5IGFwcHJlY2lhdGVkLg0KDQpQbGVh
c2UgbGV0IG1lIGtub3cgaWYgYWRkaXRpb25hbCBpbmZvcm1hdGlvbiBpcyBuZWVkZWQgb3Ig
aWYgdGhlcmUgYXJlIA0KYW55IGtub3duIGlzc3VlcyB3aXRoIHRoaXMgdmVyc2lvbi4NCg0K
LS0tDQpyZWdhcmRzLA0KcmFqZGVlcA0K
--------------vBxUmRG8XgpB4yHCdE3tRMWY
Content-Type: application/pgp-keys; name="OpenPGP_0x683BAD66E3C54C47.asc"
Content-Disposition: attachment; filename="OpenPGP_0x683BAD66E3C54C47.asc"
Content-Description: OpenPGP public key
Content-Transfer-Encoding: quoted-printable

-----BEGIN PGP PUBLIC KEY BLOCK-----

xjMEZcjGsRYJKwYBBAHaRw8BAQdAFsHHQM5yuUKpk2zn4THdaG8ksYhWtxJLNCWB
yeI7TM3NKFJhamRlZXAgTWFsYWthciA8cmFqZGVlcG0uZGV2QGdtYWlsLmNvbT7C
kwQTFgoAOxYhBJmHhd9oeyQWbbGxsmg7rWbjxUxHBQJlyMaxAhsDBQsJCAcCAiIC
BhUKCQgLAgQWAgMBAh4HAheAAAoJEGg7rWbjxUxHmLoA/RpBa2fiVQlIrqsoFly8
azNBvU7sI4nrbQ2KSXYbd+mxAQCbzGxNzoS1zJ4+kvzo99jcjg9lHNj6jy3DwAsm
LXDRDM44BGXIxrESCisGAQQBl1UBBQEBB0CS16zlts9v9wjePBnusFUxAdhQES84
wRxNQdWAbxEeIAMBCAfCeAQYFgoAIBYhBJmHhd9oeyQWbbGxsmg7rWbjxUxHBQJl
yMaxAhsMAAoJEGg7rWbjxUxHR4UA/1Y0V+zoQzjgIcFbS6XLM2GPVzSoqrMzhTDw
uydE62XUAQD1p0mO6aEZmD5UPGOApCj76fnqZPicxtsVVgIbbBBqDw=3D=3D
=3D4uUH
-----END PGP PUBLIC KEY BLOCK-----

--------------vBxUmRG8XgpB4yHCdE3tRMWY--

--------------20JOc0vO0fIFxvu0lb1xY1Yq--

--------------a6uBH1t16g02NqyDwWnWQl8s
Content-Type: application/pgp-signature; name="OpenPGP_signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="OpenPGP_signature.asc"

-----BEGIN PGP SIGNATURE-----

wnsEABYIACMWIQSZh4XfaHskFm2xsbJoO61m48VMRwUCZszF9QUDAAAAAAAKCRBoO61m48VMR/vA
AP9hrKohwxfrtwhLplBUyNnjdMXE1yioMTKuOl3XecNVNwEAkzHcYAALHpUW8HvWfLvzFY7UeOeI
SoULKjPMTgI0hAY=
=a0fF
-----END PGP SIGNATURE-----

--------------a6uBH1t16g02NqyDwWnWQl8s--
