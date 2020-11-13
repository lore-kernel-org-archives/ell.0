Content-Type: multipart/mixed; boundary="===============3095213184599183797=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] Check for NULL on output function pointer
Date: Fri, 13 Nov 2020 11:59:24 -0600
Message-ID: <70e26e11-3660-fc03-2563-320f7b290c4d@gmail.com>
In-Reply-To: <CAEXMXLRbHRt95-=yGeUx=v7Weo3wcHVEkd4fQW4t1NJtmkXYXg@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3095213184599183797==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Nuno,

On 11/9/20 4:05 AM, Nuno Gon=C3=A7alves wrote:
> While l_util_hexdump, l_util_hexdump_two and l_util_debug check
> for a eventual NULL function pointer, l_util_hexdumpv did not.
> =

> Add the same check to l_util_hexdumpv to make the interface uniform.
> =

> Signed-off-by: Nuno Goncalves <nunojpg@gmail.com>

No S-o-b lines please, we do not use these.  I took this out when applying.

> ---
>   ell/util.c | 3 +++
>   1 file changed, 3 insertions(+)

Just FYI, your patch came through with tabs replaced by spaces, which made =
it =

not apply.  This was easy to fix by hand for this small patch, but please c=
heck =

your settings next time...

Applied, thanks.

Regards,
-Denis
--===============3095213184599183797==--

