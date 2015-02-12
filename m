Content-Type: multipart/mixed; boundary="===============4161369340349960738=="
MIME-Version: 1.0
From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: Re: [PATCH 6/9] hashmap: Add re-entrancy support to foreach function
Date: Thu, 12 Feb 2015 09:23:04 +0200
Message-ID: <1423725784.4196.6.camel@linux.intel.com>
In-Reply-To: <54DB6203.3070107@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4161369340349960738==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On ke, 2015-02-11 at 08:06 -0600, Denis Kenzior wrote:
> Hi Patrik,
> =

> On 02/11/2015 03:21 AM, Patrik Flykt wrote:
> > On Tue, 2015-02-10 at 13:47 -0600, Denis Kenzior wrote:
> >> Can you tell me why this is needed?  This sounds like abuse of
> >> hashmap_foreach and an alternate data structure might be in order.
> >
> > One should not be able to crash the library by (mis)using the provided
> > API. The implementation needs to work all the time or politely tell that
> > the API function call did not complete at this time.
> >
> =

> Are you serious?  I've yet to see any library that I can't crash by =

> deliberately misusing the API; even the best can't do what you're =

> describing.  Ell's job is not to hand-hold the programmer.

I disagree you here. It is quite difficult to know how ell is being used
so it should be prepared to not to crash. For example here it is not
very obvious from the library user point of view that calling
l_dbus_unregister() from dbus callback will cause a segfault. It is
clearly a bug that needs to be fixed. I do not understand why we would
leave this kind of bug in the code and then let the library user to
invent some workarounds for this issue.


Jukka



--===============4161369340349960738==--

