Content-Type: multipart/mixed; boundary="===============8363897401454971619=="
MIME-Version: 1.0
From: Othman, Ossama <ossama.othman@intel.com>
Subject: Re: Debug logging with ell
Date: Tue, 24 Apr 2018 10:35:20 -0700
Message-ID: <CAPyD+=BDGLT8WYTZEthm9ROfRSY6fbBJyZMLCuRoXPFcLp0yCQ@mail.gmail.com>
In-Reply-To: <1524587632.3524.3.camel@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8363897401454971619==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Inga,

On Tue, Apr 24, 2018 at 9:33 AM, Stotland, Inga <inga.stotland@intel.com>=
 wrote:
>
> Quick question: can I use l_debug() when I am dynamically linking with
> installed ell library (i.e., the one created with make install and
> linked as -lell)?
> Calling l_debug() generates no output, l_info() works just fine.
>
> When I link with libell-private, l_debug works as expected. Something
> to do with debug mem sections?
>
> I would rather not write my own logging if l_debug() is
> available.

Try enabling debug logging at run-time, e.g.:   l_debug_enable("*");

HTH!
-Ossama

--===============8363897401454971619==--

