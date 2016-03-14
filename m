Content-Type: multipart/mixed; boundary="===============8163090707014658035=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2] dbus: Change type for pointer / integer cast to fix
 32-bit break
Date: Mon, 14 Mar 2016 10:40:03 -0500
Message-ID: <56E6DB53.8030609@gmail.com>
In-Reply-To: <1457968777-16212-1-git-send-email-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8163090707014658035==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 03/14/2016 10:19 AM, Mat Martineau wrote:
> Casting void* to uint64_t on 32-bit x86 causes a build error with gcc
> 5.3.1, so cast to uintptr_t instead.
> ---
>   ell/dbus-kernel.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>

Applied after tweaking the commit description.  Remember item M5 ;)

Regards,
-Denis

--===============8163090707014658035==--

