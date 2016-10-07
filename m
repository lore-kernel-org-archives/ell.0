Content-Type: multipart/mixed; boundary="===============4898108541420779489=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: ELL API changes before stabilizing
Date: Fri, 07 Oct 2016 11:42:29 -0700
Message-ID: <alpine.OSX.2.20.1610071105410.45755@mjmartin-mac01.local>
In-Reply-To: <6CF04B0E-DD61-41AA-ACAB-A1DF3EA41A30@holtmann.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4898108541420779489==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


On Thu, 6 Oct 2016, Marcel Holtmann wrote:

> we actually wanted the timerfd API to expose also range timers. In the =

> kernel it is possible to specify a range and then the kernel will =

> coalesce the wakeup time. That is what we really want. One that =

> coalesces for us and another that is precise. The seconds vs nanoseconds =

> is most likely not a good representation of that and we should just =

> switch to using milliseconds, but as range timeout and one as precise =

> timeout.

Denis makes the case that multiple constructors aren't so bad, and coarse =

(1 sec resolution) timeouts seem to be a common enough need.

timerfd needs some work to use the underlying hrtimer range capabilities. =

One approach is to add a TFD_SLACK flag that would make that timer use the =

per-thread slack value set by prctl(PR_SET_TIMERSLACK, ...). That only =

gives us one precise timer pool and one slack timer pool, though.

> I am also not convinced that creating a timerfd for each struct is a =

> good idea. It might be better to share timerfd and update timeout =

> wakeups.

It would make sense to consume an fd only for the next timer to expire. We =

would probably switch to using TFD_TIMER_ABSTIME instead of relative time =

values in timerfd_settime to prevent the later timers from drifting, which =

would require additional clock_gettime() syscalls. Another benefit would =

be the opportunity to handle some coalescing in ELL.

--
Mat Martineau
Intel OTC

--===============4898108541420779489==--

