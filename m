Content-Type: multipart/mixed; boundary="===============4351288911833043136=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 0/5] Support C89 ELL builds
Date: Mon, 04 Mar 2019 13:19:28 -0600
Message-ID: <9dccb3c7-9ae1-2c85-257d-594df08c6878@gmail.com>
In-Reply-To: <20190304184259.22809-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4351288911833043136==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ossama,

On 03/04/2019 12:42 PM, Ossama Othman wrote:
> This patch set provides several simple changes to enable C89 support
> in ELL.
> =

> Ossama Othman (5):
>    ell: Use __inline__ instead of inline for C89.
>    ell: Do not use C99 '//' single line comment.
>    settings: Explicitly enable strto{u}ll() for C89.
>    string: Use __va_copy() for pre-C99 builds.
>    unit: Remove C99 loop variable declaration.
> =

>   ell/asn1-private.h       | 4 ++++
>   ell/dbus.c               | 2 +-
>   ell/netlink.c            | 2 +-
>   ell/settings.c           | 4 ++++
>   ell/string.c             | 4 ++++
>   ell/utf8.h               | 4 ++++
>   ell/util.h               | 4 ++++
>   unit/test-dbus-message.c | 3 ++-
>   8 files changed, 24 insertions(+), 3 deletions(-)
> =


All applied, thanks.

Regards,
-Denis

--===============4351288911833043136==--

