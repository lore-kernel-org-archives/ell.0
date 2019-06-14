Content-Type: multipart/mixed; boundary="===============4772495556886389498=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] acinclude: Correct CFLAGS variable name typo.
Date: Fri, 14 Jun 2019 16:33:28 -0500
Message-ID: <1bcc1d09-daf1-16dc-3bee-0c784b964518@gmail.com>
In-Reply-To: <20190613165223.11171-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4772495556886389498==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ossama,

On 06/13/2019 11:52 AM, Ossama Othman wrote:
> The "-Wvariadic-macros" compiler command line option was appended to
> the "CFALGS" variables instead of "CFLAGS", which prevented it from
> being used when building ELL.  Change "CFALGS" to "CFLAGS".
> ---
>   acinclude.m4 | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> =


Applied, thanks.

Regards,
-Denis


--===============4772495556886389498==--

