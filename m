Content-Type: multipart/mixed; boundary="===============9101502715169722991=="
MIME-Version: 1.0
From: Phil <philip.hodges@bluewin.ch>
Subject: Re: [PATCH 7/7] examples: add acd client implementation [async safety
 in example signal handler?]
Date: Tue, 08 Dec 2020 20:22:58 +0100
Message-ID: <BDF1E310-F560-4B59-BF0D-6B6307E8B911@bluewin.ch>
In-Reply-To: <b6fdd57c205e529686f5587c3704258191effc72.camel@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9101502715169722991==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

If it is indeed just a callback from polling signalfd and not an asynchrono=
us signal handler then it should be fine.

It might help avoid false alarms if it were named accordingly, with a brief=
 comment to explain that the callback uses signalfd so that it does not nee=
d to be async-safe.

It's always good to draw attention to async-safety. Someone could be readin=
g about it for the first time, and it will suddenly dawn on them why their =
production application sometimes crashes on a termination signal.

> On 8 Dec 2020, at 18:16, James Prestwood <prestwoj@gmail.com> wrote:
> =

> Hi Phil,
> =

> On Sun, 2020-12-06 at 23:06 +0100, Phil wrote:
>> Hope you are not calling any functions that are not "async-safe" in
>> that signal handler.
>> =

>> Looks like l_main_quit just sets a flag so is probably ok, but what
>> is to stop l_info interrupting another log call?
> =

> I went ahead and CC'd the list so everyone can see it.
> =

> Thats a good point. What is unclear to me is if the actual signal
> handler call is from an interrupt or not. Looks like the l_signal APIs
> use an IO read handler and are a bit more complex than e.g. calling the
> POSIX signal().
> =

> Not that it makes it 'ok' but every single example/tool, even IWD,
> prints from the signal handler. If this is an issue we certainly would
> want to remove those prints.
> =

> Does anyone else know the details of this? Are signal handlers
> registered from l_main_run_with_signal printf safe?
> =

> Thanks,
> James
> =

> =

> _______________________________________________
> ell mailing list -- ell(a)lists.01.org
> To unsubscribe send an email to ell-leave(a)lists.01.org

--===============9101502715169722991==--

