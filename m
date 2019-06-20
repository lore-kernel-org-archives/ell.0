Content-Type: multipart/mixed; boundary="===============2482291543573129507=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] gpio: fix clang -Wpointer-bool-conversion warning
Date: Thu, 20 Jun 2019 16:48:26 -0500
Message-ID: <8bbdda97-30f4-3e58-3493-9fb20f64b348@gmail.com>
In-Reply-To: <20190619203150.8334-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2482291543573129507==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ossama,

On 06/19/2019 03:31 PM, Ossama Othman wrote:
> Remove a check that incorrectly attempted to determine if the "name"
> field of a struct gpioline_info object was NULL.  It relied on a
> pointer-to-bool conversion that didn't work as expected since the
> "name" field is an array, not a pointer.  The address of an array
> always evaluates to true when converted to a boolean.  In this case,
> there is no need for a NULL pointer check.
> ---
>   ell/gpio.c | 3 ---
>   1 file changed, 3 deletions(-)
> =


Applied, thanks.

Regards,
-Denis


--===============2482291543573129507==--

