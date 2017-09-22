Content-Type: multipart/mixed; boundary="===============1542254905485994098=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: ELL static analysis
Date: Thu, 21 Sep 2017 17:25:17 -0700
Message-ID: <alpine.OSX.2.21.1709211652520.31695@pcanepa-mobl.ger.corp.intel.com>
In-Reply-To: <56c29fd3-e5d9-c931-7fec-5eb955adfcaa@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1542254905485994098==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


On Wed, 20 Sep 2017, Denis Kenzior wrote:

> Hi Mat,
>
> On 09/20/2017 06:40 PM, Mat Martineau wrote:
>> =

>> I ran ELL through a static analysis tool and came up with a lot of hits. =

>> Only a handful were bogus, and there are also some that definitely requi=
re =

>> fixes (I'll send patches).
>> =

>> There are a few broad classes of issues that I wanted to get some feedba=
ck =

>> on before making changes.
>> =

>> =

>> 1. Ignored returned error values from l_io_get_fd()
>> =

>> l_io_get_fd() returns -1 when it's passed a NULL l_io pointer. In many =

>> places, that -1 gets passed to a system call as a file descriptor. Those =

>> system calls typically return an error when they are given a bad fd, and =

>> there is typically proper error handling for the system call.
>> =

>> Example: =

>> https://git.kernel.org/pub/scm/libs/ell/ell.git/tree/ell/netlink.c?id=3D=
a5afb52d308d9154efa26cce962572f7724e3684#n240 =

>> =

>> Many of these cases involve passing in a pointer that's only used by ELL =

>> internals and is never set to NULL anyway. What do you think about leavi=
ng =

>> these alone as long as there's a defined error path (even if that error =

>> path involves a system call that could have been skipped)?
>> =

>
> I bet almost all of these are inside read/write handlers.  read/write =

> handlers will not be called on a NULL io object or if the underlying fd =

> becomes invalid.  So you're guaranteed that the io object is valid. These=
 can =

> be left alone.

I checked a few more examples - they are mostly read/write handlers.

>
>> =

>> 2. Ignored returned error values from l_hashmap_insert()
>> =

>> l_hashmap_insert() returns false when passed a NULL l_hashmap pointer. T=
his =

>> isn't always checked, especially when the l_hashmap is something used by =

>> the ELL internals and is never set to NULL.
>> =

>> Example: =

>> https://git.kernel.org/pub/scm/libs/ell/ell.git/tree/ell/dbus.c?id=3Da5a=
fb52d308d9154efa26cce962572f7724e3684#n821 =

>> =

>> Seems like these are low risk if it can be confirmed that the pointers =

>> aren't set to NULL during their owner's lifetime.
>> =

>
> We can look at these, but generally the hashmaps we use are created at ob=
ject =

> allocation or first insertion and destroyed when the object is destroyed.=
  So =

> likely most of these can be ignored.

Ok.

>
>> =

>> 3. strcpy() instances that could easily be strncpy()
>> =

>> A number of calls to strcpy() were flagged that are copying to destinati=
ons =

>> of known length.
>> =

>> Example:
>> https://git.kernel.org/pub/scm/libs/ell/ell.git/tree/ell/gvariant-util.c=
?id=3Da5afb52d308d9154efa26cce962572f7724e3684#n836 =

>> =

>> These should get fixed, especially where the source string comes from =

>
> So the particular case you bring up is actually a good example of why we =

> _don't_ want to convert every single strcpy into a strncpy.
>
> 1. The signature is validated by the logic above to be no more than 255 =

> characters (e.g. _gvariant_valid_signature).
> 2. The builder object is meant to be used by the programmer to build D-Bu=
s =

> messages.  It isn't meant to receive arbitrary input from the network, et=
c. =

> So in this case, even if somehow a buffer overflow occurs, I want valgrin=
d to =

> warn the programmer ASAP and tell them exactly where they screwed up inst=
ead =

> of having a silent and hard-to-find failure.
>
> Our principle of crash-early applies...

Crash early, but only when running valgrind/asan/etc? When it's trivial =

to check for forseeable misuse, especially with regard to string overruns, =

we can deterministically crash (or otherwise fail) early.

>
>> non-ELL code. I can't think of a reason to use strcpy() over strncpy() =

>> unless the source string is hard-coded, and even then strncpy() isn't a =

>> burden.
>>

Ok, one reason: strncpy() has the additional cost of zeroing the unused =

space at the end of the dest buffer, so if the src length is otherwise =

checked strcpy() doesn't hurt.

>
> strncpy is a pain in the ass due to null termination semantics and strcpy=
 is =

> such an obvious attack vector that any code introduced with it gets =

> scrutinized anyway.

Static analysis helps catch strncpy misuse - it caught some off-by-one =

strncpy parameters that we need to fix.

>
> I briefly grepped and looked at our use of strcpy and everything I found =
was =

> completely and obviously okay.  Lets have a deeper look, but I'm totally =
not =

> agreeing with your assertion above ;)

Agree with the deeper look. I've also revised my assertation :)

>> =

>> 4. Ignored errors in test/example code
>> =

>> These are low risk because they aren't in the library itself. However, =

>> tests and examples are used as templates for new programs. Does it make =

>> sense to make the examples (and maybe the tests) squeaky-clean in terms =
of =

>> error handling?
>> =

>> Example:
>> =

>> https://git.kernel.org/pub/scm/libs/ell/ell.git/tree/examples/https-serv=
er-test.c?id=3Da5afb52d308d9154efa26cce962572f7724e3684#n128 =

>> =

>
> Yeah I'd vote to have that one fixed since the rest of the example provid=
es =

> proper error handling.
>
>> =

>> =

>> To take a step back, it's one thing to fix these bugs now, but another t=
o =

>> have something in place to catch future problems. I think it would be go=
od =

>> to set up ELL for scanning on an opensource-friendly static analysis sit=
e - =

>> I'll volunteer to babysit that process too.
>> =

>
> That would be nice!

I got this mostly set up today, and am waiting for approval. I'll post =

information to the list once the project is approved and accessible.

--
Mat Martineau
Intel OTC

--===============1542254905485994098==--

