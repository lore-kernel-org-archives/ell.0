Content-Type: multipart/mixed; boundary="===============6043492123556965357=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2 3/3] unit: dbus: Add test for disconnect watch API
Date: Fri, 13 Feb 2015 09:09:29 -0600
Message-ID: <54DE13A9.80003@gmail.com>
In-Reply-To: <1423837764.4196.37.camel@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6043492123556965357==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Jukka,

 >>
>> Then test this functionality in the unit test.  If you're relying on
>> semi-manual tests for this stuff, your test coverage will be pretty smal=
l.
>>
>
> But don't we want to test this against dbus-daemon? Testing this watch
> API without dbus-daemon interaction seems pointless to me.

Why?  In this case, what's the difference between getting a signal from =

DBus Daemon vs simply making one up yourself?  Isolating the code and =

unit testing the hell out of it is much simpler without dbus-daemon =

involved.  Much faster and more compact too.

Regards,
-Denis

--===============6043492123556965357==--

