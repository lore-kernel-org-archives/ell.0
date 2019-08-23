Content-Type: multipart/mixed; boundary="===============0706822186637646279=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] tls: Validate peer certificate's DNSNames against mask
Date: Fri, 23 Aug 2019 18:40:00 -0500
Message-ID: <214b2fff-03d3-dc92-0330-31d6b07f885e@gmail.com>
In-Reply-To: <20190824004731.24274-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0706822186637646279==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 8/23/19 7:47 PM, Andrew Zaborowski wrote:
> Also return success in the domain_mask check if any of the DNSNames in
> the peer certificate's subjectAltName extension matches any of the mask
> strings supplied.
> ---
>   ell/tls.c | 70 ++++++++++++++++++++++++++++++++++++++++++++++++-------
>   1 file changed, 62 insertions(+), 8 deletions(-)
> =


Both applied, thanks.

Regards,
-Denis


--===============0706822186637646279==--

