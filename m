Content-Type: multipart/mixed; boundary="===============8127141988804820526=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] settings: clear copies of values in set_value
Date: Tue, 07 Apr 2020 15:58:52 +0000
Message-ID: <0f1bb40b-813c-8dc4-2e11-8519b0ac1d42@gmail.com>
In-Reply-To: <20200403164410.18943-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8127141988804820526==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 4/3/20 11:44 AM, Andrew Zaborowski wrote:
> We bzero the setting values before they're free elsewhere in the file
> but not in set_value, and we do use it in iwd to set a PIN.
> ---
>   ell/settings.c | 14 ++++++++------
>   1 file changed, 8 insertions(+), 6 deletions(-)
> =


Applied, thanks.

Regards,
-Denis
--===============8127141988804820526==--

