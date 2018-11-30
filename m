Content-Type: multipart/mixed; boundary="===============4638225568106375978=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/6] tls: Drop local code to add hash OID, let kernel do it
Date: Fri, 30 Nov 2018 10:13:16 -0600
Message-ID: <e30e2fef-fe0f-9135-c49e-0952c4ca2fb7@gmail.com>
In-Reply-To: <20181130120550.8866-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4638225568106375978==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 11/30/2018 06:05 AM, Andrew Zaborowski wrote:
> Drop tls.c code to build the PKCS#1 DigestInfo structure which basically
> consisted of prepending the signature hash algorithm's OID to the hash.
> Let the key API do it by setting the hash type in the l_key_sign and
> l_key_verify calls.  Slightly simplify the tls_rsa_sign and
> tls_rsa_verify code while doing this.
> ---
>   ell/tls.c | 169 ++++++++++++++++++------------------------------------
>   1 file changed, 56 insertions(+), 113 deletions(-)
> =


All applied, thanks.

Regards,
-Denis


--===============4638225568106375978==--

