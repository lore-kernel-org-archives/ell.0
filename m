Content-Type: multipart/mixed; boundary="===============7170420108888171428=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 1/5] key: Implement l_keyring_link_nested
Date: Mon, 26 Nov 2018 22:45:32 +0100
Message-ID: <CAOq732KuZkpW7cW4jUG6Axexs8w4tyjD8EdNCzNymdXdY9RjXw@mail.gmail.com>
In-Reply-To: <alpine.OSX.2.21.1811261019340.9846@mjmartin-mac01.sea.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7170420108888171428==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi,

On Mon, 26 Nov 2018 at 19:35, Mat Martineau
<mathew.j.martineau@linux.intel.com> wrote:
> >
> > +bool l_keyring_link_nested(struct l_keyring *keyring,
> > +                             const struct l_keyring *nested)
>
> Still need LIB_EXPORT with these new functions.

Oops, yes, thanks for catching this and thanks Denis for fixing it.

Best regards

--===============7170420108888171428==--

