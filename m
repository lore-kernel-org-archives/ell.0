Content-Type: multipart/mixed; boundary="===============7865620398297517930=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2 02/11] dbus: Check some more return values when parsing
 messages
Date: Tue, 12 Apr 2016 13:53:35 -0500
Message-ID: <570D442F.70608@gmail.com>
In-Reply-To: <1460426175-25501-2-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7865620398297517930==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 04/11/2016 08:56 PM, Andrew Zaborowski wrote:
> Without this we will still segfault on some incoming messages.  Add a
> comment to clarify no get_header_field value check.
> ---
>   ell/dbus-kernel.c  |  2 ++
>   ell/dbus-message.c | 27 ++++++++++++++++++---------
>   2 files changed, 20 insertions(+), 9 deletions(-)
>

Applied, thanks.

Regards,
-Denis


--===============7865620398297517930==--

