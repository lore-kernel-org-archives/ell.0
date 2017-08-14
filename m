Content-Type: multipart/mixed; boundary="===============1664933631140210239=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 2/7] asn1: Use const pointers in ASN1 parsing utilities
Date: Mon, 14 Aug 2017 15:12:26 -0500
Message-ID: <1dcbb184-c77f-7c12-e08e-d20d1a7156b4@gmail.com>
In-Reply-To: <20170814145750.6683-2-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1664933631140210239==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 08/14/2017 09:57 AM, Andrew Zaborowski wrote:
> For convenience take const pointers as inputs to the ASN1 utilites,
> we only use those functions for parsing.
> ---
>   ell/asn1-private.h | 11 ++++++-----
>   ell/tls.c          |  2 +-
>   2 files changed, 7 insertions(+), 6 deletions(-)
> =


Applied, thanks.

Regards,
-Denis


--===============1664933631140210239==--

