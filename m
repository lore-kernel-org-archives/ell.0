Content-Type: multipart/mixed; boundary="===============4462068289933078679=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/5] pkcs5: Add the PKCS#12 KDF
Date: Mon, 14 Dec 2020 23:04:32 +0000
Message-ID: <11d09473-0150-6973-2bfb-b64d2068aa3f@gmail.com>
In-Reply-To: <20201212005100.578174-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4462068289933078679==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 12/11/20 6:50 PM, Andrew Zaborowski wrote:
> Add the key derivation algorithm used with PKCS#12 to pkcs5.c so that it
> can be found together with the two PKCS#5 KDFs, and so that it can also
> be used when parsing of the PKCS#12 AlgorithmIdentifiers in the next
> commit.  This KDF is not recommended for new uses.
> ---
>   ell/pkcs5-private.h |  12 +++++
>   ell/pkcs5.c         | 121 ++++++++++++++++++++++++++++++++++++++++++++
>   2 files changed, 133 insertions(+)
> =


Patch 1 & 2 applied, thanks.

Regards,
-Denis

--===============4462068289933078679==--

