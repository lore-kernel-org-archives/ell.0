Content-Type: multipart/mixed; boundary="===============0756346471815359915=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 08/10] pem: Support encrypted keys in
 l_pem_load_private_key
Date: Sat, 12 Aug 2017 02:30:24 +0200
Message-ID: <CAOq732JUrZg=3-HMnCEtT3fNPOV3furYtnvsgA=OWyNKx1=d4Q@mail.gmail.com>
In-Reply-To: <757437fc-6fa1-6cbf-97a5-be2597ef847b@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0756346471815359915==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On 11 August 2017 at 22:23, Denis Kenzior <denkenz@gmail.com> wrote:
> On 08/10/2017 06:10 PM, Andrew Zaborowski wrote:
>> Add support for loading PKCS#8 encrypted private key files (those
>> generated with "openssl pkcs8 ..." or "openssl pkey ..." commands, not
>> "openssl rsa ..." commands).  The 'encrypted' parameter can be used to
>> check if a password is required to decode the key if the caller knows
>> nothing about the key other than the file path.
>> ---
>>   ell/pem.c | 90
>> ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-----
>>   ell/pem.h |  4 +--
>>   ell/tls.c |  1 +
>>   3 files changed, 86 insertions(+), 9 deletions(-)
>>
>> diff --git a/ell/pem.c b/ell/pem.c
>> index d1f180e..058b8b8 100644
>> --- a/ell/pem.c
>> +++ b/ell/pem.c
>> @@ -36,6 +36,8 @@
>>   #include "pem.h"
>>   #include "base64.h"
>>   #include "string.h"
>> +#include "asn1-private.h"
>> +#include "cipher.h"
>>     #define PEM_START_BOUNDARY  "-----BEGIN "
>>   #define PEM_END_BOUNDARY      "-----END "
>> @@ -232,11 +234,15 @@ LIB_EXPORT uint8_t *l_pem_load_certificate(const
>> char *filename, size_t *len)
>>     LIB_EXPORT uint8_t *l_pem_load_private_key(const char *filename,
>>                                                 const char *passphrase,
>> +                                               bool *encrypted,
>>                                                 size_t *len)
>>   {
>>         uint8_t *content;
>>         char *label;
>>   +     if (encrypted)
>> +               *encrypted =3D false;
>> +
>
>
> So we set encrypted even if we fail?  Right now you're not even using this
> parameter, so I wonder if we should maybe introduce a new function, like
> l_pem_is_encrypted() instead?

I could do either thing, but the idea here was that whoever is setting
up TLS checks if a passphrase is required.  If it isn't, they get
feedback on whether the PEM file loads Ok in the same call.  If it is
they validate the passphrase and the encrypted PEM in one call.  With
a separate l_pem_is_encrypted the file will be loaded twice.

Best regards

--===============0756346471815359915==--

