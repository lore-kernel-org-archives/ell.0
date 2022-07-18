Received: from mga14.intel.com (mga14.intel.com [192.55.52.115])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1FDAC33CC
	for <ell@lists.linux.dev>; Mon, 18 Jul 2022 17:44:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1658166269; x=1689702269;
  h=date:from:to:cc:subject:in-reply-to:message-id:
   references:mime-version;
  bh=TWafOib+yoPjBLaUo8kZ3+QlHHqjUuMl6LH3VoX7gU0=;
  b=hgxY+SO8uZMeP7QaxRVejg2NlTwx7AEGuLLCdY+IsPLYlDsDLHC6FotL
   aDukUfwwHOH5gK0ARuCw6d8GzQEW8tbGN/7B9U6xh1Gc2VljcGR+u0AA/
   c/lrTvEjaKRZltJwQqm7uhldrqoIJn8qattz9rLZrCOFDKTjbjH9Wa2PA
   20wHLAVNltmK0MbmovVWF2baq+ExnaLFNPCnu0tokisXD0xnbKzUcr03y
   dTtXk+8EAAgUPAoZ8myOqUP80GXlKW+G7xyhTJu1MblJivqcYwyI7JRoK
   72Qwau3378ldtT5aJ8OAWFUEUuHOdvvWqjK6KKwFqMcLVFOTiCGcxM7dH
   w==;
X-IronPort-AV: E=McAfee;i="6400,9594,10412"; a="286298766"
X-IronPort-AV: E=Sophos;i="5.92,281,1650956400"; 
   d="scan'208";a="286298766"
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga103.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 18 Jul 2022 10:44:28 -0700
X-IronPort-AV: E=Sophos;i="5.92,281,1650956400"; 
   d="scan'208";a="924433659"
Received: from sinforoz-mobl.amr.corp.intel.com ([10.251.20.49])
  by fmsmga005-auth.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 18 Jul 2022 10:44:28 -0700
Date: Mon, 18 Jul 2022 10:44:28 -0700 (PDT)
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
To: Denis Kenzior <denkenz@gmail.com>
cc: ell@lists.linux.dev
Subject: Re: [PATCH 4/9] tls: Support peer certificates that use ECDSA
In-Reply-To: <20220718160222.10634-4-denkenz@gmail.com>
Message-ID: <b26fe3bf-fb39-65c-cdbc-784ee4cdb4a@linux.intel.com>
References: <20220718160222.10634-1-denkenz@gmail.com> <20220718160222.10634-4-denkenz@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed; charset=US-ASCII

On Mon, 18 Jul 2022, Denis Kenzior wrote:

> ---
> ell/tls.c | 22 +++++++++++++++++++---
> 1 file changed, 19 insertions(+), 3 deletions(-)
>
> diff --git a/ell/tls.c b/ell/tls.c
> index b2f7411f3b36..75b9d45c6523 100644
> --- a/ell/tls.c
> +++ b/ell/tls.c
> @@ -1899,6 +1899,8 @@ static void tls_handle_certificate(struct l_tls *tls,
> 	bool dummy;
> 	const char *error_str;
> 	char *subject_str;
> +	enum l_key_cipher_type format_type;
> +	enum l_checksum_type checksum_type;
>
> 	if (len < 3)
> 		goto decode_error;
> @@ -2028,9 +2030,23 @@ static void tls_handle_certificate(struct l_tls *tls,
> 		return;
> 	}
>
> -	if (!l_key_get_info(tls->peer_pubkey, L_KEY_RSA_PKCS1_V1_5,
> -					L_CHECKSUM_NONE, &tls->peer_pubkey_size,
> -					&dummy)) {
> +	switch (l_cert_get_pubkey_type(tls->peer_cert)) {
> +	case L_CERT_KEY_RSA:
> +		format_type = L_KEY_RSA_PKCS1_V1_5;
> +		checksum_type = L_CHECKSUM_NONE;
> +		break;
> +	case L_CERT_KEY_ECC:
> +		format_type = L_KEY_ECDSA_X962;
> +		checksum_type = L_CHECKSUM_SHA1;
> +		break;
> +	case L_CERT_KEY_UNKNOWN:

Hi Denis,

I needed to add

 	default:

here to get it to build. Details below.

> +		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
> +				"Unknown public key type");
> +		return;
> +	}
> +
> +	if (!l_key_get_info(tls->peer_pubkey, format_type, checksum_type,
> +				&tls->peer_pubkey_size, &dummy)) {

The ell (standalone, bootstrap-configure) build fails here with 
gcc12/Fedora36:

ell/tls.c:2061:14: error: 'checksum_type' may be used uninitialized [-Werror=maybe-uninitialized]
ell/tls.c:2061:14: error: 'format_type' may be used uninitialized [-Werror=maybe-uninitialized]

Apparently gcc12 can't track that -Werror=switch-enum is in use in 
combination with -Werror=maybe-uninitialized, and doesn't understand that 
the switch statement above does guarantee initialization.

> 		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
> 				"Can't l_key_get_info for peer public key");
>
> -- 
> 2.35.1
>
>
>

--
Mat Martineau
Intel
