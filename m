Content-Type: multipart/mixed; boundary="===============8064554214176541004=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 3/5] dbus-client: Only include required ELL headers.
Date: Mon, 29 Oct 2018 15:44:00 -0500
Message-ID: <0c511672-3d03-19c2-79a6-75312a73791d@gmail.com>
In-Reply-To: <20181029200715.28427-4-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8064554214176541004==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ossama,

On 10/29/2018 03:07 PM, Ossama Othman wrote:
> Reduce dependencies in ell/dbus-client.c by only including the ELL
> headers it requires rather than the <ell/ell.h> convenience header.
> This also limits build side effects caused by enabling or disabling
> C library features through C standard related compiler flags
> (e.g. -std=3Dc99).
> ---
>   ell/dbus-client.c | 4 +++-
>   1 file changed, 3 insertions(+), 1 deletion(-)
> =


Applied, thanks.

Regards,
-Denis


--===============8064554214176541004==--

