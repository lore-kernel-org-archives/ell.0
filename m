Content-Type: multipart/mixed; boundary="===============1883281687619050395=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 3/5] pem: Add l_pem_load_container_file
Date: Tue, 15 Dec 2020 02:12:04 +0000
Message-ID: <0f75d4e4-c1d7-7375-8efb-c74c5ea2a38a@gmail.com>
In-Reply-To: <CAOq732KQNQguigcFnte+0PVs5CpKTWNB5Q9cCnAgQ3DtuYqD+Q@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1883281687619050395==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

>>
>> So P12 files are mostly binary, but can also be PEM encoded, correct?  S=
hould we
>> put the pkcs12 DER loading into pkcs12.c or so?  We could also consider =
renaming
>> pkcs5.c to pkcs.c since it seems pkcs5.c is becoming a bit of a jumble o=
f pkcs8,
>> pkcs5 and pkcs12 bits...
> =

> I initially wanted to add it in cert.c, that's why I exposed
> pem_key_from_pkcs8_private_key_info() and
> pem_key_from_pkcs8_encrypted_private_key_info() in pem-private.h, but
> I ended up using them only from within pem.c because cert.c didn't
> seem right for private key stuff.  But maybe that is a good idea.
> =

> So cert.c could contain the high-level file loading/parsing/decoding,
> and then rather than pkcs.c I'd call it cert-crypto.c or similar for
> the low-level crypto stuff?

Yes, something like this...

> =

> The reasoning is that PKCS defined some of those formats and
> algorithms but some of it comes from openssl code, and a lot is really
> currently defined by RFCs.  Initially I think each PKCS standard was
> republished as an RFC but each of those RFCs has since been obsoleted
> by sets of newer RFCs.
> =


I mean ideally we'd have each file format being handled in a separate file, =

either named according to the RFC or well known name.  So pkcs5.c, pkcs12.c=
, =

etc.  But if you want to put this all into one file that is also fine since =

they're all closely related.

>>
>> Still, I'm really unconvinced that this logically belongs in pem.c.  Bes=
ides
>> iwd's TLS module, who is going to be using this function?  Maybe this be=
longs in
>> iwd itself?
> =

> I see it more as library code (like gnutls), anyone using TLS will
> need certificate loading.  ell's examples/https-* should also be
> switched to use this function.

Hmm, where does this end though since we also need to support the system CA =

store, CAs loaded externally and given via keyring ids, TPM/TPM2 keys, etc.=
.. =

Not against the idea, but not sure that it is worth it for 1 real user...

> =

