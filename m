Content-Type: multipart/mixed; boundary="===============5271126565874214464=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2 3/3] unit: dbus: Add test for disconnect watch API
Date: Mon, 16 Feb 2015 09:58:40 -0600
Message-ID: <54E213B0.4010000@gmail.com>
In-Reply-To: <1424084002.4196.45.camel@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5271126565874214464==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Jukka,

On 02/16/2015 04:53 AM, Jukka Rissanen wrote:
> On pe, 2015-02-13 at 09:09 -0600, Denis Kenzior wrote:
>> Hi Jukka,
>>
>>   >>
>>>> Then test this functionality in the unit test.  If you're relying on
>>>> semi-manual tests for this stuff, your test coverage will be pretty sm=
all.
>>>>
>>>
>>> But don't we want to test this against dbus-daemon? Testing this watch
>>> API without dbus-daemon interaction seems pointless to me.
>>
>> Why?  In this case, what's the difference between getting a signal from
>> DBus Daemon vs simply making one up yourself?  Isolating the code and
>> unit testing the hell out of it is much simpler without dbus-daemon
>> involved.  Much faster and more compact too.
>
> We have already tests for receiving signals so it seems pointless to
> test them again. To me it looks more useful to test that we really get

That is not what I told you to test ;)  I told you to unit test the =

match creation functionality and the signal match / dispatch code.

> NameOwnerChanged signal from dbus-daemon when we quit the test app.

You just said yourself that signal reception works.  So why are you =

testing this?  Are you testing the DBus Daemon or ell?

> Testing real interaction is more complex (as the code shows) but at
> least we know that the watch support works in real life.
>

Unit test the individual pieces first.  If you know the individual parts =

are working well, then you can move on to whole system testing, if needed.

Regards,
-Denis


--===============5271126565874214464==--

