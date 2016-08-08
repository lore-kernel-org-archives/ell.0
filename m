Content-Type: multipart/mixed; boundary="===============7950767958820655835=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH v2 4/6] unit: Generate and use PKCS8 version of server key
 for TLS tests
Date: Mon, 08 Aug 2016 10:53:09 -0700
Message-ID: <alpine.OSX.2.20.1608081052270.4540@mjmartin-mac01.local>
In-Reply-To: <57A8C495.7030204@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7950767958820655835==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Mon, 8 Aug 2016, Denis Kenzior wrote:

> Hi Mat,
>
> On 08/08/2016 12:25 PM, Mat Martineau wrote:
>> ---
>>   unit/cert-server-key-pkcs8.pem | 28 ++++++++++++++++++++++++++++
>>   unit/gencerts.sh               |  1 +
>>   unit/test-tls.c                | 16 ++++++++--------
>>   3 files changed, 37 insertions(+), 8 deletions(-)
>>   create mode 100644 unit/cert-server-key-pkcs8.pem
>> =

>
> I wonder, what's the reasoning behind this change?

It's the private key format that the keyctl API knows how to parse. The =

previous private key format doesn't work.

--
Mat Martineau
Intel OTC

--===============7950767958820655835==--

