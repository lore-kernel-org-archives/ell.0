Received: from mail-pl1-f170.google.com (mail-pl1-f170.google.com [209.85.214.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 86D1A12C7FB
	for <ell@lists.linux.dev>; Mon, 26 Aug 2024 19:27:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.214.170
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1724700477; cv=none; b=sx59+Wwa/0Sw4LONHBVPzJDDsF9Zwk/RfvgSC99l3ecaQrCljqjqR0ImCK7xFM3H3PFc1mBEqaQuB+b4lqzxHWdyKh+jmWGgaQpmUUA+BjuUsUMryd5pFfvjHVBxvoaaAkC30BrMx7rYwfZF5V7DKKDuNbJvhdBOw6T9qqjjeWg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1724700477; c=relaxed/simple;
	bh=eYP4IJud8UqBfKOvdFYOKdsqfEOIK6hIguMay3F9ln0=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=V44rfbX5NrHhzKBIQN954W0I1REYAu30tm2wHz3S4xJPvmTLK9cbEBdVq+KxVmy4SNUKGBXv219cOJPIREp5ePJmsIqBVEgAh+xc/WSAbS4P/PfocNlLrrkL3l9qe/qoKIo8ROAYy3D8r1AA3fuOW2R/25Gug7UroqpPioT+84g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=A64dmaVR; arc=none smtp.client-ip=209.85.214.170
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="A64dmaVR"
Received: by mail-pl1-f170.google.com with SMTP id d9443c01a7336-20202df1c2fso36942845ad.1
        for <ell@lists.linux.dev>; Mon, 26 Aug 2024 12:27:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1724700476; x=1725305276; darn=lists.linux.dev;
        h=in-reply-to:autocrypt:from:content-language:references:to:subject
         :user-agent:mime-version:date:message-id:from:to:cc:subject:date
         :message-id:reply-to;
        bh=eYP4IJud8UqBfKOvdFYOKdsqfEOIK6hIguMay3F9ln0=;
        b=A64dmaVRUhkDc6TJgBfI78BJcBOopONextbD7GQg8u7SdZxvHjjEnvZRNGGS5QNv2i
         HyIfUVC52uOJ8uqtn+3GMQXnWp6bAIDk/syMhWkjGVACVwwjkgqkXi1jAc4BAFXjysP3
         26sbTmjvvy6aH1X9XlkZESXhNDOX5tDlLDbg3twDyRLbEmrtggMAqwp/+4ycwjfyWKjl
         cxSJzw/lTkIzmdzJotU7wtzSvaALK1dNvDhFxlN2D1ZovXPp9j0PPST4dqP/+yOeFU9W
         6U45z83Zc52A4cv0nmp//NnozY9/DkoaIEewVTvh7Vex9wI3+RcNZvY06pbfIBc8n5/O
         O4sw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1724700476; x=1725305276;
        h=in-reply-to:autocrypt:from:content-language:references:to:subject
         :user-agent:mime-version:date:message-id:x-gm-message-state:from:to
         :cc:subject:date:message-id:reply-to;
        bh=eYP4IJud8UqBfKOvdFYOKdsqfEOIK6hIguMay3F9ln0=;
        b=mdyU4pWnPViiQDN8yMrwSBk6v/kKuo5ilh12P5jpUs2kIhtatQRlbjEOD6BoIF9sg6
         +7gwphr4yXf5Kyk4JCLGm17xjCq1zFMWem6UHugW5g5TsgMKMk2LiUy/JlZdmB6I5P+5
         huLMQGIjVDYV2kO2/EKMWRYEMcC0y15WfHstLizxG23pG6lvtpiOFwtJPa/ccUArxb4L
         AMyNZm5jrbStJ3iHRK6HZ9RZNXw5rEVc1eEWgyvv8uGs3O5ChaVlZLh5iV9LIiDhTnIu
         qC67edNc1//w9lX7B/z+5V6DARclWWaYp1A0IkeP5RVO8zZGwBH6R5382lKkB1Mc5aQV
         V5WA==
X-Forwarded-Encrypted: i=1; AJvYcCVTwYsyR6e46VadX2HNZEqEt2proK6edosF1C3aV/dkckgfr9QrEy5WYNNNw5UUHFWUALI=@lists.linux.dev
X-Gm-Message-State: AOJu0Yw1UcI1nzd7pydJnVZGu4QgmTHi0/RRQ1fo9a3t6o0lsSbXGocf
	Hno0YYnvs+Dk4HzbyNZvzkNMl/0AqhUFnz6R3Ksq8PFrpIfuiUbH
X-Google-Smtp-Source: AGHT+IF81DdRLfCluUPIb2mJPXL8ZaQVw6bab4VHgN/x36dB6yaOWJ3Gyi9/FjJBcPopbTBpPLPbaQ==
X-Received: by 2002:a17:903:11c7:b0:203:b05a:ad9f with SMTP id d9443c01a7336-204dddc62b5mr9718145ad.32.1724700475402;
        Mon, 26 Aug 2024 12:27:55 -0700 (PDT)
Received: from [192.168.31.182] ([152.59.163.107])
        by smtp.gmail.com with ESMTPSA id d9443c01a7336-2038560a4b7sm70813025ad.197.2024.08.26.12.27.53
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 26 Aug 2024 12:27:55 -0700 (PDT)
Message-ID: <aa9006bf-f9a5-4fa3-b5aa-7d46fd32ad9a@gmail.com>
Date: Tue, 27 Aug 2024 00:57:51 +0530
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: Segmentation Fault in iwd with ell 0.68 Due to l_netlink_send()
To: Denis Kenzior <denkenz@gmail.com>, ell@lists.linux.dev
References: <d16d043c-aa5c-4fb8-8df6-8c109c6239bf@gmail.com>
 <f321352f-641d-4fb8-ad8c-3480c97992cc@gmail.com>
 <b7a1d7fd-a42a-48f0-8c1f-c5cc19b15a9f@gmail.com>
 <5b232f87-2fd9-445f-8650-66a05ad18217@gmail.com>
 <83a579fd-1f2a-403d-a3e4-e447b3885d62@gmail.com>
Content-Language: en-US
From: Rajdeep Malakar <rajdeepm.dev@gmail.com>
Autocrypt: addr=rajdeepm.dev@gmail.com; keydata=
 xjMEZcjGsRYJKwYBBAHaRw8BAQdAFsHHQM5yuUKpk2zn4THdaG8ksYhWtxJLNCWByeI7TM3N
 KFJhamRlZXAgTWFsYWthciA8cmFqZGVlcG0uZGV2QGdtYWlsLmNvbT7CkwQTFgoAOxYhBJmH
 hd9oeyQWbbGxsmg7rWbjxUxHBQJlyMaxAhsDBQsJCAcCAiICBhUKCQgLAgQWAgMBAh4HAheA
 AAoJEGg7rWbjxUxHmLoA/RpBa2fiVQlIrqsoFly8azNBvU7sI4nrbQ2KSXYbd+mxAQCbzGxN
 zoS1zJ4+kvzo99jcjg9lHNj6jy3DwAsmLXDRDM44BGXIxrESCisGAQQBl1UBBQEBB0CS16zl
 ts9v9wjePBnusFUxAdhQES84wRxNQdWAbxEeIAMBCAfCeAQYFgoAIBYhBJmHhd9oeyQWbbGx
 smg7rWbjxUxHBQJlyMaxAhsMAAoJEGg7rWbjxUxHR4UA/1Y0V+zoQzjgIcFbS6XLM2GPVzSo
 qrMzhTDwuydE62XUAQD1p0mO6aEZmD5UPGOApCj76fnqZPicxtsVVgIbbBBqDw==
In-Reply-To: <83a579fd-1f2a-403d-a3e4-e447b3885d62@gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="------------AsX0pSSGRdr7oWMHBw0fTuyD"

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--------------AsX0pSSGRdr7oWMHBw0fTuyD
Content-Type: multipart/mixed; boundary="------------axxaIiNeYFPx5FfUwnKGJfSt";
 protected-headers="v1"
From: Rajdeep Malakar <rajdeepm.dev@gmail.com>
To: Denis Kenzior <denkenz@gmail.com>, ell@lists.linux.dev
Message-ID: <aa9006bf-f9a5-4fa3-b5aa-7d46fd32ad9a@gmail.com>
Subject: Re: Segmentation Fault in iwd with ell 0.68 Due to l_netlink_send()
References: <d16d043c-aa5c-4fb8-8df6-8c109c6239bf@gmail.com>
 <f321352f-641d-4fb8-ad8c-3480c97992cc@gmail.com>
 <b7a1d7fd-a42a-48f0-8c1f-c5cc19b15a9f@gmail.com>
 <5b232f87-2fd9-445f-8650-66a05ad18217@gmail.com>
 <83a579fd-1f2a-403d-a3e4-e447b3885d62@gmail.com>
In-Reply-To: <83a579fd-1f2a-403d-a3e4-e447b3885d62@gmail.com>

--------------axxaIiNeYFPx5FfUwnKGJfSt
Content-Type: multipart/mixed; boundary="------------DarX4xn0XV1v0L5PJBPmwkDZ"

--------------DarX4xn0XV1v0L5PJBPmwkDZ
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: base64

SGkgRGVuaXMsDQoNCk9uIDI3LzA4LzI0IDAwOjUwLCBEZW5pcyBLZW56aW9yIHdyb3RlOg0K
PiBIaSBSYWpkZWVwLA0KPiANCj4+DQo+PiBTbywgSSBjb21waWxlZCBlbGwgd2l0aCBhIGJp
dCBtb3JlIGluZm86DQo+Pg0KPj4gUHJvZ3JhbSByZWNlaXZlZCBzaWduYWwgU0lHU0VHViwg
U2VnbWVudGF0aW9uIGZhdWx0Lg0KPj4gMHgwMDAwN2ZmZmY3ZjNlMTdjIGluIGxfbmV0bGlu
a19zZW5kIChuZXRsaW5rPTB4NTU1NTU1NjNiYzYwLCANCj4+IG1lc3NhZ2U9MHgxMiwgZnVu
Y3Rpb249MHgwLCB1c2VyX2RhdGE9MHg1NTU1NTU2NTFlNTAsIGRlc3Ryb3k9MHgxMCkgYXQg
DQo+PiBlbGwvbmV0bGluay5jOjQxMw0KPj4gNDEzwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKg
IGlmICh1bmxpa2VseShtZXNzYWdlLT5uZXN0X2xldmVsKSkNCj4+DQo+PiBhIGJpdCBtb3Jl
IGJhY2t0cmFjZToNCj4+DQo+PiAjMMKgIDB4MDAwMDdmZmZmN2YzZTE3YyBpbiBsX25ldGxp
bmtfc2VuZCAobmV0bGluaz0weDU1NTU1NTYzYmM2MCwgDQo+PiBtZXNzYWdlPTB4MTIsIGZ1
bmN0aW9uPTB4MCwgdXNlcl9kYXRhPTB4NTU1NTU1NjUxZTUwLCBkZXN0cm95PTB4MTApIGF0
IA0KPj4gZWxsL25ldGxpbmsuYzo0MTMNCj4+ICMxwqAgMHgwMDAwNTU1NTU1NTZkNTNkIGlu
ID8/ICgpDQo+PiAjMsKgIDB4MDAwMDU1NTU1NTVhZTM4MCBpbiA/PyAoKQ0KPj4gIzPCoCAw
eDAwMDA3ZmZmZjdmNDAwMTQgaW4gcHJvY2Vzc191bmljYXN0IChnZW5sPTxvcHRpbWl6ZWQg
b3V0PiwgDQo+PiBubG1zZz0weDdmZmZmZmZmYzE0MCkgYXQgZWxsL2dlbmwuYzo4NjANCj4+
ICM0wqAgcmVjZWl2ZWRfZGF0YSAoaW89PG9wdGltaXplZCBvdXQ+LCB1c2VyX2RhdGE9MHg1
NTU1NTU2M2I4YjApIGF0IA0KPj4gZWxsL2dlbmwuYzo5NzINCj4+ICM1wqAgMHgwMDAwN2Zm
ZmY3ZjNjMmFjIGluIGlvX2NhbGxiYWNrIChmZD08b3B0aW1pemVkIG91dD4sIGV2ZW50cz0x
LCANCj4+IHVzZXJfZGF0YT0weDU1NTU1NTYzYjgwMCkgYXQgZWxsL2lvLmM6MTA1DQo+PiAj
NsKgIDB4MDAwMDdmZmZmN2YzYjQ5NSBpbiBsX21haW5faXRlcmF0ZSAodGltZW91dD08b3B0
aW1pemVkIG91dD4pIGF0IA0KPj4gZWxsL21haW4uYzo0NjENCj4+ICM3wqAgMHgwMDAwN2Zm
ZmY3ZjNiNTVjIGluIGxfbWFpbl9ydW4gKCkgYXQgZWxsL21haW4uYzo1MDgNCj4+ICM4wqAg
bF9tYWluX3J1biAoKSBhdCBlbGwvbWFpbi5jOjQ5MA0KPj4gIznCoCAweDAwMDA3ZmZmZjdm
M2I3N2IgaW4gbF9tYWluX3J1bl93aXRoX3NpZ25hbCAoY2FsbGJhY2s9PG9wdGltaXplZCAN
Cj4+IG91dD4sIHVzZXJfZGF0YT0weDApIGF0IGVsbC9tYWluLmM6NjMwDQo+PiAjMTAgMHgw
MDAwNTU1NTU1NTVmZDEzIGluID8/ICgpDQo+PiAjMTEgMHgwMDAwN2ZmZmY3ZDBhZTA4IGlu
ID8/ICgpIGZyb20gL3Vzci9saWIvbGliYy5zby42DQo+PiAjMTIgMHgwMDAwN2ZmZmY3ZDBh
ZWNjIGluIF9fbGliY19zdGFydF9tYWluICgpIGZyb20gL3Vzci9saWIvbGliYy5zby42DQo+
PiAjMTMgMHgwMDAwNTU1NTU1NTYwNTc1IGluID8/ICgpDQo+Pg0KPj4gTGV0IG1lIGtub3cg
aWYgeW91IG5lZWQgbW9yZSBpbmZvLg0KPiANCj4gSSBzdXNwZWN0IHRoYXQgdGhpcyBpcyBh
IGJpbmFyeSBjb21wYXRpYmlsaXR5IHByb2JsZW0uwqAgZWxsIEFQSSBpcyBub3QgDQo+IHN0
YWJsZSwgc28gZWxsICsgaXdkIGFyZSByZWxlYXNlZCBpbiB0YW5kZW0uwqAgZWxsIDAuNjgg
YnJlYWtzIGNlcnRhaW4gDQo+IG5ldGxpbmsgQVBJcy7CoCBpd2QgMi4xOSByZXF1aXJlcyBl
bGwgMC42Ny7CoCBpd2QgMi4yMCB3aWxsIHJlcXVpcmUgZWxsIA0KPiAwLjY4LCBldGMuDQo+
IA0KPiBSZWdhcmRzLA0KPiAtRGVuaXMNCj4gDQoNClRoYW5rcyBmb3IgdGhlIHF1aWNrIHJl
cGx5LiBJZiB0aGF0J3MgdGhlIGNhc2UsIHRoZW4gc29ycnkgZm9yIGJvdGhlcmluZyANCnlv
dS4NCi0tIA0KcmVnYXJkcywNCnJhamRlZXANCg0K
--------------DarX4xn0XV1v0L5PJBPmwkDZ
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

--------------DarX4xn0XV1v0L5PJBPmwkDZ--

--------------axxaIiNeYFPx5FfUwnKGJfSt--

--------------AsX0pSSGRdr7oWMHBw0fTuyD
Content-Type: application/pgp-signature; name="OpenPGP_signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="OpenPGP_signature.asc"

-----BEGIN PGP SIGNATURE-----

wnsEABYIACMWIQSZh4XfaHskFm2xsbJoO61m48VMRwUCZszXNwUDAAAAAAAKCRBoO61m48VMR2EM
AQDvnT2ZRnMQOARNCLtL0bYYZAG8Y5oZu+1Quy92OA6QewEAihKrwkFigLwdLihGBvBhOd4hmLN6
7CeImSpxtJE/TAI=
=TiT5
-----END PGP SIGNATURE-----

--------------AsX0pSSGRdr7oWMHBw0fTuyD--
