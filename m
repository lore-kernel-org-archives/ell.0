Content-Type: multipart/mixed; boundary="===============0874242611044863182=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] Add DES and MD4 support
Date: Sat, 10 Dec 2016 10:56:36 -0600
Message-ID: <bbb203cc-9a78-a0c2-07ff-5f679fa4170c@gmail.com>
In-Reply-To: <20161210084457.12774-1-ongy@ongy.net>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0874242611044863182==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Markus,

On 12/10/2016 02:44 AM, Markus Ongyerth wrote:
> From: Markus Ongyerth <ell@ongy.net>
>
> Add support for DES in cipher and MD4 in checksum to allow implementing
> the mschapv2 protocol.
> ---
>  ell/checksum.c | 8 ++++++++
>  ell/checksum.h | 1 +
>  ell/cipher.c   | 3 +++
>  ell/cipher.h   | 1 +
>  ell/key.c      | 3 +++
>  5 files changed, 16 insertions(+)
>

I split this into two commits, one for the MD4 changes and one for DES. =

Applied, thanks!

Regards,
-Denis

--===============0874242611044863182==--

