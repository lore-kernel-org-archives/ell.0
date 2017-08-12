Content-Type: multipart/mixed; boundary="===============3333331148866043596=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 06/10][RFC] cipher: Implement PKCS#5 key derivation
 functions
Date: Sat, 12 Aug 2017 02:12:11 +0200
Message-ID: <CAOq732J6m9iBomoDLDadmPaMfkNkD1zN4ps+37t2hZfHk-ONig@mail.gmail.com>
In-Reply-To: <05f6fa61-7460-b356-b3e9-5d52c77c42f8@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3333331148866043596==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On 11 August 2017 at 18:28, Denis Kenzior <denkenz@gmail.com> wrote:
> Hi Andrew,
>
> On 08/10/2017 06:10 PM, Andrew Zaborowski wrote:
>>
>> Implement the PBKDF1 and PBKDF2 functions from PKCS#4 - RFC8018.  This
>> is for now placed in cipher.c as a dependency for the
>> l_cipher_from_pkcs5_id patch but probably better fits in a separate file
>> called pkcs5.c or something else.
>> > Note iwd already has a PBKDF2 implementation and unit tests, it can be
>> switched to use this ell version and the unit tests moved to ell.
>
>
> We might as well export this from ell and use it in iwd.  There's no sense
> in both carrying the same code.
>
> So maybe we should put this into ell/pkcs5.c and export l_pkcs5_pbkdf1 and
> l_pkcs5_pbkdf2

Sounds good, that's what I was thinking about.  The PBES1 and PBES2
functions would also fit there.

>
>> ---
>>   ell/cipher.c | 127
>> +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>>   1 file changed, 127 insertions(+)
>>
>> diff --git a/ell/cipher.c b/ell/cipher.c
>> index e51f6e7..8e60d61 100644
>> --- a/ell/cipher.c
>> +++ b/ell/cipher.c
>> @@ -34,6 +34,7 @@
>>   #include "cipher.h"
>>   #include "private.h"
>>   #include "random.h"
>> +#include "checksum.h"
>>     #ifndef HAVE_LINUX_IF_ALG_H
>>   #ifndef HAVE_LINUX_TYPES_H
>> @@ -632,3 +633,129 @@ bool l_aead_cipher_is_supported(enum
>> l_aead_cipher_type type)
>>         return supported_aead_ciphers & (1 << type);
>>   }
>> +
>> +/* RFC8018 section 5.1 */
>> +static bool pkcs5_pbkdf1(enum l_checksum_type type, const char *passwor=
d,
>> +                               const uint8_t *salt, size_t salt_len,
>> +                               unsigned int iter_count,
>> +                               size_t dk_len, uint8_t *out_dk)
>
>
> I know RFC8018 uses this order, but should dk_len be after out_dk? That's
> generally how we order the parameters (e.g. in l_cipher_encrypt)
>
> Same question for pbkdf2

Ok.  Will also fix the style issues.

Best regards

--===============3333331148866043596==--

