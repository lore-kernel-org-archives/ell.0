Content-Type: multipart/mixed; boundary="===============0354560565344029430=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 04/11] pem: Add l_pem_load_certificate_list utility
Date: Fri, 02 Nov 2018 07:50:09 -0500
Message-ID: <f669dcb9-d048-5150-a37b-ce31a7dada6e@gmail.com>
In-Reply-To: <CAOq732JHSGgvP2UOHqn8wQwd95=aZhf8UMf-t6aA5XPK5U7ttg@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0354560565344029430==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

> However what I'd really prefer instead is to add back the l_cert type,
> which could be a first class object with a lot of functionality and
> tls.c would become much shorter.  It could hide the l_key usage (but
> could have an accessor for the public key in the certificate) and also
> could have l_cert_new_from_pem(), or alternatively pem.c could rather
> have a l_pem_load_cert() returning l_cert objects.

Yep, lets try doing that.

>>
>> I'm not so sure about this.  pem_load_buffer can fail for base64 decode
>> failure reasons.  So I wouldn't think that you can assume that a failure
>> means EOF + success.
> =

> I was thinking about the case of having 5 certificates already loaded
> and the last one failing -- in this case we might just want to return
> the 5 that parsed ok but I can add better error checking.
> =


No.  Please no.  We never do things this way.  If the parsing was =

partially successful then it was a failure.  Period.  Fail early, get =

the user to address it.  Don't hide problems until they become painful =

to find.

Regards,
-Denis

--===============0354560565344029430==--

