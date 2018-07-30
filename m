Content-Type: multipart/mixed; boundary="===============6738231353421329614=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/3] build: Fix up sanitizer library detection
Date: Mon, 30 Jul 2018 09:11:16 -0500
Message-ID: <9d9e64af-92fa-aa36-8728-b044285edbe3@gmail.com>
In-Reply-To: <20180727212752.20497-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6738231353421329614==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 07/27/2018 04:27 PM, Mat Martineau wrote:
> The exported symbol names in libasan/liblsan/libubsan have changed over
> time, which broke library detection. We really only care if the
> sanitizer libraries are present, but the configure scripts require a
> symbol name.  '_init' is present in new and old sanitizer libraries.
> ---
>   configure.ac | 12 ++++++------
>   1 file changed, 6 insertions(+), 6 deletions(-)

All applied, thanks.

Regards,
-Denis


--===============6738231353421329614==--

