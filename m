Content-Type: multipart/mixed; boundary="===============2418753807116359632=="
MIME-Version: 1.0
From: Gix, Brian <brian.gix@intel.com>
Subject: Re: [PATCH] cipher: Use single SK for AEAD ciphers
Date: Sat, 01 Jun 2019 18:25:48 +0000
Message-ID: <d22b8968532da38a139f1510bff14681f1a8348a.camel@intel.com>
In-Reply-To: <20190601181958.3170-1-brian.gix@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2418753807116359632==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

You mentioned earlier that the dual (seperate) SK's may not be needed
for all the ciphers supported.  I was able to confirm the problem
(some) of them, but it does not appear to be neccessary for AEAD based
ciphers, so this patch eliminates them for the AEAD versions.

On Sat, 2019-06-01 at 11:19 -0700, Brian Gix wrote:
> ---
>  ell/cipher.c | 27 +++++++--------------------
>  1 file changed, 7 insertions(+), 20 deletions(-)
> =

> diff --git a/ell/cipher.c b/ell/cipher.c
> index 7b909df..4a27b5e 100644
> --- a/ell/cipher.c
> +++ b/ell/cipher.c
> @@ -99,8 +99,7 @@ struct l_cipher {
>  =

>  struct l_aead_cipher {
>  	int type;
> -	int encrypt_sk;
> -	int decrypt_sk;
> +	int sk;
>  };
>  =

>  static int create_alg(const char *alg_type, const char *alg_name,
> @@ -229,21 +228,10 @@ LIB_EXPORT struct l_aead_cipher
> *l_aead_cipher_new(enum l_aead_cipher_type type,
>  	cipher->type =3D type;
>  	alg_name =3D aead_cipher_type_to_name(type);
>  =

> -	cipher->encrypt_sk =3D create_alg("aead", alg_name, key,
> key_length,
> -					tag_length);
> -	if (cipher->encrypt_sk < 0)
> -		goto error_free;
> -
> -	cipher->decrypt_sk =3D create_alg("aead", alg_name, key,
> key_length,
> -					tag_length);
> -	if (cipher->decrypt_sk < 0)
> -		goto error_close;
> +	cipher->sk =3D create_alg("aead", alg_name, key, key_length,
> tag_length);
> +	if (cipher->sk >=3D 0)
> +		return cipher;
>  =

> -	return cipher;
> -
> -error_close:
> -	close(cipher->encrypt_sk);
> -error_free:
>  	l_free(cipher);
>  	return NULL;
>  }
> @@ -264,8 +252,7 @@ LIB_EXPORT void l_aead_cipher_free(struct
> l_aead_cipher *cipher)
>  	if (unlikely(!cipher))
>  		return;
>  =

> -	close(cipher->encrypt_sk);
> -	close(cipher->decrypt_sk);
> +	close(cipher->sk);
>  =

>  	l_free(cipher);
>  }
> @@ -570,7 +557,7 @@ LIB_EXPORT bool l_aead_cipher_encrypt(struct
> l_aead_cipher *cipher,
>  		iv_len =3D nonce_len;
>  	}
>  =

> -	return operate_cipher(cipher->encrypt_sk, ALG_OP_ENCRYPT, in,
> in_len,
> +	return operate_cipher(cipher->sk, ALG_OP_ENCRYPT, in, in_len,
>  				ad, ad_len, iv, iv_len, out, out_len)
> =3D=3D
>  			(ssize_t)out_len;
>  }
> @@ -605,7 +592,7 @@ LIB_EXPORT bool l_aead_cipher_decrypt(struct
> l_aead_cipher *cipher,
>  		iv_len =3D nonce_len;
>  	}
>  =

> -	return operate_cipher(cipher->decrypt_sk, ALG_OP_DECRYPT, in,
> in_len,
> +	return operate_cipher(cipher->sk, ALG_OP_DECRYPT, in, in_len,
>  				ad, ad_len, iv, iv_len, out, out_len)
> =3D=3D
>  			(ssize_t)out_len;
>  }

--===============2418753807116359632==
Content-Type: application/x-pkcs7-signature
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="smime.p7s"

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
/2uO+36toXJIrkRSOXG2qYEzQI5kZ0sbLp1dcxHIXP6hMhpL7+m2bT6VgQIDAQABo4ICKTCCAiUw
HQYDVR0OBBYEFIZVvEpBGkcRsJgSGlrm4o7AsTA9MB8GA1UdIwQYMBaAFB5pKrTcKP5HGE4hCz+8
rBEv8Jj1MGUGA1UdHwReMFwwWqBYoFaGVGh0dHA6Ly93d3cuaW50ZWwuY29tL3JlcG9zaXRvcnkv
Q1JML0ludGVsJTIwRXh0ZXJuYWwlMjBCYXNpYyUyMElzc3VpbmclMjBDQSUyMDRBLmNybDCBnwYI
KwYBBQUHAQEEgZIwgY8waQYIKwYBBQUHMAKGXWh0dHA6Ly93d3cuaW50ZWwuY29tL3JlcG9zaXRv
cnkvY2VydGlmaWNhdGVzL0ludGVsJTIwRXh0ZXJuYWwlMjBCYXNpYyUyMElzc3VpbmclMjBDQSUy
MDRBLmNydDAiBggrBgEFBQcwAYYWaHR0cDovL29jc3AuaW50ZWwuY29tLzALBgNVHQ8EBAMCB4Aw
PAYJKwYBBAGCNxUHBC8wLQYlKwYBBAGCNxUIhsOMdYSZ5VGD/YEohY6fU4KRwAlngd69OZXwQwIB
ZAIBCTAfBgNVHSUEGDAWBggrBgEFBQcDBAYKKwYBBAGCNwoDDDApBgkrBgEEAYI3FQoEHDAaMAoG
CCsGAQUFBwMEMAwGCisGAQQBgjcKAwwwQwYDVR0RBDwwOqAjBgorBgEEAYI3FAIDoBUME2JyaWFu
LmdpeEBpbnRlbC5jb22BE2JyaWFuLmdpeEBpbnRlbC5jb20wDQYJKoZIhvcNAQEFBQADggEBACuN
3bQTKWnPqjCfAI95E3JEdS7jc7y7fY2FiTcofo0hiDYjZ97kdpZo7BwqWvOcMEPWfst7YQyy4naa
uS8RvC2+BM8rYtvYj0uvUj/AbwZTnlQILUtyOykV3GzyauRwq6H3fPpZeOrMbbHSsJICjGvoAUQ1
aOiV1qgLYnlrTzis6UQx+7JjzYkmRajfnMR1NcD5rNa5n8CcmvwrhYxPptvyo9FKMw5Dtwri7DUs
7bl/ls14Ie8Sf8LLJBwGUOMWtDcEToMqjBZgPhC/6CBuI74UfFLbOt9tg6QMNFtbCy5H8HQUjq+P
tLltdkaAwpAE894tf9fUhD+oz7s/o6NV49IxggIXMIICEwIBATCBkDB5MQswCQYDVQQGEwJVUzEL
MAkGA1UECBMCQ0ExFDASBgNVBAcTC1NhbnRhIENsYXJhMRowGAYDVQQKExFJbnRlbCBDb3Jwb3Jh
dGlvbjErMCkGA1UEAxMiSW50ZWwgRXh0ZXJuYWwgQmFzaWMgSXNzdWluZyBDQSA0QQITMwAAyrfo
9lLjvkm/BgAAAADKtzAJBgUrDgMCGgUAoF0wGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkq
hkiG9w0BCQUxDxcNMTkwNjAxMTgyNTQ3WjAjBgkqhkiG9w0BCQQxFgQUhWuk9LUzz1glId0aKWXS
IGrzcWowDQYJKoZIhvcNAQEBBQAEggEAdDg2LiJHmr3ysIzZPudX4PVW0MW/gBfXPnyS6oIk3szf
+KNdxdAV7bYR2C8gTSrQAgfEBDmOLS70zRbqk4j99S+kmRNw0a22pRT81R9fazSnc2c08GHOYYvz
NlnCgPphek64tO17weeqowLfnDmFayCVRQjH3cuuF7bfvEY5RjuPSTzX9Q0CYb6qgsJ+Emvu6l3U
7zu7f/CyUHbzBWPEdymYsjOwB4V777Ab/xggW84cHc3ABVbTHA/loa7I7/d0sUeCZ/V1TlekWxvu
DSBC7fBEAWWDlrxK+BXEz2np7fN+hsbkZXR4AEnspGGs6V2JssI1NB+y3VMsepAHElaHcwAAAAAA
AA==
--===============2418753807116359632==--

