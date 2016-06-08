Content-Type: multipart/mixed; boundary="===============3264229845730065752=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 3/3] timeout: Propagate watch_add errors in
 l_timeout_create functions
Date: Wed, 08 Jun 2016 08:53:45 -0500
Message-ID: <57582369.9070208@gmail.com>
In-Reply-To: <20160607223015.26693-3-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3264229845730065752==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 06/07/2016 05:30 PM, Mat Martineau wrote:
> l_timeout_create functions now free resources and return NULL if
> watch_add fails.
> ---
>   ell/timeout.c | 10 ++++++++--
>   1 file changed, 8 insertions(+), 2 deletions(-)
>

Applied, thanks.

Regards,
-Denis


--===============3264229845730065752==--

