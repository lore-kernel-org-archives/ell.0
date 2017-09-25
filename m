Content-Type: multipart/mixed; boundary="===============4222801900274562589=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/4] asn1: Call va_end() before every return
Date: Mon, 25 Sep 2017 09:56:39 -0500
Message-ID: <dd7ccf2a-40a5-4471-6778-81f6fee5e7ec@gmail.com>
In-Reply-To: <20170922221244.12670-2-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4222801900274562589==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 09/22/2017 05:12 PM, Mat Martineau wrote:
> One call to va_end() was missing on an error path.
> ---
>   ell/asn1-private.h | 4 +++-
>   1 file changed, 3 insertions(+), 1 deletion(-)
> =


Applied, thanks.

Regards,
-Denis


--===============4222801900274562589==--

