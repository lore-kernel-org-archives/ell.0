Content-Type: multipart/mixed; boundary="===============7618164284805522528=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 08/10] pem: Support encrypted keys in
 l_pem_load_private_key
Date: Sat, 12 Aug 2017 02:45:06 +0200
Message-ID: <CAOq732Jz8w13BnW024LyWt0cWZqrjHm89PhyvSnniQ8Z-SmU6Q@mail.gmail.com>
In-Reply-To: <9ee80b29-2926-ab09-8859-74944820d03d@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7618164284805522528==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On 12 August 2017 at 02:40, Denis Kenzior <denkenz@gmail.com> wrote:
>>> So we set encrypted even if we fail?  Right now you're not even using
>>> this
>>> parameter, so I wonder if we should maybe introduce a new function, like
>>> l_pem_is_encrypted() instead?
>>
>>
>> I could do either thing, but the idea here was that whoever is setting
>> up TLS checks if a passphrase is required.  If it isn't, they get
>> feedback on whether the PEM file loads Ok in the same call.  If it is
>> they validate the passphrase and the encrypted PEM in one call.  With
>> a separate l_pem_is_encrypted the file will be loaded twice.
>>
>
> Do you have a need for this?  If we don't have any immediate need, I would
> just punt on this for now.

I have iwd code to actually enable encrypted EAP-TLS or EAP-TTLS
private keys.  But it could use a "l_pem_is_encrypted" too, only the
files would be loaded more times.

Best regards

--===============7618164284805522528==--

