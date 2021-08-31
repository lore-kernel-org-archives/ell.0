Content-Type: multipart/mixed; boundary="===============3220813507023947774=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] unit/test-cipher: always report local ciphers as
 supported
Date: Tue, 31 Aug 2021 08:33:33 -0500
Message-ID: <4cc37873-71c5-5f1f-8635-570e6e9dc660@gmail.com>
In-Reply-To: <20210830140846.4096201-1-slyich@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3220813507023947774==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On 8/30/21 9:08 AM, Sergei Trofimovich wrote:
> Fixes test failure on system with CONFIG_CRYPTO_USER_API=3Dn kernel:
> =

>      FAIL: unit/test-cipher
>      =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> =

>      test-cipher: unit/test-cipher.c:124:
>        test_arc4: Assertion `l_cipher_is_supported(L_CIPHER_ARC4)' failed.
>      FAIL unit/test-cipher (exit status: 134)
> =

> Lack of AF_ALG family is the result of CONFIG_CRYPTO_USER_API=3Dn.
> =

> The change moved supported ciphed detection before AF_ALG socket
> creation attempt.
> =

> Signed-off-by: Sergei Trofimovich <slyich@gmail.com>
> ---
>   ell/cipher.c | 8 ++++----
>   1 file changed, 4 insertions(+), 4 deletions(-)
> =


Both applied, thanks.  I did add an extra line in patch 2 for coding style =

purposes and reworded the commit headers slightly.  Also removed Signed-off=
-by =

lines since we do not use them in ell.

Regards,
-Denis
--===============3220813507023947774==--

