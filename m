Content-Type: multipart/mixed; boundary="===============4096231069271170105=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 06/12] tls: Move cipher suite definitions to tls-suites.c
Date: Sat, 05 Jan 2019 15:52:54 +0100
Message-ID: <CAOq732K+7YNrvvS9cO6bt6hUAWTGeVywpNXQjrOC0fH2YQqCrQ@mail.gmail.com>
In-Reply-To: <0e235de5-3ae3-994e-8aad-3ecd1c8df3ef@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4096231069271170105==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Fri, 4 Jan 2019 at 22:37, Denis Kenzior <denkenz@gmail.com> wrote:
> On 01/03/2019 07:26 PM, Andrew Zaborowski wrote:
> > @@ -903,8 +734,7 @@ static ssize_t tls_append_hello_extensions(struct l=
_tls *tls,
> >
> >   static bool tls_send_client_hello(struct l_tls *tls)
> >   {
> > -     uint8_t buf[1024 + L_ARRAY_SIZE(tls_compression_pref) +
> > -                     2 * L_ARRAY_SIZE(tls_cipher_suite_pref)];
> > +     uint8_t buf[1024 + L_ARRAY_SIZE(tls_compression_pref)];
> >       uint8_t *ptr =3D buf + TLS_HANDSHAKE_HEADER_SIZE;
> >       uint8_t *len_ptr;
> >       unsigned int i;
>
> Was this chunk intended?
>
> Anyway, I went ahead and applied this patch.  Send me a fix if needed.

Thank you.  After scratching my head for a moment I remember this
chunk is because tls_cipher_suite_pref is now in another file so
ARRAY_SIZE won't work.  But the message size is limited by the
extensions implemented, right now it's less than 100 bytes actually.
unit/test-tls will immediately tell us if it becomes too big.

Best regards

--===============4096231069271170105==--

