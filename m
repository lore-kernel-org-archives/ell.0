Content-Type: multipart/mixed; boundary="===============3824471514479149480=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: Debug logging with ell
Date: Tue, 24 Apr 2018 15:30:35 -0500
Message-ID: <9b01b52a-c2f5-9abf-f1e0-cfeea4b56053@gmail.com>
In-Reply-To: <1524587632.3524.3.camel@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3824471514479149480==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Inga,

On 04/24/2018 11:33 AM, Stotland, Inga wrote:
> Hi all,
> =

> Quick question: can I use l_debug() when I am dynamically linking with
> installed ell library (i.e., the one created with make install and
> linked as -lell)?
> Calling l_debug() generates no output, l_info() works just fine.
> =


I suspect you're the first to try this, so doesn't surprise me that it =

doesn't work.  I imagine the current setup fails because the shared =

library has its own section and the executable has its own.

Probably can be solved with some macro magic, but will require a bit of =

surgery inside ell...

Regards,
-Denis

--===============3824471514479149480==--

