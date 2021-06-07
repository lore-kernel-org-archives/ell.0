Content-Type: multipart/mixed; boundary="===============8738635217700989596=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] dhcp-server: Fix lease expiry time calculation
Date: Mon, 07 Jun 2021 13:21:24 -0500
Message-ID: <8ba6390a-a665-c742-0536-3a540513b95a@gmail.com>
In-Reply-To: <20210604221907.202641-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8738635217700989596==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 6/4/21 5:19 PM, Andrew Zaborowski wrote:
> We were comparing the l_time_now() (usecs) to lease->lifetime (secs)
> and then converting the result from usecs to secs, so the "diff" and the
> "to_secs" operations need to be switched around.  While there, use the
> opportunity to replace the "diff" operation so that if lease->lifetime is
> already in the past (e.g. because processing took to long), we schedule
> the timeout in 1 millisec instead of the absolute value of the difference.
> ---
>   ell/dhcp-server.c | 24 ++++++++++++++----------
>   1 file changed, 14 insertions(+), 10 deletions(-)
> =


Both applied, thanks.

Regards,
-Denis

--===============8738635217700989596==--

