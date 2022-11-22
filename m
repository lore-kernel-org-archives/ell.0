Received: from mail-oo1-f44.google.com (mail-oo1-f44.google.com [209.85.161.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 607E5746C
	for <ell@lists.linux.dev>; Tue, 22 Nov 2022 17:13:38 +0000 (UTC)
Received: by mail-oo1-f44.google.com with SMTP id q2-20020a4a3302000000b0049ee5fe3ab7so2349165ooq.8
        for <ell@lists.linux.dev>; Tue, 22 Nov 2022 09:13:38 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=G8BKW1ac1klsOZTUt663reGYuapdkwLjLdKnTmWTMus=;
        b=fEB1X5bRssTpshO5HH+7qEcdFTxt7NLIp3LVpefGXqpwMtLf2spoT9utvKxjofnJX2
         9eLJuuSALRxI6V1gsOxIhqg1MkhGZIna3gF8Wwt52HQhXJajcr/oVrtTXnTo5R++x3sO
         yPryd1g1XoWTW6/8/N91QRIA7Yb5NZa+4Qbx6UfB8puMJCWeG4T++VnKpfH2qPdXk3jU
         mo3iUZINNeyyGdSmoo9ckHLGeERbYPdNmYJ9dT4f0BoGA2Ccth1ryooK1V7KAWtcJIpV
         WzVmz5Utz7dNyWX/ZZpDwEzdssOO8Fn3DNRa8AW6sB1IAaR1g+05TdP+Mh2mnMXyjLkV
         XKdA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=G8BKW1ac1klsOZTUt663reGYuapdkwLjLdKnTmWTMus=;
        b=hHzd07rApJhHrAoYdPmR8gMTgWcnV1gQdtywmARudnhT+2ATkq9rdC7cn5kkROTQpM
         3YdL4Aqvy8NMAx9AMGvzxtG/VPRZr5NsRBGXLGgEKZvXJeBhafZcejWFjYAJxBX9/Q3Q
         l07yWrvuUQbs57fD0uAf6wdR4yfQoiqnBw6MijAMU75GbF9hfOz06RNgqraAjMNwjZS+
         J7gKnxu7IxjdFj0iyvd7w9QoAIL6OK14gh+y5s0VxukFVuwSGqm2qga050iyql0oONQh
         S3eAnkKhjcwdorwqhoEDmvzuUggaxfXBEtH+CMZsfaM44HoRTFGyYwTZ0OViqijtr494
         Oupw==
X-Gm-Message-State: ANoB5pmJl/iNvm/CNz5RX28RWPVSFgiv7Xe1z+DgK6AEtPJ/q5pKiyv1
	QbfBTdQSS4PJCn+k47537xw=
X-Google-Smtp-Source: AA0mqf5gXObRNWI8L256QHQ2LPhWhzI9cXsmhzWjGZgWNK95sKlbFbfeU7HbWGvAhWb1Ea6XZt66nQ==
X-Received: by 2002:a4a:37c9:0:b0:49f:f9d3:de9e with SMTP id r192-20020a4a37c9000000b0049ff9d3de9emr2093087oor.4.1669137217412;
        Tue, 22 Nov 2022 09:13:37 -0800 (PST)
Received: from [10.0.2.15] (cpe-70-114-247-242.austin.res.rr.com. [70.114.247.242])
        by smtp.googlemail.com with ESMTPSA id r1-20020a4ae5c1000000b004968311a31asm5308176oov.39.2022.11.22.09.13.36
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 22 Nov 2022 09:13:36 -0800 (PST)
Message-ID: <6cb99e58-e7c3-cda4-9744-91d9463da173@gmail.com>
Date: Tue, 22 Nov 2022 11:00:43 -0600
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101
 Thunderbird/91.11.0
Subject: Re: [RFC 5/8] cert-crypto: refactor l_cert_pkcs5_pbkdf2
Content-Language: en-US
To: James Prestwood <prestwoj@gmail.com>, ell@lists.linux.dev
References: <20221118211624.19298-1-prestwoj@gmail.com>
 <20221118211624.19298-6-prestwoj@gmail.com>
From: Denis Kenzior <denkenz@gmail.com>
In-Reply-To: <20221118211624.19298-6-prestwoj@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi James,

On 11/18/22 15:16, James Prestwood wrote:
> This makes the actual algorithm common to prepare for adding a
> new variant which uses a key ID rather than password.
> ---
>   ell/cert-crypto.c | 67 +++++++++++++++++++++++++++++------------------
>   1 file changed, 41 insertions(+), 26 deletions(-)
> 
> diff --git a/ell/cert-crypto.c b/ell/cert-crypto.c
> index e6e8876..bf748b0 100644
> --- a/ell/cert-crypto.c
> +++ b/ell/cert-crypto.c
> @@ -103,44 +103,34 @@ LIB_EXPORT bool l_cert_pkcs5_pbkdf1(enum l_checksum_type type,
>   	return !iter_count;
>   }
>   
> -/* RFC8018 section 5.2 */
> -LIB_EXPORT bool l_cert_pkcs5_pbkdf2(enum l_checksum_type type,
> -					const char *password,
> -					const uint8_t *salt, size_t salt_len,
> -					unsigned int iter_count,
> -					uint8_t *out_dk, size_t dk_len)
> +static size_t cert_checksum_to_length(enum l_checksum_type type)

We already have l_checksum_digest_length().  Should we use that?

>   {
> -	size_t h_len;
> -	struct l_checksum *checksum;
> -	unsigned int i;
> -
>   	switch (type) {
>   	case L_CHECKSUM_SHA1:
> -		h_len = 20;
> -		break;
> +		return 20;
>   	case L_CHECKSUM_SHA224:
> -		h_len = 28;
> -		break;
> +		return 28;
>   	case L_CHECKSUM_SHA256:
> -		h_len = 32;
> -		break;
> +		return 32;
>   	case L_CHECKSUM_SHA384:
> -		h_len = 48;
> -		break;
> +		return 48;
>   	case L_CHECKSUM_SHA512:
> -		h_len = 64;
> -		break;
> +		return 64;
>   	case L_CHECKSUM_NONE:
>   	case L_CHECKSUM_MD4:
>   	case L_CHECKSUM_MD5:
> -		return false;
> +		return 0;
>   	default:
> -		return false;
> +		return 0;
>   	}
> +}
>   
> -	checksum = l_checksum_new_hmac(type, password, strlen(password));
> -	if (!checksum)
> -		return false;
> +static bool cert_pkcs5_pbkdf2(struct l_checksum *checksum, const uint8_t *salt,
> +				size_t salt_len, size_t h_len,
> +				unsigned int iter_count, uint8_t *out_dk,
> +				size_t dk_len)
> +{
> +	unsigned int i;
>   
>   	for (i = 1; dk_len; i++) {
>   		unsigned int j, k;

Regards,
-Denis
