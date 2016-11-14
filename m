Content-Type: multipart/mixed; boundary="===============6988877248981964091=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 2/2] tls: Don't fail if root CA present in received chain
Date: Mon, 14 Nov 2016 15:08:18 -0600
Message-ID: <582A27C2.2000609@gmail.com>
In-Reply-To: <1479154592-8116-2-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6988877248981964091==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 11/14/2016 02:16 PM, Andrew Zaborowski wrote:
> The certificate chain from the Server Certificate message may be a
> complete chain from server's certificate to root CA.  l_keyring_link
> would fail if we tried to add the self-signed root CA to the ring,
> this seems to be unrelated to that certificate being the same as the
> one in the trusted ring.
>
> In the early userspace tls_cert_verify_certchain implementation the
> verification would succeed if any of the certificates in the chain
> was trusted by the supplied CA + the trust chain was correct, but the
> RFC implies this must be the root CA (see the comment in the code).
> ---
>   ell/tls.c | 21 +++++++++++++++++----
>   1 file changed, 17 insertions(+), 4 deletions(-)
>

Applied, thanks.

Regards,
-Denis


--===============6988877248981964091==--

