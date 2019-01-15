Content-Type: multipart/mixed; boundary="===============4315110427671285799=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/3] tls: Implement l_tls_set_version_range
Date: Tue, 15 Jan 2019 14:45:47 -0600
Message-ID: <de90beaf-fa29-45a6-e6ca-8dc1b0c5a794@gmail.com>
In-Reply-To: <20190111141148.17379-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4315110427671285799==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 01/11/2019 08:11 AM, Andrew Zaborowski wrote:
> Allow user to set custom min and max TLS version limits, this can be
> used to ensure we comply with a specific security profile.
> ---
> Last message in the previous discussion about this was here:
> https://lists.01.org/pipermail/ell/2018-December/001625.html
> ---
>   ell/ell.sym       |  1 +
>   ell/tls-private.h | 11 +++-----
>   ell/tls-record.c  |  2 +-
>   ell/tls-suites.c  |  4 +--
>   ell/tls.c         | 66 +++++++++++++++++++++++++++++++++--------------
>   ell/tls.h         | 12 ++++++++-
>   6 files changed, 65 insertions(+), 31 deletions(-)
> =


All applied, thanks.

Regards,
-Denis


--===============4315110427671285799==--

