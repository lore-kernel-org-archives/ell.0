Content-Type: multipart/mixed; boundary="===============1970053291457502925=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dbus: Handle optional properties in PropertiesChanged
Date: Wed, 21 Sep 2016 16:53:58 -0500
Message-ID: <57E30176.7090401@gmail.com>
In-Reply-To: <1474476105-10906-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1970053291457502925==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 09/21/2016 11:41 AM, Andrew Zaborowski wrote:
> Handle property getter returning an error when building the
> PropertiesChanged signal instead of returning NULL.  This is important
> because the signal may include multiple properties and if one getter
> fails other properties should still be included.  One options is to only
> error out if all getters fail, another is to add them to the invalidated
> properties list of the signal.  The latter seems to be the right thing
> to do for optional properties that may appear and disappear.
> ---
>   ell/dbus-service.c | 26 +++++++++++++++++++++++---
>   1 file changed, 23 insertions(+), 3 deletions(-)
>

Applied, thanks.

Regards,
-Denis


--===============1970053291457502925==--

