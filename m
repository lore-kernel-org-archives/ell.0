Content-Type: multipart/mixed; boundary="===============0391890008317799179=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH] queue: Fix an l_queue_insert corner case
Date: Tue, 02 Mar 2021 16:21:06 +0100
Message-ID: <CAOq732+bJkphExwAf7A38QRP0aE9q_tP7rVS4tRQD9FV+2Nfog@mail.gmail.com>
In-Reply-To: <5542e25b-28f7-9450-255e-b485b9ff5b13@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0391890008317799179==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Tue, 2 Mar 2021 at 16:03, Denis Kenzior <denkenz@gmail.com> wrote:
> On 3/1/21 4:57 PM, Andrew Zaborowski wrote:
> > The comment doc for the function says:
> >
> >   * Inserts @data pointer at a position in the queue determined by the
> >   * compare @function.  @function should return > 0 if the @data (first
> >   * parameter) should be inserted after the current entry (second param=
eter).
> >
>
> Right.  But the docs don't say anything about treatment of 0 returns.

Right, or about the treatment of any other value.

With this wording I'm pretty sure anyone you ask is going to interpret this=
 as:

 - insert after current entry if returned value > 0
 - insert before current entry otherwise

>
> > however the function would insert @data after entries for which
> > @function returned a >=3D 0 value.  Change the check to > 0 to align wi=
th
> > the docs.
>
> The intent is that values that are 'equal' (@function returns 0) are inse=
rted
> _after_ any entries already in the queue.  While not documented explicitl=
y, I'm
> pretty sure that this is the only sensible behavior (and likely something=
 we
> implicitly rely on).  So, I'm not sure this is the right fix?

We can change the docs to much that intent then...

Best regards
--===============0391890008317799179==--

