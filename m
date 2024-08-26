Received: from mail-pf1-f171.google.com (mail-pf1-f171.google.com [209.85.210.171])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2BB9A135A79
	for <ell@lists.linux.dev>; Mon, 26 Aug 2024 19:06:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.171
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1724699173; cv=none; b=qY1JvAnnBGt/Z6haQlv95+q2RaZWTUhw6kElsTfQr2vlTFunDUgt9U8hdljBBVadmBHfXFZl8LrGl1ogf9qM/Kd2W250mZhcdIU5JXkJ8ivRoHakCVqDvp/wApsoW/Z33/5BLqJ3rC4QrAghFWZuQ4zh3oJqSQWu28rFEFoyxh8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1724699173; c=relaxed/simple;
	bh=YTNybD3H9Sbfj5e/8LGQ3xD3sZaJ9El7DSBb9IpMLao=;
	h=Message-ID:Date:MIME-Version:Subject:From:To:References:
	 In-Reply-To:Content-Type; b=Y7EJ7+EXmHBfjrNUeHlqRD15lyTZ6hl/DzfwsiwnjE2ix810d79C2K/D3KEAw43K4KSvdyXkAbgQPWKkXgHaWnnsb6aLApwlfLHGl91DCk9LtioNpOy/JsHFGOr0IhB9+cSXjqw3nC2yHG69HirOzPlEUKBdhfea1N1314s593Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=KRRMLZ3C; arc=none smtp.client-ip=209.85.210.171
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="KRRMLZ3C"
Received: by mail-pf1-f171.google.com with SMTP id d2e1a72fcca58-7143185edf2so3917375b3a.0
        for <ell@lists.linux.dev>; Mon, 26 Aug 2024 12:06:11 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1724699171; x=1725303971; darn=lists.linux.dev;
        h=in-reply-to:autocrypt:content-language:references:to:from:subject
         :user-agent:mime-version:date:message-id:from:to:cc:subject:date
         :message-id:reply-to;
        bh=YTNybD3H9Sbfj5e/8LGQ3xD3sZaJ9El7DSBb9IpMLao=;
        b=KRRMLZ3CLyYQlbUqKOQycS87MRLBZneaGdx27l2WqehzrALz/xO8PJniZoewZgrUwC
         9eSLz05R3g4EWVG8CAPJw2nAXn+3IBDibLBX5AIrSZzmEuDQuwmbfRCjuro4K1HGDsBm
         Omzf9gIuXHo3zavcw6zGBcnJtswGAUiNtLYYUsE6Th/tiO7uI67lj3tKH7sd4DouMAun
         tzFZ3lD71SkiQRSr9m9KpgQm+nj/49PL7OzjZAnE/vK0DrtP58vjDQrQH59K/BII1oEO
         T6EahVKpPNedJxnEMou9P+vutLZ73CaqSboSJxp0o+9MROi/76QBrN7AoPxVlDs72g0N
         kykQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1724699171; x=1725303971;
        h=in-reply-to:autocrypt:content-language:references:to:from:subject
         :user-agent:mime-version:date:message-id:x-gm-message-state:from:to
         :cc:subject:date:message-id:reply-to;
        bh=YTNybD3H9Sbfj5e/8LGQ3xD3sZaJ9El7DSBb9IpMLao=;
        b=hKPA2gIqFOKAQ+Uim4rPjwPbFWNDN0L9onOoPgy2LYheunfb9vRjybHkptAMDRqZ03
         Szpoar+IIgyX+3XSb4B/Z1if77EGPZm8xzPxuuAyPjdczBPwJftsA5edCvDzFEM+Uu87
         cLDHVeOG/GZ6zHwgMyltHI+JCI0os7/GcouQNI+JesJeWR8p1+77G7FGNY0rcM56yS3T
         kCwxVYsjwfobAQlKTrDPJhmJoCyMmqULJaOkCnuM5A2LaVKv1gy4j5YjPHOT/6VZG+uy
         TDtFWgjPaAxs8h1y68VvyEgmCqpilI8vYr0TrKnczGc2yjzyc0QtMkjfZHxfWF4pvKJ4
         015A==
