Content-Type: multipart/mixed; boundary="===============1625073760237862120=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 2/3] signal: Propagate watch_add errors in l_signal_create
Date: Wed, 08 Jun 2016 08:53:24 -0500
Message-ID: <57582354.8090706@gmail.com>
In-Reply-To: <20160607223015.26693-2-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1625073760237862120==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 06/07/2016 05:30 PM, Mat Martineau wrote:
> l_signal_create now fails cleanly and returns NULL if watch_add fails.
> ---
>   ell/signal.c | 20 +++++++++++++-------
>   1 file changed, 13 insertions(+), 7 deletions(-)
>

Applied after tweaking the commit header.

Regards,
-Denis

--===============1625073760237862120==--

