Received: from mail-pf1-f173.google.com (mail-pf1-f173.google.com [209.85.210.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6E7CE7406F
	for <ell@lists.linux.dev>; Mon, 26 Aug 2024 18:55:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.173
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1724698511; cv=none; b=EsACtpy8smI6SZ/Ap0++Lu+wQsbtnNq27FKtgC6esz5m0i0StwwXDfNsaCNe42Pv0J2/yRDaloVkFE13Myz89LLVwiZ+AxjENbvgAyvYtSOYdPTC902iHh9wkDf2rhsVtlXj0Rfr15okasCUrqnNfiYjSKg6aeMCcBsuk4q7T/4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1724698511; c=relaxed/simple;
	bh=SHYwiNLD5wHqGL7qPShFW6FM8EisU6ZTk5lrmbFm5sU=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=bg/kXb7AkfIrWnFwq4sNHCyTV2IoNZclTQsMRlcGryUqdNIn59L85DCXNoilROX1n5/NkSV75CHYSiyZE0Dqw4f+BGNgrIBroeDN49HUaF09mOcr39zvfvlg/P7AZnJJTBgjbiGVP5IFShe3vjNW0ndOOL+tK2GO711Kqf18k/k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=PKCYxsqS; arc=none smtp.client-ip=209.85.210.173
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="PKCYxsqS"
Received: by mail-pf1-f173.google.com with SMTP id d2e1a72fcca58-714261089c1so3291646b3a.0
        for <ell@lists.linux.dev>; Mon, 26 Aug 2024 11:55:09 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1724698509; x=1725303309; darn=lists.linux.dev;
        h=in-reply-to:autocrypt:from:content-language:references:to:subject
         :user-agent:mime-version:date:message-id:from:to:cc:subject:date
         :message-id:reply-to;
        bh=SHYwiNLD5wHqGL7qPShFW6FM8EisU6ZTk5lrmbFm5sU=;
        b=PKCYxsqSBq+USMahvv7zGrlyVrgVA5DIINtKrO4aSBLHTOIgP2S5hiTIkTcXgbID0b
         vupS1hTbUuvagLmHT5peDQsJ+kMqfJA9cGsoYcqNl1+fRBdUSXv5wNIEEngS2sXPIivK
         u97jqitKseYZeTHqA9u4Scwa6y789lzMyw0F3Mmrmg4xDc40nVOE/eIEc1txALsAjqt1
         Ip1GPAjK37HaKNHZ7BwjdKD+EPc67qar16ssq/DWUqCNKQ4zzUIsFfjrAxrKfSVKggOA
         drXCOlTi8xvhFJiyT36bd2hLleVRkCvGJ3ANXwxHpq8NcD+o4gRh5jJ8bS+FFtnR4Vge
         +z5w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1724698509; x=1725303309;
        h=in-reply-to:autocrypt:from:content-language:references:to:subject
         :user-agent:mime-version:date:message-id:x-gm-message-state:from:to
         :cc:subject:date:message-id:reply-to;
        bh=SHYwiNLD5wHqGL7qPShFW6FM8EisU6ZTk5lrmbFm5sU=;
        b=nCYGeSYVOcl0chqHfa2KNh3zjCDxvG+ko4IiA9C1HNU47yq7l/YQBGXzlHgTgCzqG0
         SzVRv8jhpfyOZQydH5IQE24aBjkRgCEk9l0tspu9qBZvE+8ZRNxAGBNrbcls0QPCF7Dt
         4TeL+z5l/XHP0Ig39bSB5GnIYGXMOBcJnIHtYOYs/TlAS1fKO1T4JeLy9+Xl8O18fhEf
         +o9HtGEmJYiIIhPLOnLhqpJQUVUfIkhGba/2N1GvqHxqXuzE6qJael4y9LoMGGuim6e2
         9qFvS67D6aUIch+ACmwj6iRIAYoaceW8BfwAehqaoPD95nYmeIR+Yh8ao7XT+ICn91dO
         q3vA==
X-Forwarded-Encrypted: i=1; AJvYcCXf5IyAQ8q67JkCGPWT2vIhnKLOow89fONtZt1ybUzUYP0FSww6YkNJxn3axsPFjmULpC4=@lists.linux.dev
X-Gm-Message-State: AOJu0YwYP2RT/oxlxvOFTaLR9b8BlFrv25ZlEXJXtK/uzj6ksFpayEh6
	0fByd6ntKGRAZwxMkQuQgyY/9cMwX0sOcXcM1kFpGgdrjQUCBAENykcrBPJg
X-Google-Smtp-Source: AGHT+IELstKPjesIwFJsMYjh8FcU3/+whnlWMbsva/7TJHnmaTQMcRRK3ZS6Hm+u4S2+ZJkLTah2Jw==
X-Received: by 2002:a05:6a00:6f16:b0:710:9d5e:1154 with SMTP id d2e1a72fcca58-715bfee4328mr966880b3a.2.1724698508420;
        Mon, 26 Aug 2024 11:55:08 -0700 (PDT)
Received: from ?IPV6:2409:40e1:1144:7fc1:e60d:36ff:fe7f:7763? ([2409:40e1:1144:7fc1:e60d:36ff:fe7f:7763])
        by smtp.gmail.com with ESMTPSA id d2e1a72fcca58-7143422ed8bsm7353093b3a.32.2024.08.26.11.55.06
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 26 Aug 2024 11:55:08 -0700 (PDT)
Message-ID: <b7a1d7fd-a42a-48f0-8c1f-c5cc19b15a9f@gmail.com>
Date: Tue, 27 Aug 2024 00:25:03 +0530
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
In-Reply-To: <f321352f-641d-4fb8-ad8c-3480c97992cc@gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="------------g4r7yuk0uVy2tufn6Bi5lHIT"

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--------------g4r7yuk0uVy2tufn6Bi5lHIT
Content-Type: multipart/mixed; boundary="------------oFToG8ZjANpOjg0Uxdn5CrhM";
 protected-headers="v1"
From: Rajdeep Malakar <rajdeepm.dev@gmail.com>
To: Denis Kenzior <denkenz@gmail.com>, ell@lists.linux.dev
Message-ID: <b7a1d7fd-a42a-48f0-8c1f-c5cc19b15a9f@gmail.com>
Subject: Re: Segmentation Fault in iwd with ell 0.68 Due to l_netlink_send()
References: <d16d043c-aa5c-4fb8-8df6-8c109c6239bf@gmail.com>
 <f321352f-641d-4fb8-ad8c-3480c97992cc@gmail.com>
In-Reply-To: <f321352f-641d-4fb8-ad8c-3480c97992cc@gmail.com>

--------------oFToG8ZjANpOjg0Uxdn5CrhM
Content-Type: multipart/mixed; boundary="------------tRMu3Lttv9fXdORIk1TtNAp1"

--------------tRMu3Lttv9fXdORIk1TtNAp1
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: base64

SGkgRGVuaXMsDQoNCk9uIDI3LzA4LzI0IDAwOjE2LCBEZW5pcyBLZW56aW9yIHdyb3RlOg0K
PiBIaSBSYWpkZWVwLA0KPiANCj4gT24gOC8yNi8yNCAxOjE0IFBNLCBSYWpkZWVwIE1hbGFr
YXIgd3JvdGU6DQo+PiBIaSwNCj4+DQo+PiBJ4oCZbSBlbmNvdW50ZXJpbmcgYSBzZWdtZW50
YXRpb24gZmF1bHQgaW4gaXdkIGFmdGVyIHVwZ3JhZGluZyB0aGUgZWxsIA0KPj4gbGlicmFy
eSBmcm9tIHZlcnNpb24gMC42NyB0byAwLjY4LiBUaGUgaXNzdWUgc2VlbXMgdG8gYmUgcmVs
YXRlZCB0byANCj4+IHRoZSBsX25ldGxpbmtfc2VuZCgpIGZ1bmN0aW9uIGluIHRoZSBlbGwg
bGlicmFyeS4NCj4gDQo+IFRoYW5rcyBmb3IgdGhlIHJlcG9ydC7CoCBEbyB5b3UgaGF2ZSBh
IGJhY2t0cmFjZSB5b3UgY2FuIHNoYXJlIGJ5IGFueSANCj4gY2hhbmNlPw0KPiANCj4gUmVn
YXJkcywNCj4gLURlbmkNClVuZm9ydHVuYXRlbHksIHRoZSBgbGliZWxsLnNvYCBJIGhhdmUg
KGZyb20gQXJjaCdzIFtleHRyYS10ZXN0aW5nXSByZXBvKSANCndhc24ndCBjb21waWxlZCB3
aXRoIGRlYnVnaW5mbywgc28gYWxsIHRoZSBiYWNrdHJhY2UgSSBoYXZlIGlzOg0KDQojMCAg
MHgwMDAwN2ZmZmY3ZjIyZGU2IGluIGxfbmV0bGlua19zZW5kICgpIGZyb20gL3Vzci9saWIv
bGliZWxsLnNvLjANCiMxICAweDAwMDA1NTU1NTU1NmQ1M2QgaW4gPz8gKCkNCiMyICAweDAw
MDA1NTU1NTU1YWUzODAgaW4gPz8gKCkNCiMzICAweDAwMDA3ZmZmZjdmMjViOTUgaW4gPz8g
KCkgZnJvbSAvdXNyL2xpYi9saWJlbGwuc28uMA0KIzQgIDB4MDAwMDdmZmZmN2YyMDNjYiBp
biA/PyAoKSBmcm9tIC91c3IvbGliL2xpYmVsbC5zby4wDQojNSAgMHgwMDAwN2ZmZmY3ZjIw
NjU1IGluIGxfbWFpbl9pdGVyYXRlICgpIGZyb20gL3Vzci9saWIvbGliZWxsLnNvLjANCiM2
ICAweDAwMDA3ZmZmZjdmMjBhY2UgaW4gbF9tYWluX3J1biAoKSBmcm9tIC91c3IvbGliL2xp
YmVsbC5zby4wDQojNyAgMHgwMDAwN2ZmZmY3ZjIyM2E0IGluIGxfbWFpbl9ydW5fd2l0aF9z
aWduYWwgKCkgZnJvbSANCi91c3IvbGliL2xpYmVsbC5zby4wDQojOCAgMHgwMDAwNTU1NTU1
NTVmZDEzIGluID8/ICgpDQojOSAgMHgwMDAwN2ZmZmY3ZDBlZTA4IGluID8/ICgpIGZyb20g
L3Vzci9saWIvbGliYy5zby42DQojMTAgMHgwMDAwN2ZmZmY3ZDBlZWNjIGluIF9fbGliY19z
dGFydF9tYWluICgpIGZyb20gL3Vzci9saWIvbGliYy5zby42DQojMTEgMHgwMDAwNTU1NTU1
NTYwNTc1IGluID8/ICgpDQoNCkkgd2lsbCB0cnkgdG8gY29tcGlsZSBpdCB3aXRoIGRlYnVn
aW5mbyBhbmQgZ2V0IHRoZSBiYWNrdHJhY2UuDQoNCi0tIA0KcmVnYXJkcywNCnJhamRlZXAN
Cg0K
--------------tRMu3Lttv9fXdORIk1TtNAp1
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

--------------tRMu3Lttv9fXdORIk1TtNAp1--

--------------oFToG8ZjANpOjg0Uxdn5CrhM--

--------------g4r7yuk0uVy2tufn6Bi5lHIT
Content-Type: application/pgp-signature; name="OpenPGP_signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="OpenPGP_signature.asc"

-----BEGIN PGP SIGNATURE-----

wnsEABYIACMWIQSZh4XfaHskFm2xsbJoO61m48VMRwUCZszPiAUDAAAAAAAKCRBoO61m48VMRzSW
AQDGJTfz9w5BU5L/svnjhzPG3ai1Y26oxgocttex3ZQa+QEAtz7UGhDqra26bsuefbPXZ6u/4nWr
d4PUwIk1EYd41A0=
=hc6v
-----END PGP SIGNATURE-----

--------------g4r7yuk0uVy2tufn6Bi5lHIT--
