Content-Type: multipart/mixed; boundary="===============0256992504442233705=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] unit: Add PBKDF2 tests from iwd
Date: Mon, 09 Oct 2017 14:33:54 -0500
Message-ID: <c95b6782-c533-71f6-4d1b-739645bbc65f@gmail.com>
In-Reply-To: <CAOq732LT7cZiC8unwyhF35PMR8t3q2inq-X1OGVATfDY=XmdzA@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0256992504442233705==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 10/09/2017 02:21 PM, Andrew Zaborowski wrote:
> Hi Denis,
> =

> On 9 October 2017 at 19:05, Denis Kenzior <denkenz@gmail.com> wrote:
>> On 10/09/2017 04:46 AM, Andrew Zaborowski wrote:
>>> Test l_pkcs5_pbkdf2 using test data from iwd with the exception of the
>>> test case that contained a \0 inside the password string.
>>
>> So the obvious question is why that test was excepted?
> =

> Because in the ell implementation I treat the password as a C string
> so it can't have a \0 in the middle, while the iwd version would take
> a length parameter.  We don't have a use case for non-C-string
> passwords but RFC8018 doesn't exactly prohibit them or define what is
> considered a password.
> =

> "Throughout this document, a password is considered to be an octet
> string of arbitrary length whose interpretation as a text string is
> unspecified.  In the interest of interoperability, however, it is
> recommended that applications follow some common text encoding rules.
> ASCII and UTF-8 [RFC3629] are two possibilities.  (ASCII is a subset
> of UTF-8.)
> =

> Although the selection of passwords is outside the scope of this
> document, guidelines have been published [NISTSP63] that may well be
> taken into account."
> =

> Best regards
> =


Sweet.  So I took the liberty of copy-pasting this explanation into the =

patch description (git commit --amend) and pushed it out ;)

Regards,
-Denis

--===============0256992504442233705==--

