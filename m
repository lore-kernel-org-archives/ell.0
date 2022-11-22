Received: from mail-ot1-f41.google.com (mail-ot1-f41.google.com [209.85.210.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 879EB746C
	for <ell@lists.linux.dev>; Tue, 22 Nov 2022 17:16:02 +0000 (UTC)
Received: by mail-ot1-f41.google.com with SMTP id p8-20020a056830130800b0066bb73cf3bcso9688919otq.11
        for <ell@lists.linux.dev>; Tue, 22 Nov 2022 09:16:02 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=pxg0MElmBIgecwJvYgE7gF5FQH5AxZezx8G0a4Wqhks=;
        b=MNtvPNIe4up3eUtb+IWvmtR1gRxJ6DVvPv3hawBR/DPll/6yR1AA4aa11iqNMaKlcb
         qLvmOkT+DnEh/itsomiux+uEELPz43p7M2jM/a9BuAS1otOIxf0k9s17JAOf2Us2K3qQ
         B86ruYSdgFqeucitpaJXbt1kNLE7bsNF+5ZXoRXPVcov9Fyy5LTb7GyyUlcM7q9CBeux
         of0ZsXPxNa9IzucIbtX2uWRYUUrzdfcnbUbDDF5l1XZ6GvY/ja1AiBouk9WzmFavcnW4
         kAB6frtZoHhX4MSLBC0sVdtQ+gTBkp1vOt7HkIEilF7PngixpWHQHEYB2+inB16zkZEh
         tovw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=pxg0MElmBIgecwJvYgE7gF5FQH5AxZezx8G0a4Wqhks=;
        b=h3erc+tT6AgCSHje3Ga/5AgJtTSjo15Syi9Cib4jztXEQzirF3Cm1v0EfQvtPx9w6N
         I4XYKmgr1Z4eWCxNF9pCZnBJtkyBxkiAnilxCZaGnqORClef02kvQCbIhOct2jGhS/Xb
         Ulk06ipY/WjhrmcvolQ9TYrIZKdCNuEFpUnY87hEIKuJhoxL+4AFIvK7btCE1OqjQI6k
         HZ8to0HMaV/ivwH8D5U7k+b9w/OHYMlz5fF74VnjIyfFFJf0H3qLLelsl7ZukZdu1Ujr
         R+T9+jYFge6jGjcyqJl7+wdf+sAPFtpl9Z3lE4ux8yuW8vt/9lb9lGYGx1BN6n/HUDwH
         yzow==
X-Gm-Message-State: ANoB5pk60wqDtBqOtAo30C6IWP+/KwvdrFTefxQvypFh1iSScjGEdwZE
	sjFT9vdz2cgfb1kmaD9AeDs=
X-Google-Smtp-Source: AA0mqf7sHB+ym/A+dK+xEX76H2I0CAnqCjnvheZBGwIyyZb3q8641MOsRdJx8NXx5kssodXihoCQIw==
X-Received: by 2002:a9d:5e8c:0:b0:66e:a4c:be4f with SMTP id f12-20020a9d5e8c000000b0066e0a4cbe4fmr2166362otl.314.1669137361649;
        Tue, 22 Nov 2022 09:16:01 -0800 (PST)
Received: from [10.0.2.15] (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id g2-20020a4ad302000000b00492f9f46aa4sm5394990oos.36.2022.11.22.09.16.00
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 22 Nov 2022 09:16:01 -0800 (PST)
Message-ID: <0bc6c87e-2e9c-d569-60e4-fcda84ca3991@gmail.com>
Date: Tue, 22 Nov 2022 11:03:08 -0600
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101
 Thunderbird/91.11.0
Subject: Re: [RFC 6/8] cert: add l_cert_pkcs5_pbkdf2_from_key_id
Content-Language: en-US
To: James Prestwood <prestwoj@gmail.com>, ell@lists.linux.dev
References: <20221118211624.19298-1-prestwoj@gmail.com>
 <20221118211624.19298-7-prestwoj@gmail.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20221118211624.19298-7-prestwoj@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi James,

On 11/18/22 15:16, James Prestwood wrote:
> The same pbkdf2 algorithm but uses a key ID as the password.
> ---
>   ell/cert-crypto.c | 27 +++++++++++++++++++++++++++
>   ell/cert.h        |  6 +++++-
>   ell/ell.sym       |  1 +
>   3 files changed, 33 insertions(+), 1 deletion(-)
> 

<snip>

> diff --git a/ell/cert.h b/ell/cert.h
> index f637588..ce430fa 100644
> --- a/ell/cert.h
> +++ b/ell/cert.h
> @@ -76,7 +76,11 @@ bool l_cert_pkcs5_pbkdf2(enum l_checksum_type type, const char *password,
>   				const uint8_t *salt, size_t salt_len,
>   				unsigned int iter_count,
>   				uint8_t *out_dk, size_t dk_len);
> -
> +bool l_cert_pkcs5_pbkdf2_from_key_id(enum l_checksum_type type,

missing LIB_EXPORT?

> +					int32_t key_id, const uint8_t *salt,
> +					size_t salt_len,
> +					unsigned int iter_count,
> +					uint8_t *out_dk, size_t dk_len);

So personally I'd rather have l_cert_pkcs5_pbkdf2 take a struct l_checksum * as 
the first parameter instead of creating two almost identical constructors. 
Especially since we already would have a special l_checksum_hmac_* constructor 
that takes a key id.

Regards,
-Denis
