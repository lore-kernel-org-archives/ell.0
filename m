Content-Type: multipart/mixed; boundary="===============3109223588668299514=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/4] genl: Sanitize incoming family name string
Date: Wed, 27 Sep 2017 20:56:16 -0500
Message-ID: <07e97477-64e1-4f08-051b-8506cafab9da@gmail.com>
In-Reply-To: <20170928002205.17218-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3109223588668299514==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 09/27/2017 07:22 PM, Mat Martineau wrote:
> The null terminated name must fit in a system-defined fixed-size buffer.
> ---
>   ell/genl.c | 3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
> =


All four applied, thanks.

Regards,
-Denis


--===============3109223588668299514==--

