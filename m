Content-Type: multipart/mixed; boundary="===============3472993446313555506=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/5] pem: Parse PKCS#1 formatted private keys
Date: Mon, 23 Nov 2020 13:13:50 -0600
Message-ID: <9bd5a8fc-8442-c46c-5f8b-1864864c26a6@gmail.com>
In-Reply-To: <20201123115417.218473-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3472993446313555506==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 11/23/20 5:54 AM, Andrew Zaborowski wrote:
> The PKCS#1 RSAPrivateKey format is used within the PKCS#8 PrivateKey
> structure so we just need to wrap it in some extra ASN.1 data to get a
> format understood by the pkcs8-key-parse module.
> =

> Improve some comments with the right RFC references.
> ---
>   ell/asn1-private.h |   1 +
>   ell/pem.c          | 106 +++++++++++++++++++++++++++++++++++++++++----
>   2 files changed, 98 insertions(+), 9 deletions(-)
> =


Patches 1, 3, 4 applied thanks.

Regards,
-Denis

--===============3472993446313555506==--

