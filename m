Content-Type: multipart/mixed; boundary="===============8985307655675130713=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] gvariant: Reset container's variable_is_last for
 fixed-size structs.
Date: Mon, 21 Mar 2016 13:05:26 -0500
Message-ID: <56F037E6.4050203@gmail.com>
In-Reply-To: <1458367247-14607-6-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8985307655675130713==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 03/19/2016 01:00 AM, Andrew Zaborowski wrote:
> We reset container->variable_is_last after basic fixed-size types but
> not after structs and dicts.  This would probably produce incorrect
> results for fixed-size structs that are the last element in a
> variable-size struct, e.g. (s(u))
> ---
>   ell/gvariant-util.c | 2 ++
>   1 file changed, 2 insertions(+)

I think you are correct on this one.  Can we add a quickie test for this?

I went ahead and applied the patch.

Regards,
-Denis

--===============8985307655675130713==--

