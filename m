Received: from mga01.intel.com (mga01.intel.com [192.55.52.88])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 345E433CC
	for <ell@lists.linux.dev>; Mon, 18 Jul 2022 17:53:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1658166791; x=1689702791;
  h=date:from:to:cc:subject:in-reply-to:message-id:
   references:mime-version;
  bh=fKdBr3Xx7PLJjqgVKBBiKwIV+H/I/SvYdQuD1SRGhsY=;
  b=ZNbbMi3P/7l/z5s7HrE2QLcdVfR7hCL0mb2spa4K5hSrF70MkV7Au3kz
   r/nPiyStFQsbg8sE75hhsXp2qnJ9r3lykpnkKLm1n1KXwdb0I6eaqmq4k
   hxACTn+5AeU75jt2Tb8lHhsb33kLspnrL85/y14eVAVTvPsp3CQVe7vvc
   1mfRBIFTYGJoymEH4+0GFqfF+/411k7SgLSXnQyGpWh/2rX/n8KIN2mLc
   V/h4rH68Lhm62rHwAvgeC6WC6+OhubRYmv8MuqSQtShtMdV81kwXvHoqh
   SzWFeYyNZcVQ2xq6909rTj/5UE+Hp98fLtWzVyYSUf3+g0nSCpvSENV1R
   w==;
X-IronPort-AV: E=McAfee;i="6400,9594,10412"; a="311967736"
X-IronPort-AV: E=Sophos;i="5.92,281,1650956400"; 
   d="scan'208";a="311967736"
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga101.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 18 Jul 2022 10:53:10 -0700
X-IronPort-AV: E=Sophos;i="5.92,281,1650956400"; 
   d="scan'208";a="547589862"
Received: from sinforoz-mobl.amr.corp.intel.com ([10.251.20.49])
  by orsmga003-auth.jf.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 18 Jul 2022 10:53:09 -0700
Date: Mon, 18 Jul 2022 10:53:09 -0700 (PDT)
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
To: Denis Kenzior <denkenz@gmail.com>
cc: ell@lists.linux.dev
Subject: Re: [PATCH 7/9] tls-suites: Add ECDSA suites from RFC 8422
In-Reply-To: <20220718160222.10634-7-denkenz@gmail.com>
Message-ID: <fb4fd04b-ca3e-681-25d3-1cd9f242f4a7@linux.intel.com>
References: <20220718160222.10634-1-denkenz@gmail.com> <20220718160222.10634-7-denkenz@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed

On Mon, 18 Jul 2022, Denis Kenzior wrote:

