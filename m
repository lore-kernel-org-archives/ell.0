Content-Type: multipart/mixed; boundary="===============8162154153859294744=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH 2/6] tls: Convert encrypt and verify to l_key crypto
Date: Mon, 08 Aug 2016 08:48:16 -0700
Message-ID: <alpine.OSX.2.20.1608080824150.4540@mjmartin-mac01.local>
In-Reply-To: <CAOq732Lt9rgt5tX7=McnTpa8cqNoNCD0xZVk-cm3rM_3KKhD=w@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8162154153859294744==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Mon, 8 Aug 2016, Andrzej Zaborowski wrote:

> Hi Mat,
>
> Just a minor comment,
>
> On 5 August 2016 at 22:53, Mat Martineau
> <mathew.j.martineau@linux.intel.com> wrote:
>> diff --git a/ell/tls.c b/ell/tls.c
>> index 18e5fae..627b57d 100644
>> @@ -1029,23 +1022,18 @@ static bool tls_rsa_verify(struct l_tls *tls, co=
nst uint8_t *in, size_t len,
>>                 return false;
>>         }
>>
>> -       rsa_client_pubkey =3D l_asymmetric_cipher_new(L_CIPHER_RSA_PKCS1=
_V1_5,
>> -                                                       tls->peer_pubkey,
>> -                                                       tls->peer_pubkey=
_length,
>> -                                                       true);
>> -       if (!rsa_client_pubkey) {
>> +       if (!l_key_get_info(tls->peer_pubkey, L_CIPHER_RSA_PKCS1_V1_5,
>> +                                       L_CHECKSUM_NONE, &key_size,
>> +                                       &is_public)) {
>>                 tls_disconnect(tls, TLS_ALERT_INTERNAL_ERROR, 0);
>> -
>> -               return false;
>>         }
>
> It looks like this return should stay.

Yes, it should. Thanks.

--
Mat Martineau
Intel OTC

--===============8162154153859294744==--

