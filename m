Content-Type: multipart/mixed; boundary="===============3093798432761935129=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] dbus: Call destroy function in l_dbus_remove_watch
Date: Fri, 01 May 2020 16:26:16 +0000
Message-ID: <c4a9b34f-7e09-78de-66a9-f7ebaf16334b@gmail.com>
In-Reply-To: <20200430132340.58244-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3093798432761935129==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 4/30/20 8:23 AM, Andrew Zaborowski wrote:
> l_dbus_remove_watch (_dbus_name_cache_remove_watch) marks name watches
> as removed and schedules a service_watch_remove_all call.  Do the
> watch's destroy callback when marking the watch as removed instead of
> waiting until the service_watch_remove_all idle callback to do this.
> =

> Semantically it may be ok to do the destroy callback later but I think
> it's easier on the user if they can be sure they'll get no more
> callbacks after using l_dbus_remove_watch.
> ---
>   ell/dbus-name-cache.c | 6 ++++++
>   1 file changed, 6 insertions(+)
> =


Both applied, thanks.

Regards,
-Denis

--===============3093798432761935129==--

