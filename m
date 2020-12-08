Content-Type: multipart/mixed; boundary="===============1494511750210489330=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: Re: [PATCH 7/7] examples: add acd client implementation [async
 safety in example signal handler?]
Date: Tue, 08 Dec 2020 09:16:31 -0800
Message-ID: <b6fdd57c205e529686f5587c3704258191effc72.camel@gmail.com>
In-Reply-To: <A317175E-272D-4E27-A2D8-19847ED89805@bluewin.ch>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1494511750210489330==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Phil,

On Sun, 2020-12-06 at 23:06 +0100, Phil wrote:
> Hope you are not calling any functions that are not "async-safe" in
> that signal handler.
> =

> Looks like l_main_quit just sets a flag so is probably ok, but what
> is to stop l_info interrupting another log call?

I went ahead and CC'd the list so everyone can see it.

Thats a good point. What is unclear to me is if the actual signal
handler call is from an interrupt or not. Looks like the l_signal APIs
use an IO read handler and are a bit more complex than e.g. calling the
POSIX signal().

Not that it makes it 'ok' but every single example/tool, even IWD,
prints from the signal handler. If this is an issue we certainly would
want to remove those prints.

Does anyone else know the details of this? Are signal handlers
registered from l_main_run_with_signal printf safe?

Thanks,
James



--===============1494511750210489330==--

