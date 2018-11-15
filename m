Content-Type: multipart/mixed; boundary="===============8674304445454344013=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 01/12] cipher: Only do the RFC3610 IV formatting for CCM
Date: Thu, 15 Nov 2018 12:46:24 +0100
Message-ID: <CAOq732+yPtt=_MNyUMiKJ8EQTqz49Lf2YKdO0oivsNnLaOyJDA@mail.gmail.com>
In-Reply-To: <alpine.OSX.2.21.1811141259360.19580@mjmartin-mac01.local>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8674304445454344013==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On Wed, 14 Nov 2018 at 22:13, Mat Martineau
<mathew.j.martineau@linux.intel.com> wrote:
> On Wed, 14 Nov 2018, Andrew Zaborowski wrote:
> > +/* RFC3610 Section 2.3 */
> > +static ssize_t build_ccm_iv(const void *nonce, uint8_t nonce_len, uint=
8_t *iv)
> > +{
> > +     const size_t iv_overhead =3D 2;
> > +     const size_t iv_len =3D 16;
>
> This depends on the length of the iv array being 16, but all we get from
> the caller is a uint8_t pointer. How about passing in iv_len for a more
> robust length check?

I think we can check that the provided buffer is big enough but does
it make sense to use it for the calculations?  Since this is now
called build_ccm_iv it can assume the cipher mode is CCM and the
buffer needs 16 bytes.

The RFC doesn't suggest there may be different IV sizes:

      Octet Number   Contents
      ------------   ---------
      0              Flags
      1 ... 15-L     Nonce N
      16-L ... 15    Counter i

>
> Other than that, the cipher patches look good. I also did a quick review
> of the rest of the series and didn't spot any issues.

Thank you!

--===============8674304445454344013==--

