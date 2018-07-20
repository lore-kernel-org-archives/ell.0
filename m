Content-Type: multipart/mixed; boundary="===============3780713645115655551=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/3] Move TEMP_FAILURE_RETRY outside dbus.h
Date: Fri, 20 Jul 2018 12:17:27 -0500
Message-ID: <da0a95aa-054b-2d0f-7454-848bd801d730@gmail.com>
In-Reply-To: <20180720164951.9338-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3780713645115655551==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 07/20/2018 11:49 AM, Andrew Zaborowski wrote:
> Make this macro available for the rest of ell in private.h and on the
> other hand remove from public header as it doesn't start with "L_".
> Note that IWD does optionally use it in rfkill.c and storage.c.
> ---
>   ell/dbus.h    | 10 ----------
>   ell/private.h | 11 +++++++++++
>   2 files changed, 11 insertions(+), 10 deletions(-)
> =


Applied, thanks.

Regards,
-Denis


--===============3780713645115655551==--

