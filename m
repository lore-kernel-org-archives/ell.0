Content-Type: multipart/mixed; boundary="===============7236070813185630865=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH] configure: Update to support Autoconf >= 2.69
Date: Thu, 07 Apr 2022 10:20:27 -0500
Message-ID: <36243bcd-0fa4-f8cf-f731-2b5a102e0878@gmail.com>
In-Reply-To: 20220407040007.99836-1-ossama.othman@intel.com

--===============7236070813185630865==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ossama,

On 4/6/22 23:00, Ossama Othman wrote:
> Bootstrapping ELL against Autoconf 2.71 triggers warnings about use of
> the deprecated Autoconf macros.  Replace use of the deprecated
> AC_HELP_STRING and AC_LANG_C macros with AS_HELP_STRING and
> AC_LANG([C]), respectively.
> =

> Bump the Autoconf prerequisite, accordingly, to support the updated
> macros, from 2.60 to 2.69.  Only require Autoconf 2.69 as a
> prerequisite since many Linux distributions do not yet ship with
> Autoconf 2.71.
> =

> This also addresses a `configure' script generation error on Fedora 36.
> ---
>   configure.ac | 20 ++++++++++----------
>   1 file changed, 10 insertions(+), 10 deletions(-)
> =


Applied, thanks,

Regards,
-Denis

--===============7236070813185630865==--

