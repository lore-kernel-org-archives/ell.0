Content-Type: multipart/mixed; boundary="===============4915382575499142819=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 02/13] icmp6: Parse extra options
Date: Fri, 22 Apr 2022 16:39:47 -0500
Message-ID: <cb3f965c-8765-896d-95c5-fa47cadf06e4@gmail.com>
In-Reply-To: 20220422185952.105279-2-andrew.zaborowski@intel.com

--===============4915382575499142819==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 4/22/22 13:59, Andrew Zaborowski wrote:
> Parse Route Information and New Advertisement Interval options.  Route
> Information options (RIOs) are supported by radvd and a few clients that
> I checked.
> ---
>   ell/icmp6-private.h |   6 ++-
>   ell/icmp6.c         | 118 +++++++++++++++++++++++++++++++++++++++-----
>   2 files changed, 110 insertions(+), 14 deletions(-)
> =


Applied, thanks.

Regards,
-Denis

--===============4915382575499142819==--

