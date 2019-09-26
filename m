Content-Type: multipart/mixed; boundary="===============1425955563501724472=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] tls: raise min DH prime modulus length to 1536 bit
Date: Wed, 25 Sep 2019 21:30:39 -0500
Message-ID: <a8ba65ab-d722-c388-c7af-3281573d9a08@gmail.com>
In-Reply-To: <20190925164524.80994-1-diabonas@gmx.de>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1425955563501724472==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Jonas,

On 9/25/19 11:45 AM, Jonas Witschel wrote:
> The minimum prime length required by the Linux kernel for DH
> calculations is 1536 bit. If a smaller prime is used,
> keyctl_dh_compute() will fail with EINVAL, cf. dh_check_params_length()
> and dh_set_params() in crypto/dh.c of the kernel sources.
> =

> On encountering a smaller prime, ELL currently fails in
> tls_send_dhe_client_key_xchg() with the not very instructive error
> message "l_key_compute_dh_public failed". Since any prime smaller than
> 1536 bit is guaranteed to fail at this step, raise the already existing
> minimum length check so that the handshake fails with the message
> "Server DH prime modulus invalid" instead. This does not have any
> compatibility implications since smaller primes never worked in the
> first place, but gives a clearer indication of what went wrong.
> ---
>   ell/tls-suites.c | 6 +++---
>   1 file changed, 3 insertions(+), 3 deletions(-)
> =


Applied, thanks.

Regards,
-Denis


--===============1425955563501724472==--

