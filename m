Content-Type: multipart/mixed; boundary="===============7603944513254338984=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: ELL API changes before stabilizing
Date: Fri, 07 Oct 2016 13:41:25 -0500
Message-ID: <57F7EC55.1010201@gmail.com>
In-Reply-To: <alpine.OSX.2.20.1610070936570.45755@mjmartin-mac01.local>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7603944513254338984==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

 >
> Works for me. Do we have a consensus around removing the nanosecond
> versions and adding:
>
> struct l_timeout *l_timeout_create_ms(unsigned long milliseconds,
>                      l_timeout_notify_cb_t callback,
>                                  void *user_data,
>                      l_timeout_destroy_cb_t destroy);
> void l_timeout_modify_ms(struct l_timeout *timeout,
>                                  unsigned long milliseconds);
>

This looks fine to me.

Regards,
-Denis


--===============7603944513254338984==--

