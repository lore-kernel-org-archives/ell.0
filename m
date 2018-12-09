Content-Type: multipart/mixed; boundary="===============1705563609728277339=="
MIME-Version: 1.0
From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH v4 5/5] gitignore: added ecc/ecdh unit tests
Date: Sun, 09 Dec 2018 12:18:17 +0100
Message-ID: <60AFA461-739B-4B72-8B70-30FDE4722B58@holtmann.org>
In-Reply-To: <20181207203009.5843-5-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1705563609728277339==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

> ---
> .gitignore | 2 ++
> 1 file changed, 2 insertions(+)
> =

> diff --git a/.gitignore b/.gitignore
> index 16725f5..75ab7b2 100644
> --- a/.gitignore
> +++ b/.gitignore
> @@ -56,6 +56,8 @@ unit/test-key
> unit/test-pbkdf2
> unit/test-dhcp
> unit/test-dir-watch
> +unit/test-ecc
> +unit/test-ecdh
> unit/cert-*.pem
> unit/cert-*.csr
> unit/cert-*.srl

have these with the patches that actually add the new binary.

Regards

Marcel


--===============1705563609728277339==--

