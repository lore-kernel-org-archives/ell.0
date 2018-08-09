Content-Type: multipart/mixed; boundary="===============6725880427796494786=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] fswatch: Notify about L_FSWATCH_EVENT_ATTRIB events
Date: Thu, 09 Aug 2018 09:46:32 -0500
Message-ID: <92fb64c3-5711-be20-658a-c0af79a4dc7a@gmail.com>
In-Reply-To: <20180809142852.17764-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6725880427796494786==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 08/09/2018 09:28 AM, Andrew Zaborowski wrote:
> Also emit events on file attribute changes, this was actually my
> original intent but I must have missed this bit in the bitmask.
> ---
>   ell/fswatch.c | 7 ++++++-
>   ell/fswatch.h | 1 +
>   2 files changed, 7 insertions(+), 1 deletion(-)
> =


Both applied, thanks.

Regards,
-Denis


--===============6725880427796494786==--

