Content-Type: multipart/mixed; boundary="===============9196585995562887216=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 1/5] icmp6: Allow multiple event handlers and clean up
Date: Thu, 06 Jan 2022 12:48:06 -0600
Message-ID: <684fb1ce-b867-9248-0134-8ad93a58bb7e@gmail.com>
In-Reply-To: 20220106150529.458775-1-andrew.zaborowski@intel.com

--===============9196585995562887216==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 1/6/22 09:05, Andrew Zaborowski wrote:
> Allow registering multiple event handlers and rename
> l_icmp6_client_set_event_handler to l_icmp6_client_add_event_handler
> accordingly.  The use case is for a client like IWD to be able to track
> routing information.
> =

> This also fixes a bug where the destroy callback passed to
> l_icmp6_client_set_event_handler wasn't actually used except if
> l_icmp6_client_set_event_handler was called again.
> =

> While there, add an event_data parameter to the event callback, rename
> the "userdata" parameters to "user_data" for consistency and clean up an
> extra empty line.
> ---
>   ell/dhcp6.c |  4 ++--
>   ell/ell.sym |  2 +-
>   ell/icmp6.c | 56 +++++++++++++++++++++++++++++++++++++++--------------
>   ell/icmp6.h |  8 ++++----
>   4 files changed, 48 insertions(+), 22 deletions(-)
> =


Applied, thanks.

Regards,
-Denis

--===============9196585995562887216==--

