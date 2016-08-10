Content-Type: multipart/mixed; boundary="===============0742379592215663826=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v3 1/5] tls: Convert encrypt and verify to l_key crypto
Date: Wed, 10 Aug 2016 12:11:31 -0500
Message-ID: <57AB6043.2030808@gmail.com>
In-Reply-To: <20160809231159.25177-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0742379592215663826==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 08/09/2016 06:11 PM, Mat Martineau wrote:
> Keep track of the peer public key as a struct l_key (loaded in the
> kernel), and use that key in encrypt and verify crypto operations.
> ---
>   ell/tls-private.h |   6 +--
>   ell/tls.c         | 151 ++++++++++++++++-------------------------------=
-------
>   2 files changed, 45 insertions(+), 112 deletions(-)
>

All 5 applied, thanks.

Regards,
-Denis


--===============0742379592215663826==--

