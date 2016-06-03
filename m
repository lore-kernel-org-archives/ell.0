Content-Type: multipart/mixed; boundary="===============2845183126400131105=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: ell/main.c Memory leak
Date: Fri, 03 Jun 2016 16:17:47 -0700
Message-ID: <alpine.OSX.2.20.1606031529580.37295@mjmartin-mac01.local>
In-Reply-To: <575203DD.5040909@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2845183126400131105==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Fri, 3 Jun 2016, Denis Kenzior wrote:

> Hi Mat,
>
>>
>> Maybe this is more of an iwd architecture problem than an ELL problem?
>> The cleanup code runs after l_main_run() returns, and that code should
>> not do anything that creates an idle or watch because those handlers
>> will never get called. The event loop is already gone.
>> =

>> The cleanup should be done before the main loop exits. Instead of
>> calling l_main_quit to kill the daemon, create an iwd_quit function that
>> will run all the teardown code first. Once teardown is complete, then
>> call l_main_quit.
>
> I've thought of this, but I wasn't really happy doing it that way.  The =

> sequence of events would also be quite different from our GLib based =

> projects.  If we want to make those projects easy to port to ell, this is=
 not =

> what we want.

Seems like glib projects would have the same kind of problem, unless there =

are some restrictions on what happens in the cleanup code.

>
> However, there's another problem.
>
> Various epoll sources can be created before the main event loop is starte=
d. =

> So if we init things, but fail prior to calling l_main_run for whatever =

> reason, then again, epoll resources are not cleaned up.

True, I didn't consider that.

>
>> =

>> The associated problem is how to give better feedback to all users of
>> ELL, so it's obvious when they're doing something they shouldn't.
>> Changing where create_epoll is called could be a big help here. Rather
>> than doing it automatically in watch_add, idle_add, and l_main_run, we
>> could add an explicit l_main_init() function that must be called before
>> l_main_run and any ELL functions that expect epoll_fd to exist.
>> watch_add and idle_add would return errors if epoll_fd was 0. Yes, this
>> is a lot like l_main_new/run/destroy, but calling it "init" doesn't
>> create the impression that you can have multiple main loops.
>
> Which is fine, but then we might as well add l_main_exit().

Sure, I'm sold on needing something to clean up. Note that l_main_exit is =

already taken.

>
> But if we add those two, how far away are we from supporting multiple eve=
nt =

> loops?

This keeps coming up. :)  Even if it's a rhetortical question, it's fun to =

ponder.

Bundling up a bunch of globals in to an l_main struct is simple enough, =

but every idle and watch-based abstraction (timeouts, signals, ios, ...) =

would need to be told which event loop to use. I'm currently in the =

keep-it-simple camp on this one, but the right use case could always =

justify the feature.

--
Mat Martineau
Intel OTC

--===============2845183126400131105==--

