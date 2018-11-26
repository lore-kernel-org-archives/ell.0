Content-Type: multipart/mixed; boundary="===============3306678881701135519=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 2/5] cert: Rewrite l_certchain_verify non-recursively
Date: Mon, 26 Nov 2018 14:02:50 -0600
Message-ID: <354a9e1b-5bdc-b23a-b849-c77a144e99dc@gmail.com>
In-Reply-To: <20181123094429.7190-2-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3306678881701135519==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On 11/23/2018 03:44 AM, Andrew Zaborowski wrote:
> Rewrite l_certchain_verify iterating over the certificates from root to
> leaf using the double-linked list property and without using recursion to
> simplify the logic.  At the same time make sure that while we link new
> certificates to the keyring we also unlink the old ones, those that have
> been used to verify previous certificates.   This should fix a long
> standing issue where we didn't verify that each certificate in the chain
> was trusted specifically by the immediately preceding one, only that it
> was trusted by any CA whose certificate was already linked to keyring.
> ---
>   ell/cert.c | 207 ++++++++++++++++++++++++++++++-----------------------
>   1 file changed, 117 insertions(+), 90 deletions(-)
> =


Patches 2, 4, 5 applied, thanks.

Regards,
-Denis


--===============3306678881701135519==--

