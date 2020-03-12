Content-Type: multipart/mixed; boundary="===============1990242284938086144=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] unit: Add graceful fail of pem, tls and key tests
Date: Thu, 12 Mar 2020 10:45:28 -0500
Message-ID: <403944ad-a6e1-7cc0-3da2-fb66af18f5b7@gmail.com>
In-Reply-To: <20200226175416.31769-1-brian.gix@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1990242284938086144==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Brian,

On 2/26/20 11:54 AM, Brian Gix wrote:
> Unit tests for PEM, TLS and KEY require the pkcs8_key_parser module
> to be running in the kernel, however not all kernels have this
> running by default. This checks for this possibility and aborts
> these tests with exit(1) rather than an assert, and includes instruction
> to correct the issue.
> ---
>   unit/test-key.c |  9 +++++++++
>   unit/test-pem.c |  9 +++++++++
>   unit/test-tls.c | 12 +++++++++++-
>   3 files changed, 29 insertions(+), 1 deletion(-)
> =


Applied, thanks.

Regards,
-Denis

--===============1990242284938086144==--

