Received: from mga11.intel.com (mga11.intel.com [192.55.52.93])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E000B33E7
	for <ell@lists.linux.dev>; Mon, 18 Jul 2022 19:08:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple;
  d=intel.com; i=@intel.com; q=dns/txt; s=Intel;
  t=1658171286; x=1689707286;
  h=date:from:to:cc:subject:in-reply-to:message-id:
   references:mime-version;
  bh=/B+U/uCgeq65yzls9My4sf5IvIX0jNug1vTx+VbocNM=;
  b=N8zs/YpZpF8ggR3xXoPo3Jg1/aeVkGhWTP4gypTBCjLedEk7APkJ5ATs
   Bu6lCwuedNees+NQOkUgs+/6eF1+1iOsDsO8zdX1dol5bPgQjz+tuvILq
   LFTF74fH2zogZ7wscyQz+Ohhp7Ph3bROQXxhqf6LLEGD78Kb2F1Rs/+dx
   QW742Tih0eKyV9K/wLe905jueLGkr+mgFTYG5ZDgaQ8pufOD1pEXj4uzy
   CXM3C/gso+0bm5Se+KofSDiOKlA4QRmDK67wsm00i87lN6WvxGbNsO/Ns
   rdGaUvMaefNXLKAQDOTcyaEeyiBg0540bJS3W6ECUu/Q1UoJjVzg4A2B2
   Q==;
X-IronPort-AV: E=McAfee;i="6400,9594,10412"; a="283866439"
X-IronPort-AV: E=Sophos;i="5.92,281,1650956400"; 
   d="scan'208";a="283866439"
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by fmsmga102.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 18 Jul 2022 12:07:57 -0700
X-IronPort-AV: E=Sophos;i="5.92,281,1650956400"; 
   d="scan'208";a="665131249"
Received: from sinforoz-mobl.amr.corp.intel.com ([10.251.20.49])
  by fmsmga004-auth.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 18 Jul 2022 12:07:57 -0700
Date: Mon, 18 Jul 2022 12:07:57 -0700 (PDT)
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
To: Denis Kenzior <denkenz@gmail.com>
cc: ell@lists.linux.dev
Subject: Re: [PATCH v2 02/10] unit: Add basic EC-DSA verification test
In-Reply-To: <20220718180045.5845-2-denkenz@gmail.com>
Message-ID: <559e999-ea7c-cab2-1327-d37b2c36e713@linux.intel.com>
References: <20220718180045.5845-1-denkenz@gmail.com> <20220718180045.5845-2-denkenz@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed; charset=US-ASCII

On Mon, 18 Jul 2022, Denis Kenzior wrote:

