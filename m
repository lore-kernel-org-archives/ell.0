Content-Type: multipart/mixed; boundary="===============4402955047126918493=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/3] cert: Add PKCS#12 loading support
Date: Fri, 15 Jan 2021 15:03:22 -0600
Message-ID: <56ba82a2-68b0-8254-317c-1164dbc9c802@gmail.com>
In-Reply-To: <20210114185057.2035125-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4402955047126918493==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 1/14/21 12:50 PM, Andrew Zaborowski wrote:
> Add ability to parse PKCS#12 files in l_cert_load_container_file().  This
> has only been tested with the files produced by openssl so far.
> =

> Extend the static buffer in struct asn1_oid (asn1-private.h) so we can
> handle some 11-byte OIDs used in PKCS#12 files.
> ---
>   ell/asn1-private.h |   2 +-
>   ell/cert.c         | 690 +++++++++++++++++++++++++++++++++++++++++++++
>   ell/pem.c          |   4 +
>   3 files changed, 695 insertions(+), 1 deletion(-)
> =


All applied, thanks.

Regards,
-Denis

--===============4402955047126918493==--

