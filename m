Content-Type: multipart/mixed; boundary="===============3274255080761688097=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: ELL static analysis
Date: Wed, 20 Sep 2017 16:40:29 -0700
Message-ID: <alpine.OSX.2.21.1709201502250.23884@telliot1-mobl1.amr.corp.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3274255080761688097==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


I ran ELL through a static analysis tool and came up with a lot of hits. =

Only a handful were bogus, and there are also some that definitely require =

fixes (I'll send patches).

There are a few broad classes of issues that I wanted to get some feedback =

on before making changes.


1. Ignored returned error values from l_io_get_fd()

l_io_get_fd() returns -1 when it's passed a NULL l_io pointer. In many =

places, that -1 gets passed to a system call as a file descriptor. Those =

system calls typically return an error when they are given a bad fd, and =

there is typically proper error handling for the system call.

Example: =

https://git.kernel.org/pub/scm/libs/ell/ell.git/tree/ell/netlink.c?id=3Da5a=
fb52d308d9154efa26cce962572f7724e3684#n240

Many of these cases involve passing in a pointer that's only used by ELL =

internals and is never set to NULL anyway. What do you think about leaving =

these alone as long as there's a defined error path (even if that error =

path involves a system call that could have been skipped)?


2. Ignored returned error values from l_hashmap_insert()

l_hashmap_insert() returns false when passed a NULL l_hashmap pointer. =

This isn't always checked, especially when the l_hashmap is something used =

by the ELL internals and is never set to NULL.

Example: =

https://git.kernel.org/pub/scm/libs/ell/ell.git/tree/ell/dbus.c?id=3Da5afb5=
2d308d9154efa26cce962572f7724e3684#n821

Seems like these are low risk if it can be confirmed that the pointers =

aren't set to NULL during their owner's lifetime.


3. strcpy() instances that could easily be strncpy()

A number of calls to strcpy() were flagged that are copying to =

destinations of known length.

Example:
https://git.kernel.org/pub/scm/libs/ell/ell.git/tree/ell/gvariant-util.c?id=
=3Da5afb52d308d9154efa26cce962572f7724e3684#n836

These should get fixed, especially where the source string comes from =

non-ELL code. I can't think of a reason to use strcpy() over strncpy() =

unless the source string is hard-coded, and even then strncpy() isn't a =

burden.


4. Ignored errors in test/example code

These are low risk because they aren't in the library itself. However, =

tests and examples are used as templates for new programs. Does it make =

sense to make the examples (and maybe the tests) squeaky-clean in terms of =

error handling?

Example:

https://git.kernel.org/pub/scm/libs/ell/ell.git/tree/examples/https-server-=
test.c?id=3Da5afb52d308d9154efa26cce962572f7724e3684#n128



To take a step back, it's one thing to fix these bugs now, but another to =

have something in place to catch future problems. I think it would be good =

to set up ELL for scanning on an opensource-friendly static analysis site =

- I'll volunteer to babysit that process too.


--
Mat Martineau
Intel OTC

--===============3274255080761688097==--

