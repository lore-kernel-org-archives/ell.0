Content-Type: multipart/mixed; boundary="===============6195518083939800007=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 08/10] pem: Support encrypted keys in
 l_pem_load_private_key
Date: Fri, 11 Aug 2017 19:49:27 -0500
Message-ID: <b8dc69ac-0d8d-93ab-03b4-e3781f526e65@gmail.com>
In-Reply-To: <CAOq732Jz8w13BnW024LyWt0cWZqrjHm89PhyvSnniQ8Z-SmU6Q@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6195518083939800007==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

> =

> I have iwd code to actually enable encrypted EAP-TLS or EAP-TTLS
> private keys.  But it could use a "l_pem_is_encrypted" too, only the
> files would be loaded more times.
> =


Ah I see, because you're asking the agent for the passphrase.

Go with the current proposal, but do me a favor and put in a doc block =

above that function and explain that 'encrypted' doesn't follow our =

typical out-argument semantics.  E.g. it is actually touched even if the =

function fails.

Regards,
-Denis

--===============6195518083939800007==--

