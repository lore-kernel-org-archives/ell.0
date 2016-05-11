Content-Type: multipart/mixed; boundary="===============2498005001927544407=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] build: Add sanitizer options
Date: Wed, 11 May 2016 13:10:02 -0500
Message-ID: <5733757A.7030806@gmail.com>
In-Reply-To: <1462990060-19817-1-git-send-email-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2498005001927544407==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 05/11/2016 01:07 PM, Mat Martineau wrote:
> Build using Address Sanitizer (asan), Leak Sanitizer (lsan), or
> Undefined Behavior Sanitizer (ubsan) by using one of these options for
> the configure script:
>
>    --enable-asan
>    --enable-lsan
>    --enable-ubsan
>
> For each of these to work, the compiler must support the requested
> sanitizer and the requisite libraries must be installed (libasan,
> liblsan, libubsan).
> ---
>   acinclude.m4 | 36 ++++++++++++++++++++++++++++++++++++
>   configure.ac | 45 +++++++++++++++++++++++++++++++++++++++++++++
>   2 files changed, 81 insertions(+)
>

Applied, thanks.

Regards,
-Denis


--===============2498005001927544407==--

