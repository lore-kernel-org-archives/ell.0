Content-Type: multipart/mixed; boundary="===============8437231221460943893=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/4] autotools: Only used -Wcast-align with gcc
Date: Wed, 14 Dec 2016 23:21:13 -0600
Message-ID: <3a09ba78-a483-fb2d-9b01-0d0f7162c57b@gmail.com>
In-Reply-To: <20161214225121.9439-2-ell@ongy.net>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8437231221460943893==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Markus,

On 12/14/2016 04:51 PM, ell(a)ongy.net wrote:
> From: Markus Ongyerth <ongy@ongy.net>
>
> clang can currently not compile NLMSG_NEXT with -Wcast-align.
> I asked about this in #llvm on irc.oftc.net, where I was told the best
> solution is to disable -Wcast-align for now.
> ---
>  acinclude.m4 | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)

All four applied. Thanks!

Regards,
-Denis

--===============8437231221460943893==--

