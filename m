Content-Type: multipart/mixed; boundary="===============8055589418309149637=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 07/10] cipher: Add l_cipher_from_pkcs5_id
Date: Sat, 12 Aug 2017 02:40:54 +0200
Message-ID: <CAOq732JXq1DS4_T==gF62=W+NcvPDcDi+jR87LH9jrp56K-Wmg@mail.gmail.com>
In-Reply-To: <33cf2bba-84ec-5624-f59b-521ca5694f5f@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8055589418309149637==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On 12 August 2017 at 02:30, Denis Kenzior <denkenz@gmail.com> wrote:
>>> Another reason to move this is that I don't really want to expose it in
>>> l_cipher.  The right way for us to enable encrypted certificates is via
>>> the
>>> keyctl API.  Until then, we should stuff this into some private file.
>>> Can
>>> we put this into asn1-private.[ch]?
>>
>>
>> If we're going to have pkcs5.c, perhaps let's put it there since all
>> of this is basically PKCS#5?  We would then also need pkcs5-private.h,
>> is that too many files?
>>
>
> I'm not to worried about the number of files.  I am mostly worried about
> introducing something into the public API and then taking it out later. So
> if we want iwd to use whatever is inside pkcs5.[ch], then it probably sho=
uld
> be public/exported API, which means it isn't a good candidate for
> l_cipher_from_pkcs5_id either.  That one should be private and hence I was
> thinking of having it in asn1-private.  If you think it belongs logically
> with pkcs5, then we could introduce pkcs5-private.h specifically for that
> purpose.
>
> Hope that made sense.

Since you want l_cipher_from_pkcs5_if private I was thinking of all of
the implementation being in pkcs5.c since it's really all just the
text of the PKCS#5 RFC.  But the PBKDF functions would be exported in
pkcs5.h while the PBES function would only be declared in
pkcs5-private.h as something potentially useless after the kernel
implements this (unless we gain another use case for it in the
meantime)

Best regards

--===============8055589418309149637==--

