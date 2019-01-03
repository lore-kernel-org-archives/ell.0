Content-Type: multipart/mixed; boundary="===============1790337250220434115=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 06/17] tls: Allow user to set custom list of cipher suites
Date: Wed, 02 Jan 2019 18:51:20 -0600
Message-ID: <239e658f-4d19-3fce-9764-7a19d0eed1bd@gmail.com>
In-Reply-To: <20190101194939.5974-6-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1790337250220434115==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 01/01/2019 01:49 PM, Andrew Zaborowski wrote:
> TLS "security profiles" define which minimum cipher suites and other
> parameter values are allowed in a specific usage scenario for TLS, for
> example WPA3 in theory requires a specific security profile for its
> TLS-based EAP method.  This will also allow the unit tests to test
> individual cipher suites.
> ---
>   ell/tls-private.h |   5 +
>   ell/tls.c         | 260 +++++++++++++++++++++++++++++++---------------
>   2 files changed, 181 insertions(+), 84 deletions(-)

Looks good to me.

Regards,
-Denis


--===============1790337250220434115==--

