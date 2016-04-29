Content-Type: multipart/mixed; boundary="===============4368399045345802641=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] dbus: Fix Dbus1 parsing of doubles
Date: Fri, 29 Apr 2016 10:21:15 -0500
Message-ID: <57237BEB.8050901@gmail.com>
In-Reply-To: <1461900728-20662-3-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4368399045345802641==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 04/28/2016 10:31 PM, Andrew Zaborowski wrote:
> Don't decode the 8-byte value as uint64_t and then cast to double
> because that will produce a different number.  Gvariant already does
> this right.
> ---
>   ell/dbus-util.c | 8 +-------
>   1 file changed, 1 insertion(+), 7 deletions(-)
>

Applied, thanks.

Regards,
-Denis


--===============4368399045345802641==--