> ---
> ell/tls-suites.c | 119 +++++++++++++++++++++++++++++++++++++++++++++++
> 1 file changed, 119 insertions(+)
>
> diff --git a/ell/tls-suites.c b/ell/tls-suites.c
> index bc6a756422b3..34141ab7fa56 100644
> --- a/ell/tls-suites.c
> +++ b/ell/tls-suites.c
> @@ -262,6 +262,81 @@ static struct tls_signature_algorithm tls_rsa_signature = {
> 	.verify = tls_rsa_verify,
> };
>
> +static bool tls_ecdsa_validate_cert_key(struct l_cert *cert)
> +{
> +	return l_cert_get_pubkey_type(cert) == L_CERT_KEY_ECC;
> +}
> +
> +static bool tls_ecdsa_verify(struct l_tls *tls,
> +				const uint8_t *in, size_t in_len,
> +				tls_get_hash_t get_hash,
> +				const uint8_t *data, size_t data_len)
> +{
> +	/* RFC 8422, Section 5.10: "SHA-1 is used in TLS 1.1 and earlier" */
> +	enum handshake_hash_type hash = HANDSHAKE_HASH_SHA1;
> +	enum l_checksum_type sign_checksum_type;
> +	const uint8_t *opaque;
> +	uint16_t opaque_len;
> +	uint8_t expected[HANDSHAKE_HASH_MAX_SIZE];
> +	size_t expected_len;
> +	bool success;
> +
> +	opaque = validate_digitally_signed(tls, in, in_len,
> +				SIGNATURE_ALGORITHM_ECDSA, &opaque_len);
> +	if (!opaque)
> +		return false;
> +
> +	if (tls->negotiated_version >= L_TLS_V12) {
> +		hash = find_hash_by_id(in[0]);
> +		if (hash == __HANDSHAKE_HASH_COUNT) {
> +			TLS_DISCONNECT(TLS_ALERT_DECRYPT_ERROR, 0,
> +					"Unknown hash type %i", in[0]);
> +			return false;
> +		}
> +
> +		/* Hash should match the curve, refer to RFC 5480, Section 4 */
> +		switch (tls->peer_pubkey_size) {
> +		case 32:
> +			if (hash != HANDSHAKE_HASH_SHA256 &&
> +					hash != HANDSHAKE_HASH_SHA384)
> +				goto bad_hash;
> +
> +			break;
> +		case 48:
> +			if (hash != HANDSHAKE_HASH_SHA384)
> +				goto bad_hash;
> +
> +			break;
> +		bad_hash:
> +		default:
> +			TLS_DISCONNECT(TLS_ALERT_DECRYPT_ERROR, 0,
> +					"Invalid hash %i",
> +					in[0]);
> +		}
> +	}
> +
> +	get_hash(tls, hash, data, data_len, expected, &expected_len);
> +	sign_checksum_type = tls_handshake_hash_data[hash].l_id;
> +
> +	success = l_key_verify(tls->peer_pubkey, L_KEY_ECDSA_X962,
> +				sign_checksum_type, expected, opaque,
> +				expected_len, opaque_len);
> +
> +	if (!success)
> +		TLS_DISCONNECT(TLS_ALERT_DECRYPT_ERROR, 0,
> +				"Peer signature verification failed");
> +	else
> +		TLS_DEBUG("Peer signature verified");
> +
> +	return success;
> +}
> +
> +static struct tls_signature_algorithm tls_ecdsa_signature = {
> +	.id = 3, /* SignatureAlgorithm.ecdsa */
> +	.validate_cert_key_type = tls_ecdsa_validate_cert_key,
> +	.verify = tls_ecdsa_verify,
> +};
> +
> static bool tls_send_rsa_client_key_xchg(struct l_tls *tls)
> {
> 	uint8_t buf[1024 + 32];
> @@ -1350,11 +1425,52 @@ static struct tls_cipher_suite tls_rsa_with_3des_ede_cbc_sha = {
> 	.prf_hmac = L_CHECKSUM_SHA384,
> 	.signature = &tls_rsa_signature,
> 	.key_xchg = &tls_ecdhe,
> +}, tls_ecdhe_ecdsa_with_3des_ede_cbc_sha = {
> +	.id = { 0xc0, 0x08 },
> +	.name = "TLS_ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA",
> +	.verify_data_length = 12,
> +	.encryption = &tls_3des_ede,
> +	.mac = &tls_sha,
> +	.signature = &tls_ecdsa_signature,
> +	.key_xchg = &tls_ecdhe,
> +}, tls_ecdhe_ecdsa_with_aes_128_cbc_sha = {
> +	.id = { 0xc0, 0x09 },
> +	.name = "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA",
> +	.verify_data_length = 12,
> +	.encryption = &tls_aes128,
> +	.mac = &tls_sha,
> +	.signature = &tls_ecdsa_signature,
> +	.key_xchg = &tls_ecdhe,
> +}, tls_ecdhe_ecdsa_with_aes_256_cbc_sha = {
> +	.id = { 0xc0, 0x0a },
> +	.name = "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA",
> +	.verify_data_length = 12,
> +	.encryption = &tls_aes256,
> +	.mac = &tls_sha,
> +	.signature = &tls_ecdsa_signature,
> +	.key_xchg = &tls_ecdhe,
> +}, tls_ecdhe_ecdsa_with_aes_128_gcm_sha256 = {
> +	.id = { 0xc0, 0x2b },
> +	.name = "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256",
> +	.verify_data_length = 12,
> +	.encryption = &tls_aes128_gcm,
> +	.signature = &tls_ecdsa_signature,
> +	.key_xchg = &tls_ecdhe,
> +}, tls_ecdhe_ecdsa_with_aes_256_gcm_sha384 = {
> +	.id = { 0xc0, 0x2c },
> +	.name = "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384",
> +	.verify_data_length = 12,
> +	.encryption = &tls_aes256_gcm,
> +	.prf_hmac = L_CHECKSUM_SHA384,
> +	.signature = &tls_ecdsa_signature,
> +	.key_xchg = &tls_ecdhe,
> };

These new suites fail in unit/test-tls with the 5.18.11-200.fc36.x86_64 
kernel (latest Fedora 36):

TEST: TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA
test-tls: unit/test-tls.c:661: test_tls_with_ver: Assertion `!!l_tls_start(s[1].tls) == !test->expect_client_start_fail' failed.

I started commenting out each failed test, also verified the failure with 
TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA and 
TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384. Didn't try the last couple cases 
(GCM_SHA256 and 3DES).

>
> struct tls_cipher_suite *tls_cipher_suite_pref[] = {
> 	&tls_ecdhe_rsa_with_aes_256_cbc_sha,
> +	&tls_ecdhe_ecdsa_with_aes_256_cbc_sha,
> 	&tls_ecdhe_rsa_with_aes_128_cbc_sha,
> +	&tls_ecdhe_ecdsa_with_aes_128_cbc_sha,
> 	&tls_dhe_rsa_with_aes_256_cbc_sha,
> 	&tls_dhe_rsa_with_aes_128_cbc_sha,
> 	&tls_rsa_with_aes_256_cbc_sha,
> @@ -1367,11 +1483,14 @@ struct tls_cipher_suite *tls_cipher_suite_pref[] = {
> 	&tls_rsa_with_aes_128_cbc_sha256,
> 	&tls_ecdhe_rsa_with_aes_256_gcm_sha384,
> 	&tls_ecdhe_rsa_with_aes_128_gcm_sha256,
> +	&tls_ecdhe_ecdsa_with_aes_256_gcm_sha384,
> +	&tls_ecdhe_ecdsa_with_aes_128_gcm_sha256,
> 	&tls_dhe_rsa_with_aes_256_gcm_sha384,
> 	&tls_dhe_rsa_with_aes_128_gcm_sha256,
> 	&tls_rsa_with_aes_256_gcm_sha384,
> 	&tls_rsa_with_aes_128_gcm_sha256,
> 	&tls_ecdhe_rsa_with_3des_ede_cbc_sha,
> +	&tls_ecdhe_ecdsa_with_3des_ede_cbc_sha,
> 	&tls_dhe_rsa_with_3des_ede_cbc_sha,
> 	&tls_rsa_with_3des_ede_cbc_sha,
> 	NULL,
> -- 
> 2.35.1
>
>
>

--
Mat Martineau
Intel
