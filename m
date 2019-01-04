Content-Type: multipart/mixed; boundary="===============5284394410691127623=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 05/12] tls: Allow user to set custom list of cipher suites
Date: Fri, 04 Jan 2019 15:32:26 -0600
Message-ID: <6e27ce58-d27c-9bd9-2461-e2d756c1d5d2@gmail.com>
In-Reply-To: <20190104012640.4022-5-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5284394410691127623==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 01/03/2019 07:26 PM, Andrew Zaborowski wrote:
> TLS "security profiles" define which minimum cipher suites and other
> parameter values are allowed in a specific usage scenario for TLS, for
> example WPA3 in theory requires a specific security profile for its
> TLS-based EAP method.  This will also allow the unit tests to test
> individual cipher suites.
> ---
>   ell/tls-private.h |   5 +
>   ell/tls.c         | 260 +++++++++++++++++++++++++++++++---------------
>   2 files changed, 181 insertions(+), 84 deletions(-)
> =


Patches 1-5 applied, thanks.

Regards,
-Denis

--===============5284394410691127623==--

