Content-Type: multipart/mixed; boundary="===============2882762777416586073=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2 1/3] main: Manually initialize and clean up the main
 loop
Date: Thu, 09 Jun 2016 10:12:00 -0500
Message-ID: <57598740.5000900@gmail.com>
In-Reply-To: <20160608215538.5590-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2882762777416586073==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 06/08/2016 04:55 PM, Mat Martineau wrote:
> Atomatic initialization and cleanup of the main loop created some
> issues with orderly shutdown of an ELL program. If cleanup functions
> were called after the l_main_run() returned, they could indirectly set
> up the epoll file descriptor and associated resources again. Those
> resources were not freed after the cleanup functions ran.
>
> Now, epoll resources are set up by l_main_init() and cleaned up by
> l_main_exit(). If cleanup functions set up any idles or watches
> (including watch-based timeouts, signals, or ios) after l_main_run()
> returns, those will be destroyed by l_main_exit().
>
> l_main_init() must be called before l_main_run() or any other ELL
> function that expects epoll to be set up. l_main_exit() should be
> called after l_main_run() returns to ensure that all resources are
> freed.
> ---
>   ell/main.c | 87 ++++++++++++++++++++++++++++++++++++++-----------------=
-------
>   ell/main.h |  4 ++-
>   2 files changed, 57 insertions(+), 34 deletions(-)
>

All three applied, thanks.

Regards,
-Denis


--===============2882762777416586073==--

