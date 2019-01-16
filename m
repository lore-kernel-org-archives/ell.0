Content-Type: multipart/mixed; boundary="===============3562146445853399981=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] checksum: add l_checksum_digest_length
Date: Wed, 16 Jan 2019 10:33:06 -0600
Message-ID: <03ca90fe-a5b9-a7cb-cfd1-48fea3f17d30@gmail.com>
In-Reply-To: <20190115223809.5763-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3562146445853399981==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 01/15/2019 04:38 PM, James Prestwood wrote:
> IWD needs the ability to get the digest length for a given checksum.
> This was trivial to do in IWD, but since the we already have the
> digest length in ELL its more fitting to add a proper ELL API.
> ---
>   ell/checksum.c | 17 +++++++++++++++++
>   ell/checksum.h |  2 ++
>   ell/ell.sym    |  1 +
>   3 files changed, 20 insertions(+)

Applied, thanks.

Regards,
-Denis


--===============3562146445853399981==--

