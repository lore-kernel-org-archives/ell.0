Content-Type: multipart/mixed; boundary="===============8520698968617254254=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/3] pem: Fix a bad l_free
Date: Thu, 10 Jan 2019 16:30:44 -0600
Message-ID: <e9c04384-cd5e-98bc-ea0f-5aad7da73a9b@gmail.com>
In-Reply-To: <20190110222537.14492-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8520698968617254254==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 01/10/2019 04:25 PM, Andrew Zaborowski wrote:
> On error pem_load_buffer will not set @label so it may end up being
> uninitialized when we l_free it.  pem_load_buffer may also fail under
> normal circumstances at the end of file, make sure we only l_free(label)
> if the call succeeded.
> ---
>   ell/pem.c | 3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)

All applied, thanks.

Regards,
-Denis

--===============8520698968617254254==--

