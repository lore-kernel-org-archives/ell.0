Content-Type: multipart/mixed; boundary="===============2032677108527498509=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] path: Fix an integer overflow in l_path_get_mtime
Date: Mon, 02 Mar 2020 11:16:52 -0600
Message-ID: <246c5979-e943-e967-48e7-72b42c4cb857@gmail.com>
In-Reply-To: <20200302151011.2125-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2032677108527498509==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 3/2/20 9:10 AM, Andrew Zaborowski wrote:
> time_t may be 32 bits wide (also signed) so we need to cast
> timespec.tv_sec to uint64_t before multiplying by 1000000.
> ---
>   ell/path.c | 3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
> =


Applied, thanks.

Regards,
-Denis

--===============2032677108527498509==--

