Content-Type: multipart/mixed; boundary="===============3834690771942183364=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] tls: Implement the RFC 7919 Supported Groups extension
Date: Wed, 09 Jan 2019 11:49:18 -0600
Message-ID: <5ca1dc02-ebf9-9d96-0042-e6e4e22121e5@gmail.com>
In-Reply-To: <20190108232530.5665-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3834690771942183364==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 01/08/2019 05:25 PM, Andrew Zaborowski wrote:
> For ECDHE (RFC 8422) we implemented the Supported Elliptic Curves
> extension which was later renamed Supported Groups in RFC 7919 and
> extended to be used for negotiating FF groups for DHE too.  This change
> is acknowledged in RFC 8422 too.  This fixes some problems with the DHE
> key exchange in TLS although it seems like it may have been released
> too late to get TLS users to re-enable DHE when ECDHE is widely
> supported and had the group negotiation specified in a way free of
> the issues in DHE.  RFC 7919 is only supported by few https servers
> (all wikipedia servers as far as I could tell)
> ---
>   ell/tls-extensions.c | 515 +++++++++++++++++++++++++++++++++++++++++--
>   ell/tls-private.h    |  29 ++-
>   ell/tls-suites.c     | 101 +++------
>   ell/tls.c            |  14 ++
>   4 files changed, 568 insertions(+), 91 deletions(-)
> =


Applied, thanks.

Regards,
-Denis


--===============3834690771942183364==--

