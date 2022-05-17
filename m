Content-Type: multipart/mixed; boundary="===============4831254649238514913=="
MIME-Version: 1.0
From: Michael Johnson <mjohnson459 at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH v2 1/3] dhcp: Add priority to logging
Date: Tue, 17 May 2022 18:10:52 +0100
Message-ID: <CACsRnHWWsTdoi11pfTmisgpyW9Vz9yrSLjoHUX76kYUtkZwEYw@mail.gmail.com>
In-Reply-To: b8567e94-89b2-8954-4063-c31484993a43@gmail.com

--===============4831254649238514913==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

Sorry about that, I thought I caught them all.

Michael

On Tue, 17 May 2022 at 18:03, Denis Kenzior <denkenz(a)gmail.com> wrote:
>
> Hi Michael,
>
> On 5/17/22 11:56, Michael Johnson wrote:
> > Most dhcp clients have some logging to show what state the lease is in
> > so this just makes iwd more in line with them. The logging won't be
> > enabled by default but requires a max logging level to be passed in when
> > logging is set up.
> > ---
> >   ell/dhcp.c | 48 +++++++++++++++++++++++++++++-------------------
> >   ell/dhcp.h |  2 +-
> >   2 files changed, 30 insertions(+), 20 deletions(-)
>
> All applied, thanks!  I did amend patch 1 & 3 slightly to break up lines =
that
> were > 80 chars.
>
> Regards,
> -Denis
--===============4831254649238514913==--

