Content-Type: multipart/mixed; boundary="===============4047984483764572227=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 1/8] dhcp6-lease: Make getters argument const, cleanup
Date: Mon, 18 Apr 2022 11:17:46 -0500
Message-ID: <1ab4a79e-c5b9-c33d-d4f5-332d4dec0b6c@gmail.com>
In-Reply-To: 20220415183211.987345-1-andrew.zaborowski@intel.com

--===============4047984483764572227==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 4/15/22 13:32, Andrew Zaborowski wrote:
> Add "const" to the lifetime getters argument, drop dhcp6-private.h
> declarations I probably added/renamed by mistake.
> ---
>   ell/dhcp6-lease.c   | 13 +++++++------
>   ell/dhcp6-private.h |  7 ++-----
>   ell/dhcp6.h         |  7 ++++---
>   3 files changed, 13 insertions(+), 14 deletions(-)
> =


Patch 1,2 applied, thanks.

Regards,
-Denis

--===============4047984483764572227==--

