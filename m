Content-Type: multipart/mixed; boundary="===============2639115452145038915=="
MIME-Version: 1.0
From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] log: Use standard variadic macro syntax
Date: Fri, 07 Dec 2018 21:05:42 +0100
Message-ID: <5954418D-EC37-4F5E-8985-F01F80D1DAD7@holtmann.org>
In-Reply-To: <20181207200109.16000-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2639115452145038915==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

> Use '...' and '__VA_ARGS__' for variadic macros as described in
> https://gcc.gnu.org/onlinedocs/cpp/Variadic-Macros.html
> =

> Previous 'args...' syntax is supported by gcc for backward compatibility,
> but triggers compiler warnings with -Wvariadic-macros.
> ---
> =

> Tested build with iwd and bluez.
> =

> =

> ell/log.h | 16 ++++++++--------
> 1 file changed, 8 insertions(+), 8 deletions(-)

patch has been applied.

Regards

Marcel


--===============2639115452145038915==--

