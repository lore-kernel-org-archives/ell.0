Content-Type: multipart/mixed; boundary="===============6312259171685588686=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] unit: Add PBKDF2 tests from iwd
Date: Mon, 09 Oct 2017 12:05:11 -0500
Message-ID: <5b626319-0894-633f-912a-4f1d08dafa1e@gmail.com>
In-Reply-To: <20171009094659.5793-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6312259171685588686==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 10/09/2017 04:46 AM, Andrew Zaborowski wrote:
> Test l_pkcs5_pbkdf2 using test data from iwd with the exception of the
> test case that contained a \0 inside the password string.

So the obvious question is why that test was excepted?

> ---
>   .gitignore         |   1 +
>   Makefile.am        |   5 +-
>   unit/test-pbkdf2.c | 206 ++++++++++++++++++++++++++++++++++++++++++++++=
+++++++
>   3 files changed, 211 insertions(+), 1 deletion(-)
>   create mode 100644 unit/test-pbkdf2.c
> =


Regards,
-Denis

--===============6312259171685588686==--

