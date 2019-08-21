Content-Type: multipart/mixed; boundary="===============5343813916999106982=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 3/4] tls: Implement l_tls_set_domain_mask
Date: Wed, 21 Aug 2019 12:57:35 -0500
Message-ID: <e5b57cc8-8e7d-4d8a-e7b1-1aad84c2e8b3@gmail.com>
In-Reply-To: <CAOq732LSS5k7emmHh9qXhuKf+aUoZOn96o488R8X3x7DTBrAUQ@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5343813916999106982==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 8/21/19 12:52 AM, Andrew Zaborowski wrote:
> Hi Denis,
> =

> On Tue, 20 Aug 2019 at 21:35, Denis Kenzior <denkenz@gmail.com> wrote:
>> On 8/16/19 7:28 PM, Andrew Zaborowski wrote:
>>> +     /*
>>> +      * Retrieve the Common Name from the Subject DN and check if it
>>> +      * matches.  TODO: possibly also look at SubjectAltName.
>>
>> We definitely need to look in the SubjectAltName dNSName extensions for
>> Hotspot.  So can we add that as well?
> =

> Yep, but that should probably be a separate patch.
> =


Sure, that'd be fine.

Regards,
-Denis

--===============5343813916999106982==--

