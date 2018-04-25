Content-Type: multipart/mixed; boundary="===============3462971269282692826=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: Debug logging with ell
Date: Wed, 25 Apr 2018 15:23:49 -0500
Message-ID: <5ca4aed4-d944-8932-9208-209dd7d5f702@gmail.com>
In-Reply-To: <1524587632.3524.3.camel@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3462971269282692826==
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

So this should work now.  I've pushed a couple of fixes upstream.

Regards,
-Denis


--===============3462971269282692826==--

