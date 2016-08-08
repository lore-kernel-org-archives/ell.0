Content-Type: multipart/mixed; boundary="===============4613992453013519568=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2 4/6] unit: Generate and use PKCS8 version of server key
 for TLS tests
Date: Mon, 08 Aug 2016 14:58:46 -0500
Message-ID: <57A8E476.50307@gmail.com>
In-Reply-To: <alpine.OSX.2.20.1608081052270.4540@mjmartin-mac01.local>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4613992453013519568==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 08/08/2016 12:53 PM, Mat Martineau wrote:
> On Mon, 8 Aug 2016, Denis Kenzior wrote:
>
>> Hi Mat,
>>
>> On 08/08/2016 12:25 PM, Mat Martineau wrote:
>>> ---
>>>   unit/cert-server-key-pkcs8.pem | 28 ++++++++++++++++++++++++++++
>>>   unit/gencerts.sh               |  1 +
>>>   unit/test-tls.c                | 16 ++++++++--------
>>>   3 files changed, 37 insertions(+), 8 deletions(-)
>>>   create mode 100644 unit/cert-server-key-pkcs8.pem
>>>
>>
>> I wonder, what's the reasoning behind this change?
>
> It's the private key format that the keyctl API knows how to parse. The
> previous private key format doesn't work.
>

The previous format was PKCS 1.5 right?  There's no way to support that one?

Unit tests inside iwd assume PKCS1.5 at the moment.  And I'm worried =

that most existing certificates won't be PKCS#8.

Regards,
-Denis


--===============4613992453013519568==--

