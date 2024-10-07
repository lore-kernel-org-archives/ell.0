Received: from mail-pl1-f178.google.com (mail-pl1-f178.google.com [209.85.214.178])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5EAF41E519
	for <ell@lists.linux.dev>; Mon,  7 Oct 2024 12:36:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.214.178
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1728304583; cv=none; b=R1Ngi0e3SBc3cVqJiEUKvj3v4pyDTniKHPmUaaSG0gy0emX2CuJ0WizUUuLlCnFYOMuA5oc17jT/FqA15603xoVn5FnAiWz84bLaY0CuPdwOx2GiQdX5aningUzsxtmVPgRNexIdkCPA/Ie4rR8smyALwEcujk+RWTe18vf+nH0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1728304583; c=relaxed/simple;
	bh=xz6w8hatiQxbmud/4m8ggXKhuUtbp+6vaaeY4JjRYkY=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=f1mV/GBY7Ksu2JSXF9JL6LC74TnzNjw7sybqnutw5q8Bn5Ndb7VtDZfbdiSxDBQoygnF08XlV/5lttUUGYML1uq6dOy68+jAUb7WFs2xaL3+Vk9sJMIFv5bxKPnx6syS7n7g+c/6nJYQR6I1cGyCWDIVYcAFJHjh9+TH+ph6coE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=a6KcFsHF; arc=none smtp.client-ip=209.85.214.178
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="a6KcFsHF"
Received: by mail-pl1-f178.google.com with SMTP id d9443c01a7336-20b7259be6fso47630855ad.0
        for <ell@lists.linux.dev>; Mon, 07 Oct 2024 05:36:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1728304582; x=1728909382; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id:from
         :to:cc:subject:date:message-id:reply-to;
        bh=3+wYour5a6D3Yd18eBQlkVKxF7kA6vII/q6BGTUOh6s=;
        b=a6KcFsHFNNYcvOsD3issmtD8uerpBHV4xPrqDmBn1kq0FYpeOwW/17i/5nD2XGXD98
         NPMCw58UPUbjObpT/d2pu/2MI84vVUxGs3ttD7qIRl2HxTpN2DUVJI44fONDGaYZlsbs
         UiBCMxaPWaTcZpinQWvLvThZOXmAaV7NvKy8tOlbFzS4jyy80Cr4jsY/tVLxJ6SY9yem
         +AIyLEEwNtZ0T++j12Csl7sLrmwByGijcSgQS6YkmogEwdwWIaa7bEGlwnbRE2CPYGPN
         u2F+eRzDnu+INzLNArElfbZCWq5k88lsBL/BHGKEqiOrl/si0FdQqi5WC6nHgtxO471a
         nFpw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1728304582; x=1728909382;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=3+wYour5a6D3Yd18eBQlkVKxF7kA6vII/q6BGTUOh6s=;
        b=qB7pVovC/n1ZNrT3MgefFb/lvulqwbt2oDG36qVaYZ3FSTAshoYtDQfNNmzNuwG2ah
         Y2tvlbYfFLR/rruPjGP8vL6si9kL2xGMjPrbwRUQF4tQbQgn8WAez17OOJxz9Q+g7WG/
         85HswNKJKbh0+tyNNfF0NUz9w3gDxC9GgiWZFdMlfEjQwEy/y+Odkm0rDCiNN7LGhGHs
         vSKugzFA67b7dSpmUsdH81JYvd4In35TtDwLj5svqQ/Yi8MUjCbrv/Ctgf38WMFhS5rF
         OPJ6hlHQanI1aF9wrBQUUfWlWcX/XbcyDO9mOGiOlACObZ5oHvrtyAOSqgK7cH82zCCf
         WVOQ==
X-Forwarded-Encrypted: i=1; AJvYcCUvkjLDYCohh2NMDSFyyGe9JF5UIdc9GpS/wWds/SQO9fp555xw/2ddjT7U/69R6Ug5cQM=@lists.linux.dev
X-Gm-Message-State: AOJu0YwS2U3kCQs7qIOiuEksibY25oFN5rj1ZGsyXHRIB/igVKbhIPRV
	jkCVZ44o1Z9lqIXNy0IaJOXlgXTPetwjPgZdmwWAyZh3UyIisjZGnIAkjg==
