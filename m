Content-Type: multipart/mixed; boundary="===============7927615111900071045=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 2/5] gvariant: Allow empty signature in
 enter_struct_dict_common
Date: Mon, 25 Apr 2016 23:01:14 -0500
Message-ID: <571EE80A.2040105@gmail.com>
In-Reply-To: <1461373807-19793-3-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7927615111900071045==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 04/22/2016 08:10 PM, Andrew Zaborowski wrote:
> gvariant_iter_init_internal now checks if the signature is empty before
> calling _gvariant_num_children which would return an error in that case.
> The gvariant_iter_init_internal caller is responsible for checking if
> the signature is allowed in the specific context.
> ---
>   ell/gvariant-util.c | 16 +++++++++++-----
>   1 file changed, 11 insertions(+), 5 deletions(-)
>

I went ahead an applied this one. But one question, what is the =

practical utility of allowing iterators into the empty struct?

Regards,
-Denis

--===============7927615111900071045==--

