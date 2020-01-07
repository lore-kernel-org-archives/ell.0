Content-Type: multipart/mixed; boundary="===============1911553151823592639=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: Warn-to-error on -Werror=cast-align
Date: Tue, 07 Jan 2020 09:51:38 -0600
Message-ID: <0894e48d-212f-9d30-1526-a5da27eec5b0@gmail.com>
In-Reply-To: <16492c82999ed2dcc5a03e9af15137970edc3faa.camel@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1911553151823592639==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Brian,

> Any opinion on this change?  It is causing us build fails on some platfor=
ms (including Raspberry PI 4).
>

I would think this is a compiler false positive.  If there was indeed an =

issue, then just casting to void as an intermediate step just hides it =

without fixing anything.

I'd attempt to figure out if the compiler is at fault, and if it is, =

then #pragma around this.

Regards,
-Denis
--===============1911553151823592639==--

