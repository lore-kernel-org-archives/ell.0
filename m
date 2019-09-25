Content-Type: multipart/mixed; boundary="===============3472551851135799731=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH] tls: raise min DH prime modulus length to 1536 bit
Date: Wed, 25 Sep 2019 11:22:56 -0700
Message-ID: <alpine.OSX.2.21.1909251110530.26111@leoliu1-mobl.amr.corp.intel.com>
In-Reply-To: <20190925164524.80994-1-diabonas@gmx.de>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3472551851135799731==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


On Wed, 25 Sep 2019, Jonas Witschel wrote:

> The minimum prime length required by the Linux kernel for DH
> calculations is 1536 bit. If a smaller prime is used,
> keyctl_dh_compute() will fail with EINVAL, cf. dh_check_params_length()
> and dh_set_params() in crypto/dh.c of the kernel sources.
>
> On encountering a smaller prime, ELL currently fails in
> tls_send_dhe_client_key_xchg() with the not very instructive error
> message "l_key_compute_dh_public failed". Since any prime smaller than
> 1536 bit is guaranteed to fail at this step, raise the already existing
> minimum length check so that the handshake fails with the message
> "Server DH prime modulus invalid" instead. This does not have any
> compatibility implications since smaller primes never worked in the
> first place, but gives a clearer indication of what went wrong.

This looks like a good change to me. The kernel limit has been at 1536 =

since it was converted to use the crypto KPP API in 4.12. The original =

MPI-based code (4.7-4.11) didn't check a lower bound.

Thanks,

Mat


> ---
> ell/tls-suites.c | 6 +++---
> 1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/ell/tls-suites.c b/ell/tls-suites.c
> index 9e020bd..ecaa2ec 100644
> --- a/ell/tls-suites.c
> +++ b/ell/tls-suites.c
> @@ -880,13 +880,13 @@ static void tls_handle_dhe_server_key_xchg(struct l=
_tls *tls,
> 	 * We have no way to confirm that it's actually prime or that it's a
> 	 * "safe prime" or that it forms a group without small sub-groups.
> 	 * There's also no way to whitelist all valid values.  But we do a
> -	 * basic sanity check and require it to be 1024-bit or longer
> -	 * (see weakdh.org), might need to move to 2048 bits actually.
> +	 * basic sanity check and require it to be 1536-bit or longer, the
> +	 * minimum length required by the Linux kernel for keyctl_dh_compute().
> 	 * The generator must also be at least within the min & max interval
> 	 * for the private/public values.
> 	 */
>
> -	if (params->prime_len > TLS_DHE_MAX_SIZE || params->prime_len < 128 ||
> +	if (params->prime_len > TLS_DHE_MAX_SIZE || params->prime_len < 192 ||
> 			!(prime_buf[params->prime_len - 1] & 1)) {
> 		TLS_DISCONNECT(TLS_ALERT_HANDSHAKE_FAIL, 0,
> 				"Server DH prime modulus invalid");
> --
> 2.23.0
>
> _______________________________________________
> ell mailing list
> ell(a)lists.01.org
> https://lists.01.org/mailman/listinfo/ell
>

--
Mat Martineau
Intel

--===============3472551851135799731==--

