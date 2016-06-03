Content-Type: multipart/mixed; boundary="===============0822526501563344329=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: ell/main.c Memory leak
Date: Fri, 03 Jun 2016 15:08:30 -0700
Message-ID: <alpine.OSX.2.20.1606031419360.37295@mjmartin-mac01.local>
In-Reply-To: <5751F223.6070901@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0822526501563344329==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Fri, 3 Jun 2016, Denis Kenzior wrote:

> This leak happens in create_epoll(). The sequence of events is a bit biza=
rre:
>
> 1. We send an invalid signal
> 2. DBus detects that and kills our connection
> 3. l_main_quit is called, which frees all main event loop resources
> 4. We start tearing down the rest of the daemon
> 	a) At some point we unregister some interfaces
> 	b) ObjectManager schedules the transmission of a signal
> 	c) idle_create gets called, which calls create_epoll()
> 5. DBus is destroyed, which removes the idle source in 4c
>
> Unfortunately at this point, nothing actually frees the resources created=
 by =

> create_epoll().
>
> I'm thinking l_main_run needs to be split up into l_main_new, l_main_run =
and =

> l_main_destroy.

Maybe this is more of an iwd architecture problem than an ELL problem? The =

cleanup code runs after l_main_run() returns, and that code should not do =

anything that creates an idle or watch because those handlers will never =

get called. The event loop is already gone.

The cleanup should be done before the main loop exits. Instead of calling =

l_main_quit to kill the daemon, create an iwd_quit function that will run =

all the teardown code first. Once teardown is complete, then call =

l_main_quit.

The associated problem is how to give better feedback to all users of ELL, =

so it's obvious when they're doing something they shouldn't. Changing =

where create_epoll is called could be a big help here. Rather than doing =

it automatically in watch_add, idle_add, and l_main_run, we could add an =

explicit l_main_init() function that must be called before l_main_run and =

any ELL functions that expect epoll_fd to exist. watch_add and idle_add =

would return errors if epoll_fd was 0. Yes, this is a lot like =

l_main_new/run/destroy, but calling it "init" doesn't create the =

impression that you can have multiple main loops.

--
Mat Martineau
Intel OTC

--===============0822526501563344329==--

