Content-Type: multipart/mixed; boundary="===============2047488101815688010=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2 3/3] unit: dbus: Add test for disconnect watch API
Date: Fri, 13 Feb 2015 08:10:59 -0600
Message-ID: <54DE05F3.9000704@gmail.com>
In-Reply-To: <1423816834.4196.31.camel@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2047488101815688010==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Jukka,

On 02/13/2015 02:40 AM, Jukka Rissanen wrote:
> On to, 2015-02-12 at 21:36 -0600, Denis Kenzior wrote:
>> On 02/12/2015 05:48 AM, Jukka Rissanen wrote:
>>> Test the dbus disconnect watch support.
>>> ---
>>>    Makefile.am            |   3 +
>>>    unit/test-dbus-watch.c | 388 +++++++++++++++++++++++++++++++++++++++=
++++++++++
>>>    2 files changed, 391 insertions(+)
>>>    create mode 100644 unit/test-dbus-watch.c
>>>
>>
>> That seems like an awful lot of copy-paste. Can we isolate the actual
>> signal dispatcher and unit test it properly?  For example, you can
>> always make the message_filter function private (e.g. without
>> LIB_EXPORT) instead of static and feed it signals created using e.g.
>> l_dbus_message_new_signal or dbus_message_from_blob
>
> I did not quite understand your comment about signal dispatcher and
> message_filter here, please elaborate a bit more?
>

Look at how unit/test-dbus-service.c is done.  Almost every part of the =

dbus-service code can be tested standalone.  You need to think about how =

to do the same.

For example:
	static void message_filter(...) -> void _dbus_message_filter(...)
	static void format_rule(...) -> void _dbus1_format_rule()

Or maybe even allow the entire handle_signal() path to be tested.

Then test this functionality in the unit test.  If you're relying on =

semi-manual tests for this stuff, your test coverage will be pretty small.

Regards,
-Denis

>>
>> Alternatively, fold this into test-dbus.c if possible.
>
> I thought about that but test-dbus.c was already quite big. But if you
> are ok with that I can certainly do that too.
>

This is the least preferred option.  Only do this for stuff that can't =

be tested via the unit test.

Regards,
-Denis


--===============2047488101815688010==--

