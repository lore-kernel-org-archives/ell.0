Content-Type: multipart/mixed; boundary="===============4415879270649459135=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 3/9] tls: Add TLS version number printf macros
Date: Fri, 14 Dec 2018 19:48:18 +0100
Message-ID: <CAOq732JaQFAm7-t2DJV5F40o1QTN19tignU_hWRANMHi1nex-g@mail.gmail.com>
In-Reply-To: <ab96eccf-b6bf-dfd8-e8a2-545207d8aa19@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4415879270649459135==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Fri, 14 Dec 2018 at 16:53, Denis Kenzior <denkenz@gmail.com> wrote:
> On 12/13/2018 01:57 PM, Andrew Zaborowski wrote:
> > ---
> >   ell/tls-private.h |  3 +++
> >   ell/tls.c         | 17 +++++++++++------
> >   2 files changed, 14 insertions(+), 6 deletions(-)
> >
>
> ell/tls.c: In function =E2=80=98tls_cipher_suite_is_compatible=E2=80=99:
> ell/tls.c:540:34: error: =E2=80=98L_TLS_V12=E2=80=99 undeclared (first us=
e in this
> function); did you mean =E2=80=98TLS_V12=E2=80=99?
>     if (negotiated && negotiated < L_TLS_V12) {
>                                    ^~~~~~~~~
>                                    TLS_V12
> ell/tls.c:540:34: note: each undeclared identifier is reported only once
> for each function it appears in
>
> I know we allow breaking compilation if unavoidable, but I think here
> this can be easily avoided.

Ah indeed, I try to not break compilation if possible, will fix this patch.

Best regards

--===============4415879270649459135==--