X-Google-Smtp-Source: AGHT+IEnlO7aV1X00zwtq7Ffq0+l9f2wU+mVkU3tg896w2QjebHpXNsTvNVEOZfKJhzUDKKmjbtDCg==
X-Received: by 2002:a17:902:ea0e:b0:20b:bdcb:e95 with SMTP id d9443c01a7336-20bfe043d7dmr131712355ad.34.1728304581485;
        Mon, 07 Oct 2024 05:36:21 -0700 (PDT)
Received: from [192.168.1.164] (h69-130-12-20.bendor.broadband.dynamic.tds.net. [69.130.12.20])
        by smtp.gmail.com with ESMTPSA id d9443c01a7336-20c13930b92sm38589175ad.128.2024.10.07.05.36.20
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 07 Oct 2024 05:36:21 -0700 (PDT)
Message-ID: <1840b514-3311-44e8-8dd6-96d7976f1d0c@gmail.com>
Date: Mon, 7 Oct 2024 05:36:20 -0700
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: TRUSTED CERTIFICATE
To: Alyssa Ross <hi@alyssa.is>, ell@lists.linux.dev
References: <878qv36hus.fsf@alyssa.is>
Content-Language: en-US
From: James Prestwood <prestwoj@gmail.com>
In-Reply-To: <878qv36hus.fsf@alyssa.is>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Hi Alyssa,

On 10/4/24 7:52 AM, Alyssa Ross wrote:
> Hello,
>
> I encountered a problem when attempting to connect to a WPA2 Enterprise
> network with iwd, that I think is caused by ell not understanding some
> certificates.
>
> I'm pretty confident that it should be valid to point EAP-TTLS-CACert to
> the /etc/ssl/certs/ca-bundle.crt that comes with my distro.  I believe
> this has worked with NetworkManager/wpa_supplicant for me in the past.
> It doesn't work with iwd/ell, because
> l_pem_load_certificate_list_from_data will error if any of the entries
> in the provided PEM data don't have the "CERTIFICATE" label, but some of
> the entries in my ca-bundle.crt have the "TRUSTED CERTIFICATE" label.
>
> I think ell should therefore either support trusted certificates (or at
> least give up if it finds any), so that users don't need to manually
> configure a certificate for networks with certificates signed by a CA in
> the system's bundle.

The TRUSTED CERTIFICATE type is an openssl-specific format. Sound like 
the certificate content itself is the same, but they append extra trust 
information onto the end. Supporting this is trivial, but requires 
removing a length check and checking for the "TRUSTED" begin block. I 
can't find any documentation on the actual ASN.1 format for this, so I 
hesitate to throw something into ELL without actually understanding it. 
Below is some code that will allow TRUSTED types though. Maybe 
Denis/Marcel know more about this?

diff --git a/ell/cert.c b/ell/cert.c
index 38bb01a..3912b19 100644
--- a/ell/cert.c
+++ b/ell/cert.c
@@ -124,7 +124,7 @@ LIB_EXPORT struct l_cert *l_cert_new_from_der(const 
uint8_t *buf,

         /* Sanity check: the SEQUENCE spans the whole buffer */
         content_len = asn1_parse_definite_length(&seq, &seq_len);
-       if (content_len < 64 || content_len != seq_len)
+       if (content_len < 64)
                 return NULL;

         /*
diff --git a/ell/pem.c b/ell/pem.c
index 24e8372..1781a46 100644
--- a/ell/pem.c
+++ b/ell/pem.c
@@ -426,7 +426,8 @@ LIB_EXPORT struct l_queue 
*l_pem_load_certificate_list_from_data(
                         goto error;
                 }

-               is_certificate = !strcmp(label, "CERTIFICATE");
+               is_certificate = !strcmp(label, "CERTIFICATE") ||
+                               !strcmp(label, "TRUSTED CERTIFICATE");
                 l_free(label);

                 if (!is_certificate)

