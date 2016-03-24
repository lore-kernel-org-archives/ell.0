Content-Type: multipart/mixed; boundary="===============8194326519273194763=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 02/15] gvariant: Add _gvariant_iter_skip_entry.
Date: Thu, 24 Mar 2016 09:35:32 -0500
Message-ID: <56F3FB34.2020501@gmail.com>
In-Reply-To: <1458598224-29325-2-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8194326519273194763==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 03/21/2016 05:10 PM, Andrew Zaborowski wrote:
> This will be used for the get_nth_string_argument function in
> dbus-message.c.  There seems to be no other way to skip over an iterator
> entry without knowing the data type.
> ---
>   ell/gvariant-private.h |  1 +
>   ell/gvariant-util.c    | 10 ++++++++++
>   2 files changed, 11 insertions(+)
>

Applied, thanks.

Regards,
-Denis


--===============8194326519273194763==--

