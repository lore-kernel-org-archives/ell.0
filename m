Content-Type: multipart/mixed; boundary="===============1069911302961365892=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 5/8] cert: Add l_cert_load_container_file
Date: Fri, 08 Jan 2021 20:39:26 -0600
Message-ID: <8801dc84-368e-516c-edf0-70890ee36f62@gmail.com>
In-Reply-To: <CAOq732+A=Dycd6uzhLpcYWA9ZatwSSh7PodmZ8xz0Jmm0xKzfg@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1069911302961365892==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

>> This makes
>> things really asymmetrical in this function.
> =

> It does, let me know if you prefer it fixed.
> =


That would be nice, but I'm not sure what the fix might be?

It almost feels like you should break up this function into separate parts.=
  One =

part for loading PEMs, one part for loading raw DERs, etc.  I mean if you l=
ook =

at the code block that handles "CERTIFICATE" PEMs, it is almost exact copy =
of =

what the block under 'if (tag =3D=3D ASN1_ID_SEQUENCE)' does.  That might a=
lso =

contribute to fixing your asymmetry...

Regards,
-Denis
--===============1069911302961365892==--