X-Forwarded-Encrypted: i=1; AJvYcCVn7oZNyf7cX2NthnvcnIKNAT7j9R2sNmOWYOBDDdXBQriFErMBmrTyVX3CclpZUBZTL0g=@lists.linux.dev
X-Gm-Message-State: AOJu0YwZkJOA3D9cd5aRNAHZ23QkJB7Pl8E3C02A+abSBNbac2phk7qK
	o5Lr+rrlLrrN7CtGxVeym8SKnvwnIZW6jl8H8hUUbI4Igle6WA0yorO7VAwL
X-Google-Smtp-Source: AGHT+IEo1y/PsdxtLhwxZn6N2Wn/i1NoYnmEThxL++Obi0kONDpYb4hh33F3G4sJG8SGAWdrNP4Sjw==
X-Received: by 2002:a05:6a21:e94:b0:1c0:f1ea:adf with SMTP id adf61e73a8af0-1cc8b47e485mr13149020637.16.1724699171013;
        Mon, 26 Aug 2024 12:06:11 -0700 (PDT)
Received: from ?IPV6:2409:40e1:1144:7fc1:f3a:898b:de0c:87f5? ([2409:40e1:1144:7fc1:f3a:898b:de0c:87f5])
        by smtp.gmail.com with ESMTPSA id 41be03b00d2f7-7cd9ad55f00sm7915621a12.73.2024.08.26.12.06.09
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 26 Aug 2024 12:06:10 -0700 (PDT)
Message-ID: <5b232f87-2fd9-445f-8650-66a05ad18217@gmail.com>
Date: Tue, 27 Aug 2024 00:36:06 +0530
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: Segmentation Fault in iwd with ell 0.68 Due to l_netlink_send()
From: Rajdeep Malakar <rajdeepm.dev@gmail.com>
To: Denis Kenzior <denkenz@gmail.com>, ell@lists.linux.dev
References: <d16d043c-aa5c-4fb8-8df6-8c109c6239bf@gmail.com>
 <f321352f-641d-4fb8-ad8c-3480c97992cc@gmail.com>
 <b7a1d7fd-a42a-48f0-8c1f-c5cc19b15a9f@gmail.com>
Content-Language: en-US
Autocrypt: addr=rajdeepm.dev@gmail.com; keydata=
 xjMEZcjGsRYJKwYBBAHaRw8BAQdAFsHHQM5yuUKpk2zn4THdaG8ksYhWtxJLNCWByeI7TM3N
 KFJhamRlZXAgTWFsYWthciA8cmFqZGVlcG0uZGV2QGdtYWlsLmNvbT7CkwQTFgoAOxYhBJmH
 hd9oeyQWbbGxsmg7rWbjxUxHBQJlyMaxAhsDBQsJCAcCAiICBhUKCQgLAgQWAgMBAh4HAheA
 AAoJEGg7rWbjxUxHmLoA/RpBa2fiVQlIrqsoFly8azNBvU7sI4nrbQ2KSXYbd+mxAQCbzGxN
 zoS1zJ4+kvzo99jcjg9lHNj6jy3DwAsmLXDRDM44BGXIxrESCisGAQQBl1UBBQEBB0CS16zl
 ts9v9wjePBnusFUxAdhQES84wRxNQdWAbxEeIAMBCAfCeAQYFgoAIBYhBJmHhd9oeyQWbbGx
 smg7rWbjxUxHBQJlyMaxAhsMAAoJEGg7rWbjxUxHR4UA/1Y0V+zoQzjgIcFbS6XLM2GPVzSo
 qrMzhTDwuydE62XUAQD1p0mO6aEZmD5UPGOApCj76fnqZPicxtsVVgIbbBBqDw==
