Content-Type: multipart/mixed; boundary="===============6710122640822158579=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH v2 3/6] tls: Use l_key crypto for decrypt and sign
Date: Tue, 09 Aug 2016 11:40:11 -0700
Message-ID: <alpine.OSX.2.20.1608091136450.24354@mjmartin-mac01.local>
In-Reply-To: <57AA0431.4050601@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6710122640822158579==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


On Tue, 9 Aug 2016, Denis Kenzior wrote:

> Hi Mat,
>
>>
>> -LIB_EXPORT void l_tls_set_auth_data(struct l_tls *tls, const char =

>> *cert_path,
>> -				const char *priv_key_path,
>> -				const char *priv_key_passphrase)
>> +LIB_EXPORT bool l_tls_set_auth_data(struct l_tls *tls, const char =

>> *cert_path,
>> +					const char *priv_key_path,
>> +					const char *priv_key_passphrase)
>>   {
>> +	uint8_t *priv_key =3D NULL;
>> +	bool is_public =3D true;
>> +
>
> Just a quick nitpick.  Can you move these into the if (priv_key_path) blo=
ck?

Sure. Good to know that fits with the style guidelines, I'd prefer to have =

them in the smaller scope.

>>   	if (tls->cert_path) {
>>   		l_free(tls->cert_path);
>> -		l_free(tls->priv_key_path);
>>   		tls->cert_path =3D NULL;
>> -		tls->priv_key_path =3D NULL;
>>   	}
>> =

>> -	if (cert_path) {
>> -		tls->cert_path =3D l_strdup(cert_path);
>> -		tls->priv_key_path =3D l_strdup(priv_key_path);
>> +	if (tls->priv_key) {
>> +		l_key_free(tls->priv_key);
>> +		tls->priv_key =3D NULL;
>> +		tls->priv_key_size =3D 0;
>>   	}
>> =

>> -	if (tls->priv_key_passphrase) {
>> -		memset(tls->priv_key_passphrase, 0,
>> -				strlen(tls->priv_key_passphrase));
>> -		l_free(tls->priv_key_passphrase);
>> -		tls->priv_key_passphrase =3D NULL;
>> +	if (priv_key_path) {
>> +		priv_key =3D l_pem_load_private_key(priv_key_path,
>> +							priv_key_passphrase,
>> +							&tls->priv_key_size);
>> +
>> +		tls->priv_key =3D l_key_new(L_KEY_RSA, priv_key,
>> +						tls->priv_key_size);
>> +		if (priv_key) {
>> +			memset(priv_key, 0, tls->priv_key_size);
>> +			l_free(priv_key);
>> +		}
>> +
>> +		if (!l_key_get_info(tls->priv_key, L_CIPHER_RSA_PKCS1_V1_5,
>> +					L_CHECKSUM_NONE, &tls->priv_key_size,
>> +					&is_public) || is_public) {
>> +			l_key_free(tls->priv_key);
>> +			tls->priv_key =3D NULL;
>> +			tls->priv_key_size =3D 0;
>> +			return false;
>> +		}
>> +
>> +		tls->priv_key_size /=3D 8;
>>   	}
>> =

>> -	if (priv_key_passphrase)
>> -		tls->priv_key_passphrase =3D l_strdup(priv_key_passphrase);
>> +	if (cert_path)
>> +		tls->cert_path =3D l_strdup(cert_path);
>> +
>> +	return true;
>>   }
>>
>>   LIB_EXPORT const char *l_tls_alert_to_str(enum l_tls_alert_desc desc)
>> diff --git a/ell/tls.h b/ell/tls.h
>> index a3f3a28..0a7c920 100644
>> --- a/ell/tls.h
>> +++ b/ell/tls.h
>> @@ -97,7 +97,7 @@ void l_tls_set_cacert(struct l_tls *tls, const char =

>> *ca_cert_path);
>>    * one certificate of each type so they can be used depending on which
>>    * is compatible with the negotiated parameters.
>>    */
>> -void l_tls_set_auth_data(struct l_tls *tls, const char *cert_path,
>> +bool l_tls_set_auth_data(struct l_tls *tls, const char *cert_path,
>>   				const char *priv_key_path,
>>   				const char *priv_key_passphrase);
>> =

>> =

>
> Regards,
> -Denis
>

--
Mat Martineau
Intel OTC

--===============6710122640822158579==--

