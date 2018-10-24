Content-Type: multipart/mixed; boundary="===============5515816972281709267=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] log: Use __func__ for function name
Date: Wed, 24 Oct 2018 14:24:39 -0500
Message-ID: <6deeafc7-2462-7e9e-7820-c46d8f9c160a@gmail.com>
In-Reply-To: <20181023233459.18708-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5515816972281709267==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 10/23/2018 06:34 PM, Mat Martineau wrote:
> __FUNCTION__ and __PRETTY_FUNCTION__ are older gcc aliases for
> __func__. Switch to use __func__ in L_DEBUG_SYMBOL(), like l_log()
> already does. This resolves some compiler warnings in ELL headers when a
> program is built with compiler flags that are more strict than the
> maintainer-mode build.
> ---
>   ell/log.h | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
> =


Both applied, thanks.

Regards,
-Denis


--===============5515816972281709267==--

