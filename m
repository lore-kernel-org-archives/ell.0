Content-Type: multipart/mixed; boundary="===============4577258482539036938=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v3 5/9] gvariant: Fix empty struct encoding
Date: Mon, 18 Apr 2016 14:33:36 -0500
Message-ID: <57153690.3090703@gmail.com>
In-Reply-To: <1460680442-15201-5-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4577258482539036938==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 04/14/2016 07:33 PM, Andrew Zaborowski wrote:
> Empty structs are encoded as a single zero byte.
> ---
>   ell/gvariant-util.c | 4 ++++
>   1 file changed, 4 insertions(+)
>

I went ahead and applied this one.  But can we get a unit test for this?

Regards,
-Denis


--===============4577258482539036938==--