> ---
> .gitignore      |  2 ++
> Makefile.am     | 39 ++++++++++++++++++++++++++++++++++++++-
> unit/test-tls.c | 22 +++++++++++++++++++++-
> 3 files changed, 61 insertions(+), 2 deletions(-)
>
> diff --git a/.gitignore b/.gitignore
> index 346243a8f9c7..76f10aecfdd3 100644
> --- a/.gitignore
> +++ b/.gitignore
> @@ -67,6 +67,8 @@ unit/cert-*.csr
> unit/cert-*.srl
> unit/cert-*.crt
> unit/cert-*.p12
> +unit/ec-cert-*.pem
> +unit/ec-cert-*.csr
> unit/key-*.dat
> unit/key-*.h
> unit/*.log
> diff --git a/Makefile.am b/Makefile.am
> index 2bf728bbde7a..e5d7143af236 100644
> --- a/Makefile.am
> +++ b/Makefile.am
> @@ -219,6 +219,7 @@ cert_tests = unit/test-pem \
> cert_files = unit/cert-chain.pem \
> 			unit/cert-entity-int.pem \
> 			unit/cert-server.pem \
> +			unit/ec-cert-server.pem \
> 			unit/cert-server-key-pkcs8.pem \
> 			unit/cert-client.pem \
> 			unit/cert-client.crt \
> @@ -246,6 +247,7 @@ cert_files = unit/cert-chain.pem \
> cert_checks = unit/cert-intca \
> 			unit/cert-entity-int \
> 			unit/cert-server \
> +			unit/ec-cert-server \
> 			unit/cert-client \
> 			unit/cert-no-keyid
>
> @@ -417,15 +419,30 @@ false_redirect_openssl = 2>/dev/null
> unit/cert-ca-key.pem:
> 	$(AM_V_GEN)openssl genrsa -out $@ 2048 $($(AM_V_P)_redirect_openssl)
>
> +unit/ec-cert-ca-key.pem:
> +	$(AM_V_GEN)openssl ecparam -out $@ -name secp384r1 \
> +				-genkey $($(AM_V_P)_redirect_openssl)
> +
> +
> unit/cert-ca.pem: unit/cert-ca-key.pem unit/gencerts.cnf
> 	$(AM_V_GEN)openssl req -x509 -new -nodes -extensions ca_ext \
> 			-config $(srcdir)/unit/gencerts.cnf \
> 			-subj '/O=International Union of Example Organizations/CN=Certificate issuer guy/emailAddress=ca@mail.example' \
> 			-key $< -sha256 -days 10000 -out $@
>
> +unit/ec-cert-ca.pem: unit/ec-cert-ca-key.pem unit/gencerts.cnf
> +	$(AM_V_GEN)openssl req -x509 -new -nodes -extensions ca_ext \
> +			-config $(srcdir)/unit/gencerts.cnf \
> +			-subj '/O=International Union of Example Organizations/CN=Certificate issuer guy/emailAddress=ca@mail.example' \
> +			-key $< -sha256 -days 10000 -out $@
> +
> unit/cert-server-key.pem:
> 	$(AM_V_GEN)openssl genrsa -out $@ $($(AM_V_P)_redirect_openssl)
>
> +unit/ec-cert-server-key.pem:
> +	$(AM_V_GEN)openssl ecparam -out $@ -name secp384r1 \
> +				-genkey $($(AM_V_P)_redirect_openssl)
> +
> unit/cert-server-key-pkcs8.pem: unit/cert-server-key.pem
> 	$(AM_V_GEN)openssl pkcs8 -topk8 -nocrypt -in $< -out $@
>
> @@ -435,6 +452,12 @@ unit/cert-server.csr: unit/cert-server-key.pem unit/gencerts.cnf
> 			-subj '/O=Foo Example Organization/CN=Foo Example Organization/emailAddress=foo@mail.example' \
> 			-key $< -out $@
>
> +unit/ec-cert-server.csr: unit/ec-cert-server-key.pem unit/gencerts.cnf
> +	$(AM_V_GEN)openssl req -new -extensions cert_ext \
> +			-config $(srcdir)/unit/gencerts.cnf \
> +			-subj '/O=Foo Example Organization/CN=Foo Example Organization/emailAddress=foo@mail.example' \
> +			-key $< -out $@
> +
> unit/cert-server.pem: unit/cert-server.csr unit/cert-ca.pem unit/gencerts.cnf
> 	$(AM_V_GEN)openssl x509 -req -extensions server_ext \
> 			-extfile $(srcdir)/unit/gencerts.cnf \
> @@ -443,9 +466,22 @@ unit/cert-server.pem: unit/cert-server.csr unit/cert-ca.pem unit/gencerts.cnf
> 			-CAserial $(builddir)/unit/cert-ca.srl \
> 			-CAcreateserial -sha256 -days 10000 -out $@ $($(AM_V_P)_redirect_openssl)
>
> +unit/ec-cert-server.pem: unit/ec-cert-server.csr unit/ec-cert-ca.pem \
> +				unit/gencerts.cnf
> +	$(AM_V_GEN)openssl x509 -req -extensions server_ext \
> +			-extfile $(srcdir)/unit/gencerts.cnf \
> +			-in $< -CA $(builddir)/unit/ec-cert-ca.pem \
> +			-CAkey $(builddir)/unit/ec-cert-ca-key.pem \
> +			-CAserial $(builddir)/unit/cert-ca.srl \
> +			-CAcreateserial -sha256 -days 10000 \
> +			-out $@ $($(AM_V_P)_redirect_openssl)
> +
> unit/cert-server: unit/cert-server.pem unit/cert-ca.pem
> 	$(AM_V_GEN)openssl verify -CAfile $(builddir)/unit/cert-ca.pem $<
>
> +unit/ec-cert-server: unit/ce-cert-server.pem unit/ce-cert-ca.pem
> +	$(AM_V_GEN)openssl verify -CAfile $(builddir)/unit/ce-cert-ca.pem $<

Denis -

A few typos here: "ce-cert" instead of "ec-cert". This showed up as:

make[2]: *** No rule to make target 'unit/ce-cert-server.pem', needed by 'unit/ec-cert-server'.  Stop.

after the testsuite summary when running "make check".


Other than that, v2 looks good on my system. I didn't try out the kernel 
patch you mention in patch 1, I assume that's why I had the test failures 
with "tls-suites: Add ECDSA suites from RFC 8422".


- Mat

> +
> unit/cert-client-key-pkcs1.pem:
> 	$(AM_V_GEN)openssl genrsa -out $@ $($(AM_V_P)_redirect_openssl)
>
> @@ -623,7 +659,8 @@ check-local: $(cert_checks)
> endif
>
> clean-local:
> -	-rm -f unit/cert-*.pem unit/cert-*.csr unit/cert-*.srl unit/key-*.dat
> +	-rm -f unit/ec-cert*.pem unit/ec-cert-*.csr \
> +		unit/cert-*.pem unit/cert-*.csr unit/cert-*.srl unit/key-*.dat
>
> maintainer-clean-local:
> 	-rm -rf build-aux
> diff --git a/unit/test-tls.c b/unit/test-tls.c
> index 7937962cf8a0..aee5b2e36b78 100644
> --- a/unit/test-tls.c
> +++ b/unit/test-tls.c
> @@ -325,6 +325,24 @@ static void test_certificates(const void *data)
> 	l_queue_destroy(twocas, (l_queue_destroy_func_t) l_cert_free);
> }
>
> +static void test_ec_certificates(const void *data)
> +{
> +	struct l_queue *cacert;
> +	struct l_certchain *chain;
> +
> +	cacert = l_pem_load_certificate_list(CERTDIR "ec-cert-ca.pem");
> +	assert(cacert && !l_queue_isempty(cacert));
> +
> +	chain = l_pem_load_certificate_chain(CERTDIR "ec-cert-server.pem");
> +	assert(chain);
> +
> +	assert(l_certchain_verify(chain, cacert, NULL));
> +	assert(l_certchain_verify(chain, NULL, NULL));
> +
> +	l_certchain_free(chain);
> +	l_queue_destroy(cacert, (l_queue_destroy_func_t) l_cert_free);
> +}
> +
> struct tls_conn_test {
> 	const char *server_cert_path;
> 	const char *server_key_path;
> @@ -948,8 +966,10 @@ int main(int argc, char *argv[])
> 	l_test_add("TLS 1.2 PRF with SHA512", test_tls12_prf,
> 			&tls12_prf_sha512_0);
>
> -	if (l_key_is_supported(L_KEY_FEATURE_RESTRICT))
> +	if (l_key_is_supported(L_KEY_FEATURE_RESTRICT)) {
> 		l_test_add("Certificate chains", test_certificates, NULL);
> +		l_test_add("ECDSA Certificates", test_ec_certificates, NULL);
> +	}
>
> 	if (!l_getrandom_is_supported()) {
> 		printf("getrandom missing, skipping TLS connection tests...\n");
> -- 
> 2.35.1
>
>
>

--
Mat Martineau
Intel
