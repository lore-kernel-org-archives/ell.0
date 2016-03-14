Content-Type: multipart/mixed; boundary="===============7720828803565331558=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 01/20] dbus: Add _dbus1_message_iter_skip_entry and
 gvariant variant
Date: Mon, 14 Mar 2016 11:50:49 -0500
Message-ID: <56E6EBE9.2040403@gmail.com>
In-Reply-To: <1457926896-9843-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7720828803565331558==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 03/13/2016 10:41 PM, Andrew Zaborowski wrote:
> This will be used for the get_nth_string_argument function in
> dbus-message.c.  There seems to be no other way to skip over an iterator
> entry without knowing the data type.
> ---
>   ell/dbus-private.h     |  1 +
>   ell/dbus-util.c        | 16 ++++++++++++++++
>   ell/gvariant-private.h |  1 +
>   ell/gvariant-util.c    | 10 ++++++++++
>   4 files changed, 28 insertions(+)
>

This just screams to be separated into two patches :)

Regards,
-Denis

--===============7720828803565331558==--