In-Reply-To: <b7a1d7fd-a42a-48f0-8c1f-c5cc19b15a9f@gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="------------N0FTDhVoZDVghuNssqa7F9uZ"

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--------------N0FTDhVoZDVghuNssqa7F9uZ
Content-Type: multipart/mixed; boundary="------------sOJqbe6x8DLDWeB2PZ0PzF02";
 protected-headers="v1"
From: Rajdeep Malakar <rajdeepm.dev@gmail.com>
To: Denis Kenzior <denkenz@gmail.com>, ell@lists.linux.dev
Message-ID: <5b232f87-2fd9-445f-8650-66a05ad18217@gmail.com>
Subject: Re: Segmentation Fault in iwd with ell 0.68 Due to l_netlink_send()
References: <d16d043c-aa5c-4fb8-8df6-8c109c6239bf@gmail.com>
 <f321352f-641d-4fb8-ad8c-3480c97992cc@gmail.com>
 <b7a1d7fd-a42a-48f0-8c1f-c5cc19b15a9f@gmail.com>
In-Reply-To: <b7a1d7fd-a42a-48f0-8c1f-c5cc19b15a9f@gmail.com>

--------------sOJqbe6x8DLDWeB2PZ0PzF02
Content-Type: multipart/mixed; boundary="------------ZlmIMTXsfgcxje4gZSM3Qp0f"

--------------ZlmIMTXsfgcxje4gZSM3Qp0f
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: base64