>>
>>>
>>> This function treats PEM files as containers that can have both private
>>> keys and certificates at the same time, openssl can parse such files and
>>> also produces such files in some situations and they may have some good
>>> uses.
>>> ---
>>>    ell/ell.sym |   1 +
>>>    ell/pem.c   | 157 ++++++++++++++++++++++++++++++++++++++++++++++++++=
--
>>>    ell/pem.h   |   5 ++
>>>    3 files changed, 158 insertions(+), 5 deletions(-)
>>>
>>> diff --git a/ell/ell.sym b/ell/ell.sym
>>> index d94b585..03c46d0 100644
>>> --- a/ell/ell.sym
>>> +++ b/ell/ell.sym
>>> @@ -415,6 +415,7 @@ global:
>>>        l_pem_load_file;
>>>        l_pem_load_private_key;
>>>        l_pem_load_private_key_from_data;
>>> +     l_pem_load_container_file;
>>>        /* pkcs5 */
>>>        l_pkcs5_pbkdf1;
>>>        l_pkcs5_pbkdf2;
>>> diff --git a/ell/pem.c b/ell/pem.c
>>> index 1b995d5..90d06fb 100644
>>> --- a/ell/pem.c
>>> +++ b/ell/pem.c
>>> @@ -195,7 +195,7 @@ const char *pem_next(const void *buf, size_t buf_le=
n, char **type_label,
>>>
>>>    static uint8_t *pem_load_buffer(const void *buf, size_t buf_len,
>>>                                char **out_type_label, size_t *out_len,
>>> -                             char **out_headers)
>>> +                             char **out_headers, const char **out_endp)
>>>    {
>>>        size_t base64_len;
>>>        const char *base64;
>>> @@ -203,7 +203,7 @@ static uint8_t *pem_load_buffer(const void *buf, si=
ze_t buf_len,
>>>        uint8_t *ret;
>>>
>>>        base64 =3D pem_next(buf, buf_len, &label, &base64_len,
>>> -                             NULL, false);
>>> +                             out_endp, false);
>>>        if (!base64)
>>>                return NULL;
>>>
>>> @@ -262,7 +262,7 @@ static uint8_t *pem_load_buffer(const void *buf, si=
ze_t buf_len,
>>>    LIB_EXPORT uint8_t *l_pem_load_buffer(const void *buf, size_t buf_le=
n,
>>>                                        char **type_label, size_t *out_l=
en)
>>>    {
>>> -     return pem_load_buffer(buf, buf_len, type_label, out_len, NULL);
>>> +     return pem_load_buffer(buf, buf_len, type_label, out_len, NULL, N=
ULL);
>>>    }
>>>
>>>    struct pem_file_info {
>>> @@ -315,7 +315,8 @@ static uint8_t *pem_load_file(const char *filename,=
 char **out_type_label,
>>>                return NULL;
>>>
>>>        result =3D pem_load_buffer(file.data, file.st.st_size,
>>> -                                     out_type_label, out_len, out_head=
ers);
>>> +                                     out_type_label, out_len, out_head=
ers,
>>> +                                     NULL);
>>>        pem_file_close(&file);
>>>        return result;
>>>    }
>>> @@ -888,7 +889,7 @@ LIB_EXPORT struct l_key *l_pem_load_private_key_fro=
m_data(const void *buf,
>>>        if (encrypted)
>>>                *encrypted =3D false;
>>>
>>> -     content =3D pem_load_buffer(buf, buf_len, &label, &len, &headers);
>>> +     content =3D pem_load_buffer(buf, buf_len, &label, &len, &headers,=
 NULL);
>>>
>>>        if (!content)
>>>                return NULL;
>>> @@ -933,3 +934,149 @@ LIB_EXPORT struct l_key *l_pem_load_private_key(c=
onst char *filename,
>>>        return pem_load_private_key(content, len, label, passphrase, hea=
ders,
>>>                                        encrypted);
>>>    }
>>> +
>>> +/*
>>> + * Look at a file, try to detect which of the few X.509 certificate an=
d/or
>>> + * private key container formats it uses and load any certificates in =
it as
>>> + * a certificate chain object, and load the first private key as an l_=
key
>>> + * object.
>>> + *
>>> + * Currently supported are:
>>> + *  PEM X.509 certificates
>>> + *  PEM PKCS#8 encrypted and unenecrypted private keys
>>> + *  PEM legacy PKCS#1 encrypted and unenecrypted private keys
>>> + *  Raw X.509 certificates (.cer, .der, .crt)
>>> + *
>>> + * The raw format contains exactly one certificate, PEM and PKCS#12 fi=
les
>>> + * can contain any combination of certificates and private keys.
>>> + */
>>> +LIB_EXPORT void l_pem_load_container_file(const char *filename,
>>> +                                     const char *password,
>>> +                                     struct l_certchain **out_certchai=
n,
>>> +                                     struct l_key **out_privkey,
>>> +                                     bool *out_encrypted)
>>> +{
>>> +     struct pem_file_info file;
>>> +     const char *ptr;
>>> +     size_t len;
>>> +     bool error =3D false;
>>> +
>>> +     if (out_encrypted)
>>> +             *out_encrypted =3D false;
>>> +
>>> +     if (out_certchain)
>>> +             *out_certchain =3D NULL;
>>> +
>>> +     if (out_privkey)
>>> +             *out_privkey =3D NULL;
>>
>> This kind of goes against our design patterns.  As a rule our functions =
should
>> not side-effect on failure.
> =

> In this case this is how we signal the failure to load any
> certificates and private keys, this just replaces the return value
> since I needed a python tuple-like type.
> =

> So this should be read as something like:
> =

>    r =3D (NULL, NULL, false);

ell isn't python though, and this is completely out of sync with the rest o=
f the =

API.  Consistency trumps everything else...

> =

>>
>>> +
>>> +     if (unlikely(!filename))
>>> +             return;
>>
>> And failing silently seems wrong as well...?
> =

> And this as:
> =

>    return r;
> =

> I can change the actual return type from void to bool if you prefer.
> I'll still need a way to signal whether the failure is due to
> encryption.  In the existing API we do this by setting *out_encrypted.
> =


The latter would be more consistent and thus more preferable.  Maybe we sho=
uld =

have made these return an int and set a negative errno for the special case=
s...

Regarrds
-Denis
--===============1883281687619050395==--

