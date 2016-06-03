Content-Type: multipart/mixed; boundary="===============4184528308063305466=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: ell/main.c Memory leak
Date: Fri, 03 Jun 2016 17:25:33 -0500
Message-ID: <575203DD.5040909@gmail.com>
In-Reply-To: <alpine.OSX.2.20.1606031419360.37295@mjmartin-mac01.local>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4184528308063305466==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

 >
> Maybe this is more of an iwd architecture problem than an ELL problem?
> The cleanup code runs after l_main_run() returns, and that code should
> not do anything that creates an idle or watch because those handlers
> will never get called. The event loop is already gone.
>
> The cleanup should be done before the main loop exits. Instead of
> calling l_main_quit to kill the daemon, create an iwd_quit function that
> will run all the teardown code first. Once teardown is complete, then
> call l_main_quit.

I've thought of this, but I wasn't really happy doing it that way.  The =

sequence of events would also be quite different from our GLib based =

projects.  If we want to make those projects easy to port to ell, this =

is not what we want.

However, there's another problem.

Various epoll sources can be created before the main event loop is =

started.  So if we init things, but fail prior to calling l_main_run for =

whatever reason, then again, epoll resources are not cleaned up.

>
> The associated problem is how to give better feedback to all users of
> ELL, so it's obvious when they're doing something they shouldn't.
> Changing where create_epoll is called could be a big help here. Rather
> than doing it automatically in watch_add, idle_add, and l_main_run, we
> could add an explicit l_main_init() function that must be called before
> l_main_run and any ELL functions that expect epoll_fd to exist.
> watch_add and idle_add would return errors if epoll_fd was 0. Yes, this
> is a lot like l_main_new/run/destroy, but calling it "init" doesn't
> create the impression that you can have multiple main loops.

Which is fine, but then we might as well add l_main_exit().

But if we add those two, how far away are we from supporting multiple =

event loops?

Regards,
-Denis

--===============4184528308063305466==--

