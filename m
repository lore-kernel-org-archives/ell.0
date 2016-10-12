Content-Type: multipart/mixed; boundary="===============4857953768272535161=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] key: return proper value and avoid leak
Date: Wed, 12 Oct 2016 10:46:30 -0500
Message-ID: <57FE5AD6.1070609@gmail.com>
In-Reply-To: <20161011213804.25873-1-phomes@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4857953768272535161==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Thomas,

On 10/11/2016 04:38 PM, Thomas Hindoe Paaboel Andersen wrote:
> The return value was incorrect for bool. The code should also go to
> 'done' to free sig_hash.
> ---
>   ell/key.c | 6 ++++--
>   1 file changed, 4 insertions(+), 2 deletions(-)
>

Applied, thanks.

Regards,
-Denis


--===============4857953768272535161==--

