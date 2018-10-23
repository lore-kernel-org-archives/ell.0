Content-Type: multipart/mixed; boundary="===============6572255996550475189=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 0/2] Correct missing field initializer warning
Date: Tue, 23 Oct 2018 16:35:15 -0500
Message-ID: <b5923398-8093-024c-0d32-7b8962deccf6@gmail.com>
In-Reply-To: <20181023195740.30204-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6572255996550475189==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ossama,

On 10/23/2018 02:57 PM, Ossama Othman wrote:
> The L_PLUGIN_DEFINE() macro triggered missing field initializer
> warnings when the corresponding warning flag was enabled for user
> defined plugins.  Prevent ELL from exposing such warnings to the user
> by explicitly initializing all l_plugin_desc fields, as well
> re-enabling that warning in maintainer mode builds.
> =

> Ossama Othman (2):
>    plugin: Explicitly initialize descriptor fields.
>    Re-enable -Wmissing-field-initializers warning.
> =

>   acinclude.m4 | 1 -
>   ell/plugin.h | 3 ++-
>   2 files changed, 2 insertions(+), 2 deletions(-)
> =



Both applied, thanks.

Regards,
-Denis

--===============6572255996550475189==--

