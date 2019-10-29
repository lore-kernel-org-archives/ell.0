Content-Type: multipart/mixed; boundary="===============1677729925758518434=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/5] tls: Fix tls12_prf buffer size
Date: Mon, 28 Oct 2019 21:09:03 -0500
Message-ID: <3afc8e13-75a9-39e9-e600-f3b894136f1c@gmail.com>
In-Reply-To: <20191029002443.23574-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1677729925758518434==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 10/28/19 7:24 PM, Andrew Zaborowski wrote:
> Enlarge the A(i) buffer to be able to hold the biggest possible hash
> result (64) + the label + the biggest possible seed (64).  As reported
> by Will Dietz the buffer size issue could cause crashes with the bigger
> hashes when built under clang.
> =

> Reported-by: Will Dietz <w@wdtz.org>
> ---
>   ell/tls.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> =


All applied, thanks.

Regards,
-Denis

--===============1677729925758518434==--

