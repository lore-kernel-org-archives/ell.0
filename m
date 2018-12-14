Content-Type: multipart/mixed; boundary="===============4483421464174132558=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 8/9] tls: Allow user to set custom list of cipher suites
Date: Fri, 14 Dec 2018 13:57:29 -0600
Message-ID: <e6547197-e66e-6ab3-85dc-1d68b135feab@gmail.com>
In-Reply-To: <CAOq732Kz4kKcv7iB4wfaqswsZgy4rZNW55Hq0rycYPF5ONLbfg@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4483421464174132558==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

>> Yes, but you also have to consider the audience for our TLS
>> implementation.  It isn't browsers.  It is just iwd and maybe eventually
>> ConnMan for the portals stuff.  So can we optimize the API for those use
>> cases ?
> =

> I don't think we should but ok.  BTW we won't be Suite B compliant for
> a while still because of the DSA certificates and likely more things.

Right, I forgot SuiteB actually implies DSA.  But we don't need SuiteB =

anyway.  WPA3 allows:

- TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA38
   ECDHE using the 384-bit prime modulus curve P-384

- TLS_DHE_RSA_WITH_AES_256_GCM_SHA384

So perhaps we just need a 'WPA3' selector.  And once we have SuiteB =

support, then we can add TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384 to WPA3 =

selector as well.

> BTW since tls.c is pretty big we could split out all the cipher suite
> definitions and the functions used by them into tls-suites.c or
> similar.  For ECDHE we'll need to add extensions support and I'm also
> thinking of defining the extensions in a new file tls-extensions.c
> (we'll support very few initially but the different specs actually
> define many).

Sure.  At 3kloc tls.c isn't too bad, but we can break it up.  Propose =

something.

Regards,
-Denis


--===============4483421464174132558==--

