Content-Type: multipart/mixed; boundary="===============0361176639390247596=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2 1/2] dbus: Check nesting depth and set proper D-Bus
 stack depth
Date: Fri, 29 Sep 2017 17:41:05 -0500
Message-ID: <dbd7c975-9498-f402-b547-6d085abff6aa@gmail.com>
In-Reply-To: <20170929223730.11955-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0361176639390247596==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 09/29/2017 05:37 PM, Mat Martineau wrote:
> The maximum nesting level was not being enforced, and the stack array use=
d to
> generate D-Bus messages was not large enough.
> ---
> =

> v2: Add 'unlikely' notation and comments for unexpected errors, and move
> one error check to skip extra work.
> =

>   ell/dbus-message.c | 33 +++++++++++++++++++++++++++++++--
>   1 file changed, 31 insertions(+), 2 deletions(-)
> =


Both applied thanks.

Regards,
-Denis


--===============0361176639390247596==--

