Content-Type: multipart/mixed; boundary="===============5164678958951003064=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v3 3/5] main: Safely free watch_data structures
Date: Thu, 17 Mar 2016 13:35:57 -0500
Message-ID: <56EAF90D.1090805@gmail.com>
In-Reply-To: <1458238542-11711-3-git-send-email-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5164678958951003064==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 03/17/2016 01:15 PM, Mat Martineau wrote:
> The race condition test in test-main exposed a case where the events
> array returned by epoll_wait could have a stale watch_data
> pointer. This triggered a use-after-free error that was reported by
> the address sanitizer (./configure --enable-asan).
>
> When the event loop is running, watch_data structures with events
> being dispatched are flagged. If watch_remove is called on a flagged
> structure, the l_free() is deferred until after all events are
> dispatched and the callback for that event is skipped.
> ---
>   ell/main.c | 31 +++++++++++++++++++++++++++++--
>   1 file changed, 29 insertions(+), 2 deletions(-)
>

Patches 3-5 applied.  Thanks.

Regards,
-Denis


--===============5164678958951003064==--

