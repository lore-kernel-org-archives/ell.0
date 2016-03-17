Content-Type: multipart/mixed; boundary="===============0884401296441728197=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v4 2/5] unit: Add race condition test to test-main
Date: Thu, 17 Mar 2016 13:35:29 -0500
Message-ID: <56EAF8F1.50507@gmail.com>
In-Reply-To: <1458238766-13264-1-git-send-email-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0884401296441728197==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 03/17/2016 01:19 PM, Mat Martineau wrote:
> This test exercises the case where multiple events are returned from
> the same epoll_wait call and an early event deletes a watch that is
> waiting to be processed in the same event loop iteration.
> ---
>   unit/test-main.c | 37 +++++++++++++++++++++++++++++++++----
>   1 file changed, 33 insertions(+), 4 deletions(-)

Applied, thanks.

Regards,
-Denis


--===============0884401296441728197==--

