Content-Type: multipart/mixed; boundary="===============6141727447591282083=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] hwdb: Remove unutilized return value
Date: Wed, 03 Aug 2016 17:05:33 -0500
Message-ID: <57A26AAD.9060600@gmail.com>
In-Reply-To: <20160802192120.14887-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6141727447591282083==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 08/02/2016 02:21 PM, Mat Martineau wrote:
> trie_fnmatch always returned 0. Make it return void instead.
> ---
>   ell/hwdb.c | 18 +++++++-----------
>   1 file changed, 7 insertions(+), 11 deletions(-)
>

Both applied, thanks.

Regards,
-Denis


--===============6141727447591282083==--

