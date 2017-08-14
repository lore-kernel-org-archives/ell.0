Content-Type: multipart/mixed; boundary="===============6262107546532529729=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/7] tls: Move DER / ASN.1 related definitions to
 asn1-private.h
Date: Mon, 14 Aug 2017 15:11:35 -0500
Message-ID: <95adda1d-9064-b8b4-ee1f-9374c8b5d715@gmail.com>
In-Reply-To: <20170814145750.6683-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6262107546532529729==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 08/14/2017 09:57 AM, Andrew Zaborowski wrote:
> Extract those utilities that can be used by pem.c for decoding encrypted
> certificates and possibly other mechanisms.  Introduce the asn1_oid_eq
> macro for comparing OIDs.
> ---
>   Makefile.am        |   1 +
>   ell/asn1-private.h | 118 ++++++++++++++++++++++++++++++++++++++++++++++=
+++++++
>   ell/tls.c          | 106 +++--------------------------------------------
>   3 files changed, 124 insertions(+), 101 deletions(-)
>   create mode 100644 ell/asn1-private.h
> =


Applied, thanks.

Regards,
-Denis


--===============6262107546532529729==--

