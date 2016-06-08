Content-Type: multipart/mixed; boundary="===============2803010424165987183=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/3] main: Manually initialize and clean up the main loop
Date: Wed, 08 Jun 2016 08:49:36 -0500
Message-ID: <57582270.3020409@gmail.com>
In-Reply-To: <20160607223015.26693-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2803010424165987183==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 06/07/2016 05:30 PM, Mat Martineau wrote:
> Automatic initialization and cleanup of the main loop created some
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
>   ell/main.c                   | 81 +++++++++++++++++++++++++++----------=
-------
>   ell/main.h                   |  4 ++-
>   examples/dbus-client.c       |  5 +++
>   examples/dbus-service.c      |  5 +++
>   examples/https-client-test.c |  5 +++
>   examples/https-server-test.c |  5 +++
>   unit/test-dbus-message-fds.c |  5 +++
>   unit/test-dbus-properties.c  |  5 +++
>   unit/test-dbus.c             |  5 +++
>   unit/test-genl.c             |  5 +++
>   unit/test-io.c               |  5 +++
>   unit/test-kdbus.c            |  5 +++
>   unit/test-main.c             |  5 +++
>   unit/test-netlink.c          |  5 +++

Can you do me a favor and split these into three patches, according to =

HACKING 'Submitting Patches'.

>   14 files changed, 113 insertions(+), 32 deletions(-)
>
> diff --git a/ell/main.c b/ell/main.c
> index f53ed9e..b4c1582 100644
> --- a/ell/main.c
> +++ b/ell/main.c
> @@ -86,9 +86,6 @@ static inline bool __attribute__ ((always_inline)) crea=
te_epoll(void)
>   {
>   	unsigned int i;
>
> -	if (likely(epoll_fd))
> -		return true;
> -
>   	epoll_fd =3D epoll_create1(EPOLL_CLOEXEC);
>   	if (epoll_fd < 0) {
>   		epoll_fd =3D 0;
> @@ -127,7 +124,7 @@ int watch_add(int fd, uint32_t events, watch_event_cb=
_t callback,
>   	if (unlikely(fd < 0 || !callback))
>   		return -EINVAL;
>
> -	if (!create_epoll())
> +	if (!epoll_fd)
>   		return -EIO;
>
>   	if ((unsigned int) fd > watch_entries - 1)
> @@ -260,7 +257,7 @@ int idle_add(idle_event_cb_t callback, void *user_dat=
a,
>   	if (unlikely(!callback))
>   		return -EINVAL;
>
> -	if (!create_epoll())
> +	if (!epoll_fd)
>   		return -EIO;
>
>   	data =3D l_new(struct idle_data, 1);
> @@ -313,25 +310,45 @@ static void idle_dispatch(void *data, void *user_da=
ta)
>   }
>
>   /**
> + * l_main_init:
> + *
> + * Initialize the main loop. This must be called before l_main_run()
> + * and any other function that directly or indirectly sets up an idle
> + * or watch. A safe rule-of-thumb is to call it before any function
> + * prefixed with "l_".
> + *
> + * Returns: true if initialization was successful, false otherwise.
> + **/
> +LIB_EXPORT bool l_main_init(void)
> +{
> +	if (unlikely(epoll_running))
> +		return false;
> +
> +	if (!create_epoll())
> +		return false;
> +
> +	epoll_terminate =3D false;
> +
> +	return true;
> +}
> +
> +/**
>    * l_main_run:
>    *
>    * Run the main loop

Should we mention that the main loop can be restarted?

e.g.
l_main_run
l_main_quit
l_main_run

is possible?

>    *
> - * Returns: #EXIT_SCUCESS after successful execution or #EXIT_FAILURE in
> + * Returns: #EXIT_SUCCESS after successful execution or #EXIT_FAILURE in
>    *          case of failure
>    **/
>   LIB_EXPORT int l_main_run(void)
>   {
> -	unsigned int i;
> -
> -	if (unlikely(epoll_running))
> +	/* Has l_main_init() been called? */
> +	if (unlikely(!epoll_fd))
>   		return EXIT_FAILURE;
>
> -	if (!create_epoll())
> +	if (unlikely(epoll_running))
>   		return EXIT_FAILURE;
>
> -	epoll_terminate =3D false;
> -
>   	epoll_running =3D true;
>
>   	for (;;) {
> @@ -375,6 +392,26 @@ LIB_EXPORT int l_main_run(void)
>   		l_queue_foreach_remove(idle_list, idle_prune, NULL);
>   	}
>
> +	epoll_running =3D false;
> +
> +	return exit_status;

Do we still need this global exit_status variable?  Or should we always =

just return 0 here?

> +}
> +
> +/**
> + * l_main_exit:
> + *
> + * Clean up after main loop completes.
> + *
> + **/
> +LIB_EXPORT bool l_main_exit(void)
> +{
> +	unsigned int i;
> +
> +	if (epoll_running) {
> +		l_error("Cleanup attempted on running main loop");
> +		return false;
> +	}
> +
>   	for (i =3D 0; i < watch_entries; i++) {
>   		struct watch_data *data =3D watch_list[i];
>
> @@ -399,12 +436,10 @@ LIB_EXPORT int l_main_run(void)
>   	l_queue_destroy(idle_list, idle_destroy);
>   	idle_list =3D NULL;
>
> -	epoll_running =3D false;
> -
>   	close(epoll_fd);
>   	epoll_fd =3D 0;
>
> -	return exit_status;
> +	return true;
>   }
>
>   /**
> @@ -472,19 +507,3 @@ int l_main_run_with_signal(l_main_signal_cb_t callba=
ck, void *user_data)
>
>   	return result;
>   }
> -
> -/**
> - * l_main_exit:
> - *
> - * Teminate the running main loop with exit status
> - *
> - **/
> -LIB_EXPORT
> -void l_main_exit(int status)
> -{
> -	if (unlikely(!epoll_running))
> -		return;
> -
> -	exit_status =3D status;
> -	epoll_terminate =3D true;
> -}
> diff --git a/ell/main.h b/ell/main.h
> index 46d2a13..c23ec55 100644
> --- a/ell/main.h
> +++ b/ell/main.h
> @@ -29,13 +29,15 @@
>   extern "C" {
>   #endif
>
> +bool l_main_init(void);
>   int l_main_run(void);
> +bool l_main_exit(void);
> +

I wonder if returning bool here is useful since you never check the =

return value in any of the actual files that use this.

>   bool l_main_quit(void);
>
>   typedef void (*l_main_signal_cb_t) (uint32_t signo, void *user_data);
>
>   int l_main_run_with_signal(l_main_signal_cb_t callback, void *user_data=
);
> -void l_main_exit(int status);
>
>   #ifdef __cplusplus
>   }

Regards,
-Denis

--===============2803010424165987183==--

