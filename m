Content-Type: multipart/mixed; boundary="===============0742791572255433711=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 08/10] pem: Support encrypted keys in
 l_pem_load_private_key
Date: Fri, 11 Aug 2017 19:40:05 -0500
Message-ID: <9ee80b29-2926-ab09-8859-74944820d03d@gmail.com>
In-Reply-To: <CAOq732JUrZg=3-HMnCEtT3fNPOV3furYtnvsgA=OWyNKx1=d4Q@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0742791572255433711==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

>> So we set encrypted even if we fail?  Right now you're not even using th=
is
>> parameter, so I wonder if we should maybe introduce a new function, like
>> l_pem_is_encrypted() instead?
> =

> I could do either thing, but the idea here was that whoever is setting
> up TLS checks if a passphrase is required.  If it isn't, they get
> feedback on whether the PEM file loads Ok in the same call.  If it is
> they validate the passphrase and the encrypted PEM in one call.  With
> a separate l_pem_is_encrypted the file will be loaded twice.
> =


Do you have a need for this?  If we don't have any immediate need, I =

would just punt on this for now.

Regards,
-Denis

--===============0742791572255433711==--

