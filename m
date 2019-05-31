Content-Type: multipart/mixed; boundary="===============5943423829487706174=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: ELL building broken for 32bit systems
Date: Fri, 31 May 2019 15:44:07 -0500
Message-ID: <2eb55c84-b8cf-90f8-867b-07b47f70dda1@gmail.com>
In-Reply-To: <DEBB0CAA2616974FAE35E4B560B9A4376CB656EC@ORSMSX103.amr.corp.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5943423829487706174==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Brian,

>> What version are you using?  Upstream ell doesn't even use strncpy in ge=
nl.c
>> anymore.
> =

> This is unmodified Fedora-30 for i686 32-bit.  I tried chasing down the n=
esting rabbit-hole to find exactly where the strncpy's were coming from, an=
d came up empty... I can only assume that some inlined function in string.h=
 resolves to some version of strncpy on 32-bit fedora...   perhaps relating=
 to the strlcpy calls.

No, I meant what version of ell?  The issue comes from gcc9 which is =

much more strict about checking strncpy use than before.  The problem is =

that we used to use something like:

#define FOO_BUFFER_SIZE
char buf[FOO_BUFFER_SIZE];

strncpy(buf, some_string, sizeof(buf));

Which would leave the buffer non-null terminated.  Not really a concern =

since all the strings came from the kernel and the chances of things =

ending up badly were small, but still...

The fix is to either use sizeof(buf) - 1 and null-terminate the string, =

or just use l_strlcpy.

Upstream ell is down to about 4 occurrences of strncpy, none of them in =

genl.  So if you are having this problem with some previous release of =

ell, then you should simply disable this warning.

Regards,
-Denis

--===============5943423829487706174==--

