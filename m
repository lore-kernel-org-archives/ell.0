Content-Type: multipart/mixed; boundary="===============8341794700105632363=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [RFC 0/2] Cipher infrastructure
Date: Mon, 02 Feb 2015 12:44:09 -0600
Message-ID: <54CFC579.9050805@gmail.com>
In-Reply-To: <1422615464-21435-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8341794700105632363==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Tomasz,

On 01/30/2015 04:57 AM, Tomasz Bursztyka wrote:
> Hi,
>
> Went quickly through the cipher proposal, to get a somehow working implem=
entation.
> Seems to work with aes, but not with arc4.
>

ARC4 is a bit weird.  The same function is used for encryption and =

decryption, so the stream is not reset.  You will likely need to set the =

key prior to each encrypt/decrypt operation.

> And now I wonder if we should not provide an initialization vector for so=
me ciphers? (like arc4).
>

I'm still not fully sure we need the IV.  EAPoL Key-IV is only used in =

certain situations.  Lets try to find an AP / trace that actually sets =

the IV field.

Regards,
-Denis

--===============8341794700105632363==--

