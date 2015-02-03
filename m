Content-Type: multipart/mixed; boundary="===============8341560979701194992=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: Re: [RFC 0/2] Cipher infrastructure
Date: Tue, 03 Feb 2015 10:07:51 +0200
Message-ID: <54D081D7.2050503@linux.intel.com>
In-Reply-To: <54CFC579.9050805@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8341560979701194992==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

> Hi Tomasz,
>
> On 01/30/2015 04:57 AM, Tomasz Bursztyka wrote:
>> Hi,
>>
>> Went quickly through the cipher proposal, to get a somehow working =

>> implementation.
>> Seems to work with aes, but not with arc4.
>>
>
> ARC4 is a bit weird.  The same function is used for encryption and =

> decryption, so the stream is not reset.  You will likely need to set =

> the key prior to each encrypt/decrypt operation.

OK.

>
>> And now I wonder if we should not provide an initialization vector =

>> for some ciphers? (like arc4).
>>
>
> I'm still not fully sure we need the IV.  EAPoL Key-IV is only used in =

> certain situations.  Lets try to find an AP / trace that actually sets =

> the IV field.
>

Ok, then I think it's worth putting an iv/iv-len params to the =

l_cipher_new(). I might implement its support later though, let's see =

(but at least the API would be fixed).

Tomasz

--===============8341560979701194992==--

