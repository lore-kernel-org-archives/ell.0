Content-Type: multipart/mixed; boundary="===============8973239164636947981=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] unit: test-ecdh: add bytes to l_getrandom wrapper
Date: Fri, 11 Jan 2019 11:37:35 -0600
Message-ID: <27bdaf5b-38c4-9b98-e715-6862da0c8f3a@gmail.com>
In-Reply-To: <20190111173859.13407-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8973239164636947981==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 01/11/2019 11:38 AM, James Prestwood wrote:
> This should have been put into the commit adding the P384 unit test.
> Since P384 works with 48 byte integers we need 48 bytes of randomness
> in the l_getrandom wrapper. A check was also added so l_getrandom will
> fail if too many bytes are requested (e.g. if a larger curve is added).
> ---
>   unit/test-ecdh.c | 20 +++++++++++++-------
>   1 file changed, 13 insertions(+), 7 deletions(-)
> =


Applied, thanks.

Regards,
-Denis


--===============8973239164636947981==--

