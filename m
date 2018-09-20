Content-Type: multipart/mixed; boundary="===============8419217743549129917=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] key: Change initialization of struct keyctl_dh_params
Date: Thu, 20 Sep 2018 18:20:44 -0500
Message-ID: <1f1a0849-94f5-7538-8f1f-f07240118b7c@gmail.com>
In-Reply-To: <20180920231405.3177-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8419217743549129917==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 09/20/2018 06:14 PM, Mat Martineau wrote:
> Using a designated initializer with struct keyctl_dh_params has broken
> due to a kernel header file change to one of the member names,
> introduced in kernel v4.19-rc3:
> =

> https://lore.kernel.org/lkml/1735b3a4-2792-0ce4-3bf4-94fee5b50ff6(a)infra=
dead.org/
> =

> If the member names are dropped from the initializer then the code will
> compile and work correctly before or after the kernel header change.
> ---

Applied, thanks.

Regards,
-Denis


--===============8419217743549129917==--