T24gMjcvMDgvMjQgMDA6MjUsIFJhamRlZXAgTWFsYWthciB3cm90ZToNCkhpIERlbmlzLA0K
DQo+IEhpIERlbmlzLA0KPiANCj4gT24gMjcvMDgvMjQgMDA6MTYsIERlbmlzIEtlbnppb3Ig
d3JvdGU6DQo+PiBIaSBSYWpkZWVwLA0KPj4NCj4+IE9uIDgvMjYvMjQgMToxNCBQTSwgUmFq
ZGVlcCBNYWxha2FyIHdyb3RlOg0KPj4+IEhpLA0KPj4+DQo+Pj4gSeKAmW0gZW5jb3VudGVy
aW5nIGEgc2VnbWVudGF0aW9uIGZhdWx0IGluIGl3ZCBhZnRlciB1cGdyYWRpbmcgdGhlIGVs
bCANCj4+PiBsaWJyYXJ5IGZyb20gdmVyc2lvbiAwLjY3IHRvIDAuNjguIFRoZSBpc3N1ZSBz
ZWVtcyB0byBiZSByZWxhdGVkIHRvIA0KPj4+IHRoZSBsX25ldGxpbmtfc2VuZCgpIGZ1bmN0
aW9uIGluIHRoZSBlbGwgbGlicmFyeS4NCj4+DQo+PiBUaGFua3MgZm9yIHRoZSByZXBvcnQu
wqAgRG8geW91IGhhdmUgYSBiYWNrdHJhY2UgeW91IGNhbiBzaGFyZSBieSBhbnkgDQo+PiBj
aGFuY2U/DQo+Pg0KPj4gUmVnYXJkcywNCj4+IC1EZW5pDQo+IFVuZm9ydHVuYXRlbHksIHRo
ZSBgbGliZWxsLnNvYCBJIGhhdmUgKGZyb20gQXJjaCdzIFtleHRyYS10ZXN0aW5nXSByZXBv
KSANCj4gd2Fzbid0IGNvbXBpbGVkIHdpdGggZGVidWdpbmZvLCBzbyBhbGwgdGhlIGJhY2t0
cmFjZSBJIGhhdmUgaXM6DQo+IA0KPiAjMMKgIDB4MDAwMDdmZmZmN2YyMmRlNiBpbiBsX25l
dGxpbmtfc2VuZCAoKSBmcm9tIC91c3IvbGliL2xpYmVsbC5zby4wDQo+ICMxwqAgMHgwMDAw
NTU1NTU1NTZkNTNkIGluID8/ICgpDQo+ICMywqAgMHgwMDAwNTU1NTU1NWFlMzgwIGluID8/
ICgpDQo+ICMzwqAgMHgwMDAwN2ZmZmY3ZjI1Yjk1IGluID8/ICgpIGZyb20gL3Vzci9saWIv
bGliZWxsLnNvLjANCj4gIzTCoCAweDAwMDA3ZmZmZjdmMjAzY2IgaW4gPz8gKCkgZnJvbSAv
dXNyL2xpYi9saWJlbGwuc28uMA0KPiAjNcKgIDB4MDAwMDdmZmZmN2YyMDY1NSBpbiBsX21h
aW5faXRlcmF0ZSAoKSBmcm9tIC91c3IvbGliL2xpYmVsbC5zby4wDQo+ICM2wqAgMHgwMDAw
N2ZmZmY3ZjIwYWNlIGluIGxfbWFpbl9ydW4gKCkgZnJvbSAvdXNyL2xpYi9saWJlbGwuc28u
MA0KPiAjN8KgIDB4MDAwMDdmZmZmN2YyMjNhNCBpbiBsX21haW5fcnVuX3dpdGhfc2lnbmFs
ICgpIGZyb20gDQo+IC91c3IvbGliL2xpYmVsbC5zby4wDQo+ICM4wqAgMHgwMDAwNTU1NTU1
NTVmZDEzIGluID8/ICgpDQo+ICM5wqAgMHgwMDAwN2ZmZmY3ZDBlZTA4IGluID8/ICgpIGZy
b20gL3Vzci9saWIvbGliYy5zby42DQo+ICMxMCAweDAwMDA3ZmZmZjdkMGVlY2MgaW4gX19s
aWJjX3N0YXJ0X21haW4gKCkgZnJvbSAvdXNyL2xpYi9saWJjLnNvLjYNCj4gIzExIDB4MDAw
MDU1NTU1NTU2MDU3NSBpbiA/PyAoKQ0KPiANCj4gSSB3aWxsIHRyeSB0byBjb21waWxlIGl0
IHdpdGggZGVidWdpbmZvIGFuZCBnZXQgdGhlIGJhY2t0cmFjZS4NCj4gDQoNClNvLCBJIGNv
bXBpbGVkIGVsbCB3aXRoIGEgYml0IG1vcmUgaW5mbzoNCg0KUHJvZ3JhbSByZWNlaXZlZCBz
aWduYWwgU0lHU0VHViwgU2VnbWVudGF0aW9uIGZhdWx0Lg0KMHgwMDAwN2ZmZmY3ZjNlMTdj
IGluIGxfbmV0bGlua19zZW5kIChuZXRsaW5rPTB4NTU1NTU1NjNiYzYwLCANCm1lc3NhZ2U9
MHgxMiwgZnVuY3Rpb249MHgwLCB1c2VyX2RhdGE9MHg1NTU1NTU2NTFlNTAsIGRlc3Ryb3k9
MHgxMCkgYXQgDQplbGwvbmV0bGluay5jOjQxMw0KNDEzICAgICAgICAgICAgIGlmICh1bmxp
a2VseShtZXNzYWdlLT5uZXN0X2xldmVsKSkNCg0KYSBiaXQgbW9yZSBiYWNrdHJhY2U6DQoN
CiMwICAweDAwMDA3ZmZmZjdmM2UxN2MgaW4gbF9uZXRsaW5rX3NlbmQgKG5ldGxpbms9MHg1
NTU1NTU2M2JjNjAsIA0KbWVzc2FnZT0weDEyLCBmdW5jdGlvbj0weDAsIHVzZXJfZGF0YT0w
eDU1NTU1NTY1MWU1MCwgZGVzdHJveT0weDEwKSBhdCANCmVsbC9uZXRsaW5rLmM6NDEzDQoj
MSAgMHgwMDAwNTU1NTU1NTZkNTNkIGluID8/ICgpDQojMiAgMHgwMDAwNTU1NTU1NWFlMzgw
IGluID8/ICgpDQojMyAgMHgwMDAwN2ZmZmY3ZjQwMDE0IGluIHByb2Nlc3NfdW5pY2FzdCAo
Z2VubD08b3B0aW1pemVkIG91dD4sIA0Kbmxtc2c9MHg3ZmZmZmZmZmMxNDApIGF0IGVsbC9n
ZW5sLmM6ODYwDQojNCAgcmVjZWl2ZWRfZGF0YSAoaW89PG9wdGltaXplZCBvdXQ+LCB1c2Vy
X2RhdGE9MHg1NTU1NTU2M2I4YjApIGF0IA0KZWxsL2dlbmwuYzo5NzINCiM1ICAweDAwMDA3
ZmZmZjdmM2MyYWMgaW4gaW9fY2FsbGJhY2sgKGZkPTxvcHRpbWl6ZWQgb3V0PiwgZXZlbnRz
PTEsIA0KdXNlcl9kYXRhPTB4NTU1NTU1NjNiODAwKSBhdCBlbGwvaW8uYzoxMDUNCiM2ICAw
eDAwMDA3ZmZmZjdmM2I0OTUgaW4gbF9tYWluX2l0ZXJhdGUgKHRpbWVvdXQ9PG9wdGltaXpl
ZCBvdXQ+KSBhdCANCmVsbC9tYWluLmM6NDYxDQojNyAgMHgwMDAwN2ZmZmY3ZjNiNTVjIGlu
IGxfbWFpbl9ydW4gKCkgYXQgZWxsL21haW4uYzo1MDgNCiM4ICBsX21haW5fcnVuICgpIGF0
IGVsbC9tYWluLmM6NDkwDQojOSAgMHgwMDAwN2ZmZmY3ZjNiNzdiIGluIGxfbWFpbl9ydW5f
d2l0aF9zaWduYWwgKGNhbGxiYWNrPTxvcHRpbWl6ZWQgDQpvdXQ+LCB1c2VyX2RhdGE9MHgw
KSBhdCBlbGwvbWFpbi5jOjYzMA0KIzEwIDB4MDAwMDU1NTU1NTU1ZmQxMyBpbiA/PyAoKQ0K
IzExIDB4MDAwMDdmZmZmN2QwYWUwOCBpbiA/PyAoKSBmcm9tIC91c3IvbGliL2xpYmMuc28u
Ng0KIzEyIDB4MDAwMDdmZmZmN2QwYWVjYyBpbiBfX2xpYmNfc3RhcnRfbWFpbiAoKSBmcm9t
IC91c3IvbGliL2xpYmMuc28uNg0KIzEzIDB4MDAwMDU1NTU1NTU2MDU3NSBpbiA/PyAoKQ0K
DQpMZXQgbWUga25vdyBpZiB5b3UgbmVlZCBtb3JlIGluZm8uDQotLSANCnJlZ2FyZHMsDQpy
YWpkZWVwDQoNCg==
--------------ZlmIMTXsfgcxje4gZSM3Qp0f
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

--------------ZlmIMTXsfgcxje4gZSM3Qp0f--

--------------sOJqbe6x8DLDWeB2PZ0PzF02--

--------------N0FTDhVoZDVghuNssqa7F9uZ
Content-Type: application/pgp-signature; name="OpenPGP_signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="OpenPGP_signature.asc"

-----BEGIN PGP SIGNATURE-----

wnsEABYIACMWIQSZh4XfaHskFm2xsbJoO61m48VMRwUCZszSHgUDAAAAAAAKCRBoO61m48VMR6FA
AP9ZdT/1ZKthLPxIS8T8I4wsaAIXkrQ9ZxYfcVpQ6qcNPwEAzmFb/rStu4+kSQwyifylLv1byGJN
7PFbWrRnVvbJuAE=
=umbX
-----END PGP SIGNATURE-----

--------------N0FTDhVoZDVghuNssqa7F9uZ--
