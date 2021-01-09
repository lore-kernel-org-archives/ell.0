Content-Type: multipart/mixed; boundary="===============1582170354496989205=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 6/8] cert: Add PKCS#12 loading support
Date: Fri, 08 Jan 2021 20:29:55 -0600
Message-ID: <1bfbcc64-9925-4a9f-cf6f-9a24f699ac67@gmail.com>
In-Reply-To: <CAOq732+3e5qMJtRx6APUVsfYixiSZyu1tku=uj3dufJDCNPrSg@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1582170354496989205==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 1/8/21 7:04 PM, Andrew Zaborowski wrote:
> On Fri, 8 Jan 2021 at 05:59, Denis Kenzior <denkenz@gmail.com> wrote:
>>> +     plaintext =3D l_malloc(encrypted_len);
>>> +     ok =3D l_cipher_decrypt(alg, encrypted, plaintext, encrypted_len);
>>> +     l_cipher_free(alg);
>>> +
>>> +     if (!ok)
>>> +             return NULL;
>>> +
>>
>> is plaintext leaked here?
> =

> l_cipher_decrypt has failed so the read() either failed or didn't happen.
> =


By my reading you l_malloc plaintext and never free it, no?

Regards,
-Denis
--===============1582170354496989205==--

