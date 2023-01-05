Received: from mail.holtmann.org (coyote.holtmann.net [212.227.132.17])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id E478E2F27
	for <ell@lists.linux.dev>; Thu,  5 Jan 2023 15:15:27 +0000 (UTC)
Received: from smtpclient.apple (p4ff9ff43.dip0.t-ipconnect.de [79.249.255.67])
	by mail.holtmann.org (Postfix) with ESMTPSA id 82080CECC8;
	Thu,  5 Jan 2023 16:15:21 +0100 (CET)
Content-Type: text/plain;
	charset=us-ascii
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3696.120.41.1.1\))
Subject: Re: [PATCH 3/3] tls: Add support l_tls_set_alpn_list() and ALPN
 extension
From: Marcel Holtmann <marcel@holtmann.org>
In-Reply-To: <CAOq732KFvqDu94GGkUfBBszgR-yrCqUj2Lqx3=oPGdKDem0Zjw@mail.gmail.com>
Date: Thu, 5 Jan 2023 16:15:21 +0100
Cc: ell@lists.linux.dev
Content-Transfer-Encoding: quoted-printable
Message-Id: <1E8A2AE4-86F5-4D0A-A0A0-DC0359466523@holtmann.org>
References: <20230103220250.717876-3-marcel@holtmann.org>
 <CAOq732KFvqDu94GGkUfBBszgR-yrCqUj2Lqx3=oPGdKDem0Zjw@mail.gmail.com>
To: Andrew Zaborowski <andrew.zaborowski@intel.com>
X-Mailer: Apple Mail (2.3696.120.41.1.1)

Hi Andrew,

>> +static bool tls_alpn_server_absent(struct l_tls *tls)
>> +{
>> +       if (!tls->alpn_list)
>> +               return false;
>=20
> I believe this returning false will break most usages of l_tls.

can you elaborate why? When are you allowed to return false.

>=20
>> +
>> +       l_free(tls->selected_alpn);
>> +       tls->selected_alpn =3D NULL;
>> +
>> +       TLS_DEBUG("ALPN not supported");
>> +
>> +       return true;
>> +}
>> +
>> /* Most extensions are not used when resuming a cached session */
>> #define SKIP_ON_RESUMPTION()   \
>>        do {    \
>> @@ -1025,6 +1089,15 @@ const struct tls_hello_extension =
tls_extensions[] =3D {
>>                tls_signature_algorithms_client_absent,
>>                NULL, NULL, NULL,
>>        },
>> +       {
>> +               "ALPN", "application_layer_protocol_negotiation", 16,
>> +               tls_alpn_client_write,
>> +               NULL,
>> +               NULL,
>> +               NULL,
>> +               tls_alpn_server_handle,
>> +               tls_alpn_server_absent,
>> +       },
>=20
> If only the client side is implemented you might want to add a hint
> either in the .h comment for l_tls_set_alpn_list(), or even in its
> name.

Good point, I think that I just implement the server side since that
is generally useful there as well. I was just focused on the client.

>>        {
>>                "Secure Renegotiation", "renegotiation_info", 0xff01,
>>                tls_renegotiation_info_client_write,
>> diff --git a/ell/tls-private.h b/ell/tls-private.h
>> index ac477885c5f7..dbc5457ef091 100644
>> --- a/ell/tls-private.h
>> +++ b/ell/tls-private.h
>> @@ -218,6 +218,8 @@ struct l_tls {
>>=20
>>        struct tls_cipher_suite **cipher_suite_pref_list;
>>        char *server_name;
>> +       char **alpn_list;
>> +       char *selected_alpn;
>>=20
>>        struct l_settings *session_settings;
>>        char *session_prefix;
>> diff --git a/ell/tls.c b/ell/tls.c
>> index 9556efd932bc..8c1c9040ff89 100644
>> --- a/ell/tls.c
>> +++ b/ell/tls.c
>> @@ -3421,6 +3421,8 @@ LIB_EXPORT void l_tls_free(struct l_tls *tls)
>>                l_free(tls->cipher_suite_pref_list);
>>=20
>>        l_free(tls->server_name);
>> +       l_strv_free(tls->alpn_list);
>=20
> Would perhaps l_tls_set_alpn_list(tls, NULL) be more future proof?

Let me check when I have the server side done.

>> +       l_free(tls->selected_alpn);
>>        l_free(tls);
>> }
>>=20
>> @@ -3668,6 +3670,25 @@ LIB_EXPORT bool l_tls_set_server_name(struct =
l_tls *tls, const char *name)
>>        return true;
>> }
>>=20
>> +LIB_EXPORT bool l_tls_set_alpn_list(struct l_tls *tls, const char =
**list)
>> +{
>> +       if (!tls)
>> +               return false;
>> +
>> +       l_strv_free(tls->alpn_list);
>> +       tls->alpn_list =3D l_strv_copy((char **) list);
>> +
>> +       return true;
>> +}
>> +
>> +LIB_EXPORT const char *l_tls_get_alpn(struct l_tls *tls)
>> +{
>> +       if (!tls)
>> +               return NULL;
>> +
>> +       return tls->selected_alpn;
>> +}
>> +
>> LIB_EXPORT bool l_tls_set_cacert(struct l_tls *tls, struct l_queue =
*ca_certs)
>> {
>>        if (tls->ca_certs) {
>> diff --git a/ell/tls.h b/ell/tls.h
>> index c931b5db0a54..e33f7c070008 100644
>> --- a/ell/tls.h
>> +++ b/ell/tls.h
>> @@ -105,6 +105,9 @@ void l_tls_handle_rx(struct l_tls *tls, const =
uint8_t *data, size_t len);
>>=20
>> bool l_tls_set_server_name(struct l_tls *tls, const char *name);
>>=20
>> +bool l_tls_set_alpn_list(struct l_tls *tls, const char **list);
>> +const char *l_tls_get_alpn(struct l_tls *tls);
>=20
> Since these and l_tls_set_server_name are extensions, I'd move them
> further down in the file after the basic API, maybe aronud
> l_tls_set_domain_mask.  Both patchsets look good otherwise.

Generally I would agree, but since with TLS 1.3 everything is an
extension anyway, I think such argument is void these days. And
logically the SNI and ALPN are pretty much core concept of TLS
these days. TLS 1.3 requires SNI to be supported even while the
usage is optional. There are really just only rare cases where
you would not use SNI and thus making this pretty much a core
feature of TLS now.

The same applies to ALPN and what I have seen from IETF, they did
make sure ALPN is in their RFCs and gets used to identify the
application protocol.

Regards

Marcel

