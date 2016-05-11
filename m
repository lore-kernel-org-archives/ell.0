Content-Type: multipart/mixed; boundary="===============2531093268334515563=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] dbus: Add name_cache argument NULL checks
Date: Wed, 11 May 2016 10:12:00 -0500
Message-ID: <57334BC0.1010100@gmail.com>
In-Reply-To: <1462959370-30764-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2531093268334515563==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 05/11/2016 04:36 AM, Andrew Zaborowski wrote:
> This is so that _dbus_name_cache_free and _dbus_name_cache_notify can be
> called with a null pointer similar to l_free, _dbus_filter_free, etc.
> ---
>   ell/dbus-name-cache.c | 6 ++++++
>   1 file changed, 6 insertions(+)
>

Applied, thanks.

Regards,
-Denis


--===============2531093268334515563==--

