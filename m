Content-Type: multipart/mixed; boundary="===============7718576135008094302=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 4/9] tls: Pass the verified peer identity to "ready"
 callback
Date: Wed, 28 Nov 2018 13:02:25 +0100
Message-ID: <CAOq732LsuH+HEmpfwkK+sECQDFNEMFLvcq2QS6agEHro0CFh6Q@mail.gmail.com>
In-Reply-To: <7d1d5073-c998-371c-da4c-c1e9c83b7c38@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7718576135008094302==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Wed, 28 Nov 2018 at 05:24, Denis Kenzior <denkenz@gmail.com> wrote:
> On 11/27/2018 08:38 PM, Andrew Zaborowski wrote:
> > Extract a human-readable peer identity string from the supplied
> > certificate and pass it to the ready callback provided by API user to
> > indicate that the peer has actually been authenticated.  For some users
> > it will only really matter whether the value is non-NULL meaning that
> > the peer is trusted by the locally configured CA, while for others,
> > such as web browsers it's useful to display a human-readable peer
> > identity to the user so they can see if a website is served by who they
> > think it belongs to.  If we got a peer certificate but user supplied no
> > CAs or peer couldn't be authenticated, don't bother to extract the
> > identity string and pass NULL.
> >
> > Until now we'd always pass NULL (there was a TODO comment) because
> > we'd hoped we could at some point leverage the kernel's certificate
> > parser to extract the subject name.  The newly added
> > tls_get_peer_identity_str might also fit in cert.c instead of tls.c.
> > ---
> >   ell/tls.c | 70 ++++++++++++++++++++++++++++++++++++++++++++++++++++---
> >   1 file changed, 67 insertions(+), 3 deletions(-)
> >
>
> I went ahead and applied this and patch 5.  But really the more
> interesting feature for us would be the certificate element name
> matching described in the appropriate iwd.git/TODO task.  But that one
> is a whole other story...

So with this patch we will be able to already kind of do this,
although maybe we need to pass more values for it to work better.  The
logic in this patch is to use organizationName and if that is not
available then commonName.  The TODO (is it really C8?) mentions
matching on dNSName or commonName.  Maybe we should pass all the
various strings and then separately a bool value (authenticated/not
authenticated) although they're pointless if the peer was not
authenticated.

On the other hand the CA certificate is optional in iwd configs and
until now we couldn't even check if peer identity was known so it's a
little premature to worry about it having a specific suffix :)

Also I'm not sure how effective this suffix matching actually is... if
a trusted CA is issuing certificates to rogue subjects then that CA
can no longer be trusted.   What if the CA issued a CA certificate?
The subject could then fake any subject string they want.  Maybe it's
the best we can do though.

Best regards

--===============7718576135008094302==--

