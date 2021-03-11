Content-Type: multipart/mixed; boundary="===============5730716278506593996=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] pem: Write encrypted flag in load_container with .crt
 format
Date: Wed, 10 Mar 2021 18:52:35 -0600
Message-ID: <54fd1219-c24a-ec55-1b5a-e595cf78768e@gmail.com>
In-Reply-To: <20210310232257.955127-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5730716278506593996==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 3/10/21 5:22 PM, Andrew Zaborowski wrote:
> Make sure a value is written to *out_encrypted whenever
> l_cert_load_container_file() returns success.  Specifically we were
> forgetting to do this with raw DER-encoded certificates.  Fixes the
> following valgrind warning (sometimes test failure) in test-pem:
> =

> =3D=3D1142=3D=3D Conditional jump or move depends on uninitialised value(=
s)
> =3D=3D1142=3D=3D    at 0x10B427: test_load_file (test-pem.c:369)
> =3D=3D1142=3D=3D    by 0x10CF53: l_test_run (test.c:83)
> =3D=3D1142=3D=3D    by 0x10BC19: main (test-pem.c:523)
> =3D=3D1142=3D=3D
> test-pem: unit/test-pem.c:369: test_load_file: Assertion `encrypted =3D=
=3D params->expect_encrypted' failed.
> ---
>   ell/cert.c | 3 +++
>   1 file changed, 3 insertions(+)
> =


Applied, thanks.

Regards,
-Denis

--===============5730716278506593996==--

