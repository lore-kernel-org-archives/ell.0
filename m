Content-Type: multipart/mixed; boundary="===============0666447787102126096=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] genl: Fix size calculation in msg_grow
Date: Tue, 22 Oct 2019 09:37:12 -0500
Message-ID: <348aad63-f009-6f20-e26c-17569a234ace@gmail.com>
In-Reply-To: <20191022143409.21089-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0666447787102126096==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 10/22/19 9:34 AM, Andrew Zaborowski wrote:
> "msg->size - needed" was the opposite of the value we actually need and
> could end up being negative if we were appending an attribute larger
> than the current message size.
> ---
>   ell/genl.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> =


applied, thanks.

Regards,
-Denis

--===============0666447787102126096==--

