Content-Type: multipart/mixed; boundary="===============7905237391664614716=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 2/4] unit: Update expected peer identity strings in TLS
Date: Thu, 08 Aug 2019 02:04:03 +0200
Message-ID: <CAOq732+DMuxtd9u+KeAFngdodJHsbiGov+HL5Q--F2m5EjNzpg@mail.gmail.com>
In-Reply-To: <44bb79f3-d284-c27c-99e5-37a3cc6e1169@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7905237391664614716==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Thu, 8 Aug 2019 at 01:40, Denis Kenzior <denkenz@gmail.com> wrote:
> >> Also, what happens if the strings contain a '/' character? Or is that
> >> not possible?
> >
> > So apparently openssl has some \ unescaping support for these strings
> > when you generate the certificate and probably the characters are
> > escaped again when you extract this string from a cert.  We could
> > replicate this but in terms of security I think it doesn't add
> > anything, users will just need to remember to not escape the
> > characters in the iwd configs.
> >
>
> This response doesn't fill me with a lot of confidence :)  How is domain
> name suffix matching code (for example) going to deal with random '/'
> characters if they serve as delimiters?

So with the simple fnmatch or substring matching this wasn't really a
problem as without a regex you had no way to distinguish a '/' from an
escaped "\/".  I mean, it was just as bad in both cases :)

With a proper parser for this string in the client code though, and
with proper escaping, we may be able to prevent some attacks where
someone convinces the CA to sell them a certificate with e.g.
"/CN=3Dexample.com" contained inside another field in the subject DN, so
yeah, perhaps it's worth adding, I'll do that.

Best regards

--===============7905237391664614716==--

