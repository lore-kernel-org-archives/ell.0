Content-Type: multipart/mixed; boundary="===============6107749549910557616=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: ell/main.c Memory leak
Date: Fri, 03 Jun 2016 18:56:04 -0500
Message-ID: <57521914.7040804@gmail.com>
In-Reply-To: <alpine.OSX.2.20.1606031529580.37295@mjmartin-mac01.local>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6107749549910557616==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 06/03/2016 06:17 PM, Mat Martineau wrote:
> On Fri, 3 Jun 2016, Denis Kenzior wrote:
>
>> Hi Mat,
>>
>>>
>>> Maybe this is more of an iwd architecture problem than an ELL problem?
>>> The cleanup code runs after l_main_run() returns, and that code should
>>> not do anything that creates an idle or watch because those handlers
>>> will never get called. The event loop is already gone.
>>>
>>> The cleanup should be done before the main loop exits. Instead of
>>> calling l_main_quit to kill the daemon, create an iwd_quit function that
>>> will run all the teardown code first. Once teardown is complete, then
>>> call l_main_quit.
>>
>> I've thought of this, but I wasn't really happy doing it that way.
>> The sequence of events would also be quite different from our GLib
>> based projects.  If we want to make those projects easy to port to
>> ell, this is not what we want.
>
> Seems like glib projects would have the same kind of problem, unless
> there are some restrictions on what happens in the cleanup code.
>

I don't recall ever having such issues.  I think glib allows loops to be =

restarted after main_loop_quit.  We could as well.

>
> Sure, I'm sold on needing something to clean up. Note that l_main_exit
> is already taken.

Which no one uses, so we can hi-jack that one.

>
>>
>> But if we add those two, how far away are we from supporting multiple
>> event loops?
>
> This keeps coming up. :)  Even if it's a rhetortical question, it's fun
> to ponder.
>
> Bundling up a bunch of globals in to an l_main struct is simple enough,
> but every idle and watch-based abstraction (timeouts, signals, ios, ...)
> would need to be told which event loop to use. I'm currently in the
> keep-it-simple camp on this one, but the right use case could always
> justify the feature.
>

Yes, but all of this can be hidden away from the API level.  First main =

event loop that is created becomes the default.  Then subsequent calls =

to l_idle_add, etc will always use the default main event loop.

If someone *actually* wants to use multiple event loops in the future, =

we can add API extensions to handle that.

Regards,
-Denis

--===============6107749549910557616==--

