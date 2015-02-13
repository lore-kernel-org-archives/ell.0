Content-Type: multipart/mixed; boundary="===============2298448867098843799=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2 3/3] unit: dbus: Add test for disconnect watch API
Date: Thu, 12 Feb 2015 21:36:43 -0600
Message-ID: <54DD714B.7080502@gmail.com>
In-Reply-To: <1423741733-26743-4-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2298448867098843799==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On 02/12/2015 05:48 AM, Jukka Rissanen wrote:
> Test the dbus disconnect watch support.
> ---
>   Makefile.am            |   3 +
>   unit/test-dbus-watch.c | 388 ++++++++++++++++++++++++++++++++++++++++++=
+++++++
>   2 files changed, 391 insertions(+)
>   create mode 100644 unit/test-dbus-watch.c
>

That seems like an awful lot of copy-paste. Can we isolate the actual =

signal dispatcher and unit test it properly?  For example, you can =

always make the message_filter function private (e.g. without =

LIB_EXPORT) instead of static and feed it signals created using e.g. =

l_dbus_message_new_signal or dbus_message_from_blob

Alternatively, fold this into test-dbus.c if possible.

Regards,
-Denis

--===============2298448867098843799==--

