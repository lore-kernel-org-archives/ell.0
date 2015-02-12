Content-Type: multipart/mixed; boundary="===============3964018533620516343=="
MIME-Version: 1.0
From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: Re: [PATCH 6/9] hashmap: Add re-entrancy support to foreach function
Date: Thu, 12 Feb 2015 09:25:32 +0200
Message-ID: <1423725932.4196.8.camel@linux.intel.com>
In-Reply-To: <54DB6203.3070107@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3964018533620516343==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On ke, 2015-02-11 at 08:06 -0600, Denis Kenzior wrote:
> Hi Patrik,
> =


> >
> > glib also crashed with this pattern. Or usually worked ok, as the
> > removed/added item wasn't always the item used in foreach or the next
> > item. Fixing this to allow any API call successfully work at any time
> > requires quite some more work to be done, the above patch by Jukka was
> > approximately the minimum needed for a remove to work at any one time.
> >
> =

> If you find a good way to fix this in the data structure, great.  But =

> the current fix is not acceptable.  We will not be iterating over the =

> _entire_ data structure twice.  The foreach operation is already =

> expensive and too tempting to abuse.

The patch would iterate the data structure twice only if user did modify
the hash in the callback func. That is probably not very common case
anyway.


Jukka



--===============3964018533620516343==--

